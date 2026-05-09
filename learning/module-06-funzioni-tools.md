# Modulo 6: Funzioni | Strumenti riutilizzabili per sequenze

## Obiettivo
Imparare a definire e usare funzioni BASH per incapsulare operazioni ripetute, e costruire una libreria di strumenti riutilizzabili per analizzare file FASTA.

## Prerequisiti
- Moduli 1–5: comandi base, variabili, I/O, pipe, condizionali, loop

---

## Parte 1 — BASH: Funzioni

### Definire una funzione

```bash
nome_funzione() {
    # corpo della funzione
    comando1
    comando2
}
```

Oppure con la sintassi esplicita (equivalente):

```bash
function nome_funzione {
    # corpo della funzione
}
```

La funzione deve essere **definita prima** di essere chiamata. Puoi chiamarla come un qualsiasi comando:

```bash
saluta() {
    echo "Ciao, mondo!"
}

saluta   # chiamata
```

---

### Argomenti di una funzione

All'interno di una funzione, gli argomenti si leggono con `$1`, `$2`, ecc. — esattamente come gli argomenti di uno script.

```bash
saluta_specie() {
    echo "Analisi di: $1"
}

saluta_specie "Homo sapiens"
saluta_specie "Mus musculus"
```

`$#` dentro la funzione conta gli argomenti passati alla funzione (non allo script).

---

### Valori di ritorno

BASH distingue due concetti:

**1. Exit code** — un numero intero (0 = successo, ≠ 0 = errore). Si imposta con `return`:

```bash
file_valido() {
    [ -s "$1" ] && return 0 || return 1
}

if file_valido "sequenze.fasta"; then
    echo "File OK"
fi
```

**2. Output di testo** — si usa `echo` dentro la funzione e si cattura con `$()`:

```bash
conta_sequenze() {
    grep -c "^>" "$1"
}

n=$(conta_sequenze "sequenze.fasta")
echo "Trovate $n sequenze"
```

Questa è la distinzione più importante: `return` è per il codice di uscita, `echo` è per i dati.

---

### Scope delle variabili

Per default, le variabili in BASH sono **globali**. Una variabile creata dentro una funzione è visibile fuori:

```bash
imposta() {
    risultato="42"
}
imposta
echo "$risultato"   # stampa 42
```

Per limitare una variabile alla funzione, usa `local`:

```bash
calcola() {
    local temp=100    # visibile solo dentro calcola()
    echo $(( temp * 2 ))
}
calcola
echo "$temp"   # stringa vuota — temp non esiste qui
```

**Regola pratica:** usa sempre `local` per le variabili interne alle funzioni. Eviti effetti collaterali difficili da trovare.

---

### Funzioni che restituiscono più valori

BASH non ha un modo diretto per restituire più di un valore. Le strategie comuni sono:

**Stampare valori separati** e catturarli con `read`:

```bash
statistiche() {
    local file="$1"
    local n_seq=$(grep -c "^>" "$file")
    local n_char=$(grep -v "^>" "$file" | tr -d '\n' | wc -c)
    echo "$n_seq $n_char"
}

read n_seq n_char <<< "$(statistiche sequenze.fasta)"
echo "Sequenze: $n_seq, Caratteri: $n_char"
```

**Usare variabili globali nominate** (meno elegante, ma semplice):

```bash
_n_seq=0
_n_char=0

statistiche() {
    _n_seq=$(grep -c "^>" "$1")
    _n_char=$(grep -v "^>" "$1" | tr -d '\n' | wc -c)
}

statistiche sequenze.fasta
echo "Sequenze: $_n_seq, Caratteri: $_n_char"
```

---

### Sourcing: condividere funzioni tra script

Se hai un file di funzioni (es. `lib.sh`), puoi importarlo in altri script con `source`:

```bash
source ./lib.sh   # carica le funzioni definite in lib.sh
# oppure: . ./lib.sh   (equivalente)

conta_sequenze "sequenze.fasta"   # funzione definita in lib.sh
```

Questo ti permette di costruire una libreria riutilizzabile.

---

## Parte 2 — Bioinformatica: Libreria di strumenti per FASTA

### Perché le funzioni in bioinformatica?

In una pipeline reale, le stesse operazioni si ripetono decine di volte: contare le sequenze, validare il formato, calcolare la lunghezza media. Scriverle come funzioni in un file `fasta_lib.sh` ti dà:

