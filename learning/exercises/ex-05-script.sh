#!/bin/bash

# TODO: rinominare in REPORT_FILE — non è una directory ma un percorso file
REPORT_DIR=batch_test/report.tsv
passati=0
falliti=0
min_seq=2

echo "--- QC Batch FASTA ---"

echo -e "File\tSequenze\tStato" > $REPORT_DIR
for file in batch_test/data/*.fasta; do

    name=$(basename "$file")
    n_seq=$(grep -c "^>" "$file")

    if [ ! -s "$file" ]; then
        (( falliti++ ))
        echo "FAIL: $name   — file vuoto"
        echo -e "$name\t$n_seq\tFAIL" >> "$REPORT_DIR"
        continue
    fi

    if [ $n_seq -lt $min_seq ]; then
        (( falliti++ ))
        echo "FAIL: $name     — solo $n_seq sequenza (minimo: $min_seq)"
        echo -e "$name\t$n_seq\tFAIL" >> "$REPORT_DIR"
        continue
    fi

    (( passati++ ))
    echo "OK:   $name ($n_seq sequenze)"
    echo -e "$name\t$n_seq\tOK" >> "$REPORT_DIR"

done

echo " "
echo "--- Riepilogo ---"
echo "Passati: $passati"
echo "Falliti: $falliti"
echo "Report salvato in: $REPORT_DIR"
