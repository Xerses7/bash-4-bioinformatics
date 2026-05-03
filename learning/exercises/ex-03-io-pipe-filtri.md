# Esercizio 3: Pipeline per filtrare sequenze

## Modulo di riferimento
[module-03-io-pipe-filtri.md](../module-03-io-pipe-filtri.md)

## Difficoltà
Medio

## Scenario
Hai ricevuto un file FASTA con sequenze della famiglia HSP70 da più specie. Devi estrarre le sequenze umane, costruire un report e organizzare i risultati in file separati.

## Setup
Crea il dataset di test:

```bash
cat > database_hsp.fasta << 'EOF'
>NP_005339.2 HSP70 member 1A [Homo sapiens]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>NP_006588.1 HSP70 member 8 [Homo sapiens]
MSKGPAVGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>NP_031381.2 heat shock protein 1 [Mus musculus]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>XP_016793815.1 heat shock 70kDa protein [Mus musculus]
MSKGPAVGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>NP_001291958.1 HSP70 [Danio rerio]
MAKAAAIGIDLGTTYSCVGVFQHGKVEIIANDQGNRTTPSYVAFTDTERLIGDAAK
>P11021.3 78 kDa glucose-regulated protein [Homo sapiens]
MKLSLVAAMLLLLSAARAGSSHHHHHHHGSACPGACTFCGACTSPACTSPACTSP
EOF
```

## Task

1. Quante sequenze totali ci sono in `database_hsp.fasta`?
2. Estrai solo gli header delle sequenze di *Homo sapiens* e salvali in `human_headers.txt`
3. Usa **`tee`** per estrarre gli header umani, salvarli in `human_headers.txt` **e** stampare contemporaneamente quante sono (tutto in un solo comando)
4. Costruisci un file `report.txt` con questo contenuto:
   ```
   === Analisi database_hsp.fasta ===
   Totale sequenze: 6
   Sequenze Homo sapiens: 3
   --- Header umani ---
   >NP_005339.2 HSP70 member 1A [Homo sapiens]
   >NP_006588.1 HSP70 member 8 [Homo sapiens]
   >P11021.3 78 kDa glucose-regulated protein [Homo sapiens]
   ```
5. Ogni comando che potrebbe produrre errori deve redirigere stderr in `errori.log`

## Requirements
- [ ] Usare `|` in almeno 2 comandi diversi
- [ ] Usare `>` e `>>` per costruire il report progressivamente
- [ ] Usare `tee` nel punto 3 per fare due cose con un solo comando
- [ ] Usare `2>` per redirigere stderr
- [ ] Il report deve essere costruito senza aprire un editor di testo

## Hints

<details>
<summary>Hint 1</summary>

Per filtrare header umani:
```bash
grep "^>" database_hsp.fasta | grep "Homo sapiens"
```
La doppia `grep` funziona in pipe: la prima estrae le righe header, la seconda filtra per specie.

</details>

<details>
<summary>Hint 2</summary>

Per costruire il report progressivamente usa `>` per la prima riga e `>>` per tutte le successive:
```bash
echo "Titolo" > report.txt
echo "Altra riga" >> report.txt
grep "^>" database_hsp.fasta >> report.txt
```

</details>

<details>
<summary>Hint 3</summary>

`tee` si mette in mezzo a una pipe. Salva su file ciò che passa, e lo lascia scorrere al comando successivo:
```bash
grep "^>" database_hsp.fasta | grep "Homo sapiens" | tee human_headers.txt | wc -l
```
Questo salva gli header in `human_headers.txt` E stampa il conteggio.

</details>

## Solution Outline

<details>
<summary>Mostra soluzione</summary>

```bash
# 1. Totale sequenze
grep -c "^>" database_hsp.fasta

# 2. Salva header umani
grep "^>" database_hsp.fasta | grep "Homo sapiens" > human_headers.txt

# 3. Con tee: salva E conta in un colpo
grep "^>" database_hsp.fasta | grep "Homo sapiens" | tee human_headers.txt | wc -l

# 4. Costruisci il report progressivamente
echo "=== Analisi database_hsp.fasta ===" > report.txt
echo "Totale sequenze: $(grep -c "^>" database_hsp.fasta)" >> report.txt
echo "Sequenze Homo sapiens: $(grep "^>" database_hsp.fasta | grep -c "Homo sapiens")" >> report.txt
echo "--- Header umani ---" >> report.txt
grep "^>" database_hsp.fasta | grep "Homo sapiens" >> report.txt

# 5. Versione con gestione errori
grep "^>" database_hsp.fasta | grep "Homo sapiens" > human_headers.txt 2> errori.log
```

</details>
