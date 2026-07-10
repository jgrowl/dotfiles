# Rust / Leptos Rules

These rules apply to Rust, Leptos, WebAssembly, browser UI, SVG rendering, data import, persistence, and related projects.

Project-specific repository instructions take precedence over this file when they are more specific.

## General priorities

* Prefer Rust-first solutions.
* Preserve browser and WebAssembly compatibility where the project requires it.
* Reuse existing project types, components, modules, and dependencies before introducing parallel abstractions.
* Prefer the smallest coherent change that solves the requested problem.
* Preserve unrelated behavior.
* Avoid unnecessary JavaScript and JavaScript-only dependencies.
* Keep domain logic, state management, persistence, rendering, and UI controls separated by clear ownership boundaries.
* Prefer incremental changes over broad rewrites.
* Do not introduce speculative abstractions without a current use.
* Follow existing repository conventions unless the requested work requires changing them.

## Rust

* Prefer explicit, readable types when they clarify ownership, invariants, or API boundaries.
* Prefer domain-specific types over loose strings, tuples, or unrelated booleans when meaning matters.
* Prefer enums and typed state over magic strings.
* Preserve invalid-state prevention through types where practical.
* Avoid unnecessary cloning.
* When cloning is required, keep the ownership reason understandable.
* Prefer borrowing when it keeps ownership clear and does not create excessive lifetime complexity.
* Prefer `Result`-based error handling over panics in application logic.
* Avoid broad `unwrap()` or `expect()` use outside tests, prototypes, startup invariants, or genuinely impossible states.
* Keep public APIs narrow.
* Do not make types or functions public unless another module or crate actually requires access.
* Avoid global mutable state unless ownership and synchronization require it.
* Prefer explicit control flow over clever compact code.
* Avoid speculative optimization.
* Do not sacrifice correctness or clarity merely to reduce allocations.
* Prefer `tracing` or the project’s established structured logging system over scattered debug printing.
* Do not leave temporary debug output in completed changes.
* Add comments for non-obvious invariants, lifecycle constraints, browser limitations, geometry, or domain reasoning.
* Do not add comments that merely restate the code.

## File size and module structure

Treat file length as a design signal, not a correctness rule.

* Review files approaching roughly 800–1000 lines for mixed responsibilities.
* Split files when they contain multiple stable ownership or responsibility boundaries.
* Do not split cohesive files solely to satisfy a line-count target.
* Do not split generated code, schemas, lookup tables, static data, or tightly coupled rendering definitions merely because they are long.
* Avoid allowing one file to become the home for unrelated concerns.
* Avoid creating many tiny files that make navigation harder without improving ownership.
* Keep module names plain, descriptive, and searchable.
* Prefer module folders when a feature has several meaningful internal responsibilities.
* Avoid expanding a large file with another major concern when a stable extraction boundary already exists.
* Keep editor, LSP, review, and agent context size in mind.

For a substantial feature, a useful structure may be:

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

For a UI-heavy feature:

```text
feature_name/
  mod.rs
  component.rs
  layout.rs
  controls.rs
  panels.rs
  overlays.rs
```

For a rendering-heavy feature:

```text
feature_name/
  mod.rs
  state.rs
  geometry.rs
  render.rs
  interaction.rs
  controls.rs
```

Do not create every suggested file preemptively. Add a module only when the corresponding responsibility exists.

## Component design

* Components should have focused responsibilities and clear ownership boundaries.
* Prefer small, composable components over monolithic components.
* Do not split components solely to reduce line count.
* Extract child components when markup, ownership, interaction, or reuse becomes independently meaningful.
* Avoid thin wrappers that add no semantic, behavioral, styling, ownership, or reuse value.
* Keep component props focused on what the component renders or controls.
* Prefer typed props and domain-specific enums over clusters of loosely related booleans.
* Avoid boolean combinations that permit contradictory states.
* Avoid using one component as both a data loader, state coordinator, and complex renderer unless the feature is very small.
* Keep temporary UI state local when only one component owns it.
* Lift state only when multiple independent consumers require shared ownership.
* Do not introduce global state solely to avoid reasonable prop passing.
* Avoid passing large undifferentiated collections of signals or callbacks through many component layers.
* Prefer cohesive grouped state when several values form one domain concept.

