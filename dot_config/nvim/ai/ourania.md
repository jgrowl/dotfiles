# Ourania Project Rules

Ourania is a Rust/Leptos astrology application.

## Project priorities

- Keep the app Rust-first.
- Use Leptos and rust-ui components where they fit.
- Preserve browser-based functionality.
- Avoid unnecessary JavaScript.
- Keep chart rendering, chart controls, menus, overlays, and state management separated.
- Design for desktop and mobile.
- Keep SVG and PNG output customizable.
- Keep web-view presentation customizable.
- Prefer clear user-facing labels.

## Navigation and information architecture

- The app name should be presented as Urania/Ourania according to the existing project convention.
- Do not use “Navigation” as a meaningful menu title unless it adds actual clarity.
- New chart actions should be limited to chart creation flows such as Natal and Transit.
- People and Events should be treated as a broader genealogy/events area.
- Genealogy features should be able to stand alone without astrology unless astrology is explicitly opted into.
- Avoid exposing Astro-Databank-specific wording in the user-facing People and Events area unless specifically requested.

## Chart UI

- Prefer chart-level action menus over scattered unrelated controls.
- Transit chart creation should clearly distinguish:
  - same location as source chart
  - viewer/current location
  - manually selected location
- Avoid vague actions like “save chart” or “rename chart” unless the data model actually supports them.
- Keep global “Now” visible when relevant.
- Preserve precise UTC/local time controls.
- Avoid visual overflow from cards, menus, and panels.

## Refactoring

- Large components like `RubrumChart` should be split into focused subcomponents.
- Prefer structures like:
  - `ChartFrame`
  - `ChartSvgLayer`
  - `ChartOverlayLayer`
  - `ChartActionMenu`
  - `ChartStatusBar`
- Keep behavior changes separate from layout-only changes when possible.
