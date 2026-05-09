# Modulo 9: grep, sed, awk | Parsing di formati bioinformatici

## Obiettivo
Padroneggiare `grep`, `sed` e `awk` per manipolare testo strutturato, e applicarli al parsing dei formati che incontrerai ogni giorno: GFF3, BED, e BLAST tabular output.

## Prerequisiti
- Moduli 1–8: comandi base, variabili, I/O, pipe, condizionali, loop, funzioni, stringhe

---

## Parte 1 — BASH: grep, sed, awk

### grep con espressioni regolari

`grep` cerca pattern in file di testo. Conosci già la forma base; qui vediamo le regex.

**Modalità di grep:**

| Flag | Significato |
|---|---|
| `-E` | Regex estesa (ERE) — la più usata |
| `-P` | Regex Perl-compatibile (PCRE) |
| `-F` | Stringa fissa, no regex (più veloce) |
| `-i` | Case insensitive |
| `-v` | Inverte il match (righe che NON contengono) |
| `-c` | Conta le righe corrispondenti |
| `-o` | Stampa solo la parte che fa match |
| `-n` | Mostra il numero di riga |

**Metacaratteri essenziali:**

```
.        qualsiasi carattere
*        zero o più del precedente
+        uno o più del precedente (con -E)
?        zero o uno del precedente (con -E)
^        inizio riga
$        fine riga
[ABC]    uno tra A, B, C
[^ABC]   nessuno tra A, B, C
(ab|cd)  "ab" oppure "cd" (con -E)
\t       tab (con -P o con $'\t')
```

**Esempi pratici:**

```bash
# Righe che iniziano con un numero
grep -E "^[0-9]" file.txt

# Header FASTA con accession NM_
grep -E "^>NM_[0-9]+" sequences.fasta

# Righe che NON sono commenti (# in prima posizione)
grep -v "^#" file.gff3

# Estrarre solo l'accession number dall'header
grep "^>" seqs.fasta | grep -oE "NM_[0-9]+\.[0-9]+"
```

---

### sed — stream editor

`sed` trasforma il testo riga per riga. Il comando più usato è la sostituzione:

```bash
sed 's/pattern/sostituzione/flag'
```

Dove i flag più comuni sono:
- `g` — sostituisce tutte le occorrenze sulla riga (non solo la prima)
- `i` — case insensitive
- `2` — sostituisce solo la seconda occorrenza

**Esempi:**

```bash
# Rimuovere il carattere > dagli header FASTA
sed 's/^>//' sequences.fasta

# Sostituire spazi con underscore negli header
sed 's/ /_/g' sequences.fasta

# Eliminare righe vuote
sed '/^$/d'

# Eliminare commenti (righe che iniziano con #)
sed '/^#/d' file.gff3

# Estrarre solo le righe da N a M
sed -n '10,20p' file.txt

# Stampare solo le righe con pattern
sed -n '/^>/p' sequences.fasta   # equivalente a grep "^>"
```

**Indirizzi:** `sed` può operare su un sottoinsieme di righe:

```bash
sed '1d'           # elimina la prima riga (header)
sed '1s/^/# /'     # aggiunge # alla prima riga
sed '/pattern/d'   # elimina le righe che matchano il pattern
```

**Modificare un file in-place:**

```bash
sed -i 's/vecchio/nuovo/g' file.txt       # modifica il file originale
sed -i.bak 's/vecchio/nuovo/g' file.txt   # crea un backup .bak prima
```

---

### awk — programmazione su file tabellari

`awk` tratta ogni riga come un record diviso in **campi** da un separatore. È l'ideale per file con colonne (TSV, CSV, GFF3, BLAST output).

**Sintassi base:**

```bash
awk 'pattern { azione }' file
```

**Variabili built-in:**

| Variabile | Significato |
|---|---|
| `$0` | Tutta la riga |
| `$1`, `$2`, ... | Il primo, secondo, ... campo |
| `NF` | Numero di campi della riga corrente |
| `NR` | Numero di riga corrente (progressivo) |
| `FS` | Field Separator (default: whitespace) |
| `OFS` | Output Field Separator |

**Esempi:**

```bash
# Stampa il terzo campo di un TSV
awk '{ print $3 }' file.tsv

# Cambia il separatore di input
awk -F'\t' '{ print $1 }' file.tsv

# Filtro: stampa le righe dove il quinto campo > 100
awk '$5 > 100' file.tsv

# Calcola la media del secondo campo
awk '{ sum += $2; n++ } END { print sum/n }' file.tsv

# Blocchi speciali: BEGIN e END
awk 'BEGIN { print "Inizio" } { print $1 } END { print "Fine" }' file.tsv

# Cambia il separatore di output
awk -F'\t' 'OFS=","; { print $1, $3, $5 }' file.tsv
```

---

## Parte 2 — Bioinformatica: Parsing di formati reali

### Il formato GFF3

GFF3 (General Feature Format 3) descrive le annotazioni genomiche. Ha 9 campi separati da tab:

```
seqname  source  feature  start  end  score  strand  frame  attributes
```

Esempio di file GFF3:

```
##gff-version 3
NC_000001.11  RefSeq  gene    11874   14409   .   +   .   ID=gene-DDX11L1;Name=DDX11L1
NC_000001.11  RefSeq  mRNA    11874   14409   .   +   .   ID=rna-NR_046018.2;Parent=gene-DDX11L1
NC_000001.11  RefSeq  exon    11874   12227   .   +   .   Parent=rna-NR_046018.2
NC_000001.11  RefSeq  exon    12613   12721   .   +   .   Parent=rna-NR_046018.2
NC_000001.11  RefSeq  gene    14362   29370   .   -   .   ID=gene-WASH7P;Name=WASH7P
```

