#!/usr/bin/env bash
# Plots the most recent slow antenna .raw/.raw.gz file in the terminal

DATA_DIR="${SA_DATA_DIR:-$HOME/Desktop/DATA}"
PYTHON="${SA_PYTHON:-python3}"
# Resolve symlinks so raw_plot_terminal.py and sa_common.py are found next to the real script
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

shopt -s nullglob
files=("$DATA_DIR"/*.raw "$DATA_DIR"/*.raw.gz)

if (( ${#files[@]} == 0 )); then
    echo "No .raw or .raw.gz files found in $DATA_DIR"
    exit 1
fi

latest="${files[0]}"
for f in "${files[@]}"; do
    [[ "$f" -nt "$latest" ]] && latest="$f"
done

echo "Plotting $latest"
"$PYTHON" "$SCRIPT_DIR/raw_plot_terminal.py" -i "$latest"
