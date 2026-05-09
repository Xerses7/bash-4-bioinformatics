# Modulo 8: Stringhe e array | Manipolazione diretta di sequenze

## Obiettivo
Padroneggiare la manipolazione di stringhe e gli array in BASH, e usarli per parsing FASTA puro, calcolo del GC content e analisi della composizione nucleotidica — senza strumenti esterni.

## Prerequisiti
- Moduli 1–7: comandi base, variabili, I/O, condizionali, loop, funzioni, script

---

## Parte 1 — BASH: Stringhe e array

### Manipolazione di stringhe con Parameter Expansion

BASH offre un sistema potente di manipolazione delle stringhe senza bisogno di `sed` o `awk`.

#### Lunghezza di una stringa

```bash
seq="ATGCGATCGA"
echo "${#seq}"   # 10
```

#### Sottostringa

```bash
seq="ATGCGATCGA"
echo "${seq:0:3}"    # ATG — 3 caratteri da posizione 0
echo "${seq:4}"      # GATCGA — dalla posizione 4 alla fine
echo "${seq: -3}"    # CGA — ultimi 3 caratteri (nota lo spazio prima del -)
```

#### Rimozione di prefissi e suffissi

```bash
file="homo_sapiens.fasta"
echo "${file%.fasta}"        # homo_sapiens — rimuove suffisso (greedy a destra)
echo "${file%.*}"            # homo_sapiens — rimuove tutto dopo l'ultimo punto
echo "${file#homo_}"         # sapiens.fasta — rimuove prefisso
echo "${file##*/}"           # solo il nome file (come basename)
```

| Sintassi | Significato |
|---|---|
| `${var%pattern}` | Rimuove il match più corto da destra |
| `${var%%pattern}` | Rimuove il match più lungo da destra |
| `${var#pattern}` | Rimuove il match più corto da sinistra |
| `${var##pattern}` | Rimuove il match più lungo da sinistra |

#### Sostituzione di caratteri

```bash
seq="ATGCN-ATCG"
echo "${seq/N/A}"      # sostituisce prima occorrenza di N con A
echo "${seq//N/}"      # rimuove tutte le N
echo "${seq//-/}"      # rimuove tutti i trattini
```

#### Conversione maiuscolo/minuscolo

```bash
seq="atgcatgc"
echo "${seq^^}"    # ATGCATGC — tutto maiuscolo
echo "${seq,,}"    # atgcatgc — tutto minuscolo (utile per normalizzare input)

seq="ATGCATGC"
echo "${seq,}"     # aTGCATGC — solo il primo carattere minuscolo
echo "${seq^}"     # ATGCATGC — solo il primo carattere maiuscolo
```

---

### Array indicizzati

```bash
# Dichiarazione
specie=("homo_sapiens" "mus_musculus" "danio_rerio")

# Accesso per indice (inizia da 0)
echo "${specie[0]}"    # homo_sapiens
echo "${specie[2]}"    # danio_rerio

# Tutti gli elementi
echo "${specie[@]}"    # homo_sapiens mus_musculus danio_rerio

# Numero di elementi
echo "${#specie[@]}"   # 3

# Aggiungere un elemento
specie+=("rattus_norvegicus")

# Iterare
for s in "${specie[@]}"; do
    echo "$s"
done
```

**Importante:** usa sempre `"${array[@]}"` con le virgolette per gestire correttamente elementi con spazi.

---

### Array associativi (dizionari)

```bash
# Dichiarazione esplicita obbligatoria
declare -A gc_content

# Assegnazione
gc_content["homo_sapiens"]=41
gc_content["mus_musculus"]=42
gc_content["danio_rerio"]=36

# Accesso
echo "${gc_content["homo_sapiens"]}"   # 41

# Tutte le chiavi
echo "${!gc_content[@]}"

# Tutti i valori
echo "${gc_content[@]}"

# Iterare su chiave-valore
for specie in "${!gc_content[@]}"; do
    echo "$specie: ${gc_content[$specie]}%"
done
```

---

### Dividere una stringa in un array

```bash
# Con IFS (Internal Field Separator)
header=">NM_001301717.2 Homo sapiens BRCA1 mRNA"
IFS=' ' read -ra campi <<< "$header"
echo "${campi[0]}"   # >NM_001301717.2
echo "${campi[1]}"   # Homo
echo "${campi[2]}"   # sapiens
```

---

## Parte 2 — Bioinformatica: Analisi di sequenze in puro BASH

### Parsing FASTA a mano

Il ciclo di lettura FASTA fondamentale in BASH: accumula la sequenza riga per riga, poi la processa quando trovi il prossimo header.

```bash
#!/usr/bin/env bash

parse_fasta() {
    local file="$1"
    local header=""
    local seq=""

    while IFS= read -r riga; do
        if [[ "$riga" == ">"* ]]; then
            # Processa la sequenza precedente
            if [ -n "$header" ]; then
                processa "$header" "$seq"
            fi
            header="$riga"
            seq=""
        else
            seq+="${riga}"
        fi
    done < "$file"

    # Non dimenticare l'ultima sequenza
    if [ -n "$header" ]; then
        processa "$header" "$seq"
    fi
}

processa() {
    local header="$1"
    local seq="$2"
    echo "Header: $header"
    echo "Lunghezza: ${#seq} bp"
}
```

