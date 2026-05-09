# Modulo 7: Script robusti | Pipeline da riga di comando

## Obiettivo
Scrivere script BASH con un'interfaccia CLI professionale — argomenti, opzioni, messaggi di uso, exit code appropriati — come i tool bioinformatici reali.

## Prerequisiti
- Moduli 1–6: comandi base, variabili, I/O, condizionali, loop, funzioni

---

## Parte 1 — BASH: Script robusti

### Lo shebang

La prima riga di ogni script dovrebbe essere:

```bash
#!/usr/bin/env bash
```

`/usr/bin/env bash` trova `bash` nel PATH dell'utente, il che rende lo script portabile su sistemi dove bash non è in `/bin/bash` (macOS con Homebrew, alcuni server).

### Argomenti posizionali

Quando esegui `./myscript.sh input.fasta output.txt 10`, dentro lo script:

| Variabile | Valore |
|---|---|
| `$0` | `./myscript.sh` (nome dello script) |
| `$1` | `input.fasta` |
| `$2` | `output.txt` |
| `$3` | `10` |
| `$#` | `3` (numero di argomenti) |
| `$@` | tutti gli argomenti come lista separata |

**Validare gli argomenti obbligatori:**

```bash
#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo "Uso: $0 <input.fasta> <output.txt>" >&2
    exit 1
fi

input="$1"
output="$2"
```

Usa `exit 1` (o qualsiasi valore ≠ 0) per segnalare errore, `exit 0` per successo.

---

### Messaggi di uso (usage)

Ogni script professionale ha una funzione `usage()`:

```bash
usage() {
    echo "Uso: $(basename "$0") [OPZIONI] <input.fasta>"
    echo ""
    echo "Filtra le sequenze di un file FASTA per lunghezza minima."
    echo ""
    echo "Opzioni:"
    echo "  -o FILE     file di output (default: stdout)"
    echo "  -m NUM      lunghezza minima in bp (default: 100)"
    echo "  -h          mostra questo aiuto"
    echo ""
    echo "Esempio:"
    echo "  $(basename "$0") -m 200 -o filtrate.fasta sequenze.fasta"
}
```

Questa funzione va chiamata quando l'utente passa `-h` o quando gli argomenti sono sbagliati.

---

### getopts — parsing delle opzioni

`getopts` è lo strumento BASH standard per parsare opzioni in stile Unix (`-o`, `-m NUM`, ecc.):

```bash
#!/usr/bin/env bash

output=""
min_len=100

while getopts "o:m:h" opt; do
    case "$opt" in
        o) output="$OPTARG" ;;
        m) min_len="$OPTARG" ;;
        h) usage; exit 0 ;;
        ?) usage; exit 1 ;;
    esac
done

shift $(( OPTIND - 1 ))   # rimuove le opzioni già parsate, lascia gli argomenti posizionali
```

**Come funziona la stringa delle opzioni:**
- `"o:m:h"` — `o` e `m` hanno i due punti (richiedono un argomento), `h` no
- `$OPTARG` — il valore dell'argomento dell'opzione corrente
- `shift $(( OPTIND - 1 ))` — dopo il loop, `$1` sarà il primo argomento non-opzione

Dopo `shift`, puoi accedere agli argomenti posizionali normalmente:

```bash
input_file="$1"
if [ -z "$input_file" ]; then
    echo "Errore: file di input mancante" >&2
    usage
    exit 1
fi
```

---

### Exit code e `$?`

Ogni comando restituisce un exit code. `0` = successo, qualsiasi altro valore = errore.

```bash
grep "^>" "$file"
if [ "$?" -ne 0 ]; then
    echo "Nessun header trovato in $file" >&2
    exit 1
fi
```

Forma più compatta (idiomatica):

```bash
if ! grep -q "^>" "$file"; then
    echo "Nessun header trovato in $file" >&2
    exit 1
fi
```

**Exit code convenzionali:**
- `0` — successo
- `1` — errore generico
- `2` — uso scorretto (argomenti sbagliati)
- `126` — comando non eseguibile
- `127` — comando non trovato

---

### Struttura completa di uno script professionale

```bash
#!/usr/bin/env bash

# --- Funzioni ---

usage() {
    echo "Uso: $(basename "$0") [OPZIONI] <input.fasta>"
    echo "  -o FILE     output (default: stdout)"
    echo "  -m NUM      lunghezza minima bp (default: 100)"
    echo "  -h          aiuto"
}

# --- Parsing delle opzioni ---

output=""
min_len=100

while getopts "o:m:h" opt; do
    case "$opt" in
        o) output="$OPTARG" ;;
        m) min_len="$OPTARG" ;;
        h) usage; exit 0 ;;
        ?) usage >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

# --- Validazione argomenti ---

input="$1"
if [ -z "$input" ]; then
    echo "Errore: file di input mancante" >&2
    usage >&2
    exit 2
fi

if [ ! -f "$input" ]; then
    echo "Errore: file non trovato: $input" >&2
    exit 1
fi

# --- Logica principale ---

# Se output è vuoto, usa stdout
exec_output() {
    if [ -n "$output" ]; then
        "$@" > "$output"
    else
        "$@"
    fi
}

# ... corpo dello script ...

exit 0
```