## Leptos

* Use the Leptos version and style established by the repository.
* For projects using Leptos 0.8, use Leptos 0.8-compatible APIs and patterns.
* Keep domain and transformation logic outside `view!` macros when practical.
* Avoid embedding large amounts of business logic directly in `view!`.
* Avoid deeply nested or excessively large `view!` blocks.
* Extract named child components or helpers when markup becomes difficult to reason about.
* Prefer readable component props over heavily overloaded generic interfaces.
* Keep reactive ownership explicit.
* Be careful with `move` closures and captured state.
* Avoid large reactive closures that capture unrelated values.
* Prefer named callbacks or helper functions when event closures become difficult to read.
* Do not assume server functions or server-side APIs are available in browser-only code.
* Keep browser-specific code behind clear boundaries.
* Keep reusable domain logic independent of Leptos where practical.

## Reactive state

* Maintain one authoritative source of truth for each piece of state.
* Prefer `Memo`, selectors, derived closures, or derived values over mirrored signals.
* Avoid effects whose only purpose is copying one signal into another.
* Use explicit event handlers when an interaction represents a state transition.
* Prefer direct state transitions over chains of incidental effects.
* Do not create signals inside closures that may execute repeatedly unless the lifecycle is intentional.
* Avoid creating subscriptions or resources inside repeatedly evaluated reactive paths without explicit ownership.
* Keep temporary component state local.
* Move state into a store only when shared lifetime or ownership requires it.
* Avoid duplicate signals representing the same domain value in different formats.
* Convert values at boundaries rather than synchronizing multiple representations continuously.
* Avoid reactive cycles.
* Ensure derived state does not write back to its own dependencies.
* Avoid holding reactive guards, references, or borrowed state across `await` points.
* Be deliberate about local versus thread-safe reactive types in WebAssembly code.
* Use `StoredValue`, signals, memos, resources, or context according to ownership and reactivity needs rather than convenience alone.

## Effects and lifecycle

* Use effects for external side effects, not as the default mechanism for deriving state.
* Prefer memos or derived closures for pure calculations.
* Keep interval, timeout, observer, listener, subscription, worker, and resource handles alive for as long as their behavior is required.
* Register cleanup for browser resources that must not outlive the owning component.
* Remove event listeners, observers, timers, and subscriptions when their component lifecycle ends.
* Avoid starting duplicate background work through multiple reactive paths.
* Avoid effects that repeatedly re-register identical listeners or timers.
* Make ownership of browser resources explicit.
* Preserve cleanup handles when dropping them would cancel or disable required behavior.
* Be careful with closures captured by browser APIs that may outlive their original scope.

## Async behavior

* Do not block the browser main thread with large parsing, compression, database, rendering, or transformation work.
* Use workers, chunked execution, yielding, or asynchronous browser APIs for expensive work where practical.
* Keep loading, empty, success, stale, cancelled, and error states distinguishable when those states matter.
* Do not silently convert errors into empty results.
* Handle stale async responses when inputs may change before work completes.
* Cancel, ignore, replace, or supersede outdated work where practical.
* Avoid triggering duplicate requests or tasks from multiple reactive paths.
* Make async ownership and cancellation behavior understandable.
* Do not update disposed component state after asynchronous work completes.
* Preserve error context across asynchronous boundaries.
* Avoid using async work as a substitute for a simpler synchronous derived calculation.
* Provide progress reporting for long-running imports or transformations when useful.

## Rust/UI and component libraries

When Rust/UI is part of the project, treat it as the preferred source for ordinary application UI primitives.

Before creating a custom button, dialog, menu, dropdown, popover, tooltip, form control, card, tabs, drawer, sheet, or similar component:

1. Check whether the project already contains a suitable reusable component.
2. Check whether Rust/UI provides a suitable component.
3. Compose, extend, or wrap the existing component when practical.
4. Create a custom implementation only for specialized behavior, ownership, or rendering requirements.

Additional rules:

