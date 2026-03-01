# Pictures Directory Structure

This document defines the structure used for organizing `~/Pictures`.

The guiding principles:
- Keep directory depth shallow.
- Organize by image type (what it *is*), not subjective meaning.
- Use chronology for scalability.
- Use software metadata/tags for fine classification.

---

## Top-Level Layout

```
~/Pictures/
    Captured/
    Synthetic/
    Collected/
    Screenshots/
```

### Captured/
Images recorded from physical reality.

Examples:
- Camera photos
- Phone photos
- Film scans
- Document scans

Suggested structure:
```
Captured/
    Camera/
        2026/
    Scans/
        2025/
```

Use year-based grouping when helpful. Avoid deep semantic nesting.

---

### Synthetic/
Images generated through computation.

Examples:
- AI-generated images
- 3D renders
- Procedural graphics
- Digital paintings

Suggested structure:
```
Synthetic/
    2026/
        2026-02-Experiment-01/
```

Chronology scales well for high-volume generation.

---

### Collected/
Images created by others and acquired.

Examples:
- Downloaded wallpapers
- Reference images
- Textures
- Inspiration material

Optional structure:
```
Collected/
    Wallpapers/
    Reference/
```

Keep depth shallow. Do not mirror `Downloads/` here — downloads are intake, not identity.

---

### Screenshots/
System-state captures.

Examples:
- Desktop screenshots
- Debug captures
- UI references
- Conversation captures

Screenshots are separated because they:
- Are high volume
- Are often temporary
- Behave differently from curated images

Optional structure:
```
Screenshots/
    2026/
```

---

## Project Layout Model

For structured creative work, use a project-based layout:

```
MyCoolProject/
    Source/
    Working/
    Exports/
```

### Source/
Original inputs:
- RAW photos
- Initial AI generations
- High-resolution scans
- Base assets

### Working/
Editable project files:
- .xcf (GIMP)
- .psd
- .kra (Krita)
- .blend
- Layered composites

Files intended to be reopened and modified.

### Exports/
Final output files:
- Flattened PNG
- JPEG
- Web-sized versions
- Deliverables

Exports are derived artifacts and can usually be regenerated from Source/ or Working/.

---

## Core Rules

1. Keep depth ≤ 3 meaningful levels.
2. Organize by ontological type (captured vs synthetic vs collected).
3. Use time as the primary scaling axis.
4. Use metadata and tagging software for meaning.
5. Treat `~/Downloads` as a temporary intake buffer.
