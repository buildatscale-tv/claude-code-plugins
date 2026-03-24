---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to "build a page", "create a component", "design a UI", "make a landing page", "build a website", "create a frontend", "design an interface", or any request involving web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
allowed-tools: Bash(npm:*), Bash(npx:*), Bash(node:*), Read, Write, Edit, Glob, Grep, AskUserQuestion, Skill
---

# Frontend Design

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## Design Thinking

Before coding, understand the context and commit to a **bold** aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme — brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:

- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

### Typography

Choose fonts that are beautiful, unique, and interesting. **Avoid** generic fonts like Arial, Inter, Roboto, and system fonts. Opt for distinctive choices that elevate the frontend's aesthetics — unexpected, characterful font choices. Pair a distinctive display font with a refined body font.

Use Google Fonts or other CDN-hosted fonts:

```html
<link href="https://fonts.googleapis.com/css2?family=DISPLAY_FONT&family=BODY_FONT&display=swap" rel="stylesheet">
```

### Color & Theme

Commit to a cohesive aesthetic. Use CSS variables for consistency:

```css
:root {
  --color-primary: ...;
  --color-accent: ...;
  --color-bg: ...;
  --color-text: ...;
}
```

Dominant colors with sharp accents outperform timid, evenly-distributed palettes. **Never** default to purple gradients on white backgrounds.

### Motion & Animation

Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available.

Focus on high-impact moments: one well-orchestrated page load with staggered reveals (`animation-delay`) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.

```css
@keyframes fadeSlideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.element {
  animation: fadeSlideUp 0.8s ease-out both;
}

.element:nth-child(2) { animation-delay: 0.15s; }
.element:nth-child(3) { animation-delay: 0.3s; }
```

### Spatial Composition

Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density. Avoid predictable, cookie-cutter component patterns.

### Backgrounds & Visual Details

Create atmosphere and depth rather than defaulting to solid colors. Apply creative forms:

- Gradient meshes and noise textures
- Geometric patterns and layered transparencies
- Dramatic shadows and decorative borders
- Custom cursors and grain overlays
- Contextual effects that match the overall aesthetic

## Anti-Patterns to Avoid

**NEVER** use:

- Overused font families (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (purple gradients on white)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character
- The same aesthetic across different projects

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No two designs should look the same. Vary between light and dark themes, different fonts, different aesthetics.

## Implementation Approach

Match implementation complexity to the aesthetic vision:

- **Maximalist designs** need elaborate code with extensive animations and effects
- **Minimalist designs** need restraint, precision, and careful attention to spacing, typography, and subtle details
- Elegance comes from executing the vision well

### HTML/CSS Projects

Single-file or multi-file HTML with embedded or linked CSS/JS. Include all assets via CDN where possible.

### React/Vue Projects

Use framework conventions. Install dependencies with npm/npx. Leverage component architecture for reusable design elements.

## Integration with Nano Banana

When the project needs custom imagery, invoke the `nano-banana` skill to generate images that match the design aesthetic:

1. **Plan the visual hierarchy** — Identify where generated images add value
2. **Match the aesthetic** — Ensure image prompts align with the chosen design direction
3. **Generate images first** — Create visual assets before coding the frontend
4. **Reference in code** — Use relative paths to generated images in your HTML/CSS/React

## Workflow

1. **Understand requirements** — Read the user's request carefully. Ask clarifying questions if needed.
2. **Choose aesthetic direction** — Pick a bold, specific design direction. Announce it to the user.
3. **Plan the structure** — Decide on framework, layout approach, and key visual elements.
4. **Implement** — Write production-grade code with meticulous attention to detail.
5. **Refine** — Review for visual polish, animation timing, spacing, and typography.

Remember: Claude is capable of extraordinary creative work. Don't hold back — show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