* Follow the component-library integration conventions already present in the repository.
* Preserve established theme, spacing, interaction, accessibility, and styling behavior.
* Prefer composing existing primitives over copying their behavior into unrelated custom implementations.
* Wrap shared primitives in project-specific components when doing so creates stable semantics or avoids repeated configuration.
* Do not introduce a second general-purpose UI component system without justification.
* Do not force a component library into specialized SVG, canvas, graphics, or domain-rendering paths.
* Keep custom controls visually and behaviorally compatible with the surrounding component system.
* Avoid replacing accessible library primitives with less accessible custom implementations.

## UI and design

* Prioritize usability, visual hierarchy, spacing, accessibility, and clarity.
* Use plain user-facing labels when they are clearer than internal terminology.
* Avoid duplicate navigation concepts.
* Separate creation actions from navigation actions.
* Keep primary actions visually distinct from secondary actions.
* Avoid excessive cards, borders, shadows, nested containers, and competing emphasis.
* Do not let cards, menus, toolbars, dialogs, or panels overflow their intended containers.
* Avoid layouts where important controls become compressed, clipped, or unreadable.
* Prefer responsive layouts that degrade intentionally on smaller screens.
* Treat mobile layout as a designed composition, not only a compressed desktop layout.
* Avoid fixed dimensions unless the visualization or interaction requires them.
* Prefer flexible sizing with sensible minimum and maximum constraints.
* Distinguish intentional local scrolling from accidental document-level overflow.
* Do not solve layout problems by indiscriminately applying `overflow: hidden`.
* Preserve keyboard and touch usability.
* Keep form labels visible and associated with their controls.
* Provide clear loading, empty, disabled, and error states.
* Maintain consistent dark and light theme behavior.
* Reuse design tokens and semantic CSS variables where they exist.
* Avoid hard-coded colors when a theme token is appropriate.
* Do not rely on color alone to communicate state or meaning.

## Accessibility

* Use semantic HTML.
* Use buttons for actions and links for navigation.
* Do not use clickable `div` or `span` elements when a semantic element is appropriate.
* Preserve keyboard access for menus, dialogs, popovers, tabs, forms, and interactive visualizations.
* Provide accessible names for icon-only controls.
* Maintain visible focus states.
* Preserve logical tab order.
* Ensure dialogs, drawers, popovers, and overlays manage focus appropriately.
* Ensure dismissible overlays can be closed through expected keyboard and pointer interactions.
* Keep interactive targets usable on touchscreens.
* Avoid hover-only access to required functionality.
* Respect reduced-motion preferences for nonessential animation.
* Associate help text and validation errors with the relevant form controls.
* Ensure disabled controls are visibly and behaviorally disabled.
* Use ARIA only when native semantics are insufficient.
* Avoid adding ARIA roles that conflict with native element behavior.

## SVG and rendering

* Keep rendering logic separate from state coordination and application controls.
* Avoid mixing geometry, domain computation, SVG layout, interaction handling, and unrelated UI controls in one component.
* Keep coordinate transforms explicit.
* Prefer named geometry and rendering helpers.
* Use named constants for meaningful dimensions, offsets, radii, thresholds, and line widths.
* Avoid unexplained magic numbers.
* Keep geometry independent from browser-only overlays where practical.
* Keep hit testing, dragging, labels, glyph rendering, clipping, and overlays separate when their complexity grows.
* Preserve chart or visualization semantics when refactoring rendering code.
* Do not change domain meaning merely to simplify drawing.
* Be careful with text placement, clipping, transforms, scaling, and responsive sizing.
* Avoid coupling exported output to the current browser viewport without an explicit reason.
* Keep web-only controls and overlays out of exported output unless explicitly requested.
* Preserve vector output when vector rendering is expected.
* Do not rasterize content unnecessarily.
* Verify rendering at more than one size after geometry or layout changes.

## Wasm and browser boundaries

* Keep WebAssembly constraints visible when selecting libraries and APIs.
* Avoid filesystem assumptions in browser code.
* Isolate `web_sys`, `js_sys`, `wasm_bindgen`, and browser-specific types behind small modules or adapters.
* Convert browser values into project-owned Rust types near the boundary.
* Avoid spreading browser API types throughout domain models.
* Keep domain logic usable outside wasm where practical.
* Treat unavailable browser capabilities as recoverable conditions.
* Prefer asynchronous browser APIs for storage and large data operations.
* Avoid blocking the browser main thread.
* Use workers for CPU-heavy tasks when the complexity and workload justify them.
* Be explicit about browser security, permission, origin, and isolation requirements.
* Account for multiple-tab behavior where storage or workers may have exclusive-access constraints.
* Account for storage locking, OPFS access-handle restrictions, and concurrent-tab failure modes where relevant.
* Avoid assuming all supported browsers provide identical APIs or behavior.
* Degrade gracefully when optional browser APIs are unavailable.

