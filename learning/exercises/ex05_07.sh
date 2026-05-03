#!/bin/bash

falliti=0

for file in testloop/*fasta; do
    nome=$(basename "$file" .fasta)
    if [ ! -s "$file" ]; then
        (( falliti++ ))
        continue # riprende dall'inizio della prossima iterazione
    fi
    
    n_seq=$(grep -c "^>" "$file")
    echo "sequenze: $n_seq" > "testloop/${nome}_stats.txt" 
done

echo "Completato: $falliti analisi fallite."