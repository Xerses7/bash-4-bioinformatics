# Esercizio 1: Esplorare un file FASTA dalla shell

## Modulo di riferimento
[module-01-shell-fasta.md](../module-01-shell-fasta.md)

## Difficoltà
Facile

## Scenario
Hai appena scaricato un file FASTA da NCBI contenente alcune sequenze proteiche della famiglia delle chaperonine HSP70 (heat shock proteins). Prima di qualsiasi analisi, devi capire cosa contiene il file.

## Setup
Crea il file di esempio con questo comando (copia-incolla nel terminale):

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

1. Quante sequenze contiene il file `hsp70.fasta`?
2. Visualizza **solo le righe header** (quelle che iniziano con `>`)
3. Mostra le **prime 4 righe** del file
4. Conta le **righe totali** del file
5. Crea una cartella `analisi/` e **sposta** `hsp70.fasta` al suo interno
6. Verifica con `pwd` e `ls` di essere nella cartella giusta e che il file sia presente

## Requirements
- [ ] Usare `grep` con il pattern corretto per contare le sequenze
- [ ] Usare `grep` per estrarre solo gli header
- [ ] Usare `head` per le prime 4 righe
- [ ] Usare `wc -l` per contare le righe
- [ ] Usare `mkdir` e `mv`
- [ ] Usare `pwd` e `ls` per verificare

## Hints

<details>
<summary>Hint 1</summary>

Per contare le sequenze: ogni record FASTA inizia con `>`. Quale flag di `grep` conta le corrispondenze invece di mostrarle?

</details>

<details>
<summary>Hint 2</summary>

Il pattern `"^>"` significa "riga che **inizia** con `>`". Il carattere `^` in una regex indica l'inizio riga. Senza `^`, grep troverebbe anche `>` nel mezzo di una riga di testo (raro nei FASTA, ma buona abitudine usarlo sempre).

</details>

## Solution Outline

<details>
<summary>Mostra soluzione</summary>

```bash
# 1. Conta sequenze
grep -c "^>" hsp70.fasta

# 2. Solo header
grep "^>" hsp70.fasta

# 3. Prime 4 righe
head -4 hsp70.fasta

# 4. Righe totali
wc -l hsp70.fasta

# 5. Crea cartella e sposta
mkdir analisi
mv hsp70.fasta analisi/

# 6. Verifica
pwd
ls analisi/
```

Risultati attesi:
- Sequenze: 4
- Header: 4 righe che iniziano con `>`
- Righe totali: 9 (4 header + 4 righe di sequenza + 1 riga vuota finale)

</details>
