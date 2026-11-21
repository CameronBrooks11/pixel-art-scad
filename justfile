# pixel-art-scad task runner

set dotenv-load := false

# Default: show available recipes
default:
    @just --list

# Install dependencies into .venv
setup:
    uv sync

# Format the Python with ruff and the .scad with topiary (mutates working tree)
fmt:
    uv run ruff format .
    uv run ruff check --fix .
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Verify formatting (non-mutating)
fmt-check:
    uv run ruff format --check .
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

# Run linters
lint:
    uv run ruff check .

# Format check + lint
check: fmt-check lint

# Run the converter tests, then render every example with OpenSCAD
test: && render
    uv run pytest

# Render every example to STL, failing on any OpenSCAD warning
render:
    @for f in examples/sample_*.scad; do echo "render $f"; log=$(openscad --hardwarnings --export-format binstl -o - "$f" 2>&1 >/dev/null) || { echo "$log"; exit 1; }; done
