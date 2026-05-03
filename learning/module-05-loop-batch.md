# Modulo 5: Loop | Elaborazione batch di sequenze

## Obiettivo
Padroneggiare i loop `for` e `while` in BASH, e usarli per elaborare automaticamente interi dataset di file FASTA — la base di qualsiasi pipeline bioinformatica reale.

## Prerequisiti
- Moduli 1–4: comandi base, variabili, I/O, pipe, condizionali

---

## Parte 1 — BASH: Loop

### Il loop `for`

Il `for` itera su una lista di elementi.

```bash
for elemento in lista; do
    # comandi che usano $elemento
done
```

Esempio minimo:

```bash
for specie in umano topo zebrafish; do
    echo "Analisi: $specie"
done
```

Output:
```
Analisi: umano
Analisi: topo
Analisi: zebrafish
```

### Iterare su file (il caso più comune in bioinformatica)

```bash
for file in *.fasta; do
    echo "Processo: $file"
done
```

Il glob `*.fasta` viene espanso dalla shell in tutti i file `.fasta` nella cartella corrente.
**Importante:** usa sempre le virgolette attorno a `"$file"` per gestire spazi nel nome.

```bash
for file in *.fasta; do
    n_seq=$(grep -c "^>" "$file")
    echo "$file: $n_seq sequenze"
done
```

### Iterare su un intervallo numerico

```bash
for i in {1..5}; do
    echo "Campione $i"
done
```

Oppure con step:

```bash
for i in {0..100..10}; do
    echo "$i%"
done
```

### Stile C (con variabile contatore)

```bash
for (( i=0; i<5; i++ )); do
    echo "Iterazione $i"
done
```

Utile quando hai bisogno di un contatore esplicito.

---

### Il loop `while`

`while` continua finché una condizione è vera.

```bash
while [ condizione ]; do
    # comandi
done
```

Esempio — leggere un file riga per riga:

```bash
while IFS= read -r riga; do
    echo "$riga"
done < file.txt
```

- `IFS=` disabilita il word splitting (preserva spazi)
- `read -r` non interpreta i backslash
- `< file.txt` reindirizza il file come stdin del loop

### `while` con contatore

```bash
i=1
while [ "$i" -le 5 ]; do
    echo "Step $i"
    (( i++ ))
done
```

### Loop infinito con `break`

```bash
while true; do
    leggi o aspetta qualcosa
    if [ condizione_uscita ]; then
        break
    fi
done
```

---

### `break` e `continue`

```bash
for file in *.fasta; do
    if [ ! -s "$file" ]; then
        echo "Salto $file (vuoto)"
        continue    # salta al prossimo file
    fi
    
    n_seq=$(grep -c "^>" "$file")
    if [ "$n_seq" -gt 1000 ]; then
        echo "STOP: $file ha troppe sequenze ($n_seq)"
        break       # esce dal loop
    fi
    
    echo "OK: $file ($n_seq sequenze)"
done
```

- `continue` — salta l'iterazione corrente, vai alla prossima
- `break` — esci dal loop completamente

---

### Costruire output strutturato dentro un loop

Un pattern fondamentale: accumulare risultati in un file durante il loop.

```bash
output="report.tsv"
echo -e "File\tSequenze" > "$output"   # intestazione, sovrascrive

for file in *.fasta; do
    n=$(grep -c "^>" "$file")
    echo -e "$file\t$n" >> "$output"   # appende risultati
done

echo "Report salvato in $output"
```

---

## Parte 2 — Bioinformatica: Elaborazione batch di sequenze

### Cos'è il batch processing?

Nella bioinformatica reale non lavori mai su un solo file: hai cartelle con decine o centinaia di file FASTA (un per organismo, un per campione, un per gene). Il loop è lo strumento che trasforma un'operazione manuale ripetuta in una pipeline automatizzata.

Esempio tipico: hai ricevuto 50 file `.fasta` dal sequenziatore e devi calcolare le statistiche di base su ognuno prima di decidere quali passano al passo successivo.

