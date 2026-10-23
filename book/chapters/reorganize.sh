#!/usr/bin/env bash
set -euo pipefail

# Run this script from the directory containing the top-level .md files
# (e.g., the "examples" directory).

shopt -s nullglob  # *.md expands to nothing if no match

for md in *.md; do
  [ -e "$md" ] || continue

  base="${md%.md}"
  target="$base"

  echo "Processing $md -> $target/index.md"

  # Create the target directory if it doesn't exist
  mkdir -p "$target"

  # Move the markdown file into the target directory as index.md
  if [ -e "$target/index.md" ]; then
    echo "  Warning: $target/index.md already exists, skipping move of $md."
  else
    mv "$md" "$target/index.md"
  fi

  # Move the figures directory (if it exists) and rename it to "figures"
  figdir="${base}.figures"
  if [ -d "$figdir" ]; then
    if [ -d "$target/figures" ]; then
      echo "  Warning: $target/figures already exists, merging contents of $figdir"
      cp -R "$figdir"/. "$target/figures"/
      rm -rf "$figdir"
    else
      mv "$figdir" "$target/figures"
    fi
  fi

  # Correct figure references in all markdown files inside the target directory.
  # Replaces:
  #   ../${base}.figures/foo.svg  -> figures/foo.svg
  #   ./${base}.figures/foo.svg   -> figures/foo.svg
  #   ${base}.figures/foo.svg    -> figures/foo.svg
  find "$target" -type f -name '*.md' -print0 | while IFS= read -r -d '' mdfile; do
    # \Q...\E quotes any regex metacharacters in $base
    perl -pi -e "s#(\.\./|\./)?\Q${base}\E\.figures/#figures/#g" "$mdfile"
  done
done

echo "Done."
