---
name: Blush & Sand Serenity
colors:
  surface: '#fff8f6'
  surface-dim: '#e8d6d0'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1ec'
  surface-container: '#fdeae4'
  surface-container-high: '#f7e4de'
  surface-container-highest: '#f1dfd9'
  on-surface: '#231916'
  on-surface-variant: '#554244'
  inverse-surface: '#392e2a'
  inverse-on-surface: '#ffede7'
  outline: '#887273'
  outline-variant: '#dbc0c2'
  surface-tint: '#9e3e4e'
  primary: '#7f2738'
  on-primary: '#ffffff'
  primary-container: '#9e3e4e'
  on-primary-container: '#ffccd0'
  inverse-primary: '#ffb2ba'
  secondary: '#7b5459'
  on-secondary: '#ffffff'
  secondary-container: '#fecad0'
  on-secondary-container: '#7a5358'
  tertiary: '#7f2737'
  on-tertiary: '#ffffff'
  tertiary-container: '#9e3e4e'
  on-tertiary-container: '#ffccd0'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9dc'
  primary-fixed-dim: '#ffb2ba'
  on-primary-fixed: '#400011'
  on-primary-fixed-variant: '#7f2738'
  secondary-fixed: '#ffd9dd'
  secondary-fixed-dim: '#ecbabf'
  on-secondary-fixed: '#2f1318'
  on-secondary-fixed-variant: '#613d42'
  tertiary-fixed: '#ffd9dc'
  tertiary-fixed-dim: '#ffb2ba'
  on-tertiary-fixed: '#400010'
  on-tertiary-fixed-variant: '#7f2737'
  background: '#fff8f6'
  on-background: '#231916'
  surface-variant: '#f1dfd9'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-md: 1.5rem
  gutter-lg: 2rem
  margin: 1rem
  margin-md: 2rem
  margin-lg: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a compassionate, calm, and clinically reassuring environment for a breast health companion. Balancing medical credibility with deep emotional gentleness, the aesthetic combines soft organic warmth and clean modern clarity. 

The visual style blends soft minimalism with tactile wellness cues:
- **Atmosphere**: Reassuring, private, non-alarmist, and profoundly human.
- **Tactile Harmony**: High-comfort surfaces, pill-shaped interactions, and whisper-quiet structural borders.
- **Visual Weight**: Airy negative space counterbalanced by grounded deep mulberry anchors, eliminating the sterile coldness of clinical apps while avoiding infantilizing tropes.

## Colors

The palette grounds the interface in comforting, earthy berry tones paired with sunlit sand and warm powder surfaces.

- **Primary Brand (`#9E3E4E` - Deep Mulberry)**: Conveys quiet clinical authority, structural dignity, and emotional resilience. Used for major landmarks, key headlines, and primary brand indicators.
- **Interactive Action (`#F2808F` - Coral Blush)**: Highly visible, friendly, and empowering. Reserved for primary calls-to-action, active progress metrics, and vital positive affirmations.
- **Secondary Tone (`#7B5459` - Muted Plum)**: Structural subheaders, secondary navigation tabs, and intermediate status components.
- **Soft Accent (`#EEBCC2` - Dusty Blush)**: Used for subtle outlines, selected state backgrounds, secondary highlights, and divider accents.
- **Warm Neutral (`#E8D6D0` - Sand)**: Framing containers, inactive borders, and muted card strokes.
- **Global Canvas (`#F9E9EF` - Soft Powder)**: Base viewport canvas color providing ambient warmth.
- **Surfaces**: Pure White (`#FFFFFF`) for primary floating interactive cards, complemented by Soft Tinted White (`#FFF8F9`) for nested modules and grouped content blocks.
- **Typography**: Deep Espresso (`#21191E`) for maximum legibility without harsh black-on-white vibration; Warm Muted Gray (`#554243`) for supportive metadata, secondary content, and helper text.
- **Feedback Semantics**: Success (`#2E7D32`), Warning/Pending (`#E65100`), Info (`#0277BD`), and Critical/Alert (`#BA1A1A`). Critical states must always be balanced with soft tinted containers to prevent user panic.

## Typography

The type system prioritizes comforting clarity, high legibility, and geometric warmth.

- **Primary Font Engine**: Plus Jakarta Sans serves as the global English standard, providing open apertures, gentle curves, and accessible counter-forms.
- **RTL & Localization**: In Arabic interfaces, the system maps seamlessly onto **Cairo**, preserving proportional optical hierarchy, weight distribution, and baseline balance.
- **Editorial Voice**:
  - Headings communicate calm guidance through medium and semi-bold weights rather than aggressive heavy weights.
  - Body copy maintains generous line-heights to support stress-free, fatigue-free reading during clinical reviews or symptom tracking.

## Layout & Spacing

A fluid grid architecture engineered for frictionless multi-device adaptation, from handheld mobile self-checks to desktop clinical consultation portals.

