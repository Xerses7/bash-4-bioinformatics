# Esercizio 9: Parsing di formati bioinformatici

## Modulo correlato
[module-09-grep-sed-awk-formati.md](../module-09-grep-sed-awk-formati.md)

## Difficoltà
Hard

---

## Scenario

Hai appena ricevuto tre file da un collaboratore: un'annotazione GFF3, un file BED con regioni di interesse, e un output BLAST. Il tuo compito è estrarre informazioni utili da ciascuno usando `grep`, `sed` e `awk` — e infine combinare i risultati.

---

## Setup — crea i file di test

```bash
mkdir -p formati_test

cat > formati_test/annotation.gff3 << 'EOF'
##gff-version 3
##sequence-region chr1 1 248956422
# Annotazione semplificata per esercizio
chr1	RefSeq	gene	11874	14409	.	+	.	ID=gene-DDX11L1;Name=DDX11L1;gene_biotype=lncRNA
chr1	RefSeq	mRNA	11874	14409	.	+	.	ID=rna-NR_046018.2;Parent=gene-DDX11L1;Name=DDX11L1
chr1	RefSeq	exon	11874	12227	.	+	.	Parent=rna-NR_046018.2;exon_number=1
chr1	RefSeq	exon	12613	12721	.	+	.	Parent=rna-NR_046018.2;exon_number=2
chr1	RefSeq	exon	13221	14409	.	+	.	Parent=rna-NR_046018.2;exon_number=3
chr1	RefSeq	gene	14362	29370	.	-	.	ID=gene-WASH7P;Name=WASH7P;gene_biotype=pseudogene
chr1	RefSeq	mRNA	14362	29370	.	-	.	ID=rna-NR_024540.1;Parent=gene-WASH7P;Name=WASH7P
chr1	RefSeq	exon	14362	14829	.	-	.	Parent=rna-NR_024540.1;exon_number=1
chr1	RefSeq	exon	14970	15038	.	-	.	Parent=rna-NR_024540.1;exon_number=2
chr1	RefSeq	gene	17369	17436	.	-	.	ID=gene-MIR6859-1;Name=MIR6859-1;gene_biotype=miRNA
chr1	RefSeq	gene	29554	31109	.	+	.	ID=gene-MIR1302-2HG;Name=MIR1302-2HG;gene_biotype=lncRNA
chr1	RefSeq	exon	29554	30039	.	+	.	Parent=rna-NR_036051.2;exon_number=1
chr1	RefSeq	exon	30564	30667	.	+	.	Parent=rna-NR_036051.2;exon_number=2
chr1	RefSeq	exon	30976	31109	.	+	.	Parent=rna-NR_036051.2;exon_number=3
EOF

cat > formati_test/regions.bed << 'EOF'
chr1	11000	15000	region_A	.	+
chr1	14000	30000	region_B	.	-
chr1	17000	18000	region_C	.	-
chr1	29000	32000	region_D	.	+
chr1	50000	60000	region_E	.	+
EOF

cat > formati_test/blast_results.txt << 'EOF'
DDX11L1	XR_001753175.2	98.5	535	8	0	1	535	1	535	0.0	987
DDX11L1	NR_046018.3	95.2	535	26	1	1	535	1	534	0.0	945
DDX11L1	XR_003080084.1	78.3	460	100	5	1	535	10	465	1e-120	432
WASH7P	NR_024540.2	99.1	1100	10	0	1	1100	1	1100	0.0	2030
WASH7P	XR_001752015.1	88.7	980	111	8	1	1100	50	1020	1e-95	350
MIR6859-1	NR_106918.1	100.0	68	0	0	1	68	1	68	2e-30	126
MIR6859-1	NR_106919.1	97.1	68	2	0	1	68	1	68	3e-28	119
MIR1302-2HG	XR_001753201.1	92.4	1500	114	7	1	1555	1	1498	0.0	2150
MIR1302-2HG	NR_036051.3	99.8	1555	3	0	1	1555	1	1555	0.0	2873
UNKNOWN_GENE	XR_999999.1	45.2	200	110	10	1	200	50	248	1e-15	89
EOF
```

---

## Task

Crea lo script `formati_test/analisi_formati.sh` che risponde a queste domande usando `grep`, `sed` e `awk`:

### Parte A — GFF3

1. **Conta le feature per tipo** (gene, mRNA, exon, ecc.) e stampa una tabella ordinata per conteggio decrescente
2. **Elenca i nomi dei geni** (campo `Name=` dal campo 9) presenti nel file, uno per riga
3. **Calcola la lunghezza media degli esoni** in bp (ricorda: BED è 0-based, GFF3 è 1-based e incluso, quindi lunghezza = `end - start + 1`)

### Parte B — BED

4. **Stampa le regioni con lunghezza >= 5000 bp**, con nome e lunghezza
5. **Calcola la lunghezza totale coperta** dalle regioni BED

### Parte C — BLAST

6. **Filtra gli hit con e-value <= 1e-50 e identità >= 90%** e stampa `query`, `subject`, `identità`, `e-value`
7. **Trova il miglior hit per ogni gene** (quello con bitscore più alto), stampa `gene: subject (bitscore)`
8. **Elenca i geni senza un hit significativo** (e-value > 1e-10 per tutti i loro hit)

### Parte D — Combinazione

9. **Elenca i geni del GFF3 che hanno almeno un hit BLAST con e-value <= 1e-50** — cioè l'intersezione tra i geni annotati e quelli con hit significativo

