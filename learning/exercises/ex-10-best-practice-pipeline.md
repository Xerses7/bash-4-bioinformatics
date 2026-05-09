# Esercizio 10: Pipeline production-ready

## Modulo correlato
[module-10-best-practice-pipeline.md](../module-10-best-practice-pipeline.md)

## Difficoltà
Hard — esercizio finale del corso

---

## Scenario

Hai costruito strumenti e script nei moduli precedenti. Ora è il momento di mettere tutto insieme: scrivi una pipeline bioinformatica completa, robusta e riproducibile, che potrebbe girare su un server di laboratorio senza supervisione. La pipeline deve gestire gli errori in modo elegante, fare logging, e produrre un report strutturato.

---

## Setup — crea i file di test

```bash
mkdir -p pipeline_final/input

# File con sequenze di lunghezze miste e qualità variabile
cat > pipeline_final/input/sample_A.fasta << 'EOF'
>SEQ_A001 gene brca1 - Homo sapiens chromosome 17
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
GTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTGTGACCACATATTTTGCAAATTTTG
CCTGTCCAGCCTCCCTAAAAATCTAGGACAAGTTCCAGAAGAAAGAAATCATGAAAACAGCAAAAGCCAC
>SEQ_A002 gene tp53 - Homo sapiens
ATGGAGGAGCCGCAGTCAGATCCTAGCGGTAAGCGTGAGCTATTTCGGAGCAGCTTCTGGACAGGAGGT
GGAAGGAAATTTGCGTGTGGAGTATTTGGATGACAGAAACACTTTTCGACATAGTGTGGTGGTGCCCTAT
>SEQ_A003 sequenza corta - sotto soglia
ATGCATGC
>SEQ_A004 gene myc - Homo sapiens
ATGCCCCTCAACGTTAGCTTCACCAACAGGAACTATGACCTCGACTACGACTCGGTGCAGCCGTATTTCT
ACTGCGACGAGGAGGAGAACTTCTACCAGCAGCAGCAGCAGCTCAGCGCCGCGCAGAGCTTCGAGCTGCT
GCCTCCTCCGTGCAGCCCGAGCCCCTGGTGCTCCATGAGGAGACACCGCCCACCACCAGCAGCGGTCGCA
EOF

cat > pipeline_final/input/sample_B.fasta << 'EOF'
>SEQ_B001 gene brca2 - Homo sapiens
ATGCCTATTGGATCCAAAGAGAGGCCAACATTTTTTGAAATTTTTAAGACACGCTGCAACAAAGCAGATT
TAGGACCAATAAGTCTTAATTGGTTTGAAGAACTTTCTTCAGAAGCTCCAAAAACTTGTACAAGTTTGCT
GTATTTGTGTTTCTAAAATGTGATGTTGCTTGCATGCCTGAAGATTTCTGGCATGATCCAGAAAGCATGG
>SEQ_B002 sequenza cortissima
AT
>SEQ_B003 gene egfr - Homo sapiens
ATGCGACCCTCCGGGACGGCCGGGGCAGCGCTCCTGGCGCTGCTGGCTGCGCTCTGCCCGGCGAGTCGGG
CTCTGGAGGAAAAGAAAGTTTGCCAAGGCACGAGTAACAAGCTCACGCAGTTGGGCACTTTTGAAGATCA
EOF

# File con un problema — nessun header FASTA
cat > pipeline_final/input/corrupted.fasta << 'EOF'
ATGCATGCATGCATGCATGCATGCATGCATGC
GCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTA
EOF

# File vuoto
> pipeline_final/input/empty.fasta
```

---

## Task

Scrivi la pipeline `pipeline_final/run_pipeline.sh` che:

### Requisiti BASH (tecnici)

- [ ] `#!/usr/bin/env bash` e `set -euo pipefail`
- [ ] Funzione di `logging` (INFO/WARN/ERROR) con timestamp, su stderr + file di log
- [ ] `trap cleanup EXIT` che rimuove i file temporanei anche in caso di errore
- [ ] `trap` su `ERR` che logga la riga del fallimento
- [ ] Parsing con `getopts` per le opzioni:
  - `-i DIR` — directory di input (obbligatoria)
  - `-o DIR` — directory di output (default: `./pipeline_out`)
  - `-m NUM` — lunghezza minima in bp (default: 50)
  - `-h` — aiuto
- [ ] Funzione `usage()` con esempio di uso
- [ ] Validazione: la directory di input esiste, contiene almeno un file `.fasta`
- [ ] Exit code appropriati (0 = successo, 1 = errore, 2 = uso scorretto)

### Requisiti bioinformatici (pipeline)

La pipeline deve processare tutti i file `.fasta` nella directory di input:

**Step 1 — Validazione**
- Salta i file vuoti (log WARN)
- Salta i file senza header FASTA (log WARN)
- Logga il numero di sequenze per i file validi

**Step 2 — Filtraggio**
- Filtra le sequenze con lunghezza < MIN_LEN
- Scrive le sequenze filtrate in `output/filtered/`
- Se nessuna sequenza supera il filtro, logga WARN e salta il file

**Step 3 — Statistiche per file**
- Per ogni file filtrato: numero sequenze, basi totali, GC content
- Scrive le statistiche in `output/stats/nome_file.tsv`

