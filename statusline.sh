#!/bin/bash
read input
pct=$(echo "$input" | grep -o '"remaining_percentage":[0-9.]*' | head -1 | grep -o '[0-9.]*$')
echo "Lin | ctx: ${pct:-?}%"
