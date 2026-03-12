---
name: generate
description: Nano Banana (nano-banana) image generation skill. Use this skill when the user asks to "generate an image", "generate images", "create an image", "make an image", uses "nano banana", or requests multiple images like "generate 5 images". Generates images using Google's Gemini models (Flash, Pro, or Nano Banana 2) for any purpose - frontend designs, web projects, illustrations, graphics, hero images, icons, backgrounds, or standalone artwork. Invoke this skill for ANY image generation request.
---

# Nano Banana - Gemini Image Generation

Generate custom images using Google's Gemini models for integration into frontend designs.

## Prerequisites

Set the `GEMINI_API_KEY` environment variable with your Google AI API key.

## Available Models

| Model | Flag | ID | Best For | Max Resolution |
|-------|------|----|----------|----------------|
| **Flash** (Nano Banana) | `flash` | `gemini-2.5-flash-image` | Speed, high-volume tasks | 1024px |
| **Pro** (Nano Banana Pro) | `pro` | `gemini-3-pro-image-preview` | Professional quality, complex scenes | Up to 4K |
| **2** (Nano Banana 2) | `2` | `gemini-3.1-flash-image-preview` | Fast + high-res, best all-around | Up to 4K |

## Image Generation Workflow

### Step 1: Generate the Image

Use `scripts/image.py` with uv. The script is located in the skill directory at `skills/generate/scripts/image.py`:

```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "Your image description" \
  --output "/path/to/output.png"
```

Where `${SKILL_DIR}` is the directory containing this SKILL.md file.

Options:
- `--prompt` (required): Detailed description of the image to generate
- `--output` (required): Output file path (PNG format)
- `--aspect` (optional): Named shortcut (`square`, `landscape`, `portrait`) or direct ratio (`1:1`, `1:4`, `1:8`, `2:3`, `3:2`, `3:4`, `4:1`, `4:3`, `4:5`, `5:4`, `8:1`, `9:16`, `16:9`, `21:9`). Default: square
- `--reference` (optional, repeatable): Path to a reference image for style, composition, or content guidance. Can be specified multiple times for multiple references.
- `--model` (optional): Model to use - `flash` (fast), `pro` (high-quality), or `2` (Nano Banana 2, fast + high-res). Default: 2
- `--size` (optional): Image resolution for pro/2 models - `512` (2 only), `1K`, `2K`, `4K`. Default: 1K. Ignored for flash.

### Aspect Ratios by Model

| Ratio | Flash | Pro | 2 |
|-------|-------|-----|---|
| 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 | Yes | Yes | Yes |
| 1:4, 1:8, 4:1, 8:1 | No | No | Yes |

### Using Different Models

**Flash model** - Fast generation, good for iterations:
```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "A minimalist logo design" \
  --output "/path/to/logo.png" \
  --model flash
```

**Pro model** - Higher quality for final assets:
```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "A detailed hero illustration for a tech landing page" \
  --output "/path/to/hero.png" \
  --model pro \
  --size 2K
```

**Nano Banana 2 (default)** - Fast with high-res output and extra aspect ratios:
```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "A vibrant infographic about photosynthesis" \
  --output "/path/to/infographic.png" \
  --model 2 \
  --size 2K \
  --aspect 16:9
```

### Using Reference Images

To generate an image based on an existing reference:

```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "Create a similar abstract pattern with warmer colors" \
  --output "/path/to/output.png" \
  --reference "/path/to/reference.png"
```

To use multiple reference images (e.g., blend styles from several sources):

```bash
uv run "${SKILL_DIR}/scripts/image.py" \
  --prompt "Combine the color palette of the first image with the composition of the second" \
  --output "/path/to/output.png" \
  --reference "/path/to/style-ref.png" \
  --reference "/path/to/composition-ref.png"
```

Reference images help Gemini understand the desired style, composition, or visual elements you want in the generated image. When multiple references are provided, all images are sent to the model together.

**Reference image limits:**
- Flash: up to 3 reference images
- Pro: up to 6 object images + 5 character images (14 total)
- 2: up to 10 object images + 4 character images (14 total)

### Step 2: Integrate with Frontend Design

After generating images, incorporate them into frontend code:

**HTML/CSS:**
```html
<img src="./generated-hero.png" alt="Description" class="hero-image" />
```

**React:**
```jsx
import heroImage from './assets/generated-hero.png';
<img src={heroImage} alt="Description" className="hero-image" />
```

**CSS Background:**
```css
.hero-section {
  background-image: url('./generated-hero.png');
  background-size: cover;
  background-position: center;
}
```

## Crafting Effective Prompts

Write detailed, specific prompts for best results:

**Good prompt:**
> A minimalist geometric pattern with overlapping translucent circles in coral, teal, and gold on a deep navy background, suitable for a modern fintech landing page hero section

**Avoid vague prompts:**
> A nice background image

### Prompt Elements to Include

1. **Subject**: What the image depicts
2. **Style**: Artistic style (minimalist, abstract, photorealistic, illustrated)
3. **Colors**: Specific color palette matching the design system
4. **Mood**: Atmosphere (professional, playful, elegant, bold)
5. **Context**: How it will be used (hero image, icon, texture, illustration)
6. **Technical**: Aspect ratio needs, transparency requirements

## Integration with Frontend-Design Skill

When used alongside the frontend-design skill:

1. **Plan the visual hierarchy** - Identify where generated images add value
2. **Match the aesthetic** - Ensure prompts align with the chosen design direction (brutalist, minimalist, maximalist, etc.)
3. **Generate images first** - Create visual assets before coding the frontend
4. **Reference in code** - Use relative paths to generated images in your HTML/CSS/React

### Example Workflow

1. User requests a landing page with custom hero imagery
2. Invoke nano-banana to generate the hero image with a prompt matching the design aesthetic
3. Invoke frontend-design to build the page, referencing the generated image
4. Result: A cohesive design with custom AI-generated visuals

## Output Location

By default, save generated images to the project's assets directory:
- `./assets/` for simple HTML projects
- `./src/assets/` or `./public/` for React/Vue projects
- Use descriptive filenames: `hero-abstract-gradient.png`, `icon-user-avatar.png`
