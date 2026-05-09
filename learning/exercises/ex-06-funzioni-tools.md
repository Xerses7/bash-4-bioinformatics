# Esercizio 6: Libreria di funzioni FASTA

## Modulo correlato
[module-06-funzioni-tools.md](../module-06-funzioni-tools.md)

## Difficoltà
Medium

---

## Scenario

Il tuo laboratorio ha decine di script diversi che fanno tutti le stesse cose: contare sequenze, validare file FASTA, estrarre header. Ogni script ha la sua versione del codice, con bug diversi. È il momento di unificare tutto in una libreria condivisa.

---

## Setup — crea i file di test

```bash
mkdir -p funzioni_test/data

cat > funzioni_test/data/brca1_sequences.fasta << 'EOF'
>NM_007294.4 Homo sapiens BRCA1 mRNA
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
GTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTGTGACCACATATTTTGCAAATTTTG
CCTGTCCAGCCTCCCTAAAAATCTAGGACAAGTTCCAGAAGAAAGAAATCATGAAAACAGCAAAAGCCAC
>NM_007297.4 Homo sapiens BRCA1 isoform delta11b
ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGT
GTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTGTGACCACATATTTTGCAAATTTTG
>NM_007300.4 Homo sapiens BRCA1 isoform 3
ATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTG
EOF

cat > funzioni_test/data/brca2_sequences.fasta << 'EOF'
>NM_000059.4 Homo sapiens BRCA2 mRNA
ATGCCTATTGGATCCAAAGAGAGGCCAACATTTTTTGAAATTTTTAAGACACGCTGCAACAAAGCAGATT
TAGGACCAATAAGTCTTAATTGGTTTGAAGAACTTTCTTCAGAAGCTCCAAAAACTTGTACAAGTTTGCT
>NM_000059.3 Homo sapiens BRCA2 isoform 2
ATGCCTATTGGATCCAAAGAGAGGCCAACATTTTTTGAAATTTTTAAGACACGCTGCAACAAAGCAGATT
EOF

# File non valido — nessun header
cat > funzioni_test/data/invalid.txt << 'EOF'
ATGCTAGCTAGCTAGCTAGCTAGC
GCTAGCTAGCTAGCTAGCTAGCTA
EOF

# File vuoto
> funzioni_test/data/empty.fasta
```

---

## Task

Crea il file `funzioni_test/fasta_lib.sh` contenente le seguenti funzioni:

1. **`conta_sequenze <file>`** — restituisce il numero di sequenze (header `>`) su stdout
2. **`valida_fasta <file>`** — return 0 se il file è un FASTA valido (esiste, non è vuoto, ha almeno un header), return 1 altrimenti
3. **`estrai_header <file>`** — stampa tutti gli header su stdout, senza il carattere `>`
4. **`lunghezza_totale <file>`** — stampa il numero totale di basi (esclusi header e newline)
5. **`lunghezza_media <file>`** — stampa la lunghezza media per sequenza (divisione intera)
6. **`report_fasta <file>`** — stampa un report compatto con tutte le statistiche

Poi crea `funzioni_test/analizza.sh` che:
- Fa il `source` di `fasta_lib.sh`
- Itera su tutti i file in `funzioni_test/data/`
- Per ogni file: se valido, stampa il report; se non valido, stampa un messaggio di errore
- Al termine stampa: quanti file validi e quanti non validi

### Output atteso

```
=== funzioni_test/data/brca1_sequences.fasta ===
File:            funzioni_test/data/brca1_sequences.fasta
Sequenze:        3
Lunghezza tot:   630 bp
Lunghezza media: 210 bp
Stato:           OK

=== funzioni_test/data/brca2_sequences.fasta ===
File:            funzioni_test/data/brca2_sequences.fasta
Sequenze:        2
Lunghezza tot:   280 bp
Lunghezza media: 140 bp
Stato:           OK

=== funzioni_test/data/empty.fasta ===
ERRORE: file non valido: funzioni_test/data/empty.fasta

=== funzioni_test/data/invalid.txt ===
ERRORE: file non valido: funzioni_test/data/invalid.txt

---
Validi: 2  |  Non validi: 2
```

---

## Requisiti

- [ ] Ogni funzione in `fasta_lib.sh` usa `local` per le variabili interne
- [ ] `valida_fasta` usa `return 0/1` (non `echo`)
- [ ] Le funzioni che restituiscono dati usano `echo` (non `return`)
- [ ] `analizza.sh` usa `source` per importare la libreria
- [ ] Gli errori vanno su stderr (`>&2`)
- [ ] `analizza.sh` usa contatori con `(( ))` per il riepilogo finale

---

## Hints

<details>
<summary>Hint 1 — struttura di fasta_lib.sh</summary>

```bash
#!/usr/bin/env bash
# fasta_lib.sh

conta_sequenze() {
    local file="$1"
    grep -c "^>" "$file"
}

valida_fasta() {
    local file="$1"
    # Controlla: esiste? non è vuoto? ha almeno un header?
    [ -f "$file" ] && [ -s "$file" ] && grep -q "^>" "$file"
    # grep -q restituisce 0 se trova qualcosa, 1 altrimenti
    # l'intera espressione con && propaga il return code corretto
}
```

</details>

<details>
<summary>Hint 2 — lunghezza_totale</summary>

Per calcolare la lunghezza totale devi:
1. Escludere le righe header con `grep -v "^>"`
2. Rimuovere i newline con `tr -d '\n'`
3. Contare i caratteri rimasti con `wc -c`

Attenzione: `wc -c` conta anche il newline finale se c'è. `tr -d '\n'` lo rimuove, quindi il conteggio è corretto.

</details>

<details>
<summary>Hint 3 — struttura di analizza.sh</summary>

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/fasta_lib.sh"

validi=0
non_validi=0

for file in funzioni_test/data/*; do
    echo "=== $file ==="
    if valida_fasta "$file"; then
        report_fasta "$file"
        (( validi++ ))
    else
        echo "ERRORE: file non valido: $file" >&2
        (( non_validi++ ))
    fi
    echo ""
done

echo "---"
echo "Validi: $validi  |  Non validi: $non_validi"
```

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

**`fasta_lib.sh`:**
1. `conta_sequenze`: `grep -c "^>" "$1"`
2. `valida_fasta`: catena di test con `&&` — `[ -f ]`, `[ -s ]`, `grep -q "^>"`
3. `estrai_header`: `grep "^>" "$1" | sed 's/^>//'`
4. `lunghezza_totale`: `grep -v "^>" "$1" | tr -d '\n' | wc -c` (attenzione allo spazio prodotto da `wc -c` — usa `echo $(...) ` o `tr -d ' '`)
5. `lunghezza_media`: usa `conta_sequenze` e `lunghezza_totale` internamente, poi `$(( tot / n ))`
6. `report_fasta`: chiama le altre funzioni, stampa le righe, chiama `valida_fasta` per lo stato

**`analizza.sh`:**
- `source "$(dirname "$0")/fasta_lib.sh"` — percorso relativo alla posizione dello script
- Loop `for file in funzioni_test/data/*` — itera su tutti i file
- `if valida_fasta "$file"` — usa l'exit code della funzione direttamente nell'`if`
- Contatori `validi` e `non_validi` con `(( ))`

</details>