- **Mobile Viewports (<600px)**: 4-column layout with 1rem margins and 1rem gutters, optimizing for thumb-zone reach and focused single-stream cards.
- **Tablet Viewports (600px–1024px)**: 8-column layout with 2rem margins and 1.5rem gutters, allowing side-by-side symptom timelines and instructional medical diagrams.
- **Desktop Viewports (>1024px)**: 12-column layout capped at 1280px max-width, with 3rem margins and 2rem gutters, organizing complex medical logs, appointments, and support resources in balanced panels.

## Elevation & Depth

Visual hierarchy uses warm, diffuse ambient drop shadows alongside perimeter borders rather than harsh, cold drop shadows.

- **Resting Surface Elevation**: Cards, sheets, and interactive modules utilize a warm-tinted shadow: `box-shadow: 0 4px 20px rgba(85, 66, 67, 0.06)`. This replaces synthetic cold black shadows with the muted undertone of the secondary palette.
- **Structural Framing**: Surfaces rely on subtle 1.5px continuous borders in Dusty Blush (`#EEBCC2`) or Sand (`#E8D6D0`), grounding each element against the Soft Powder canvas.
- **Active / Floating Overlays**: Drawers, bottom sheets, and dialogs step up to `box-shadow: 0 12px 32px rgba(85, 66, 67, 0.12)` paired with a soft backdrop blur (`backdrop-filter: blur(8px)` with `rgba(249, 233, 239, 0.75)`).

## Shapes

The shape system centers on comforting curves that remove sharp edges:

- **Buttons & Interactive Tags**: Continuous full-pill radius (`28px - 32px` / `9999px`) to create inviting, approachable touch targets.
- **Cards & Primary Modules**: Curvature between `20px` and `24px`, delivering a protective enclosure for personal medical data.
- **Inner Controls & Small Inputs**: Moderated pill curvature (`12px` to `16px`) ensuring inputs remain distinct from primary action pills while avoiding angular corners.

## Components

### Buttons
- **Primary Action (CTA)**: Full pill geometry (`height: 52px`, `borderRadius: 9999px`), background Coral Blush (`#F2808F`), text Pure White (`#FFFFFF`), `font-weight: 600`. Active state deepens subtly to `#E56B7B`.
- **Secondary Action**: Full pill geometry, background Soft Tinted (`#FFF8F9`), border `1.5px solid #EEBCC2`, text Deep Mulberry (`#9E3E4E`).
- **Ghost/Tertiary**: Text Deep Mulberry (`#9E3E4E`) with transparent background; hover activates an overlay of `rgba(238, 188, 194, 0.2)`.

### Cards
- **Clinical & Insight Panels**: Pure White (`#FFFFFF`) surface, `borderRadius: 24px`, border `1.5px solid #E8D6D0`, elevation `0 4px 20px rgba(85, 66, 67, 0.06)`. Padding: `1.5rem`.
- **Informational / Nested Sub-Cards**: Soft Tinted (`#FFF8F9`), border `1.5px solid #EEBCC2`, no shadow, `borderRadius: 20px`. Padding: `1rem`.

### Input Fields
- **Container**: Pure White (`#FFFFFF`) base, height `52px`, `borderRadius: 16px`, border `1.5px solid #E8D6D0`, text Deep Espresso (`#21191E`), placeholder Warm Muted Gray (`#554243` at 60% opacity).
- **Focus State**: Border transitions to Coral Blush (`#F2808F`) with an ambient outer ring of `0 0 0 3px rgba(242, 128, 143, 0.25)`.

### Chips & Selection Badges
- **Unselected Filter**: Background Pure White (`#FFFFFF`), border `1.5px solid #E8D6D0`, text Warm Muted Gray (`#554243`), pill shape (`borderRadius: 9999px`), padding `0.5rem 1rem`.
- **Selected Filter**: Background Soft Tinted (`#FFF8F9`), border `1.5px solid #9E3E4E`, text Deep Mulberry (`#9E3E4E`), font-weight `600`.

### Checkboxes & Radio Buttons
- **Selection Mechanics**: 22px diameter circles/rounded squares (`borderRadius: 6px` for checkboxes; full circle for radio).
- **Active State**: Deep Mulberry (`#9E3E4E`) fill with Pure White (`#FFFFFF`) check or inner radio dot. Inactive state features an unselected Sand outline (`#E8D6D0`) against Pure White (`#FFFFFF`).

### Lists & Navigation Rows
- **List Items**: Framed with light bottom divider lines (`1px solid #E8D6D0`).
- **Interactive Rows**: Contain trailing chevron glyphs in Dusty Blush (`#EEBCC2`) and padding of `1rem 0`.

### Symptom Trackers & Self-Check Indicators
- **Pain & Texture Scales**: Circular tap nodes utilizing the semantic range with muted tonal backgrounds, ensuring self-examination logging feels clinical, direct, and supportive.