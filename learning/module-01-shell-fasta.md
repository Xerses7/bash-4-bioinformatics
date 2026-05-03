# Modulo 1: La shell e i comandi base | Il formato FASTA

## Obiettivo
Navigare il filesystem da terminale, usare i comandi di ispezione base, e capire la struttura del formato FASTA — il formato universale per le sequenze biologiche.

## Prerequisiti
Nessuno — è il punto di partenza.

---

## Parte 1 — BASH: La shell e i comandi base

### Cos'è la shell?

La shell è un programma che riceve comandi testuali e li esegue. BASH (*Bourne Again SHell*) è la shell più diffusa su Linux e macOS.

Quando apri un terminale, stai parlando con la shell. Ogni cosa che digiti è un comando che la shell interpreta ed esegue.

In bioinformatica, la shell è lo strumento di lavoro principale: la maggior parte dei tool (BLAST, samtools, bwa, bedtools, seqkit...) si usa esclusivamente dalla riga di comando. Automatizzare le analisi significa scrivere script BASH.

### Orientarsi nel filesystem

```bash
pwd          # stampa la cartella corrente (Print Working Directory)
ls           # elenca i file nella cartella corrente
ls -l        # lista dettagliata (permessi, dimensione, data)
ls -lh       # come -l ma con dimensioni leggibili (es. 2.4M invece di 2457600)
ls -la       # include anche i file nascosti (quelli che iniziano con .)
```

### Spostarsi tra cartelle

```bash
cd /percorso/assoluto     # vai a un percorso preciso
cd cartella               # vai in una sottocartella
cd ..                     # sali di un livello
cd -                      # torna alla cartella precedente
cd ~                      # vai alla home
```

**Percorso assoluto vs relativo:**
- `/home/dario/dati/sequenze` → assoluto (parte dalla radice `/`)
- `dati/sequenze` → relativo (parte dalla cartella corrente)

### Creare e cancellare

```bash
mkdir dati-sequenze            # crea una cartella
mkdir -p analisi/fasta/raw     # crea l'intera catena di cartelle
touch sequenze.fasta           # crea un file vuoto (o aggiorna la data)
rm file.txt                    # cancella un file — definitivo, non va nel cestino
rm -r cartella/                # cancella una cartella e tutto il suo contenuto
```

### Leggere il contenuto di un file

```bash
cat sequenze.fasta             # stampa tutto il file
head -5 sequenze.fasta         # prime 5 righe
tail -5 sequenze.fasta         # ultime 5 righe
less sequenze.fasta            # sfoglia interattivamente (frecce per muoversi, q per uscire)
wc -l sequenze.fasta           # conta le righe totali
```

---

## Parte 2 — Bioinformatica: Il formato FASTA

### Cos'è FASTA?

FASTA è il formato più semplice e universale per rappresentare sequenze biologiche (DNA, RNA, proteine). Nato negli anni '80 con il tool FASTA di William Pearson, oggi è lo standard de facto accettato da quasi tutti i software di bioinformatica: BLAST, clustal, MUSCLE, samtools, bedtools, e decine di altri.

### Struttura di un record FASTA

Un file FASTA è composto da **record**. Ogni record ha due parti:

```
>NP_005339.2 heat shock protein 70 kDa [Homo sapiens]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAKNQVAMNPTNTVFDAK
RLIGRKFGDPVVQSDMKHWPFQVVNDAGRPKVQVEYKGEEKSTGASIELDSSGKLLTKVNSIFEFLKKNN
```

1. **Header line**: inizia **sempre** con `>`, seguita dall'identificatore e (opzionalmente) da una descrizione
2. **Sequenza**: una o più righe di caratteri (`A T C G` per DNA, single-letter code per proteine)

### Multi-FASTA

Un file può contenere **molte sequenze** (multi-FASTA), una dopo l'altra:

```
>NP_005339.2 HSP70 member 1A [Homo sapiens]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>NP_031381.2 heat shock protein 1 [Mus musculus]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>XP_524525.2 heat shock protein 70 [Pan troglodytes]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
```

I database come UniProt o NCBI nr distribuiscono milioni di sequenze in un unico file FASTA di questo tipo.

### Ispezione di un file FASTA dalla shell

Quando ricevi un file FASTA, le prime domande sono quasi sempre le stesse:
- Quante sequenze contiene?
- Di che organismi/geni si tratta?
- Quanto sono lunghe?

Con i comandi che hai appena imparato puoi rispondere in pochi secondi:

```bash
# Vedere le prime righe (header + inizio sequenze)
head -20 sequenze.fasta

# Contare le sequenze — ogni record inizia con >
grep -c "^>" sequenze.fasta

# Vedere solo gli header
grep "^>" sequenze.fasta

# Contare le righe totali
wc -l sequenze.fasta

# Sfogliare senza aprire un editor
less sequenze.fasta
```

Il pattern `"^>"` usa una **regex minima**: `^` significa "inizio riga". Questo assicura che tu trovi solo le righe header e non un eventuale `>` nel testo. Le regex le approfondiamo nel Modulo 9.

### Estensioni comuni

| Estensione | Contenuto tipico |
|------------|-----------------|
| `.fasta`, `.fa` | generico |
| `.fna` | nucleotidi (DNA/RNA) |
| `.faa` | aminoacidi (proteine) |
| `.ffn` | sequenze nucleotidiche di geni codificanti |

### Caratteri speciali nelle sequenze

- **DNA standard:** `A`, `T`, `C`, `G`
- **Caratteri IUPAC ambigui:** `N` = qualsiasi nucleotide, `R` = A o G, `Y` = C o T, ecc.
- **Proteine:** i 20 aminoacidi + `X` (qualsiasi) + `*` (stop codon)

Un file con molte `N` nelle sequenze è spesso sintomo di sequenziamento di bassa qualità o regioni genomiche non risolte.

---

## Key Takeaways

**BASH:**
- `pwd`, `ls`, `cd` — i tre comandi di navigazione fondamentali
- `cat`, `head`, `tail`, `less` — per leggere file
- `wc -l` — conta le righe
- `rm` è definitivo: non usa il cestino

**Bioinformatica:**
- Il formato FASTA è: riga `>header` seguita da una o più righe di sequenza
- `grep -c "^>"` conta le sequenze in un file FASTA
- `grep "^>"` estrae tutti gli header — il modo più rapido per esplorare un dataset
- `N` e `X` indicano sequenze ambigue — da tenere d'occhio

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-01-shell-fasta.md](exercises/ex-01-shell-fasta.md)
→ Poi vai a: [module-02-variabili-metadati.md](module-02-variabili-metadati.md)
