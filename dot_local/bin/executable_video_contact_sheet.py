#!/usr/bin/env python3

import argparse
import math
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from typing import List, Optional, Tuple

from PIL import Image, ImageDraw, ImageFont, ImageStat


DEFAULT_OUTPUT = "preview.jpg"
DEFAULT_WIDTH = 1920
DEFAULT_HEIGHT = 1080
# DEFAULT_WIDTH = 1024
# DEFAULT_HEIGHT = 1024
DEFAULT_SHOTS = 9
DEFAULT_OVERSAMPLE = 8
DEFAULT_ANALYSIS_WIDTH = 256
DEFAULT_SAMPLE_START = 5.0
DEFAULT_SAMPLE_END = 9.4


@dataclass
class FrameCandidate:
    timestamp: float
    image: Image.Image
    mean_luma: float
    stddev_luma: float
    ahash: int


def run_command(cmd: List[str]) -> str:
    try:
        result = subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip() if exc.stderr else ""
        stdout = exc.stdout.strip() if exc.stdout else ""
        msg = f"Command failed: {' '.join(cmd)}"
        if stdout:
            msg += f"\nstdout:\n{stdout}"
        if stderr:
            msg += f"\nstderr:\n{stderr}"
        raise RuntimeError(msg) from exc


def ensure_binary_exists(name: str) -> None:
    if shutil.which(name) is None:
        raise RuntimeError(f"Required binary not found in PATH: {name}")


def probe_video_duration(input_file: str) -> float:
    out = run_command([
        "ffprobe",
        "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        input_file,
    ])
    try:
        duration = float(out)
    except ValueError as exc:
        raise RuntimeError(f"Could not parse duration from ffprobe output: {out!r}") from exc

    if duration <= 0:
        raise RuntimeError("Video duration is zero or negative.")

    return duration


def format_timestamp(seconds: float) -> str:
    total_ms = int(round(seconds * 1000))
    ms = total_ms % 1000
    total_s = total_ms // 1000
    s = total_s % 60
    total_m = total_s // 60
    m = total_m % 60
    h = total_m // 60

    if h > 0:
        return f"{h:d}:{m:02d}:{s:02d}.{ms:03d}"
    return f"{m:d}:{s:02d}.{ms:03d}"


def compute_ahash(img: Image.Image, size: int = 8) -> int:
    gray = img.convert("L").resize((size, size), Image.Resampling.LANCZOS)
    pixels = gray.tobytes()
    avg = sum(pixels) / len(pixels)

    bits = 0
    for i, px in enumerate(pixels):
        if px >= avg:
            bits |= 1 << i
    return bits


def hamming_distance(a: int, b: int) -> int:
    return (a ^ b).bit_count()


def image_stats(img: Image.Image) -> Tuple[float, float]:
    gray = img.convert("L")
    stat = ImageStat.Stat(gray)
    mean = stat.mean[0]
    stddev = stat.stddev[0]
    return mean, stddev


def extract_frame(
    input_file: str,
    timestamp: float,
    temp_dir: str,
    analysis_width: int,
) -> Optional[Image.Image]:
    output_path = os.path.join(temp_dir, f"frame_{timestamp:.6f}.jpg")
    vf = f"scale='min({analysis_width},iw)':-2"

    cmd = [
        "ffmpeg",
        "-hide_banner",
        "-loglevel", "error",
        "-ss", f"{timestamp:.6f}",
        "-i", input_file,
        "-frames:v", "1",
        "-vf", vf,
        "-q:v", "2",
        "-y",
        output_path,
    ]

    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError:
        return None

    if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
        return None

    try:
        img = Image.open(output_path).convert("RGB")
        img.load()
        return img
    except Exception:
        return None


def is_blank_or_flat(
    mean_luma: float,
    stddev_luma: float,
    black_threshold: float,
    white_threshold: float,
    flat_stddev_threshold: float,
) -> bool:
    if mean_luma <= black_threshold:
        return True
    if mean_luma >= white_threshold:
        return True
    if stddev_luma <= flat_stddev_threshold:
        return True
    return False


def generate_candidate_times(
    duration: float,
    desired_shots: int,
    oversample_factor: int,
    sample_start_fraction: float,
    sample_end_fraction: float,
) -> List[float]:
    if not (0.0 <= sample_start_fraction < 1.0):
        raise RuntimeError("--sample-start must be >= 0.0 and < 1.0")

    if not (0.0 < sample_end_fraction <= 1.0):
        raise RuntimeError("--sample-end must be > 0.0 and <= 1.0")

    if sample_end_fraction <= sample_start_fraction:
        raise RuntimeError("--sample-end must be greater than --sample-start")

    usable_start = duration * sample_start_fraction
    usable_end = duration * sample_end_fraction

    candidate_count = max(desired_shots * oversample_factor, desired_shots)
    span = usable_end - usable_start

    if candidate_count == 1:
        return [usable_start + span / 2.0]

    times = []
    for i in range(candidate_count):
        t = usable_start + span * (i + 0.5) / candidate_count
        t = min(max(t, 0.0), max(duration - 0.001, 0.0))
        times.append(t)

    return times