---

## Parte 2 — Bioinformatica: Pipeline da riga di comando

### Perché un'interfaccia CLI professionale?

Tool come `samtools`, `bedtools`, `seqkit` hanno tutti la stessa struttura: opzioni con flag, messaggio di uso, exit code precisi. Questo non è solo estetica — è quello che permette di **comporre tool in pipeline**:

```bash
fasta_filter.sh -m 200 input.fasta | fasta_stats.sh -o report.tsv
```

Se uno script stampa errori su stdout invece di stderr, o esce con codice 0 anche in caso di errore, la pipeline produce silenziosamente risultati sbagliati.

### Esempio completo: `fasta_filter.sh`

```bash
#!/usr/bin/env bash
# fasta_filter.sh — filtra sequenze FASTA per lunghezza minima

usage() {
    echo "Uso: $(basename "$0") [OPZIONI] <input.fasta>"
    echo ""
    echo "Filtra le sequenze più corte di una soglia minima."
    echo ""
    echo "Opzioni:"
    echo "  -m NUM   lunghezza minima in bp (default: 100)"
    echo "  -o FILE  file di output (default: stdout)"
    echo "  -v       verbose: mostra quante sequenze sono state filtrate"
    echo "  -h       mostra questo aiuto"
    echo ""
    echo "Esempio:"
    echo "  $(basename "$0") -m 500 -o long_seqs.fasta genome.fasta"
}

min_len=100
output=""
verbose=false

while getopts "m:o:vh" opt; do
    case "$opt" in
        m) min_len="$OPTARG" ;;
        o) output="$OPTARG" ;;
        v) verbose=true ;;
        h) usage; exit 0 ;;
        ?) usage >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

input="$1"
if [ -z "$input" ]; then
    echo "Errore: file di input mancante" >&2
    usage >&2
    exit 2
fi
if [ ! -f "$input" ]; then
    echo "Errore: file non trovato: $input" >&2
    exit 1
fi

# Redirect dell'output
if [ -n "$output" ]; then
    exec > "$output"
fi

# Filtraggio
totale=0
passate=0
seq=""
header=""

while IFS= read -r riga; do
    if [[ "$riga" == ">"* ]]; then
        # Processa la sequenza precedente (se c'è)
        if [ -n "$header" ]; then
            (( totale++ ))
            len=${#seq}
            if [ "$len" -ge "$min_len" ]; then
                echo "$header"
                echo "$seq"
                (( passate++ ))
            fi
        fi
        header="$riga"
        seq=""
    else
        seq+="$riga"
    fi
done < "$input"

# Processa l'ultima sequenza
if [ -n "$header" ]; then
    (( totale++ ))
    len=${#seq}
    if [ "$len" -ge "$min_len" ]; then
        echo "$header"
        echo "$seq"
        (( passate++ ))
    fi
fi

if $verbose; then
    echo "Sequenze totali:  $totale" >&2
    echo "Sequenze passate: $passate" >&2
    echo "Sequenze filtrate: $(( totale - passate ))" >&2
fi

exit 0
```

### Usarlo in una pipeline

```bash
# Usa direttamente
./fasta_filter.sh -m 300 -v -o filtrate.fasta genoma.fasta

# In una pipeline
./fasta_filter.sh -m 300 genoma.fasta | grep -c "^>"

# Concatenare due filtri
./fasta_filter.sh -m 100 raw.fasta | ./fasta_filter.sh -m 500 > long_seqs.fasta
```

### Controllare gli exit code nelle pipeline

```bash
./fasta_filter.sh -m 300 input.fasta > output.fasta
if [ "$?" -ne 0 ]; then
    echo "Filtraggio fallito. Pipeline interrotta." >&2
    exit 1
fi
```

---

## Key Takeaways

**BASH:**
- `#!/usr/bin/env bash` — shebang portabile, sempre presente
- `getopts "o:m:h" opt` — parsing standard delle opzioni; `:` dopo la lettera = richiede argomento
- `shift $(( OPTIND - 1 ))` — rimuove le opzioni parsate, espone gli argomenti posizionali
- `exit 0/1/2` — 0 successo, 1 errore logico, 2 uso scorretto
- Errori su `stderr` (`>&2`), dati su `stdout` — principio fondamentale di composizione

**Bioinformatica:**
- Un'interfaccia CLI con `-m`, `-o`, `-h` è lo standard de facto per i tool bioinformatici
- Separare stderr da stdout permette di usare lo script nelle pipeline senza inquinare i dati
- Il flag `-v` (verbose) per informazioni diagnostiche su stderr è un pattern comune (es. `samtools`, `bwa`)
- Script che terminano con exit code precisi possono essere integrati in workflow manager come Snakemake e Nextflow

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-07-script-pipeline.md](exercises/ex-07-script-pipeline.md)
→ Poi vai a: [module-08-stringhe-sequenze.md](module-08-stringhe-sequenze.md)
