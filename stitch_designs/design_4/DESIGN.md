---
name: Hayat Modular System
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c2c8c2'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8c928c'
  outline-variant: '#424843'
  surface-tint: '#b4ccbb'
  primary: '#b4ccbb'
  on-primary: '#203529'
  primary-container: '#1a2f23'
  on-primary-container: '#809787'
  inverse-primary: '#4d6355'
  secondary: '#c1c8ca'
  on-secondary: '#2b3234'
  secondary-container: '#434a4c'
  on-secondary-container: '#b2babc'
  tertiary: '#a8cfbc'
  on-tertiary: '#113729'
  tertiary-container: '#0a3124'
  on-tertiary-container: '#749a88'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d0e9d6'
  primary-fixed-dim: '#b4ccbb'
  on-primary-fixed: '#0a2014'
  on-primary-fixed-variant: '#364c3e'
  secondary-fixed: '#dde4e6'
  secondary-fixed-dim: '#c1c8ca'
  on-secondary-fixed: '#161d1f'
  on-secondary-fixed-variant: '#41484a'
  tertiary-fixed: '#c3ecd7'
  tertiary-fixed-dim: '#a8cfbc'
  on-tertiary-fixed: '#002115'
  on-tertiary-fixed-variant: '#294e3f'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 20px
  gutter: 16px
  card-padding: 24px
  section-gap: 32px
---

## Brand & Style

The design system is centered on a "Digital Sanctuary" philosophy—creating a serene, focused, and high-utility environment for religious and community engagement. The target audience includes modern community members who require tools for spiritual practice, charity, and social connection within a unified interface.

The design style is **Modern Minimalist with a Modular influence**. It utilizes high-contrast interfaces to ensure legibility in low-light environments (perfect for early morning or late night prayer times). The aesthetic combines the raw structure of modular cards with the softness of generous "2xl" rounded corners. The emotional response should be one of peace, reliability, and technological sophistication. All layouts are optimized for Right-to-Left (RTL) reading patterns, specifically tailored for the Persian language.

## Colors

This design system uses a sophisticated dark palette designed to reduce eye strain and provide a premium, grounded feel.

- **Primary (Forest Deep):** Used for main surfaces, primary action buttons, and header backgrounds. It provides the spiritual, organic foundation of the app.
- **Secondary (Slate/Charcoal):** Used for card backgrounds and secondary UI elements to provide depth against the deep primary background.
- **Accent (Mint Highlight):** Reserved for active states, progress bars, highlights, and critical CTA text. This color should be used sparingly to maintain high visual impact.
- **Surface/Neutral:** A true dark charcoal for the base background layer to ensure the forest greens feel vibrant and distinct.

## Typography

The typography uses **Be Vietnam Pro** as the primary Latin stack, paired with a high-quality Persian sans-serif (like Vazirmatn or IRANSans) for RTL text. The focus is on clarity, generous line heights to accommodate complex Perso-Arabic scripts, and a strong weight hierarchy.

Headlines should use heavy weights to anchor the modular cards, while body text maintains a lighter weight for maximum readability. For Persian text, avoid "Thin" weights as they can break legibility on low-resolution mobile screens; stick to Regular (400) for body and Semi-Bold (600+) for UI labels.

## Layout & Spacing

The design system employs a **Fluid Modular Grid** with an 8px base unit. 

- **Desktop/Tablet:** 12-column grid with 24px gutters. Content is organized into modular "Tiles" that can span 3, 4, or 6 columns.
- **Mobile:** 4-column grid with 20px side margins. Most modules span the full width or 2 columns (50% width).
- **RTL Logic:** All layouts must mirror globally. Navigation starts from the right, and progress bars animate from right-to-left. 
- **Modular Rhythm:** Use generous vertical spacing (32px+) between distinct feature blocks (e.g., Prayer Times vs. Community News) to avoid visual clutter and maintain a sanctuary-like atmosphere.

## Elevation & Depth

Hierarchy in this design system is achieved through **Tonal Layering** rather than heavy drop shadows.

1.  **Level 0 (Base):** Neutral Dark (#121212).
2.  **Level 1 (Cards/Modules):** Deep Forest (#1A2F23) or Dark Slate (#2D3436).
3.  **Level 2 (Overlays/Pop-ups):** Lighter Slate with a 1px inner border in Mint (10% opacity) to define the edge.

**Shadows:** Use a single, very soft ambient shadow for floating elements (like the navigation bar or FABs). The shadow should have a large blur (24px) and very low opacity (15%), using the Primary Forest color as the tint instead of pure black.

## Shapes

The shape language is defined by the **2xl (Pill-shaped/High Radius)** philosophy. This softens the high-contrast dark mode and makes the app feel approachable and modern.

- **Main Modules:** 24px (1.5rem) to 32px (2rem) corner radius.
- **Buttons/Chips:** Full pill-shape for actions.
- **Icons:** Large module icons should be contained within "Squircle" backgrounds with a 20px radius to create a distinct, friendly visual rhythm.
- **Progress Bars:** Fully rounded ends (caps) to match the button style.

## Components

### Buttons & Actions
- **Primary:** High-contrast Mint green backgrounds with Deep Forest text. Fully rounded (Pill).
- **Secondary:** Deep Forest background with Mint green border (1px) and Mint text.

### Charity Cards & Progress
- **Cards:** Use the "2xl" radius with a Slate background.
- **Progress Bars:** Use a thick (8px-12px) track. The background is a 20% opacity Mint, while the progress indicator is 100% Mint. Labels for "Amount Raised" should be in `label-sm`.

### Module Icons
- Displayed in a grid. Each icon sits in a 64x64px or 80x80px rounded-square container. Icons are minimal, mono-line, and colored in Mint.

### Minimalist Lists
- List items have no dividers. Separation is achieved through vertical spacing (8px) and a subtle hover/active state that changes the background to a 5% lighter tint of the Forest Green.

### Prayer Time Widget
- A hero-style modular card using a subtle background gradient from Forest Green to Dark Charcoal. Active prayer time is highlighted using the Mint accent and a larger font size.

### Input Fields
- Dark Charcoal background with a 1px Forest Green border. On focus, the border becomes Mint. Labels are always positioned on the right for Persian alignment.