## Browser storage

* Do not store large structured application state directly in `localStorage`.
* Use `localStorage` only for small, simple preferences or identifiers where synchronous access is acceptable.
* Consider IndexedDB, SQLite in WebAssembly, OPFS, or another appropriate browser storage layer for larger datasets.
* Keep durable persistence separate from transient UI state.
* Version persistence formats.
* Design migration behavior before persistent data becomes difficult to change.
* Handle missing, partial, stale, invalid, or incompatible stored data gracefully.
* Do not silently discard user data during migrations.
* Avoid treating browser storage as infallible.
* Surface quota, permission, locking, and compatibility failures appropriately.
* Consider export and backup behavior when users own important browser-resident data.
* Avoid storing derived values that can be recreated cheaply unless caching has a clear benefit.

## Serialization and persistence compatibility

* Treat persisted formats as compatibility boundaries.
* Do not rename serialized fields, enum variants, or structural representations without considering backward compatibility.
* Prefer explicit schema or format versions.
* Provide migrations when durable data formats change incompatibly.
* Separate durable domain data from ephemeral UI state.
* Preserve unknown or future-compatible data when practical.
* Test serialization round trips when changing persisted structures.
* Do not assume successful deserialization implies semantic validity.
* Validate invariants after deserialization.
* Avoid serializing implementation details that should remain internal.
* Keep imported source data distinguishable from normalized or user-authored data.
* Preserve stable identifiers when records may outlive one import or storage version.

## Data and import work

* Prefer streaming parsers for large files.
* Avoid loading large datasets fully into memory unless the size is known to be manageable.
* Design importers so they can be rerun safely.
* Support resuming long-running imports when practical.
* Keep raw external data separate from normalized application data.
* Keep imported data separate from user overrides.
* Prefer deterministic transforms.
* Preserve enough provenance to debug incorrect records.
* Avoid mixing importer logic with UI logic.
* Prefer explicit import stages:

  1. read;
  2. parse;
  3. normalize;
  4. validate;
  5. store.
* Use chunked processing for large inputs.
* Provide progress reporting for long operations where useful.
* Make failure modes recoverable when practical.
* Do not silently skip malformed records unless the behavior is intentional and reported.
* Avoid partial durable writes without a recovery or transaction strategy.
* Validate with small representative samples before processing full datasets.
* Preserve idempotence where imports may be repeated.

## Error handling

* Use typed errors when they improve ownership, recovery, or diagnostics.
* Preserve useful error context across module boundaries.
* Do not add panic paths for recoverable browser, storage, network, parsing, user-input, or imported-data failures.
* Present actionable user-facing errors.
* Keep technical diagnostics separate when exposing them directly would confuse users.
* Do not silently ignore failed persistence, parsing, rendering, worker, or async operations.
* Do not convert meaningful failures into empty states.
* Preserve graceful degradation for optional browser capabilities.
* Avoid logging the same error repeatedly through multiple reactive paths.
* Include enough context in logs to identify the failing operation without exposing sensitive data.

## Dependencies

* Reuse existing dependencies when they adequately solve the problem.
* Do not add a crate for behavior that is simple and clear with the standard library or existing project dependencies.
* Review default features before adding a dependency.
* Disable unnecessary default features when practical.
* Avoid enabling broad feature sets when a narrower set is sufficient.
* Consider:

  * WebAssembly compatibility;
  * browser support;
  * bundle size;
  * compile time;
  * maintenance status;
  * licensing;
  * transitive dependencies;
  * JavaScript requirements;
  * server assumptions.
* Avoid server-oriented dependencies in browser-only paths unless clearly required.
* Do not introduce another UI framework without strong justification.
* Avoid dependencies that duplicate existing project functionality.
* Keep feature-gated dependencies understandable.
* Explain materially significant new dependencies in the implementation summary.

## Refactoring

