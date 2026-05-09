# Modulo 10: Best practice e debugging | Pipeline production-ready

## Obiettivo
Scrivere script BASH robusti, sicuri e riproducibili usando `set -euo pipefail`, logging strutturato, gestione degli errori con `trap`, e costruire una pipeline bioinformatica completa e production-ready.

## Prerequisiti
- Moduli 1–9: tutto il corso

---

## Parte 1 — BASH: Best practice e debugging

### `set -euo pipefail` — la riga più importante dei tuoi script

Aggiungi questa riga subito dopo lo shebang in ogni script:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Cosa fa ciascuna opzione:

| Opzione | Significato |
|---|---|
| `-e` | Esce immediatamente se un comando fallisce (exit code ≠ 0) |
| `-u` | Tratta le variabili non definite come errori (invece di trattarle come stringa vuota) |
| `-o pipefail` | Una pipeline fallisce se **uno qualsiasi** dei comandi al suo interno fallisce |

**Perché è cruciale:**

Senza `set -e`, uno script continua anche dopo un errore — processando dati sbagliati senza che tu te ne accorga. `pipefail` è particolarmente importante in bioinformatica:

```bash
# Senza pipefail: se grep fallisce, il wc -l conta 0 ma lo script continua
grep "pattern" $file | wc -l

# Con pipefail: se grep fallisce, lo script si ferma
```

**Aggirare `-e` quando vuoi ignorare il fallimento di un comando:**

```bash
count=$(grep -c "^>" "$file" || true)   # || true previene l'uscita
```

---

### Logging strutturato

Un sistema di logging ti permette di capire cosa sta succedendo senza `echo` sparsi ovunque.

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-pipeline.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE" >&2
}

log_info()  { log "INFO " "$1"; }
log_warn()  { log "WARN " "$1"; }
log_error() { log "ERROR" "$1"; }

# Uso
log_info "Inizio pipeline"
log_warn "File di input piccolo — risultati potrebbero essere limitati"
log_error "File non trovato: $input"
```

- `tee -a` scrive sia su stderr (visibile a schermo) che nel file di log (per futura consultazione)
- Il livello (`INFO`, `WARN`, `ERROR`) permette di filtrare il log in seguito

---

### `trap` — gestione degli errori e pulizia

`trap` intercetta segnali e condizioni speciali. Il pattern più utile: fare pulizia se lo script si interrompe inaspettatamente.

```bash
#!/usr/bin/env bash
set -euo pipefail

TMPDIR=$(mktemp -d)   # crea una directory temporanea unica

cleanup() {
    log_info "Pulizia file temporanei in $TMPDIR"
    rm -rf "$TMPDIR"
}

trap cleanup EXIT   # chiama cleanup() quando lo script esce (con qualsiasi exit code)
trap 'log_error "Script interrotto alla riga $LINENO"; cleanup; exit 1' ERR
```

I segnali più usati con `trap`:

| Segnale | Quando viene attivato |
|---|---|
| `EXIT` | Sempre, quando lo script termina |
| `ERR` | Quando un comando fallisce (con `-e`) |
| `INT` | Ctrl+C |
| `TERM` | Segnale di terminazione (kill) |

`$LINENO` è una variabile speciale che contiene il numero di riga corrente — estremamente utile nel debugging.

---

### shellcheck — il linter per BASH

`shellcheck` analizza staticamente i tuoi script e trova errori comuni prima che tu li esegua:

```bash
shellcheck myscript.sh
```

Esempi di errori che rileva:

```bash
# SC2086: variabile senza virgolette
for f in $files; do ...

# SC2046: command substitution senza virgolette
cp $(find . -name "*.fasta") dest/

# SC2064: trap con virgolette doppie (il valore viene espanso al momento del trap, non all'esecuzione)
trap "rm $tmpfile" EXIT   # sbagliato
trap 'rm "$tmpfile"' EXIT  # corretto
```

Installa con: `sudo apt install shellcheck` o `brew install shellcheck`.

---

### Debugging con `set -x`

`set -x` abilita il trace mode: ogni comando viene stampato su stderr prima di essere eseguito.

```bash
set -x   # attiva
./operazione_complessa.sh
set +x   # disattiva
```

Oppure esegui uno script in debug mode senza modificarlo:

```bash
bash -x myscript.sh
```

---

### Variabili con valori di default

```bash
# Se $1 non è definito, usa "input.fasta" come default
input="${1:-input.fasta}"

# Se la variabile di ambiente OUTPUT_DIR non è definita, usa "./results"
output_dir="${OUTPUT_DIR:-./results}"
```

---

## Parte 2 — Bioinformatica: Pipeline production-ready

### Anatomia di una pipeline bioinformatica

Una pipeline completa ha questa struttura:

```
Input FASTA
    ↓
[1] Validazione input
    ↓
[2] QC: filtra sequenze non valide
    ↓
[3] Filtraggio: applica criteri biologici
    ↓
[4] Analisi: statistiche, GC content, ecc.
    ↓
