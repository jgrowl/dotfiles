# Rust / Leptos Rules

These rules apply to Rust, Leptos, wasm, UI, SVG, data-import, and related projects.

## Rust

- Prefer Rust-first solutions.
- Prefer explicit, readable types when they clarify ownership or API boundaries.
- Avoid unnecessary cloning.
- When cloning is useful, make the reason clear.
- Prefer `Result`-based error handling over panics in application logic.
- Avoid broad `unwrap()` or `expect()` use outside tests, prototypes, or impossible states.
- Prefer small modules with clear responsibilities.
- Do not introduce global mutable state unless there is a strong reason.
- Keep wasm/browser constraints in mind.
- Avoid blocking operations in wasm paths.
- Prefer `cargo check` for quick verification and `cargo test` when behavior changes.
- Prefer `tracing` or structured logging over scattered debug prints.
- Keep public APIs narrow.
- Avoid making types public unless another module actually needs them.
- Prefer domain-specific types over loose strings or tuples when meaning matters.
- Prefer incremental refactors over large rewrites.

## File size and module structure

- Keep files ideally below **1000 lines**.
- If a file is approaching **800 lines**, consider splitting it before adding major new logic.
- If a file exceeds **1000 lines**, do not continue expanding it unless there is a strong reason.
- Avoid changes that make editor buffers, LSP, or CodeCompanion context too large to handle reliably.
- Split large files by responsibility, not randomly.
- Do not create tiny files only to satisfy line-count rules.
- Keep components, state, rendering, data loading, helpers, and types in separate files when practical.
- Do not let a single file become the home for unrelated concerns.
- If a component grows too large, split it into subcomponents before adding more features.
- If `view!` markup becomes deeply nested, extract named child components.
- If a file contains multiple independent sections, move them into a module folder.

For large features, prefer a structure like:

```text
feature_name/
  mod.rs
  types.rs
  state.rs
  view.rs
  controls.rs
  effects.rs
  helpers.rs
```

For UI-heavy features, prefer a structure like:

```text
feature_name/
  mod.rs
  component.rs
  layout.rs
  controls.rs
  panels.rs
  overlays.rs
```

For chart/SVG-heavy features, prefer a structure like:

```text
chart_name/
  mod.rs
  frame.rs
  svg_layer.rs
  overlay_layer.rs
  action_menu.rs
  status_bar.rs
  geometry.rs
  labels.rs
  styles.rs
```

## Leptos

- Use Leptos 0.8 style.
- Prefer small components over monolithic components.
- Avoid putting too much logic directly inside `view!`.
- Separate layout, rendering, state, controls, overlays, and data loading where practical.
- Prefer derived signals or memos when recalculation matters.
- Be careful with reactive ownership and move closures.
- Avoid excessive nesting in `view!`.
- Prefer readable component props over overloaded generic props.
- Do not assume server-side APIs are available in wasm-only code.
- Keep browser-only code behind clear wasm-compatible boundaries.
- Avoid large reactive closures that capture too much state.
- Prefer named callbacks and helper functions when closures become hard to read.
- Keep component props focused on what the component actually renders or controls.
- Avoid using one component as both a data loader and a complex renderer unless the feature is very small.

## UI and design

- Prefer usability, spacing, visual hierarchy, and accessibility.
- Use semantic labels.
- Avoid duplicate navigation concepts.
- Avoid clever names when plain labels are clearer.
- Preserve keyboard accessibility.
- Prefer rust-ui components where they fit.
- Avoid adding JavaScript unless there is a strong reason.
- Keep dark/light theme behavior consistent.
- For menus, separate creation actions from navigation actions.
- Do not let cards or panels overflow their intended containers.
- Avoid layouts where important controls become compressed or unreadable.
- Prefer responsive layouts that degrade cleanly on smaller screens.
- Keep form labels visible and associated with their inputs.
- Prefer clear empty states, loading states, and error states.

## SVG / chart rendering

- Keep rendering code separate from controls and state.
- Avoid mixing chart math, SVG layout, and UI controls in one large component.
- Prefer named layers such as frame, SVG layer, overlay layer, menu/actions, and status.
- Keep coordinate transforms explicit.
- Be careful with text placement, clipping, and responsive behavior.
- Do not change chart semantics just to simplify rendering.
- Keep geometry and rendering helpers separate from interactive UI code.
- Prefer named constants for dimensions, offsets, and radii.
- Avoid magic numbers in chart layout.
- Keep hit testing, dragging, overlays, labels, and glyph rendering in separate helpers when they grow.

## Data and import work

- Prefer streaming parsers for large files.
- Avoid loading huge datasets fully into memory.
- Design importers so they can resume or be rerun safely.
- Keep raw external data separate from normalized application data.
- Prefer deterministic transforms.
- Preserve enough provenance to debug bad records.
- Avoid mixing importer logic with UI logic.
- Prefer explicit import stages: read, parse, normalize, validate, store.
- For large data files, prefer chunked processing and progress reporting.
- Make failure modes recoverable where practical.

## Wasm and browser storage

- Keep wasm constraints visible when choosing libraries.
- Avoid filesystem assumptions in browser code.
- Prefer async browser APIs for storage and large data operations.
- Avoid blocking parsing, compression, or database work on the main UI path.
- Consider IndexedDB or SQLite-in-wasm when data may exceed localStorage limits.
- Do not store large structured application state directly in localStorage.
- Keep persistence formats versioned.
- Design migrations before data becomes difficult to change.

## Refactoring rules

- Before adding a large feature, check whether the target file is already too large.
- If adding a feature would push a file over **1000 lines**, split the file first or add the feature in a new module.
- Prefer extracting stable boundaries:
  - types
  - props
  - state
  - effects
  - controls
  - rendering
  - layout
  - data loading
  - import/export
  - geometry/math
- Do not perform broad rewrites when a narrow extraction would solve the problem.
- Preserve behavior while refactoring unless the requested change explicitly alters behavior.
- After a refactor, verify imports, visibility, and call sites.
- Keep module names boring and searchable.

## Verification

- Use `cargo fmt` after meaningful Rust edits.
- Use `cargo check` for quick verification.
- Use `cargo test` when logic or behavior changes.
- For wasm/Leptos UI changes, check that the app still builds for the browser target.
- When changing layout, verify both desktop and narrow/mobile widths.
- When changing SVG/chart rendering, verify labels, clipping, responsive sizing, and interaction overlays.
- When changing importers, test with small sample data before large files.

## CodeCompanion guidance

- Avoid sending or editing unnecessarily large files as a single buffer.
- Prefer targeted patches.
- If a file is large, summarize the intended split before editing.
- When asked to modify a large file, first identify safe extraction points.
- Prefer creating new module files instead of repeatedly expanding one large file.
- Avoid generating massive `view!` blocks in one response.
- Keep generated code compact, but not cryptic.
- If context is limited, ask for the smallest relevant file or section rather than the whole project.
- When possible, return patch-oriented instructions instead of full-file rewrites.
