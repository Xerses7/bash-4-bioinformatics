# Esercizio 4: Script di Quality Control per FASTA

## Modulo di riferimento
[module-04-condizionali-qc.md](../module-04-condizionali-qc.md)

## Difficoltà
Medio-Alto

## Scenario
Lavori in un laboratorio dove diversi colleghi caricano file FASTA per un'analisi automatizzata. Prima che un file entri nella pipeline, deve superare un controllo qualità automatico. Scrivi lo script `qc_fasta.sh` che esegue questa verifica.

## Setup
Crea i file di test per i vari casi:

```bash
# File valido con 2 sequenze pulite
printf ">seq1 gene A [Homo sapiens]\nATCGATCGATCG\n>seq2 gene B [Homo sapiens]\nGCTAGCTAGCTA\n" > test_valid.fasta

# File con sequenze che contengono N (ambiguità)
printf ">seq1 gene A\nATCGNNNNATCG\n>seq2 gene B\nGCTAGCTAGCTA\n" > test_n.fasta

# File completamente vuoto
touch test_empty.fasta

# File con una sola sequenza
printf ">seq1 gene A\nATCGATCG\n" > test_single.fasta
```

## Task

Scrivi lo script `qc_fasta.sh` che:

1. Accetta il file FASTA come **primo argomento** (`$1`)
2. Verifica che sia stato passato un argomento — se no, stampa l'uso corretto ed esce:
   ```
   Uso: qc_fasta.sh <file.fasta>
   ```
3. Verifica che il file esista
4. Verifica che il file non sia vuoto
5. Verifica che abbia almeno un header FASTA valido (riga che inizia con `>`)
6. Verifica che il numero di sequenze sia **≥ 2**
7. Controlla se ci sono righe di sequenza contenenti `N` — se sì, stampa un **avviso** (non blocca l'esecuzione)
8. Se tutti i check passano, stampa:
   ```
   QC SUPERATO: 2 sequenze valide in test_valid.fasta
   ```

Testa lo script su tutti e 4 i file di test e verifica che si comporti correttamente:
```bash
bash qc_fasta.sh                    # nessun argomento
bash qc_fasta.sh test_empty.fasta   # file vuoto
bash qc_fasta.sh test_single.fasta  # una sola sequenza
bash qc_fasta.sh test_n.fasta       # sequenze con N (avviso, ma passa)
bash qc_fasta.sh test_valid.fasta   # tutto ok
```

## Requirements
- [ ] Usare `$1` e `[ -z "$1" ]` per il check dell'argomento
- [ ] Ogni check fallisce con `exit 1` e un messaggio che inizia con `ERRORE:`
- [ ] Il check degli `N` stampa `ATTENZIONE:` ma **non** fa `exit 1`
- [ ] Lo script funziona correttamente su tutti e 4 i file di test

## Hints

<details>
<summary>Hint 1</summary>

Per verificare che l'argomento sia stato passato: `[ -z "$1" ]` è vero se la stringa è vuota (zero length). Quindi:
```bash
if [ -z "$1" ]; then
    echo "Uso: $0 <file.fasta>"
    exit 1
fi
```
`$0` è il nome dello script stesso — usarlo nel messaggio d'uso è buona pratica.

</details>

<details>
<summary>Hint 2</summary>

Per il check degli N, il flag `-q` di grep è il tuo amico: non stampa nulla, ma restituisce exit code 0 se trova qualcosa (e 1 se non trova niente). Puoi usarlo direttamente in un `if`:

```bash
if grep -v "^>" "$file" | grep -q "N"; then
    echo "ATTENZIONE: trovate sequenze con caratteri ambigui (N)"
fi
```

`grep -v "^>"` esclude le righe header; `grep -q "N"` cerca N nelle righe di sequenza.

</details>

## Solution Outline

<details>
<summary>Mostra soluzione</summary>

Struttura completa (implementa tu il codice per ogni check):

```bash
#!/bin/bash

# Check 1: argomento passato?
if [ -z "$1" ]; then
    echo "Uso: $0 <file.fasta>"
    exit 1
fi

file="$1"

# Check 2: il file esiste?
if [ ! -f "$file" ]; then
    echo "ERRORE: file non trovato: $file"
    exit 1
fi

# Check 3: il file non è vuoto?
if [ ! -s "$file" ]; then
    echo "ERRORE: il file è vuoto: $file"
    exit 1
fi

# Check 4: ha almeno un header FASTA?
n=$(grep -c "^>" "$file")
if [ "$n" -eq 0 ]; then
    echo "ERRORE: nessun header FASTA trovato in $file"
    exit 1
fi

# Check 5: almeno 2 sequenze?
if [ "$n" -lt 2 ]; then
    echo "ERRORE: il file contiene $n sequenza (minimo richiesto: 2)"
    exit 1
fi

# Check 6 (avviso, non blocca): sequenze con N?
if grep -v "^>" "$file" | grep -q "N"; then
    echo "ATTENZIONE: trovate sequenze con caratteri ambigui (N)"
fi

echo "QC SUPERATO: $n sequenze valide in $file"
```

</details>