[5] Report: output strutturato
```

### `fasta_pipeline.sh` — pipeline completa

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─── Configurazione ───────────────────────────────────────────

VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")

# Defaults
INPUT=""
OUTPUT_DIR="./pipeline_output"
MIN_LEN=100
MIN_SEQ=1
VERBOSE=false
LOG_FILE=""

# ─── Funzioni di logging ──────────────────────────────────────

log() {
    local level="$1" msg="$2"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local line="[$ts] [$level] $msg"
    echo "$line" >&2
    if [ -n "$LOG_FILE" ]; then
        echo "$line" >> "$LOG_FILE"
    fi
}

log_info()  { log "INFO " "$1"; }
log_warn()  { log "WARN " "$1"; }
log_error() { log "ERROR" "$1"; }

# ─── Pulizia ──────────────────────────────────────────────────

TMPDIR_PIPELINE=""
cleanup() {
    if [ -n "$TMPDIR_PIPELINE" ] && [ -d "$TMPDIR_PIPELINE" ]; then
        rm -rf "$TMPDIR_PIPELINE"
    fi
}
trap cleanup EXIT
trap 'log_error "Errore alla riga $LINENO. Uscita."; exit 1' ERR

# ─── Uso ──────────────────────────────────────────────────────

usage() {
    cat << EOF
Uso: $SCRIPT_NAME [OPZIONI] -i <input.fasta>

Pipeline FASTA: QC → filtraggio → analisi → report.

Opzioni:
  -i FILE   file FASTA di input (obbligatorio)
  -o DIR    directory di output (default: $OUTPUT_DIR)
  -m NUM    lunghezza minima sequenza in bp (default: $MIN_LEN)
  -n NUM    numero minimo di sequenze richieste (default: $MIN_SEQ)
  -l FILE   file di log (default: <output_dir>/pipeline.log)
  -v        verbose
  -h        mostra questo aiuto

Esempio:
  $SCRIPT_NAME -i genoma.fasta -o results/ -m 500 -v
EOF
}

# ─── Parsing opzioni ──────────────────────────────────────────

while getopts "i:o:m:n:l:vh" opt; do
    case "$opt" in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        m) MIN_LEN="$OPTARG" ;;
        n) MIN_SEQ="$OPTARG" ;;
        l) LOG_FILE="$OPTARG" ;;
        v) VERBOSE=true ;;
        h) usage; exit 0 ;;
        ?) usage >&2; exit 2 ;;
    esac
done

# ─── Validazione input ────────────────────────────────────────

if [ -z "$INPUT" ]; then
    log_error "File di input obbligatorio (-i)"
    usage >&2
    exit 2
fi

if [ ! -f "$INPUT" ]; then
    log_error "File non trovato: $INPUT"
    exit 1
fi

if ! grep -q "^>" "$INPUT"; then
    log_error "Il file non sembra un FASTA valido (nessun header trovato): $INPUT"
    exit 1
fi

# ─── Setup ────────────────────────────────────────────────────

mkdir -p "$OUTPUT_DIR"
LOG_FILE="${LOG_FILE:-$OUTPUT_DIR/pipeline.log}"
TMPDIR_PIPELINE=$(mktemp -d)

log_info "=== Pipeline FASTA v$VERSION ==="
log_info "Input:        $INPUT"
log_info "Output dir:   $OUTPUT_DIR"
log_info "Min lunghezza: ${MIN_LEN} bp"
log_info "Min sequenze: $MIN_SEQ"

# ─── Step 1: QC iniziale ──────────────────────────────────────

log_info "Step 1: QC iniziale"

n_totale=$(grep -c "^>" "$INPUT")
log_info "Sequenze totali nel file: $n_totale"

if [ "$n_totale" -lt "$MIN_SEQ" ]; then
    log_error "Troppo poche sequenze: $n_totale (minimo: $MIN_SEQ)"
    exit 1
fi

# ─── Step 2: Filtraggio per lunghezza ─────────────────────────

log_info "Step 2: Filtraggio (lunghezza >= ${MIN_LEN} bp)"

filtered="$TMPDIR_PIPELINE/filtered.fasta"
n_passate=0
header=""
seq=""

while IFS= read -r riga; do
    if [[ "$riga" == ">"* ]]; then
        if [ -n "$header" ] && [ "${#seq}" -ge "$MIN_LEN" ]; then
            { echo "$header"; echo "$seq"; } >> "$filtered"
            (( n_passate++ )) || true
        fi
        header="$riga"
        seq=""
    else
        seq+="$riga"
    fi
done < "$INPUT"

if [ -n "$header" ] && [ "${#seq}" -ge "$MIN_LEN" ]; then
    { echo "$header"; echo "$seq"; } >> "$filtered"
    (( n_passate++ )) || true
fi

n_filtrate=$(( n_totale - n_passate ))
log_info "Sequenze passate il filtro: $n_passate / $n_totale (filtrate: $n_filtrate)"

if [ "$n_passate" -eq 0 ]; then
    log_error "Nessuna sequenza supera la lunghezza minima di ${MIN_LEN} bp"
    exit 1
fi

# Copia il file filtrato nell'output
cp "$filtered" "$OUTPUT_DIR/filtered.fasta"

# ─── Step 3: Analisi statistiche ──────────────────────────────

log_info "Step 3: Calcolo statistiche"

stats_file="$OUTPUT_DIR/stats.tsv"
echo -e "Metrica\tValore" > "$stats_file"
echo -e "Sequenze_input\t$n_totale" >> "$stats_file"
echo -e "Sequenze_filtrate_lunghezza\t$n_filtrate" >> "$stats_file"
echo -e "Sequenze_output\t$n_passate" >> "$stats_file"

# GC content sul file filtrato
gc_count=$(grep -v "^>" "$OUTPUT_DIR/filtered.fasta" | tr -d '\n[:space:]' | grep -oE '[GCgc]' | wc -l || echo 0)
tot_bp=$(grep -v "^>" "$OUTPUT_DIR/filtered.fasta" | tr -d '\n[:space:]' | wc -c)
gc_pct=$(awk -v gc="$gc_count" -v tot="$tot_bp" 'BEGIN { if (tot>0) printf "%.1f", gc/tot*100; else print 0 }')

echo -e "Basi_totali_bp\t$tot_bp" >> "$stats_file"
echo -e "GC_content_pct\t$gc_pct" >> "$stats_file"

log_info "Basi totali: ${tot_bp} bp, GC content: ${gc_pct}%"

# ─── Step 4: Report finale ────────────────────────────────────

log_info "Step 4: Generazione report"

report="$OUTPUT_DIR/report.txt"
cat > "$report" << EOF
=== REPORT PIPELINE FASTA ===
Data:              $(date '+%Y-%m-%d %H:%M:%S')
Input:             $INPUT
Output:            $OUTPUT_DIR

--- QC e Filtraggio ---
Sequenze input:    $n_totale
Filtrate (length): $n_filtrate
Sequenze output:   $n_passate
Parametro usato:   lunghezza >= ${MIN_LEN} bp

--- Statistiche sequenze output ---
Basi totali:       ${tot_bp} bp
GC content:        ${gc_pct}%

--- File prodotti ---
filtered.fasta     sequenze che superano il QC
stats.tsv          statistiche in formato tabellare
pipeline.log       log completo dell'esecuzione
report.txt         questo file
EOF

log_info "=== Pipeline completata ==="
log_info "File prodotti in: $OUTPUT_DIR"
$VERBOSE && cat "$report" >&2 || true

exit 0
```

