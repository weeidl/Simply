# Search Field Redesign Design

**Date:** 2026-04-23

## Goal

Turn the existing search field into a proper reusable app-level control with a
clean “single-piece pill” appearance like the provided reference, then make
that component the default search pattern across the app.

## Current Problem

`WarmSearchField` currently reads like a `Container` with a `TextField` placed
inside it. The geometry, border treatment, and icon spacing make it feel like a
wrapped primitive instead of a polished control. This is visually weaker and
also makes the component less reusable as a design-system building block.

## Approaches Considered

### 1. Style-only patch

Keep the current implementation shape and only tweak colors, padding, and
radius.

**Rejected:** fastest, but preserves the architectural issue that the component
behaves like a decorated wrapper rather than a cohesive search control.

### 2. Evolve `WarmSearchField` into the canonical app search control

Keep the existing component name and usage sites, but redesign its internals so
it becomes a true reusable control with defined slots and interaction states.

**Recommended:** gives the app one search-field standard without introducing a
parallel component hierarchy or unnecessary migration overhead.

### 3. Introduce a brand-new `AppSearchField`

Create a new shared component and gradually migrate away from
`WarmSearchField`.

**Rejected for now:** clean in theory, but too much duplication for the current
app state when `WarmSearchField` can be evolved in place.

## Visual Direction

The control should match the reference:

- one continuous white pill;
- soft warm-neutral shadow instead of a noticeable border;
- generous horizontal padding and balanced icon spacing;
- slightly warmer placeholder color;
- right-side action icon visually integrated into the same control;
- no stacked or layered look suggesting “container + input”.

## Component Design

`WarmSearchField` will become a proper reusable control with:

- a single outer decoration handling shape, fill, subtle shadow, and focus;
- a built-in left search icon;
- a right action slot for filter or auxiliary actions;
- support for `hint`, `controller`, `onChanged`, `readOnly`, `onTap`,
  `textInputAction`, and optional custom trailing widget;
- consistent height and padding so every screen gets the same look by default.

## Scope

### In scope

- redesign `WarmSearchField`;
- update current usage in the messages list screen;
- keep the API reusable for future search surfaces;
- tune theme tokens only if strictly necessary for this control.

### Out of scope

- redesigning chip filters under the search field;
- changing search logic or cubit behavior;
- broad typography or global theme overhaul unrelated to the search control.

## Validation

Implementation will be considered correct when:

1. the search field visually reads as one polished control similar to the
   provided screenshot;
2. current search behavior on the messages screen still works;
3. the component API is cleaner and easier to reuse elsewhere;
4. tests/build/analyze continue to pass.
