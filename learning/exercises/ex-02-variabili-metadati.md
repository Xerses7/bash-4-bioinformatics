# Esercizio 2: Variabili e metadati FASTA

## Modulo di riferimento
[module-02-variabili-metadati.md](../module-02-variabili-metadati.md)

## Difficoltà
Facile-Medio

## Scenario
Stai preparando un'analisi comparativa di sequenze HSP70 tra specie diverse. Devi scrivere un piccolo script che, dato un file FASTA come argomento, stampi un report con i metadati principali e generi automaticamente un nome di file di output standardizzato.

## Setup
Usa il file `hsp70.fasta` creato nell'esercizio 1. Se non ce l'hai, ricrealo:

```bash
cat > hsp70.fasta << 'EOF'
>NP_005339.2 heat shock protein family A member 1A [Homo sapiens]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAKNQVAMNPTNTVFDAK
RLIGRKFGDPVVQSDMKHWPFQVVNDAGRPKVQVEYKGEEKSTGASIELDSSGKLLTKVNSIFEFLKKNN
>NP_006588.1 heat shock protein family A member 8 [Homo sapiens]
MSKGPAVGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAKNQVALNPQNTVFDAK
RLIGRKFGDPVIQSDMKHWPFQVINDAGRPKVQVEYKGEEKSTGASIELDSSGKLLTKVNSIFEELKANKN
>NP_031381.2 heat shock protein 1 [Mus musculus]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAKNQVAMNPTNTVFDAK
RLIGRKFGDPVVQSDMKHWPFQVVNDAGRPKVQVEYKGEEKSTGASIELDSSGKLLTKVNSIFEFLKKNN
>sp|P11142|HSP7C_HUMAN heat shock cognate 71 kDa protein [Homo sapiens]
MSKGPAVGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAKNQVALNPQNTVFDAK
EOF
```

## Task

Scrivi uno script `report_fasta.sh` che:

1. Accetta il percorso del file FASTA come **primo argomento** (`$1`)
2. Salva il percorso in una variabile `input`
3. Conta le sequenze e salva il risultato in `n_seq`
4. Conta le righe totali e salva in `n_righe`
5. Estrae il **primo header** (senza il `>` iniziale) in `primo_id`
6. Genera il nome del file di output come `<nome_base>_analisi.txt` — dove il nome base viene estratto automaticamente dal nome del file input (senza estensione e senza percorso)
7. Stampa questo report:

```
=== Report FASTA ===
File:        hsp70.fasta
Sequenze:    4
Righe:       9
Prima seq:   NP_005339.2 heat shock protein family A member 1A [Homo sapiens]
Output:      hsp70_analisi.txt
```

Esegui lo script con:
```bash
bash report_fasta.sh hsp70.fasta
```

## Requirements
- [ ] Usare `$1` per ricevere il file come argomento
- [ ] Usare almeno 4 variabili con nomi descrittivi
- [ ] Usare command substitution `$(...)` per almeno 3 valori
- [ ] Il nome dell'output deve essere generato **automaticamente** dal nome del file input — non scritto a mano
- [ ] Il report deve essere formattato come nell'esempio sopra

## Hints

<details>
<summary>Hint 1</summary>

Per estrarre il nome base senza estensione:
```bash
nome_base=$(basename "$input" .fasta)
```
`basename` rimuove il percorso. Con il secondo argomento `.fasta` rimuove anche l'estensione.

</details>

<details>
<summary>Hint 2</summary>

Per togliere il `>` dall'header puoi usare `sed 's/^>//'` — rimuove il carattere `>` a inizio riga (`^` = inizio, `s/vecchio/nuovo/` = sostituisci):

```bash
primo_id=$(grep "^>" "$input" | head -1 | sed 's/^>//')
```

</details>

## Solution Outline

<details>
<summary>Mostra soluzione</summary>

Struttura dello script (implementa tu i dettagli):

```bash
#!/bin/bash

input=$1

# Estrai il nome base senza estensione
nome_base=$(basename "$input" .fasta)

# Conta sequenze e righe
n_seq=$(grep -c "^>" "$input")
n_righe=$(wc -l < "$input")

# Estrai il primo header (senza >)
primo_id=$(grep "^>" "$input" | head -1 | sed 's/^>//')

# Costruisci il nome output
output="${nome_base}_analisi.txt"

# Stampa il report
echo "=== Report FASTA ==="
echo "File:        $input"
echo "Sequenze:    $n_seq"
echo "Righe:       $n_righe"
echo "Prima seq:   $primo_id"
echo "Output:      $output"
```

</details>
