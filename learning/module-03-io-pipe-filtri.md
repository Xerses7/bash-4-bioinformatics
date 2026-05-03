# Modulo 3: I/O, Redirect e Pipe | Filtrare dataset di sequenze

## Obiettivo
Capire come BASH gestisce i flussi di dati (stdin, stdout, stderr), reindirizzarli su file, e collegare comandi in pipeline — applicandolo al filtraggio e all'ispezione di grandi dataset FASTA.

## Prerequisiti
- Modulo 1: comandi base, formato FASTA
- Modulo 2: variabili e command substitution

---

## Parte 1 — BASH: I/O, Redirect e Pipe

### I tre canali standard

Ogni processo BASH ha tre canali di comunicazione:

```
STDIN  (0) ← input (di default: la tastiera)
STDOUT (1) → output normale (di default: il terminale)
STDERR (2) → messaggi di errore (di default: il terminale)
```

Per default, sia STDOUT che STDERR finiscono sullo schermo — ma puoi reindirizzarli dove vuoi.

### Redirect dell'output

```bash
# Redirigere stdout su file — sovrascrive se il file esiste
grep "^>" sequenze.fasta > headers.txt

# Appendere invece di sovrascrivere
echo "Analisi completata" >> log.txt

# Redirigere stderr (errori) su file
tool_bioinformatico 2> errori.log

# Redirigere sia stdout che stderr nello stesso file
tool_bioinformatico > output.txt 2>&1

# Scartare completamente l'output (silenzio assoluto)
tool_bioinformatico > /dev/null 2>&1
```

### Pipe `|`

La pipe collega lo stdout di un comando con lo stdin del successivo — **senza file intermedi**:

```bash
grep "^>" sequenze.fasta | wc -l          # conta gli header
grep "^>" sequenze.fasta | sort           # header in ordine alfabetico
grep "^>" sequenze.fasta | sort | uniq    # header unici
```

Puoi concatenare quante pipe vuoi. Ogni comando elabora l'output del precedente:

```bash
grep "^>" big_database.fasta | grep -i "kinase" | sort | uniq | wc -l
```

### `tee` — duplicare l'output

`tee` manda l'output **sia su file che sul terminale**, contemporaneamente:

```bash
grep "^>" sequenze.fasta | tee headers.txt | wc -l
# Salva gli header in headers.txt E stampa il conteggio sul terminale
```

Utile quando vuoi vedere i risultati E salvarli, senza doverlo fare in due passi.

### Redirect dell'input

```bash
# Dare un file come input a un comando
wc -l < sequenze.fasta    # conta le righe senza "sequenze.fasta" nell'output

# Usato in combinazione con variabili
n=$(wc -l < "$input")
```

---

## Parte 2 — Bioinformatica: Filtrare dataset di sequenze

### Il problema: dataset enormi

Un file FASTA da NCBI o UniProt può contenere milioni di sequenze e pesare diversi gigabyte. Non puoi aprirlo in un editor. La shell processa questi file **riga per riga**, senza caricarli in memoria — questo è uno dei suoi punti di forza più importanti rispetto a Python o R per operazioni semplici.

### Esplorazione rapida con pipe

```bash
# Quante sequenze nel database?
grep -c "^>" nr_database.fasta

# Che specie ci sono? Estrai la parte descrittiva degli header
grep "^>" sequenze.fasta | cut -d" " -f2-5

# Quante specie uniche (approssimativo)?
grep "^>" sequenze.fasta | grep -o "\[.*\]" | sort | uniq -c | sort -rn | head -20

# Cerca sequenze per nome gene
grep "^>" sequenze.fasta | grep -i "kinase"

# Cerca sequenze di una specie specifica
grep "^>" sequenze.fasta | grep "Homo sapiens"
```

### Costruire un report sulle specie presenti

```bash
input="hsp70_database.fasta"

echo "=== Report: $input ===" > report.txt
echo "Sequenze totali: $(grep -c "^>" "$input")" >> report.txt
echo "" >> report.txt
echo "Sequenze umane:" >> report.txt
grep "^>" "$input" | grep "Homo sapiens" >> report.txt
```

### Separare output da errori — una buona abitudine

In bioinformatica, vuoi sempre separare i risultati dai messaggi di errore:

```bash
blast -query query.fasta -db nr -out risultati.txt 2> blast_errori.log
samtools sort input.bam -o sorted.bam 2> samtools.log
```

Se l'analisi fallisce, guardi solo `errori.log` — i risultati restano puliti.

### Combinare più file FASTA

Una delle operazioni più comuni: unire dataset da fonti diverse in un unico file.

```bash
# Concatenare file FASTA — funziona perché il formato è semplicemente testo
cat umano.fasta topo.fasta zebrafish.fasta > comparativo.fasta

# Verificare che la concatenazione sia andata bene
grep -c "^>" comparativo.fasta

# Con redirect append: aggiungere nuove sequenze a un file esistente
cat nuove_sequenze.fasta >> database.fasta
```

**Attenzione:** controlla sempre che ogni file FASTA termini con una riga vuota prima di concatenare, altrimenti l'ultimo header del primo file e il primo header del secondo potrebbero finire sulla stessa riga (un bug raro ma insidioso).

### Filtrare per parola chiave: pattern frequente

```bash
# Salva solo gli header che contengono "BRCA"
grep "^>" proteine.fasta | grep "BRCA" > brca_headers.txt

# Quante isoforme di un gene?
grep "^>" trascrittoma.fasta | grep "TP53" | wc -l

# Usa tee per vedere E salvare in una sola riga
grep "^>" sequenze.fasta | grep "Homo sapiens" | tee umane.txt | wc -l
```

**Nota:** con queste tecniche estrai e conti solo gli **header**. Per estrarre anche le sequenze corrispondenti serve `awk` o un tool dedicato — lo vediamo nel Modulo 9.

---

## Key Takeaways

**BASH:**
- `>` sovrascrive, `>>` appende — non confonderli mai
- `2>` redirige gli errori su file separato
- `|` collega stdout → stdin senza file intermedi
- `tee` duplica: salva su file E mostra sul terminale

**Bioinformatica:**
- La shell processa file da gigabyte riga per riga, senza caricarli in memoria
- `cat file1.fasta file2.fasta > merged.fasta` per unire dataset
- Separare sempre output (`>`) da errori (`2>`) nelle pipeline reali
- `grep "^>" | grep "keyword"` è il filtro più rapido su dataset multi-FASTA

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-03-io-pipe-filtri.md](exercises/ex-03-io-pipe-filtri.md)
→ Poi vai a: [module-04-condizionali-qc.md](module-04-condizionali-qc.md)
