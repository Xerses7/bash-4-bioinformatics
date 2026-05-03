# Modulo 2: Variabili | Metadati delle sequenze

## Obiettivo
Usare variabili BASH per rendere gli script flessibili e riutilizzabili, e capire come i metadati sono codificati negli header FASTA — imparando a estrarli e usarli automaticamente.

## Prerequisiti
- Modulo 1: navigazione filesystem, comandi base, cos'è un file FASTA

---

## Parte 1 — BASH: Variabili

### Dichiarare e usare variabili

In BASH, una variabile è un nome che punta a un valore:

```bash
specie="Homo_sapiens"
gene="BRCA1"

echo $specie          # stampa: Homo_sapiens
echo "$specie"        # preferibile: le virgolette evitano problemi con spazi
echo "${gene}_v2"     # usa {} quando il nome è seguito subito da altro testo → BRCA1_v2
```

**Regole importanti:**
- Nessuno spazio intorno a `=`: `nome=valore` ✅ — `nome = valore` ❌
- Usa sempre le virgolette doppie `"$variabile"` per evitare sorprese con spazi o caratteri speciali

### Tipi di dati

BASH non ha tipi: tutto è stringa. Ma puoi fare aritmetica intera:

```bash
n_sequenze=42
echo $((n_sequenze * 2))      # 84
echo $((n_sequenze + 1))      # 43
```

### Command substitution

La sintassi `$(...)` esegue un comando e cattura il suo output in una variabile:

```bash
n=$(grep -c "^>" sequenze.fasta)
echo "Il file contiene $n sequenze"

data=$(date +%Y-%m-%d)
echo "Analisi del $data"

nome_file=$(basename /percorso/sequenze.fasta)
echo "File: $nome_file"   # sequenze.fasta
```

### Variabili speciali

BASH ha variabili predefinite molto utili negli script:

```bash
$0    # nome dello script stesso
$1    # primo argomento passato allo script
$2    # secondo argomento
$#    # numero di argomenti passati
$@    # tutti gli argomenti (come lista)
$?    # exit code dell'ultimo comando (0 = successo, != 0 = errore)
$$    # PID del processo corrente (utile per file temporanei unici)
```

Esempio pratico — uno script che accetta un file FASTA come argomento:

```bash
#!/bin/bash
# Uso: bash analisi.sh sequenze.fasta

input=$1
n=$(grep -c "^>" "$input")
echo "Analizzo: $input"
echo "Sequenze trovate: $n"
```

### Costruire nomi di file con le variabili

Un pattern che userai continuamente:

```bash
specie="Homo_sapiens"
gene="BRCA1"
data=$(date +%Y-%m-%d)

output="${specie}_${gene}_${data}.fasta"
echo "$output"   # Homo_sapiens_BRCA1_2025-03-15.fasta
```

---

## Parte 2 — Bioinformatica: Metadati delle sequenze

### L'header FASTA: molto più di un nome

L'header FASTA (la riga `>`) contiene informazioni strutturate sul gene o sulla proteina. Nei database NCBI ha un formato preciso:

```
>NM_007294.4 Homo sapiens BRCA1 DNA repair associated (BRCA1), transcript variant 1, mRNA
```

Scomponendolo:
- `NM_007294.4` → **accession number** con versione
- `Homo sapiens` → specie
- `BRCA1` → nome del gene
- `DNA repair associated` → funzione
- `transcript variant 1` → isoforma
- `mRNA` → tipo di molecola

In un file multi-FASTA da database, ogni header porta metadati diversi. Estrarli con BASH è il primo passo di qualsiasi pipeline.

### Accession number NCBI: leggere il prefisso

Il prefisso dell'accession ti dice subito che tipo di sequenza stai trattando:

| Prefisso | Tipo |
|----------|------|
| `NM_` | mRNA RefSeq (curato manualmente) |
| `NP_` | Proteina RefSeq (curata manualmente) |
| `XM_` | mRNA predetto computazionalmente |
| `XP_` | Proteina predetta computazionalmente |
| `NC_` | Cromosoma o genoma completo |
| `WP_` | Proteina non-ridondante (prokaryoti) |
| `sp\|` | SwissProt/UniProtKB (curato) |
| `tr\|` | TrEMBL/UniProtKB (automatico) |

`NM_` e `NP_` sono sequenze curate da revisori umani — le più affidabili. `XM_` e `XP_` sono predizioni automatiche.

### Estrarre metadati con variabili

```bash
input="hsp70.fasta"

# Contare le sequenze
n=$(grep -c "^>" "$input")
echo "Sequenze: $n"

# Estrarre il primo header (togliendo il >)
primo_header=$(grep "^>" "$input" | head -1 | sed 's/^>//')
echo "Prima sequenza: $primo_header"

# Estrarre solo il primo identificatore (prima parola dell'header)
primo_id=$(grep "^>" "$input" | head -1 | cut -d' ' -f1 | sed 's/^>//')
echo "ID: $primo_id"   # es: NP_005339.2

# Generare nome output dal nome del file input
nome_base=$(basename "$input" .fasta)
output="${nome_base}_risultati.txt"
echo "Output: $output"   # hsp70_risultati.txt
```

### `basename` e `dirname`

Due utility molto utili per lavorare con percorsi:

```bash
percorso="/home/dario/dati/hsp70_human.fasta"

basename "$percorso"              # hsp70_human.fasta
basename "$percorso" .fasta       # hsp70_human  (rimuove l'estensione)
dirname "$percorso"               # /home/dario/dati
```

Questo ti permette di costruire script che accettano un percorso qualunque e generano automaticamente i nomi dei file di output nella stessa cartella.

---

## Key Takeaways

**BASH:**
- Variabili: `nome=valore`, usate con `"$nome"` o `"${nome}"`
- Command substitution: `n=$(comando)` cattura l'output di un comando
- Variabili speciali `$1`, `$#`, `$?` sono fondamentali negli script
- `basename` rimuove il percorso (e l'estensione) da un nome file

**Bioinformatica:**
- L'header FASTA contiene metadati strutturati: accession, specie, gene, tipo di molecola
- Il prefisso dell'accession NCBI indica subito il tipo di sequenza (`NM_`, `NP_`, `NC_`...)
- `NM_`/`NP_` = curato = più affidabile; `XM_`/`XP_` = predetto = da verificare
- Pattern `${specie}_${gene}_${data}.fasta` per nomi file standardizzati e auto-generati

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-02-variabili-metadati.md](exercises/ex-02-variabili-metadati.md)
→ Poi vai a: [module-03-io-pipe-filtri.md](module-03-io-pipe-filtri.md)