### Pattern 1 — Raccogliere statistiche su più file

```bash
#!/bin/bash
echo -e "File\tSequenze\tLunghezza_totale_bp"

for file in data/*.fasta; do
    nome=$(basename "$file")                        # solo il nome, senza percorso
    n_seq=$(grep -c "^>" "$file")
    lunghezza=$(grep -v "^>" "$file" | tr -d '\n' | wc -c)
    echo -e "$nome\t$n_seq\t$lunghezza"
done
```

`basename` rimuove il percorso: `data/specie.fasta` → `specie.fasta`.

`tr -d '\n'` rimuove i newline prima di contare i caratteri — così ottieni la lunghezza totale della sequenza, non il numero di righe.

### Pattern 2 — Processare e salvare un output per file

```bash
#!/bin/bash
mkdir -p results/

for file in data/*.fasta; do
    nome=$(basename "$file" .fasta)      # rimuove anche l'estensione
    output="results/${nome}_stats.txt"

    n_seq=$(grep -c "^>" "$file")
    echo "File: $file" > "$output"
    echo "Sequenze: $n_seq" >> "$output"
    echo "Processato il: $(date)" >> "$output"

    echo "✓ $nome → $output"
done
```

`basename "$file" .fasta` fa due cose: toglie il percorso E l'estensione `.fasta`.
Così `data/mus_musculus.fasta` diventa semplicemente `mus_musculus`.

### Pattern 3 — QC batch: filtrare i file che non passano

Combinare loop e condizionali è il cuore delle pipeline reali:

```bash
#!/bin/bash
min_seq=5
ok=0
falliti=0

for file in data/*.fasta; do
    n_seq=$(grep -c "^>" "$file")

    if [ "$n_seq" -lt "$min_seq" ]; then
        echo "FAIL: $(basename "$file") — solo $n_seq sequenze (min: $min_seq)"
        (( falliti++ ))
        continue
    fi

    echo "OK:   $(basename "$file") — $n_seq sequenze"
    (( ok++ ))
done

echo ""
echo "Risultato: $ok OK, $falliti falliti"
```

Questo script è già una mini-pipeline di QC batch utilizzabile in produzione.

### Leggere un file di lista (loop `while` su stdin)

Spesso hai un file di testo con i nomi (o gli accession number) da processare, uno per riga:

```
NC_000001.11
NC_000002.12
NC_000003.12
```

```bash
while IFS= read -r accession; do
    echo "Scarico: $accession"
    # qui potresti chiamare efetch, curl, o altro
done < lista_accession.txt
```

Questo pattern è il modo standard per processare qualsiasi lista di input in BASH.

### `$(( ))` per l'aritmetica

Nei loop hai spesso bisogno di contatori o calcoli:

```bash
(( contatore++ ))        # incrementa di 1
(( totale += n_seq ))    # somma cumulativa
echo $(( 100 * ok / totale ))   # percentuale
```

`$(( ))` è l'aritmetica intera di BASH. Non usa decimali — per quelli serve `awk` o `python`.

---

## Key Takeaways

**BASH:**
- `for elemento in lista` — itera su valori, file (glob), o range `{1..N}`
- `while IFS= read -r riga` — il modo corretto per leggere un file riga per riga
- `continue` salta l'iterazione corrente, `break` esce dal loop
- `basename file .ext` rimuove percorso ed estensione
- `(( var++ ))` e `$(( expr ))` per l'aritmetica nei loop

**Bioinformatica:**
- I loop trasformano operazioni manuali su un file in pipeline automatizzate su interi dataset
- Pattern fondamentali: raccogliere statistiche, generare un output per file, QC batch
- `mkdir -p results/` prima del loop assicura che la cartella di output esista
- Leggere una lista di accession da file con `while read` è il gateway verso pipeline più complesse (download, BLAST, alignment)

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-05-loop-batch.md](exercises/ex-05-loop-batch.md)
→ Poi vai a: [module-06-funzioni-tools.md](module-06-funzioni-tools.md)