**Step 4 — Report finale**
- Genera `output/report.tsv` con una riga per ogni file: `File | Seq_input | Seq_output | Basi_totali | GC_pct | Stato`
- Genera `output/summary.txt` leggibile con i totali complessivi

### Output atteso

```
[2026-05-09 10:00:01] [INFO ] === Pipeline FASTA v1.0 ===
[2026-05-09 10:00:01] [INFO ] Input dir: pipeline_final/input
[2026-05-09 10:00:01] [INFO ] Output dir: pipeline_out
[2026-05-09 10:00:01] [INFO ] Min lunghezza: 50 bp
[2026-05-09 10:00:01] [INFO ] Step 1: Validazione
[2026-05-09 10:00:01] [WARN ] Saltato: corrupted.fasta — nessun header FASTA
[2026-05-09 10:00:01] [WARN ] Saltato: empty.fasta — file vuoto
[2026-05-09 10:00:01] [INFO ] Valido: sample_A.fasta — 3 sequenze
[2026-05-09 10:00:01] [INFO ] Valido: sample_B.fasta — 3 sequenze
[2026-05-09 10:00:01] [INFO ] Step 2: Filtraggio (min 50 bp)
[2026-05-09 10:00:01] [INFO ] sample_A.fasta: 3 → 2 sequenze (filtrata 1)
[2026-05-09 10:00:01] [INFO ] sample_B.fasta: 3 → 2 sequenze (filtrata 1)
[2026-05-09 10:00:01] [INFO ] Step 3: Statistiche
[2026-05-09 10:00:01] [INFO ] sample_A.fasta: 420 bp, GC 52.4%
[2026-05-09 10:00:01] [INFO ] sample_B.fasta: 420 bp, GC 54.3%
[2026-05-09 10:00:01] [INFO ] Step 4: Report
[2026-05-09 10:00:01] [INFO ] === Pipeline completata ===
[2026-05-09 10:00:01] [INFO ] File processati: 2 validi, 2 saltati
[2026-05-09 10:00:01] [INFO ] Output in: pipeline_out/
```

---

## Hints

<details>
<summary>Hint 1 — struttura dello script</summary>

```
#!/usr/bin/env bash
set -euo pipefail

# 1. Costanti e defaults
# 2. Funzioni: log_info, log_warn, log_error, usage, cleanup
# 3. trap cleanup EXIT
# 4. trap ERR
# 5. Parsing getopts
# 6. Validazione input
# 7. Setup: mkdir output dirs, init log file, init report TSV
# 8. Loop sui file .fasta
#    - Step 1: validazione
#    - Step 2: filtraggio
#    - Step 3: statistiche
# 9. Step 4: report finale e summary.txt
# 10. exit 0
```

Segui questa struttura dall'alto verso il basso — non cercare di fare tutto in una volta.

</details>

<details>
<summary>Hint 2 — gestire set -e nel filtraggio</summary>

Con `set -e`, `grep -c "^>"` restituisce exit code 1 se non trova nulla — e lo script si fermerebbe. Usa `|| true` per i comandi che possono legittimamente restituire "nessun risultato":

```bash
n_seq=$(grep -c "^>" "$file" || true)
```

Analogamente, `(( n++ ))` con `set -e` termina quando il risultato è 0. Usa `(( n++ )) || true` oppure `n=$(( n + 1 ))`.

</details>

<details>
<summary>Hint 3 — il report TSV</summary>

Inizializza il report con l'header prima del loop:

```bash
report="$OUTPUT_DIR/report.tsv"
echo -e "File\tSeq_input\tSeq_output\tBasi_totali\tGC_pct\tStato" > "$report"
```

Poi nel loop, aggiungi una riga per ogni file con `>> "$report"`. Anche i file saltati devono avere una riga (con stato `SALTATO`).

</details>

<details>
<summary>Hint 4 — summary.txt con totali</summary>

Dopo il loop, usa `awk` per sommare le colonne numeriche dal report TSV (salta la riga di header):

```bash
awk -F'\t' 'NR>1 && $6=="OK" { seq_in+=$2; seq_out+=$3; basi+=$4 }
            END { print "Sequenze input totali: " seq_in
                  print "Sequenze output totali: " seq_out
                  print "Basi totali: " basi " bp" }' "$report" >> "$OUTPUT_DIR/summary.txt"
```

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

Questa è la pipeline più complessa del corso — non aspettarti di scriverla in un unico passaggio. Costruiscila in incrementi verificando ogni step:

1. **Scheletro**: shebang, `set -euo pipefail`, funzioni di log, trap, getopts, validazione, `exit 0` — verifica che giri senza errori
2. **Step 1**: loop sui file, check vuoto e check header — verifica che saltati i file corrotti
3. **Step 2**: parsing FASTA e filtraggio per lunghezza — verifica che `filtered/` contenga i file corretti
4. **Step 3**: calcolo statistiche dal file filtrato — verifica i TSV in `stats/`
5. **Step 4**: costruzione del report e del summary — verifica il contenuto di entrambi

**Punti critici:**
- `set -e` + `grep -c` + `(( n++ ))`: aggiungi `|| true` dove serve
- `trap cleanup EXIT` con `TMPDIR_PIPELINE`: `mktemp -d` prima del loop, `rm -rf` nel cleanup
- File TSV report: una riga anche per i file saltati, così il report è completo
- `comm` / `grep -f` per l'intersezione: non servono qui, ma il pattern è utile se estendi la pipeline

</details>
