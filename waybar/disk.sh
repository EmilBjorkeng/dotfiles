#!/bin/bash

# Get used and total for / and /home in bytes
read used_root total_root <<< $(df -B1 / | awk 'NR==2 {print $3, $2}')
read used_home total_home <<< $(df -B1 /home | awk 'NR==2 {print $3, $2}')

total_comb=$((total_root + total_home))
used_comb=$((used_root + used_home))

# Calculate percentage with 1 decimal
percent_root=$(awk -v u="$used_root" -v t="$total_root" 'BEGIN { printf "%.1f", u / t * 100 }')
percent_home=$(awk -v u="$used_home" -v t="$total_home" 'BEGIN { printf "%.1f", u / t * 100 }')
percent_comb=$(awk -v u="$used_comb" -v t="$total_comb" 'BEGIN { printf "%.1f", u / t * 100 }')

# Human-readable sizes for tooltip
used_root=$(numfmt --to=iec-i --suffix=B "$used_root")
total_root=$(numfmt --to=iec-i --suffix=B "$total_root")

used_home=$(numfmt --to=iec-i --suffix=B "$used_home")
total_home=$(numfmt --to=iec-i --suffix=B "$total_home")

used_comb=$(numfmt --to=iec-i --suffix=B "$used_comb")
total_comb=$(numfmt --to=iec-i --suffix=B "$total_comb")

tooltip="Root: $used_root / $total_root\nHome: $used_home / $total_home"
echo "{\"text\": \"$percent_root%/$percent_home%\", \"tooltip\": \"$tooltip\"}"