### Calcolo del GC content

```bash
gc_content() {
    local seq="${1^^}"   # normalizza in maiuscolo

    local totale=${#seq}
    if [ "$totale" -eq 0 ]; then
        echo 0
        return
    fi

    # Conta G e C rimuovendo tutto il resto e misurando ciò che rimane
    local solo_gc="${seq//[^GC]/}"
    local n_gc=${#solo_gc}

    # Percentuale con decimali via awk
    awk -v gc="$n_gc" -v tot="$totale" 'BEGIN { printf "%.1f\n", gc/tot*100 }'
}

seq="ATGCGCATGCGCATG"
echo "GC content: $(gc_content "$seq")%"   # 53.3%
```

La chiave: `${seq//[^GC]/}` rimuove tutto ciò che non è G o C — quanto rimane sono solo G e C, e `${#...}` ne conta la lunghezza.

### Reverse complement

```bash
reverse_complement() {
    local seq="${1^^}"
    local rev_comp=""

    # Reverse: leggi la stringa al contrario
    local rev=""
    local len=${#seq}
    for (( i=len-1; i>=0; i-- )); do
        rev+="${seq:$i:1}"
    done

    # Complemento
    for (( i=0; i<${#rev}; i++ )); do
        local base="${rev:$i:1}"
        case "$base" in
            A) rev_comp+="T" ;;
            T) rev_comp+="A" ;;
            G) rev_comp+="C" ;;
            C) rev_comp+="G" ;;
            N) rev_comp+="N" ;;
            *) rev_comp+="$base" ;;
        esac
    done

    echo "$rev_comp"
}

seq="ATGCTAGC"
echo "Originale:        $seq"
echo "Rev complement:   $(reverse_complement "$seq")"
# Risultato: GCTAGCAT
```

### Composizione nucleotidica con array associativo

```bash
composizione() {
    local seq="${1^^}"
    declare -A conta

    for base in A T G C N; do
        conta[$base]=0
    done

    for (( i=0; i<${#seq}; i++ )); do
        local b="${seq:$i:1}"
        if [[ -v conta[$b] ]]; then
            (( conta[$b]++ ))
        fi
    done

    local tot=${#seq}
    echo "A: ${conta[A]} ($(awk -v n="${conta[A]}" -v t="$tot" 'BEGIN{printf "%.1f", n/t*100}')%)"
    echo "T: ${conta[T]} ($(awk -v n="${conta[T]}" -v t="$tot" 'BEGIN{printf "%.1f", n/t*100}')%)"
    echo "G: ${conta[G]} ($(awk -v n="${conta[G]}" -v t="$tot" 'BEGIN{printf "%.1f", n/t*100}')%)"
    echo "C: ${conta[C]} ($(awk -v n="${conta[C]}" -v t="$tot" 'BEGIN{printf "%.1f", n/t*100}')%)"
    echo "N: ${conta[N]}"
}
```

### Quando usare BASH puro vs strumenti dedicati

| Operazione | BASH puro | Strumento dedicato |
|---|---|---|
| Contare sequenze | `grep -c "^>"` | `seqkit stats` |
| GC content su pochi file | Ok con le funzioni sopra | `seqkit fx2tab -g` |
| GC content su genomi interi | Lento | `seqkit`, `biopython` |
| Reverse complement | Ok per singole sequenze | `seqkit seq -r -p` |
| Parsing FASTA complesso | Fragile | BioPython, seqkit |

BASH puro è ottimo per imparare il funzionamento interno e per operazioni semplici. Su dataset grandi (milioni di sequenze), usa strumenti dedicati.

---

## Key Takeaways

**BASH:**
- `${#var}` — lunghezza; `${var:pos:len}` — sottostringa; `${var//pattern/repl}` — sostituzione globale
- `${var%suf}` / `${var#pre}` — rimozione di suffisso/prefisso (utile per estensioni file)
- `${var^^}` / `${var,,}` — conversione maiuscolo/minuscolo
- Array: `arr=(a b c)`, accesso `${arr[i]}`, tutti `"${arr[@]}"`, lunghezza `${#arr[@]}`
- `declare -A dict` — array associativo; chiavi con `${!dict[@]}`

**Bioinformatica:**
- Il loop di parsing FASTA accumula la sequenza riga per riga e la processa all'header successivo — non dimenticare l'ultima sequenza dopo il loop
- GC content: rimuovi tutto ciò che non è G/C con `${seq//[^GC]/}` e misura la lunghezza
- Il reverse complement richiede due passi: inversione della stringa, poi sostituzione base per base
- BASH puro è utile per singole sequenze e per capire gli algoritmi; per dataset grandi, delegare a seqkit o BioPython

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-08-stringhe-sequenze.md](exercises/ex-08-stringhe-sequenze.md)
→ Poi vai a: [module-09-grep-sed-awk-formati.md](module-09-grep-sed-awk-formati.md)