- Codice leggibile (un nome descrittivo invece di un comando criptico)
- Riusabilità (importi la libreria in ogni script)
- Manutenibilità (correggi il bug in un posto solo)

### Costruire `fasta_lib.sh`

```bash
#!/bin/bash
# fasta_lib.sh — libreria di funzioni per file FASTA

# Conta le sequenze in un file FASTA
# Argomento: $1 = percorso del file
# Output: numero intero su stdout
conta_sequenze() {
    grep -c "^>" "$1"
}

# Verifica che un file sia un FASTA valido (non vuoto, ha header)
# Argomento: $1 = percorso del file
# Return: 0 = valido, 1 = invalido
valida_fasta() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    if [ ! -s "$file" ]; then
        return 1
    fi
    if ! grep -q "^>" "$file"; then
        return 1
    fi
    return 0
}

# Estrae tutti gli header di un file FASTA (senza il carattere >)
# Argomento: $1 = percorso del file
# Output: un header per riga su stdout
estrai_header() {
    grep "^>" "$1" | sed 's/^>//'
}

# Calcola la lunghezza totale delle sequenze (bp)
# Argomento: $1 = percorso del file
# Output: numero intero su stdout
lunghezza_totale() {
    grep -v "^>" "$1" | tr -d '\n[:space:]' | wc -c
}

# Calcola la lunghezza media delle sequenze
# Argomento: $1 = percorso del file
# Output: numero intero (divisione intera) su stdout
lunghezza_media() {
    local file="$1"
    local n=$(conta_sequenze "$file")
    local tot=$(lunghezza_totale "$file")
    if [ "$n" -eq 0 ]; then
        echo 0
        return
    fi
    echo $(( tot / n ))
}

# Stampa un report compatto di un file FASTA
# Argomento: $1 = percorso del file
report_fasta() {
    local file="$1"
    echo "File:            $file"
    if ! valida_fasta "$file"; then
        echo "Stato:           INVALIDO"
        return 1
    fi
    echo "Sequenze:        $(conta_sequenze "$file")"
    echo "Lunghezza tot:   $(lunghezza_totale "$file") bp"
    echo "Lunghezza media: $(lunghezza_media "$file") bp"
    echo "Stato:           OK"
}
```

### Usare la libreria in uno script

```bash
#!/bin/bash
source ./fasta_lib.sh

for file in data/*.fasta; do
    if valida_fasta "$file"; then
        n=$(conta_sequenze "$file")
        echo "OK: $(basename "$file") — $n sequenze"
    else
        echo "FAIL: $(basename "$file") — file non valido"
    fi
done
```

### Pattern avanzato: funzione con validazione degli argomenti

Nelle librerie reali, le funzioni controllano sempre i propri argomenti:

```bash
conta_sequenze() {
    if [ "$#" -ne 1 ]; then
        echo "Errore: conta_sequenze richiede esattamente 1 argomento" >&2
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Errore: file non trovato: $1" >&2
        return 1
    fi
    grep -c "^>" "$1"
}
```

L'output degli errori va su **stderr** (`>&2`), non su stdout — così chi cattura l'output con `$()` non riceve i messaggi di errore mescolati ai dati.

---

## Key Takeaways

**BASH:**
- `nome() { ... }` — definisce una funzione; `$1`, `$2` sono i suoi argomenti
- `return N` — imposta l'exit code; `echo` restituisce dati testuali
- `local var=valore` — variabile locale alla funzione; usala sempre per evitare side effect
- `source file.sh` — importa funzioni da un altro file
- Gli errori vanno su stderr con `>&2`, i dati su stdout

**Bioinformatica:**
- Incapsulare operazioni FASTA in funzioni (`conta_sequenze`, `valida_fasta`, `estrai_header`) rende le pipeline leggibili e manutenibili
- Una `fasta_lib.sh` condivisa tra script evita la duplicazione del codice
- Le funzioni di validazione con `return 0/1` si integrano perfettamente con `if` e `&&`
- La lunghezza media si calcola con aritmetica intera BASH; per i decimali, delega ad `awk`

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-06-funzioni-tools.md](exercises/ex-06-funzioni-tools.md)
→ Poi vai a: [module-07-script-pipeline.md](module-07-script-pipeline.md)
