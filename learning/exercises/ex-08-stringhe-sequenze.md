# Esercizio 8: Analisi di sequenze con stringhe e array

## Modulo correlato
[module-08-stringhe-sequenze.md](../module-08-stringhe-sequenze.md)

## Difficoltà
Hard

---

## Scenario

Hai un piccolo file FASTA con sequenze di cui devi calcolare le proprietà di base — senza installare nessuno strumento esterno. Tutto in BASH puro, usando la manipolazione di stringhe e gli array associativi che hai imparato.

---

## Setup — crea i file di test

```bash
mkdir -p stringhe_test

cat > stringhe_test/sequences.fasta << 'EOF'
>SEQ001 gene A - Homo sapiens
ATGCGCATGCGCATGCGCATGCGCATGCGC
ATGCGCATGCGCATGCGCATGCGCATGCGC
>SEQ002 gene B - Mus musculus
AAAATTTTCCCCGGGGAAAATTTTCCCCGGGG
>SEQ003 gene C - Danio rerio
ATATATATATATATATATAT
>SEQ004 gene D - mixed
ATGCNNATGCNNATGCNNATGCNN
>SEQ005 gene E - all GC
GCGCGCGCGCGCGCGCGCGCGCGCGCGCGC
EOF
```

---

## Task

Scrivi lo script `stringhe_test/analisi_sequenze.sh` che:

1. **Legge il file FASTA** `stringhe_test/sequences.fasta` usando il loop di parsing
2. **Per ogni sequenza calcola:**
   - Lunghezza in bp con `${#seq}`
   - GC content (%) — usa `${seq//[^GCgc]/}` per isolare G e C
   - Composizione: numero di A, T, G, C, N — usa un array associativo `declare -A`
   - Se la sequenza contiene N (basi ambigue): sì/no
3. **Stampa a schermo** un riepilogo per ogni sequenza
4. **Al termine** stampa:
   - La sequenza con il GC content più alto (nome e valore)
   - La lunghezza media di tutte le sequenze

### Output atteso

```
=== SEQ001 ===
Lunghezza: 60 bp
GC content: 66.7%
Composizione: A=10 T=10 G=20 C=20 N=0
Basi ambigue: no

=== SEQ002 ===
Lunghezza: 32 bp
GC content: 50.0%
Composizione: A=8 T=8 G=8 C=8 N=0
Basi ambigue: no

=== SEQ003 ===
Lunghezza: 20 bp
GC content: 0.0%
Composizione: A=10 T=10 G=0 C=0 N=0
Basi ambigue: no

=== SEQ004 ===
Lunghezza: 24 bp
GC content: 33.3%
Composizione: A=4 T=4 G=4 C=4 N=8
Basi ambigue: sì

=== SEQ005 ===
Lunghezza: 30 bp
GC content: 100.0%
Composizione: A=0 T=0 G=15 C=15 N=0
Basi ambigue: no

--- Riepilogo ---
Sequenza con GC più alto: SEQ005 (100.0%)
Lunghezza media: 33 bp
```

---

## Requisiti

- [ ] Usare il loop di parsing FASTA (header + accumulazione sequenza)
- [ ] Estrarre il nome della sequenza dall'header con `${var%%  *}` o simile (togliere il `>` e prendere solo la prima parola)
- [ ] Calcolare la lunghezza con `${#seq}`
- [ ] Calcolare il GC content con `${seq//[^GCgc]/}` e `awk` per le percentuali con decimali
- [ ] Usare `declare -A` per la composizione nucleotidica
- [ ] Tracciare il massimo GC content con un array associativo o variabili
- [ ] Calcolare la lunghezza media alla fine con `$(( tot / n ))`

---

## Hints

<details>
<summary>Hint 1 — estrarre il nome della sequenza dall'header</summary>

L'header è tipo `>SEQ001 gene A - Homo sapiens`. Vuoi solo `SEQ001`.

```bash
# Rimuovi il > iniziale
senza_gt="${header#>}"
# Prendi solo la prima parola (fino al primo spazio)
nome="${senza_gt%% *}"
# Oppure in un passo solo
nome="${header#>}"
nome="${nome%% *}"
```

</details>

<details>
<summary>Hint 2 — calcolo GC content con awk</summary>

```bash
seq_upper="${seq^^}"   # normalizza in maiuscolo
solo_gc="${seq_upper//[^GC]/}"   # rimuove tutto tranne G e C
n_gc=${#solo_gc}
tot=${#seq_upper}
gc_pct=$(awk -v gc="$n_gc" -v tot="$tot" 'BEGIN { printf "%.1f", gc/tot*100 }')
```

Se `tot` è 0 (sequenza vuota), la divisione darebbe errore — aggiungi un controllo.

</details>

<details>
<summary>Hint 3 — composizione con array associativo</summary>

```bash
declare -A comp
for base in A T G C N; do comp[$base]=0; done

seq_upper="${seq^^}"
for (( i=0; i<${#seq_upper}; i++ )); do
    b="${seq_upper:$i:1}"
    if [[ -v comp[$b] ]]; then
        (( comp[$b]++ )) || true
    fi
done
```

Nota `|| true`: evita che `(( comp[$b]++ ))` esca con errore quando il valore è 0 (BASH considera `(( 0 ))` un exit code 1 — un'eccezione bizzarra ma reale).

</details>

<details>
<summary>Hint 4 — tracciare il massimo GC</summary>

Hai bisogno di confrontare floats. BASH fa solo aritmetica intera, quindi usa i centesimi come interi:

```bash
# Invece di confrontare 66.7 e 50.0, confronta 667 e 500
gc_int=$(awk -v gc="$n_gc" -v tot="$tot" 'BEGIN { printf "%d", gc/tot*1000 }')

if [ "$gc_int" -gt "$max_gc_int" ]; then
    max_gc_int=$gc_int
    max_gc_nome="$nome"
    max_gc_pct="$gc_pct"
fi
```

</details>

## Solution Outline

<details>
<summary>Mostra la traccia della soluzione</summary>

1. **Inizializza**: `max_gc_int=0`, `max_gc_nome=""`, `max_gc_pct=""`, `lunghezza_tot=0`, `n_seq=0`
2. **Loop di parsing FASTA**: accumula `$seq`, processa al prossimo header o fine file
3. **Per ogni sequenza**:
   a. Estrai `$nome` dall'header
   b. Normalizza `${seq^^}`
   c. Calcola lunghezza con `${#seq}`
   d. Calcola GC: isola con `${seq//[^GC]/}`, percentuale con `awk`
   e. Loop su caratteri per la composizione con `declare -A comp`
   f. Controlla N con `[ "${comp[N]}" -gt 0 ]`
   g. Aggiorna il massimo GC comparando gli interi (`gc_int`)
   h. Accumula `lunghezza_tot` e incrementa `n_seq`
4. **Riepilogo**: stampa `$max_gc_nome` e `$(( lunghezza_tot / n_seq ))`

La parte più sottile è `(( comp[$b]++ )) || true` — senza `|| true`, quando il contatore è 0 BASH esce (perché `(( 0 ))` è exit code 1).

</details>