def collect_candidates(
    input_file: str,
    duration: float,
    desired_shots: int,
    oversample_factor: int,
    analysis_width: int,
    black_threshold: float,
    white_threshold: float,
    flat_stddev_threshold: float,
    sample_start_fraction: float,
    sample_end_fraction: float,
) -> List[FrameCandidate]:
    candidates: List[FrameCandidate] = []

    candidate_times = generate_candidate_times(
        duration=duration,
        desired_shots=desired_shots,
        oversample_factor=oversample_factor,
        sample_start_fraction=sample_start_fraction,
        sample_end_fraction=sample_end_fraction,
    )

    with tempfile.TemporaryDirectory(prefix="contactsheet_") as temp_dir:
        for timestamp in candidate_times:
            img = extract_frame(
                input_file=input_file,
                timestamp=timestamp,
                temp_dir=temp_dir,
                analysis_width=analysis_width,
            )
            if img is None:
                continue

            mean_luma, stddev_luma = image_stats(img)

            if is_blank_or_flat(
                mean_luma=mean_luma,
                stddev_luma=stddev_luma,
                black_threshold=black_threshold,
                white_threshold=white_threshold,
                flat_stddev_threshold=flat_stddev_threshold,
            ):
                continue

            ah = compute_ahash(img)

            candidates.append(FrameCandidate(
                timestamp=timestamp,
                image=img,
                mean_luma=mean_luma,
                stddev_luma=stddev_luma,
                ahash=ah,
            ))

    return candidates


def choose_frames(
    candidates: List[FrameCandidate],
    desired_shots: int,
    hash_distance_threshold: int,
) -> List[FrameCandidate]:
    if not candidates:
        return []

    selected: List[FrameCandidate] = []

    for candidate in candidates:
        too_similar = False
        for existing in selected:
            if hamming_distance(candidate.ahash, existing.ahash) <= hash_distance_threshold:
                too_similar = True
                break

        if not too_similar:
            selected.append(candidate)
            if len(selected) >= desired_shots:
                return selected

    if len(selected) < desired_shots:
        used_timestamps = {f.timestamp for f in selected}

        for candidate in candidates:
            if candidate.timestamp in used_timestamps:
                continue
            selected.append(candidate)
            if len(selected) >= desired_shots:
                break

    return selected[:desired_shots]


def choose_grid(n: int, preferred_columns: Optional[int] = None) -> Tuple[int, int]:
    if n <= 0:
        return 1, 1

    if preferred_columns and preferred_columns > 0:
        cols = min(preferred_columns, n)
        rows = math.ceil(n / cols)
        return cols, rows

    if n == 1:
        return 1, 1
    if n <= 4:
        return 2, math.ceil(n / 2)
    if n <= 9:
        return 3, math.ceil(n / 3)

    cols = math.ceil(math.sqrt(n))
    rows = math.ceil(n / cols)
    return cols, rows


def fit_size_preserve_aspect(
    src_w: int,
    src_h: int,
    box_w: int,
    box_h: int,
) -> Tuple[int, int]:
    scale = min(box_w / src_w, box_h / src_h)
    return max(1, int(src_w * scale)), max(1, int(src_h * scale))


def draw_timestamp(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    label: str,
    font: ImageFont.ImageFont,
) -> None:
    try:
        left, top, right, bottom = draw.textbbox((x, y), label, font=font)
        pad_x = 4
        pad_y = 2
        draw.rectangle(
            (left - pad_x, top - pad_y, right + pad_x, bottom + pad_y),
            fill=(0, 0, 0),
        )
        draw.text((x, y), label, fill=(255, 255, 255), font=font)
    except Exception:
        draw.text((x, y), label, fill=(255, 255, 255), font=font)


