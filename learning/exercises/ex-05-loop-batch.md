# Esercizio 5: Pipeline di QC batch su file FASTA

## Modulo correlato
[module-05-loop-batch.md](../module-05-loop-batch.md)

## Difficoltà
Medium

---

## Scenario

Hai ricevuto da un collaboratore una cartella con 5 file FASTA — uno per ogni specie di un gruppo tassonomico. Prima di lanciare l'allineamento multiplo, devi verificare che ogni file soddisfi i criteri minimi di qualità e produrre un report riassuntivo.

---

## Setup — crea i file di test

Esegui questi comandi per creare la cartella e i file di esempio:

```bash
mkdir -p batch_test/data

cat > batch_test/data/homo_sapiens.fasta << 'EOF'
>NM_001301717.2 Homo sapiens BRCA1
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
GTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTGTGACCACATATTTTGCAAATTTTG
>NM_007294.4 Homo sapiens BRCA1 isoform 2
ATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTG
EOF

cat > batch_test/data/mus_musculus.fasta << 'EOF'
>NM_009764.3 Mus musculus Brca1
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
>NM_009765.2 Mus musculus Brca1 isoform b
ATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTG
>NM_001289530.1 Mus musculus Brca1 variant
ATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTG
EOF

cat > batch_test/data/danio_rerio.fasta << 'EOF'
>XM_017352429.2 Danio rerio brca1
ATGGATTTACCCGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAGATCTTAGAGT
EOF

# File vuoto — deve fallire il QC
> batch_test/data/gallus_gallus.fasta

cat > batch_test/data/rattus_norvegicus.fasta << 'EOF'
>NM_031550.2 Rattus norvegicus Brca1
ATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTG
>NM_001108118.1 Rattus norvegicus Brca1 isoform 2
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
EOF
```

---

## Task

Scrivi uno script BASH `batch_qc.sh` che:

1. **Itera su tutti i file `.fasta`** nella cartella `batch_test/data/`
2. **Per ogni file verifica:**
   - Il file non è vuoto (`-s`)
   - Contiene almeno **2 sequenze**
3. **Stampa a schermo** per ogni file: `OK` o `FAIL` con il motivo, e il numero di sequenze trovate
4. **Produce un report TSV** `batch_test/report.tsv` con le colonne: `File`, `Sequenze`, `Stato`
5. **Al termine** stampa un riepilogo: quanti file hanno passato il QC e quanti no

### Output atteso (a schermo)

```
--- QC Batch FASTA ---
OK:   homo_sapiens.fasta    (2 sequenze)
OK:   mus_musculus.fasta    (3 sequenze)
FAIL: danio_rerio.fasta     — solo 1 sequenza (minimo: 2)
FAIL: gallus_gallus.fasta   — file vuoto
OK:   rattus_norvegicus.fasta (2 sequenze)

--- Riepilogo ---
Passati: 3
Falliti: 2
Report salvato in: batch_test/report.tsv
```

---

## Requisiti

- [ ] Usare un loop `for` sui file `.fasta`
- [ ] Usare `basename` per mostrare solo il nome del file, non il percorso
- [ ] Controllare prima se il file è vuoto, poi il numero di sequenze
- [ ] Usare `continue` per saltare i file che falliscono il QC
- [ ] Salvare il report TSV con header `File`, `Sequenze`, `Stato`
- [ ] Usare contatori `ok` e `falliti` con `(( ))`

---

## Hints

<details>
<summary>Hint 1 — struttura generale</summary>

Lo script ha questa struttura:

```bash
#!/bin/bash
min_seq=2
ok=0
falliti=0
output="batch_test/report.tsv"

echo -e "File\tSequenze\tStato" > "$output"

echo "--- QC Batch FASTA ---"
for file in batch_test/data/*.fasta; do
    nome=$(basename "$file")
    # ... controlli e logica ...
done

echo ""
echo "--- Riepilogo ---"
# ... stampa contatori ...
```

</details>

<details>
<summary>Hint 2 — gestire il file vuoto prima di contare le sequenze</summary>

Se provi `grep -c "^>"` su un file vuoto ottieni `0`, che funziona — ma è più robusto (e più chiaro) fare il check di file vuoto separatamente con `[ ! -s "$file" ]`. Così sai *perché* ha fallito.

```bash
if [ ! -s "$file" ]; then
    echo "FAIL: $nome — file vuoto"
    echo -e "$nome\t0\tFAIL (vuoto)" >> "$output"
    (( falliti++ ))
    continue
fi
```

</details>

<details>
<summary>Hint 3 — scrivere nel TSV sia OK che FAIL</summary>

Ricorda di scrivere nel file TSV sia per i file che passano che per quelli che falliscono. Dopo il `continue` per i file vuoti, aggiungi un altro blocco per quelli con poche sequenze, e infine scrivi la riga OK per quelli che superano tutto.

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

1. Inizializza variabili: `ok=0`, `falliti=0`, percorso output
2. Crea l'header TSV con `echo -e "File\tSequenze\tStato" > "$output"`
3. Loop `for file in batch_test/data/*.fasta`
4. Per ogni file:
   a. `nome=$(basename "$file")`
   b. Check file vuoto → stampa FAIL, scrivi TSV, `(( falliti++ ))`, `continue`
   c. `n_seq=$(grep -c "^>" "$file")`
   d. Check `$n_seq -lt $min_seq` → stampa FAIL con motivo, scrivi TSV, `(( falliti++ ))`, `continue`
   e. Se arriva qui: stampa OK, scrivi TSV con stato OK, `(( ok++ ))`
5. Dopo il loop: stampa riepilogo con `$ok` e `$falliti`
6. Stampa il percorso del report

La parte più delicata è scrivere nel TSV in tutti i rami (sia FAIL che OK). Un errore comune è dimenticarsi di `>> "$output"` nel ramo finale.

</details>
