# Esercizio 7: Script CLI per filtraggio FASTA

## Modulo correlato
[module-07-script-pipeline.md](../module-07-script-pipeline.md)

## Difficoltà
Medium / Hard

---

## Scenario

Un collaboratore ti ha inviato un file FASTA con sequenze di lunghezze molto variabili. Hai bisogno di uno script con interfaccia CLI professionale che filtri le sequenze per lunghezza minima, con opzioni per il file di output e una modalità verbose — qualcosa che potresti condividere con chiunque nel laboratorio.

---

## Setup — crea i file di test

```bash
mkdir -p cli_test/data

cat > cli_test/data/mixed_lengths.fasta << 'EOF'
>SEQ001 sequenza molto corta
ATGC
>SEQ002 sequenza media
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
>SEQ003 sequenza lunga
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
>SEQ004 sequenza brevissima
AT
>SEQ005 sequenza media-lunga
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
ATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGAATGCGATCGA
EOF
```

---

## Task

Scrivi uno script `cli_test/fasta_filter.sh` con questa interfaccia:

```
Uso: fasta_filter.sh [OPZIONI] -i <input.fasta>

Filtra le sequenze FASTA per lunghezza minima.

Opzioni:
  -i FILE   file FASTA di input (obbligatorio)
  -o FILE   file di output (default: stdout)
  -m NUM    lunghezza minima in bp (default: 50)
  -v        verbose: mostra statistiche su stderr
  -h        mostra questo aiuto ed esce
```

Lo script deve:

1. **Parsare le opzioni** con `getopts`
2. **Validare l'input:** `-i` è obbligatorio, il file deve esistere e contenere almeno un header `>`
3. **Filtrare le sequenze** che hanno lunghezza `>= MIN_LEN`
4. **Stampare le sequenze filtrate** su stdout (o su file se `-o` è specificato)
5. **In modalità verbose** (`-v`), stampare su stderr:
   - Numero totale di sequenze nel file
   - Numero di sequenze che superano il filtro
   - Numero di sequenze filtrate
6. **Uscire con exit code** 0 se almeno una sequenza supera il filtro, 1 se nessuna la supera

### Comportamento atteso

```bash
# Test base: solo sequenze >= 50 bp su stdout
./cli_test/fasta_filter.sh -i cli_test/data/mixed_lengths.fasta

# Con verbose: statistiche su stderr, sequenze su stdout
./cli_test/fasta_filter.sh -i cli_test/data/mixed_lengths.fasta -v

# Con output su file
./cli_test/fasta_filter.sh -i cli_test/data/mixed_lengths.fasta -o cli_test/filtered.fasta -v

# Con soglia diversa
./cli_test/fasta_filter.sh -i cli_test/data/mixed_lengths.fasta -m 200 -v

# Aiuto
./cli_test/fasta_filter.sh -h

# Verifica exit code: deve essere 0 se ci sono sequenze, 1 se non ce ne sono
./cli_test/fasta_filter.sh -i cli_test/data/mixed_lengths.fasta -m 9999; echo "Exit: $?"
```

---

## Requisiti

- [ ] Shebang `#!/usr/bin/env bash`
- [ ] Funzione `usage()` che stampa le istruzioni d'uso
- [ ] `getopts` per parsare le opzioni
- [ ] `shift $(( OPTIND - 1 ))` dopo il loop di getopts (anche se non ci sono argomenti posizionali)
- [ ] Validazione che `-i` sia fornito (errore su stderr + exit 2)
- [ ] Validazione che il file esista (errore su stderr + exit 1)
- [ ] Output su stdout di default, su file con `-o`
- [ ] Statistiche verbose su **stderr** (non stdout!)
- [ ] Exit code 0 se almeno una sequenza passa, 1 se nessuna

---

## Hints

<details>
<summary>Hint 1 — struttura getopts</summary>

```bash
input=""
output=""
min_len=50
verbose=false

while getopts "i:o:m:vh" opt; do
    case "$opt" in
        i) input="$OPTARG" ;;
        o) output="$OPTARG" ;;
        m) min_len="$OPTARG" ;;
        v) verbose=true ;;
        h) usage; exit 0 ;;
        ?) usage >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))
```

</details>

<details>
<summary>Hint 2 — filtraggio con il loop di parsing FASTA</summary>

Per filtrare le sequenze per lunghezza devi fare il parsing del FASTA come nel modulo 8: accumula la sequenza riga per riga, e quando trovi il prossimo header (o la fine del file) decidi se stampare quella precedente.

```bash
header=""
seq=""
n_passate=0
n_totale=0

while IFS= read -r riga; do
    if [[ "$riga" == ">"* ]]; then
        if [ -n "$header" ]; then
            (( n_totale++ ))
            if [ "${#seq}" -ge "$min_len" ]; then
                echo "$header"
                echo "$seq"
                (( n_passate++ ))
            fi
        fi
        header="$riga"
        seq=""
    else
        seq+="$riga"
    fi
done < "$input"
# Non dimenticare l'ultima sequenza!
```

</details>

<details>
<summary>Hint 3 — redirect dell'output su file o stdout</summary>

Il modo più pulito è redirigere `exec` all'inizio:

```bash
if [ -n "$output" ]; then
    exec > "$output"
fi
# Da qui in poi, qualsiasi echo va nel file (o stdout se -o non era specificato)
```

Oppure puoi usare una variabile per accumulare l'output e scriverlo alla fine — ma exec è più semplice e idiomatico.

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

1. **Shebang + defaults**: `input=""`, `output=""`, `min_len=50`, `verbose=false`
2. **`usage()`**: stampa le istruzioni con `cat << EOF ... EOF`
3. **Parsing con getopts**: loop su `"i:o:m:vh"`, `case` per ogni opzione
4. **Validazione**: controlla che `$input` non sia vuoto (exit 2), che il file esista (exit 1), che contenga header `>`
5. **Redirect output**: se `$output` non è vuoto, `exec > "$output"`
6. **Loop di filtraggio**: parsing FASTA riga per riga, accumula `$seq`, stampa se `${#seq} >= $min_len`
7. **Ricorda l'ultima sequenza** dopo il loop
8. **Verbose**: se `$verbose` è `true`, stampa le statistiche su stderr con `>&2`
9. **Exit code**: `[ "$n_passate" -gt 0 ]` — exit 0 se ci sono sequenze, exit 1 altrimenti

La parte più delicata è il redirect dell'output: decidi se usare `exec >` (redirect tutto lo stdout) o wrappare gli `echo` in una condizione. `exec >` è più pulito.

</details>