def make_contact_sheet(
    frames: List[FrameCandidate],
    output_file: str,
    sheet_width: int,
    sheet_height: int,
    columns: Optional[int],
    margin: int,
    gutter: int,
    show_timestamps: bool,
    jpeg_quality: int,
    background: Tuple[int, int, int],
) -> None:
    if not frames:
        raise RuntimeError("No usable frames were found.")

    cols, rows = choose_grid(len(frames), columns)

    usable_w = sheet_width - (2 * margin) - ((cols - 1) * gutter)
    usable_h = sheet_height - (2 * margin) - ((rows - 1) * gutter)

    if usable_w <= 0 or usable_h <= 0:
        raise RuntimeError("Requested output dimensions are too small.")

    cell_w = usable_w // cols
    cell_h = usable_h // rows

    canvas = Image.new("RGB", (sheet_width, sheet_height), background)
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()

    for idx, frame in enumerate(frames):
        row = idx // cols
        col = idx % cols

        x = margin + col * (cell_w + gutter)
        y = margin + row * (cell_h + gutter)

        img = frame.image
        fitted_w, fitted_h = fit_size_preserve_aspect(img.width, img.height, cell_w, cell_h)
        thumb = img.resize((fitted_w, fitted_h), Image.Resampling.LANCZOS)

        paste_x = x + (cell_w - fitted_w) // 2
        paste_y = y + (cell_h - fitted_h) // 2
        canvas.paste(thumb, (paste_x, paste_y))

        if show_timestamps:
            label = format_timestamp(frame.timestamp)
            tx = x + 6
            ty = y + cell_h - 18
            draw_timestamp(draw, tx, ty, label, font)

    ext = os.path.splitext(output_file)[1].lower()
    if ext in {".jpg", ".jpeg"}:
        canvas.save(output_file, quality=jpeg_quality, optimize=True)
    else:
        canvas.save(output_file)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a video contact sheet from evenly spaced frames inside a chosen sampling window."
    )

    parser.add_argument("input", help="Input video file")
    parser.add_argument("output", nargs="?", default=DEFAULT_OUTPUT, help="Output image file (default: preview.jpg)")

    parser.add_argument("--shots", type=int, default=DEFAULT_SHOTS, help="Number of screenshots to include")
    parser.add_argument("--width", type=int, default=DEFAULT_WIDTH, help="Output sheet width")
    parser.add_argument("--height", type=int, default=DEFAULT_HEIGHT, help="Output sheet height")
    parser.add_argument("--columns", type=int, default=0, help="Columns in grid; 0 = auto")
    parser.add_argument("--margin", type=int, default=20, help="Outer margin in pixels")
    parser.add_argument("--gutter", type=int, default=12, help="Space between cells in pixels")
    parser.add_argument("--no-timestamps", action="store_true", help="Do not draw timestamps")
    parser.add_argument("--quality", type=int, default=92, help="JPEG quality if output is JPG")

    parser.add_argument("--oversample", type=int, default=DEFAULT_OVERSAMPLE, help="Try more timestamps than needed")
    parser.add_argument("--analysis-width", type=int, default=DEFAULT_ANALYSIS_WIDTH, help="Temporary frame width used for analysis")

    parser.add_argument("--sample-start", type=float, default=DEFAULT_SAMPLE_START, help="Fraction of video where sampling starts, e.g. 0.5")
    parser.add_argument("--sample-end", type=float, default=DEFAULT_SAMPLE_END, help="Fraction of video where sampling ends, e.g. 1.0")

    parser.add_argument("--black-threshold", type=float, default=6.0, help="Mean luma at or below this is considered blank")
    parser.add_argument("--white-threshold", type=float, default=249.0, help="Mean luma at or above this is considered blank")
    parser.add_argument("--flat-stddev-threshold", type=float, default=3.0, help="Very low contrast frames are skipped")
    parser.add_argument("--hash-distance-threshold", type=int, default=2, help="Near-duplicate threshold; lower keeps more frames")

    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.shots <= 0:
        print("Error: --shots must be greater than 0", file=sys.stderr)
        return 1
    if args.width <= 0 or args.height <= 0:
        print("Error: --width and --height must be greater than 0", file=sys.stderr)
        return 1
    if args.oversample <= 0:
        print("Error: --oversample must be greater than 0", file=sys.stderr)
        return 1

    ensure_binary_exists("ffmpeg")
    ensure_binary_exists("ffprobe")

    if not os.path.isfile(args.input):
        print(f"Error: input file does not exist: {args.input}", file=sys.stderr)
        return 1

    try:
        duration = probe_video_duration(args.input)

        candidates = collect_candidates(
            input_file=args.input,
            duration=duration,
            desired_shots=args.shots,
            oversample_factor=args.oversample,
            analysis_width=args.analysis_width,
            black_threshold=args.black_threshold,
            white_threshold=args.white_threshold,
            flat_stddev_threshold=args.flat_stddev_threshold,
            sample_start_fraction=args.sample_start,
            sample_end_fraction=args.sample_end,
        )

        frames = choose_frames(
            candidates=candidates,
            desired_shots=args.shots,
            hash_distance_threshold=args.hash_distance_threshold,
        )

        if not frames:
            raise RuntimeError(
                "No usable frames found. Try lowering blank thresholds, lowering duplicate filtering, or increasing --oversample."
            )

        make_contact_sheet(
            frames=frames,
            output_file=args.output,
            sheet_width=args.width,
            sheet_height=args.height,
            columns=args.columns if args.columns > 0 else None,
            margin=args.margin,
            gutter=args.gutter,
            show_timestamps=not args.no_timestamps,
            jpeg_quality=max(1, min(args.quality, 100)),
            background=(20, 20, 20),
        )

        print(f"Generated preview: {args.output}")
        print(f"Video duration: {format_timestamp(duration)}")
        print(f"Sampling window: {args.sample_start:.3f} -> {args.sample_end:.3f}")
        print(f"Candidate frames kept after blank filtering: {len(candidates)}")
        print(f"Frames used: {len(frames)} / requested {args.shots}")
        return 0

    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
