#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "google-genai",
#     "pillow",
# ]
# ///
"""
Generate images using Google's Gemini 2.5 Flash (Nano Banana Pro).

Usage:
    uv run generate_image.py --prompt "A colorful abstract pattern" --output "./hero.png"
    uv run generate_image.py --prompt "Minimalist icon" --output "./icon.png" --aspect landscape
"""

import argparse
import os
import sys

from google import genai


def get_aspect_instruction(aspect: str) -> str:
    """Return aspect ratio instruction for the prompt."""
    aspects = {
        "square": "Generate a square image (1:1 aspect ratio).",
        "landscape": "Generate a landscape/wide image (16:9 aspect ratio).",
        "portrait": "Generate a portrait/tall image (9:16 aspect ratio).",
    }
    return aspects.get(aspect, aspects["square"])


def generate_image(prompt: str, output_path: str, aspect: str = "square") -> None:
    """Generate an image using Gemini 2.5 Flash and save to output_path."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set", file=sys.stderr)
        sys.exit(1)

    client = genai.Client(api_key=api_key)

    aspect_instruction = get_aspect_instruction(aspect)
    full_prompt = f"{aspect_instruction} {prompt}"

    response = client.models.generate_content(
        model="gemini-2.5-flash-image",
        contents=[full_prompt],
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
        description="Generate images using Gemini 2.5 Flash (Nano Banana Pro)"
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
        choices=["square", "landscape", "portrait"],
        default="square",
        help="Aspect ratio (default: square)",
    )

    args = parser.parse_args()
    generate_image(args.prompt, args.output, args.aspect)


if __name__ == "__main__":
    main()