* Prefer narrow extractions over broad rewrites.
* Preserve behavior while refactoring unless the requested change explicitly changes behavior.
* Identify stable extraction boundaries before moving code.
* Useful boundaries may include:

  * types;
  * props;
  * state;
  * effects;
  * controls;
  * rendering;
  * layout;
  * data loading;
  * import and export;
  * browser adapters;
  * geometry and math.
* Do not move code solely to reduce line count.
* Do not introduce new global state merely to simplify an extraction.
* Verify imports, visibility, module ownership, and call sites after moving code.
* Keep cohesive code together.
* Avoid turning one understandable component into many trivial wrappers.
* Remove obsolete code made unnecessary by the completed refactor.
* Do not leave commented-out implementations or abandoned replacement paths.
* Keep behavior changes separate from structural changes when practical.

## Feature flags

* Follow the project’s established feature-flag strategy.
* Use compile-time features for dependency selection, platform support, or genuinely excluded functionality.
* Use runtime feature visibility for incomplete or optional UI that remains part of normal builds.
* Do not use runtime feature flags as security boundaries.
* Avoid scattering feature checks through unrelated components.
* Prefer centralized feature visibility or capability models.
* Ensure direct routes and deep links follow the same feature restrictions as navigation.
* Test relevant non-default feature combinations when modifying feature-gated code.
* Avoid creating feature combinations that cannot compile or cannot be meaningfully tested.
* Document dependencies between features when they are not obvious.

## Verification

Use the narrowest relevant validation first, then expand according to the scope of the change.

After meaningful Rust edits:

* run `cargo fmt`;
* run the relevant `cargo check`;
* run relevant tests when logic or behavior changes;
* run Clippy when appropriate for the repository and scope;
* check the browser target when wasm-facing code changes.

Additional rules:

* Prefer package-specific commands before workspace-wide commands.
* Use relevant feature flags when default features do not cover the changed code.
* Test important non-default feature combinations when modifying feature-gated paths.
* Do not assume a native `cargo check` validates wasm-only code.
* Do not assume a wasm check validates native-only utilities.
* Do not claim validation passed unless the command actually ran successfully.
* Report commands that could not be run.
* Report pre-existing failures separately from failures introduced by the change.

For Leptos or browser UI changes:

* verify the application still builds for the intended browser target;
* verify loading, empty, disabled, success, and error states when relevant;
* verify desktop and narrow/mobile widths;
* verify dark and light themes;
* verify keyboard interaction;
* check for accidental horizontal overflow.

For SVG or rendering changes:

* verify labels and text placement;
* verify clipping and transforms;
* verify more than one output size;
* verify interaction overlays;
* verify exported output when shared rendering code changes.

For import changes:

* test with small representative samples;
* test malformed or partial input;
* verify repeat or resume behavior where supported;
* verify persistence and transaction behavior;
* verify progress and failure reporting.

For persistence changes:

* verify existing stored data still loads;
* verify round trips;
* verify migration behavior;
* verify invalid and missing data handling;
* verify user-authored data is not silently discarded.

## Repository inspection

Before editing:

* inspect the smallest relevant set of files;
* search for existing definitions, types, components, helpers, and patterns;
* inspect call sites before changing public or shared behavior;
* inspect related tests;
* check feature gates and platform-specific boundaries;
* check repository-local instructions.

Do not ask for files that are already available in the repository.

Request additional context only when the repository does not contain enough information to proceed safely.

## CodeCompanion guidance

* Prefer targeted edits over full-file rewrites.
* Avoid sending or editing unnecessarily large files as one undifferentiated context block.
* Search for relevant definitions and call sites before editing.
* When a file is large, identify stable extraction points before adding another major concern.
* Prefer adding a focused module over repeatedly expanding a mixed-responsibility file.
* Avoid generating massive `view!` blocks.
* Keep generated code compact but readable.
* Do not omit error handling, lifecycle cleanup, or validation merely to reduce output size.
* Use patch-oriented changes when practical.
* When presenting a proposed refactor, identify ownership boundaries rather than only listing new filenames.
* Avoid unnecessary questions when the repository already contains enough information.
* State significant assumptions.
* Report validation actually performed.
* Distinguish pre-existing failures from failures caused by the change.
* Do not claim work was completed when only a proposal or partial implementation was produced.