**Operazioni comuni:**

```bash
# Rimuovere le righe di commento
grep -v "^#" annotations.gff3

# Estrarre solo i geni
awk -F'\t' '$3 == "gene"' annotations.gff3

# Estrarre geni sul filamento positivo, colonne 1,4,5,9
awk -F'\t' '$3 == "gene" && $7 == "+"  { print $1"\t"$4"\t"$5"\t"$9 }' annotations.gff3

# Contare le feature per tipo
awk -F'\t' '!/^#/ { count[$3]++ } END { for (f in count) print f, count[f] }' annotations.gff3

# Calcolare la lunghezza media degli esoni
awk -F'\t' '$3 == "exon" { sum += $5 - $4 + 1; n++ } END { print "Media esoni:", sum/n, "bp" }' annotations.gff3

# Estrarre il valore di un attributo specifico dal campo 9
grep "gene" annotations.gff3 | grep -oP 'Name=[^;]+' | sed 's/Name=//'
```

### Il formato BED

BED (Browser Extensible Data) descrive coordinate genomiche. Ha almeno 3 colonne (seqname, start, end), con start **0-based** e end **esclusivo**:

```
chr1    11873   14409   DDX11L1   .   +
chr1    14361   29370   WASH7P    .   -
chr1    17368   17436   .         .   -
```

**Operazioni comuni:**

```bash
# Calcolare la lunghezza di ogni feature (end - start)
awk -F'\t' '{ print $4, $3 - $2 }' features.bed

# Filtrare per cromosoma
awk '$1 == "chr1"' features.bed

# Filtrare per lunghezza minima
awk '{ if ($3 - $2 >= 1000) print }' features.bed

# Ordinare per cromosoma e poi per posizione
sort -k1,1 -k2,2n features.bed

# Contare le feature per cromosoma
awk '{ count[$1]++ } END { for (c in count) print c, count[c] }' features.bed | sort -k1,1
```

### Il formato BLAST tabular (-outfmt 6)

BLAST con `-outfmt 6` produce un TSV con 12 colonne standard:

```
qseqid  sseqid  pident  length  mismatch  gapopen  qstart  qend  sstart  send  evalue  bitscore
```

Esempio:

```
NM_001301717  XM_017352429  87.3  1200  152  8  1  1200  1  1185  1e-180  654
NM_007294     XM_009332461  92.1   980   77  3  1   980  1   975  0.0     825
NM_001301717  XM_009332461  45.2   450  220 12  1   450  1   442  2e-45   189
```

**Operazioni comuni:**

```bash
# Filtrare per e-value <= 1e-10
awk '$11 <= 1e-10' blast_results.txt

# Filtrare per identità >= 90% e lunghezza allineamento >= 500
awk '$3 >= 90 && $4 >= 500' blast_results.txt

# Miglior hit per ogni query (primo per bitscore)
sort -k1,1 -k12,12rn blast_results.txt | sort -u -k1,1

# Statistiche: distribuzione dell'identità
awk '{ printf "%.0f\n", $3 }' blast_results.txt | sort | uniq -c | sort -k2,2n

# Contare gli hit unici per query
awk '{ print $1 }' blast_results.txt | sort | uniq -c

# Estrarre query con almeno un hit sopra soglia
awk '$11 <= 1e-20 { print $1 }' blast_results.txt | sort -u
```

### Pipeline combinata: GFF3 + BLAST

Un esempio reale: trovare i geni annotati in GFF3 che hanno un hit BLAST significativo.

```bash
# 1. Estrai i gene names dal GFF3
grep -oP 'Name=[^;]+' annotations.gff3 | sed 's/Name=//' | sort > gff_genes.txt

# 2. Estrai le query con hit significativo da BLAST
awk '$11 <= 1e-10 { print $1 }' blast_results.txt | sort -u > blast_hits.txt

# 3. Interseca i due insiemi
comm -12 gff_genes.txt blast_hits.txt
```

---

## Key Takeaways

**BASH:**
- `grep -E` per regex estese; `-o` per estrarre solo il match; `-v` per invertire
- `sed 's/pat/repl/g'` — sostituzione globale; `/pattern/d` — eliminazione righe
- `awk -F'\t' '$3 == "gene"'` — filtrare per valore in colonna; `{ count[$1]++ }` — dizionario in awk
- `awk 'END { print sum/n }'` — calcoli aggregati su tutto il file
- `sort -k1,1 -k2,2n` — ordinamento multi-chiave essenziale per file genomici

**Bioinformatica:**
- GFF3: 9 colonne tab-separate, commenti con `#`, attributi nel campo 9 come `chiave=valore;`
- BED: coordinate 0-based half-open (start incluso, end escluso) — la lunghezza è `end - start`
- BLAST -outfmt 6: 12 colonne standard; e-value in colonna 11, bitscore in 12
- Il "miglior hit" BLAST si estrae con `sort -k1,1 -k12,12rn | sort -u -k1,1`
- `comm -12` è lo strumento per intersecare due liste ordinate

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-09-grep-sed-awk-formati.md](exercises/ex-09-grep-sed-awk-formati.md)
→ Poi vai a: [module-10-best-practice-pipeline.md](module-10-best-practice-pipeline.md)
