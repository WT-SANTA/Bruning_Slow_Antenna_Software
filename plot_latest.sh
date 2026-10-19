#!/usr/bin/env bash
# Plots the most recent slow antenna .raw/.raw.gz file in the terminal

DATA_DIR="${SA_DATA_DIR:-$HOME/Desktop/DATA}"
PYTHON="${SA_PYTHON:-python3}"
# Only plot files written within this many seconds of the script being run
MAX_AGE=90
# Resolve symlinks so raw_plot_terminal.py and sa_common.py are found next to the real script
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Make sure chrony has selected (*), combined (+), or flagged as possibly in error (x) the GPS NMEA refclock,
# matching the states accepted by check_fix_gps.py
# CSV fields from chronyc -c sources: mode, state, name/refid, ...
if ! chronyc -c sources 2>/dev/null | awk -F, '$1 == "#" && $3 == "GPS" && ($2 == "*" || $2 == "+" || $2 == "x") { found = 1 } END { exit !found }'; then
    echo "chrony is not using GPS as a time source, not plotting"
    exit 1
fi

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

age=$(( $(date +%s) - $(date -r "$latest" +%s) ))
if (( age > MAX_AGE )); then
    echo "Latest file $latest was written ${age} s ago, not plotting"
    exit 1
fi

echo "Plotting $latest"
"$PYTHON" "$SCRIPT_DIR/raw_plot_terminal.py" -i "$latest"