### Eseguire e verificare la pipeline

```bash
# Esecuzione base
./fasta_pipeline.sh -i sequenze.fasta -o results/

# Con tutti i parametri
./fasta_pipeline.sh -i sequenze.fasta -o results/ -m 300 -n 5 -v

# Controllare l'exit code
echo "Exit code: $?"

# Leggere il log
cat results/pipeline.log

# Verificare il report
cat results/report.txt
```

### Rendere la pipeline riproducibile

Una pipeline production-ready include sempre:

```bash
# Versione degli strumenti usati nel log
log_info "bash: $(bash --version | head -1)"
log_info "grep: $(grep --version | head -1)"

# Commit git se disponibile
if git rev-parse --is-inside-work-tree &>/dev/null; then
    log_info "git commit: $(git rev-parse --short HEAD)"
fi

# Parametri completi salvati nel log
log_info "Parametri: INPUT=$INPUT MIN_LEN=$MIN_LEN MIN_SEQ=$MIN_SEQ"
```

---

## Key Takeaways

**BASH:**
- `set -euo pipefail` — obbligatorio in ogni script serio; `-e` ferma su errore, `-u` ferma su variabile non definita, `pipefail` ferma se fallisce qualcosa in una pipe
- `trap cleanup EXIT` — pulisce sempre, anche in caso di errore; `$LINENO` nel trap per localizzare il fallimento
- `log()` con timestamp e livello scritto su stderr + file — fondamentale per il debugging di pipeline lunghe
- `shellcheck` — eseguilo prima di deployare qualsiasi script
- `set -x` / `bash -x` — debug in trace mode per vedere ogni comando eseguito

**Bioinformatica:**
- Una pipeline production-ready segue sempre: validazione input → QC → elaborazione → analisi → report
- I file temporanei vanno in `mktemp -d` e vengono rimossi dal trap `EXIT`
- Il log deve contenere parametri, versioni degli strumenti, e il commit git — per la riproducibilità
- L'output strutturato (TSV per dati, TXT per report leggibili) permette di integrare la pipeline in workflow più grandi (Snakemake, Nextflow, CWL)

---

## Congratulazioni — hai completato il corso!

Hai imparato a:
- Navigare e manipolare il filesystem da terminale
- Usare variabili, condizionali, loop e funzioni
- Lavorare con I/O, redirect e pipe
- Parsare FASTA, GFF3, BED e BLAST tabular
- Scrivere script con interfaccia CLI professionale
- Costruire pipeline robuste e riproducibili

Il passo successivo naturale è **Rosalind.info** per problemi di bioinformatica di crescente complessità, e **shellcheck + ShellSpec** per testing automatizzato dei tuoi script.

→ Completa l'esercizio finale: [exercises/ex-10-best-practice-pipeline.md](exercises/ex-10-best-practice-pipeline.md)