### Output atteso (a schermo)

```
=== A: Feature GFF3 ===
exon    7
mRNA    3
gene    4

=== A: Nomi dei geni ===
DDX11L1
MIR1302-2HG
MIR6859-1
WASH7P

=== A: Lunghezza media esoni ===
Media esoni: 530 bp

=== B: Regioni >= 5000 bp ===
region_B  16000 bp
region_E  10000 bp

=== B: Lunghezza totale BED ===
Totale: 36000 bp

=== C: Hit BLAST significativi (e-value<=1e-50, identità>=90%) ===
DDX11L1      XR_001753175.2  98.5  0.0
DDX11L1      NR_046018.3     95.2  0.0
WASH7P       NR_024540.2     99.1  0.0
MIR1302-2HG  XR_001753201.1  92.4  0.0
MIR1302-2HG  NR_036051.3     99.8  0.0

=== C: Miglior hit per gene ===
DDX11L1: XR_001753175.2 (987)
MIR1302-2HG: NR_036051.3 (2873)
MIR6859-1: NR_106918.1 (126)
UNKNOWN_GENE: XR_999999.1 (89)
WASH7P: NR_024540.2 (2030)

=== C: Geni senza hit significativo (e-value > 1e-10) ===
UNKNOWN_GENE

=== D: Geni annotati con hit BLAST significativo ===
DDX11L1
MIR1302-2HG
WASH7P
```

---

## Requisiti

- [ ] Ogni sezione usa almeno uno tra `grep`, `sed`, `awk`
- [ ] I commenti GFF3 (righe `#`) vengono esclusi prima dell'analisi
- [ ] La lunghezza degli esoni usa la formula GFF3: `end - start + 1`
- [ ] La lunghezza delle regioni BED usa la formula BED: `end - start`
- [ ] Il filtraggio BLAST per e-value usa la comparazione numerica di `awk`
- [ ] Il miglior hit si ottiene ordinando e prendendo il primo per ogni query
- [ ] L'intersezione (Parte D) usa `comm` o `grep -f`

---

## Hints

<details>
<summary>Hint 1 — contare feature per tipo (Parte A, punto 1)</summary>

```bash
grep -v "^#" formati_test/annotation.gff3 | awk -F'\t' '{ count[$3]++ } END { for (f in count) print f, count[f] }' | sort -k2,2rn
```

</details>

<details>
<summary>Hint 2 — estrarre nomi dei geni (Parte A, punto 2)</summary>

Il nome è nel campo 9, nella forma `Name=DDX11L1;`. Puoi estrarlo con:

```bash
grep -v "^#" formati_test/annotation.gff3 | awk -F'\t' '$3 == "gene"' | grep -oE 'Name=[^;]+' | sed 's/Name=//' | sort
```

</details>

<details>
<summary>Hint 3 — miglior hit per gene (Parte C, punto 7)</summary>

Ordina per query (colonna 1 alfabetico) e poi per bitscore (colonna 12, numerico decrescente). Poi prendi la prima riga unica per query:

```bash
sort -k1,1 -k12,12rn formati_test/blast_results.txt | sort -u -k1,1
```

`sort -u -k1,1` mantiene solo la prima riga per ogni valore unico della colonna 1.

</details>

<details>
<summary>Hint 4 — geni senza hit significativo (Parte C, punto 8)</summary>

Per ogni gene, vuoi sapere se TUTTI i suoi hit hanno e-value > 1e-10. Il trucco: trova i geni che hanno almeno un hit con e-value <= 1e-10, poi usa `comm` per trovare quelli che NON sono in questa lista.

```bash
# Geni con almeno un hit significativo
awk '$11 <= 1e-10 { print $1 }' formati_test/blast_results.txt | sort -u > /tmp/con_hit.txt

# Tutti i geni nel file BLAST
awk '{ print $1 }' formati_test/blast_results.txt | sort -u > /tmp/tutti.txt

# Differenza: geni senza hit significativo
comm -23 /tmp/tutti.txt /tmp/con_hit.txt
```

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

Organizza lo script in sezioni con `echo "=== A: Feature GFF3 ==="` ecc.

**Parte A:**
1. `grep -v "^#" | awk '{ count[$3]++ } END {...}' | sort -k2,2rn`
2. `awk '$3=="gene"' | grep -oE 'Name=[^;]+' | sed 's/Name=//' | sort`
3. `awk '$3=="exon" { sum += $5-$4+1; n++ } END { print int(sum/n) }'`

**Parte B:**
4. `awk '{ len=$3-$2; if(len>=5000) print $4, len }' | sort -k2,2rn`
5. `awk '{ sum += $3-$2 } END { print sum }'`

**Parte C:**
6. `awk '$11 <= 1e-50 && $3 >= 90 { print $1, $2, $3, $11 }'`
7. `sort -k1,1 -k12,12rn | sort -u -k1,1 | awk '{ print $1": "$2" ("$12")" }'`
8. Due passi: geni con hit significativo (awk + sort -u), poi tutti i geni (sort -u), poi `comm -23`

**Parte D:**
- Geni GFF3: da (A, punto 2) → file temporaneo ordinato
- Geni con hit BLAST sig.: da (C, punto 8 in negativo) → file temporaneo ordinato
- `comm -12 gff_genes.txt blast_sig.txt`

Usa file temporanei in `/tmp/` oppure variabili con process substitution: `comm -12 <(lista_gff) <(lista_blast)`.

</details>
