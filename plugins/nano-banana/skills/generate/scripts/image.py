#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "google-genai",
#     "pillow",
# ]
# ///
"""
Generate images using Google's Gemini image models (Nano Banana family).

Usage:
    uv run generate_image.py --prompt "A colorful abstract pattern" --output "./hero.png"
    uv run generate_image.py --prompt "Minimalist icon" --output "./icon.png" --aspect landscape
    uv run generate_image.py --prompt "Similar style image" --output "./new.png" --reference "./existing.png"
    uv run generate_image.py --prompt "Blend these styles" --output "./new.png" --reference "./a.png" --reference "./b.png"
    uv run generate_image.py --prompt "High quality art" --output "./art.png" --model pro --size 2K
    uv run generate_image.py --prompt "Fast high-res" --output "./fast.png" --model 2 --size 2K --aspect 4:3
"""

import argparse
import os
import sys

from google import genai
from google.genai import types
from PIL import Image

MODEL_IDS = {
    "flash": "gemini-2.5-flash-image",
    "pro": "gemini-3-pro-image-preview",
    "2": "gemini-3.1-flash-image-preview",
}

# Named shortcuts for common aspect ratios
ASPECT_ALIASES = {
    "square": "1:1",
    "landscape": "16:9",
    "portrait": "9:16",
}

# All valid aspect ratios (Nano Banana 2 superset)
ALL_ASPECT_RATIOS = [
    "1:1", "1:4", "1:8", "2:3", "3:2", "3:4", "4:1",
    "4:3", "4:5", "5:4", "8:1", "9:16", "16:9", "21:9",
]

# Aspect ratios supported per model
MODEL_ASPECT_RATIOS = {
    "flash": ["1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"],
    "pro": ["1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"],
    "2": ALL_ASPECT_RATIOS,
}


def resolve_aspect(aspect: str) -> str:
    """Resolve a named alias or direct ratio string to a ratio string."""
    return ASPECT_ALIASES.get(aspect, aspect)


def get_aspect_instruction(aspect_ratio: str) -> str:
    """Return aspect ratio instruction for the prompt."""
    descriptions = {
        "1:1": "Generate a square image (1:1 aspect ratio).",
        "1:4": "Generate a tall narrow image (1:4 aspect ratio).",
        "1:8": "Generate a very tall narrow image (1:8 aspect ratio).",
        "2:3": "Generate a tall image (2:3 aspect ratio).",
        "3:2": "Generate a wide image (3:2 aspect ratio).",
        "3:4": "Generate a tall image (3:4 aspect ratio).",
        "4:1": "Generate a wide panoramic image (4:1 aspect ratio).",
        "4:3": "Generate a landscape image (4:3 aspect ratio).",
        "4:5": "Generate a slightly tall image (4:5 aspect ratio).",
        "5:4": "Generate a slightly wide image (5:4 aspect ratio).",
        "8:1": "Generate a very wide panoramic image (8:1 aspect ratio).",
        "9:16": "Generate a portrait/tall image (9:16 aspect ratio).",
        "16:9": "Generate a landscape/wide image (16:9 aspect ratio).",
        "21:9": "Generate an ultrawide image (21:9 aspect ratio).",
    }
    return descriptions.get(aspect_ratio, f"Generate an image with {aspect_ratio} aspect ratio.")


def generate_image(
    prompt: str,
    output_path: str,
    aspect: str = "square",
    references: list[str] | None = None,
    model: str = "2",
    size: str = "1K",
) -> None:
    """Generate an image using Gemini and save to output_path."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set", file=sys.stderr)
        sys.exit(1)

    client = genai.Client(api_key=api_key)

    aspect_ratio = resolve_aspect(aspect)

    # Validate aspect ratio for selected model
    valid_ratios = MODEL_ASPECT_RATIOS[model]
    if aspect_ratio not in valid_ratios:
        print(f"Error: Aspect ratio '{aspect_ratio}' not supported for model '{model}'. Valid ratios: {', '.join(valid_ratios)}", file=sys.stderr)
        sys.exit(1)

    aspect_instruction = get_aspect_instruction(aspect_ratio)
    full_prompt = f"{aspect_instruction} {prompt}"

    # Build contents with optional reference images
    contents: list = []
    if references:
        for ref_path in references:
            if not os.path.exists(ref_path):
                print(f"Error: Reference image not found: {ref_path}", file=sys.stderr)
                sys.exit(1)
            contents.append(Image.open(ref_path))
        if len(references) == 1:
            full_prompt = f"{full_prompt} Use the provided image as a reference for style, composition, or content."
        else:
            full_prompt = f"{full_prompt} Use the provided {len(references)} images as references for style, composition, or content."
    contents.append(full_prompt)

    model_id = MODEL_IDS[model]

    # Pro and Nano Banana 2 models support image_config for resolution and aspect ratio
    if model in ("pro", "2"):
        valid_sizes = ["512", "1K", "2K", "4K"] if model == "2" else ["1K", "2K", "4K"]
        if size not in valid_sizes:
            print(f"Error: Size '{size}' not supported for model '{model}'. Valid sizes: {', '.join(valid_sizes)}", file=sys.stderr)
            sys.exit(1)
        config = types.GenerateContentConfig(
            response_modalities=["TEXT", "IMAGE"],
            image_config=types.ImageConfig(
                aspect_ratio=aspect_ratio,
                image_size=size,
            ),
        )
        response = client.models.generate_content(
            model=model_id,
            contents=contents,
            config=config,
        )
    else:
        response = client.models.generate_content(
            model=model_id,
            contents=contents,
        )

    # Ensure output directory exists
    output_dir = os.path.dirname(output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    # Extract image from response
    for part in response.parts:
        if part.text is not None:
            print(f"Model response: {part.text}")
        elif part.inline_data is not None:
            image = part.as_image()
            image.save(output_path)
            print(f"Image saved to: {output_path}")
            return

    print("Error: No image data in response", file=sys.stderr)
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Nano Banana (Gemini Flash, Pro, or 2)"
    )
    parser.add_argument(
        "--prompt",
        required=True,
        help="Description of the image to generate",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Output file path (PNG format)",
    )
    parser.add_argument(
        "--aspect",
        choices=list(ASPECT_ALIASES.keys()) + ALL_ASPECT_RATIOS,
        default="square",
        help="Aspect ratio: named shortcut (square, landscape, portrait) or direct ratio (e.g. 4:3, 21:9). Default: square",
    )
    parser.add_argument(
        "--reference",
        action="append",
        dest="references",
        help="Path to a reference image (can be specified multiple times for multiple references)",
    )
    parser.add_argument(
        "--model",
        choices=["flash", "pro", "2"],
        default="2",
        help="Model: flash (Nano Banana, fast, 1024px), pro (Nano Banana Pro, up to 4K), 2 (Nano Banana 2, fast + up to 4K) (default: 2)",
    )
    parser.add_argument(
        "--size",
        choices=["512", "1K", "2K", "4K"],
        default="1K",
        help="Image resolution for pro/2 models: 512 (2 only), 1K (default), 2K, 4K. Ignored for flash.",
    )

    args = parser.parse_args()
    generate_image(args.prompt, args.output, args.aspect, args.references, args.model, args.size)


if __name__ == "__main__":
    main()
