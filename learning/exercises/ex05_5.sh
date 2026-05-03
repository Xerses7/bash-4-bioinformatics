#!/bin/bash

ok=0
falliti=0

for file in testloop/*.fasta; do
    if [ ! -s "$file" ]; then
        (( falliti++ ))
        echo "Salto: $file"
        continue
    fi
    (( ok++ ))
    echo "OK: $file"
done

echo "OK: $ok"
echo "falliti: $falliti"