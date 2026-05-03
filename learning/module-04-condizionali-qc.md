# Modulo 4: Condizionali | Controllo qualità delle sequenze

## Obiettivo
Scrivere logica condizionale in BASH con if/elif/else, e applicarla al Quality Control (QC) basilare di file FASTA — verificare che i dati siano nel formato corretto prima di lanciare qualsiasi analisi.

## Prerequisiti
- Moduli 1-3: comandi base, variabili, I/O e pipe

---

## Parte 1 — BASH: Condizionali

### Struttura di base

```bash
if [ condizione ]; then
    # eseguito se vera
elif [ altra_condizione ]; then
    # eseguito se la seconda è vera
else
    # eseguito se nessuna condizione è vera
fi
```

Le parentesi quadre `[ ]` sono in realtà il comando `test`. Puoi usare anche `[[ ]]` (versione estesa, più robusta per stringhe).

### Test su file

```bash
[ -f file.fasta ]    # esiste ed è un file regolare?
[ -d cartella/ ]     # esiste ed è una cartella?
[ -e percorso ]      # esiste (file, cartella, link...)?
[ -s file.fasta ]    # esiste ed è NON vuoto?
[ -r file.fasta ]    # è leggibile?
[ -w file.fasta ]    # è scrivibile?
```

Esempio classico all'inizio di ogni script:

```bash
if [ ! -f "$input" ]; then
    echo "Errore: file non trovato: $input"
    exit 1
fi
```

### Test su stringhe

```bash
[ "$a" = "$b" ]      # uguali (usare = non ==)
[ "$a" != "$b" ]     # diversi
[ -z "$a" ]          # stringa vuota (zero length)
[ -n "$a" ]          # stringa non vuota (non-zero)
```

### Test su numeri interi

```bash
[ "$n" -eq 0 ]    # uguale (equal)
[ "$n" -ne 0 ]    # diverso (not equal)
[ "$n" -lt 10 ]   # minore di (less than)
[ "$n" -gt 10 ]   # maggiore di (greater than)
[ "$n" -le 10 ]   # minore o uguale (less or equal)
[ "$n" -ge 10 ]   # maggiore o uguale (greater or equal)
```

**Nota:** per i numeri usa sempre `-eq`, `-lt`, ecc. — mai `=` o `<` che in BASH hanno significato diverso.

### Combinare condizioni

```bash
[ cond1 ] && [ cond2 ]    # AND: entrambe vere
[ cond1 ] || [ cond2 ]    # OR: almeno una vera
! [ condizione ]           # NOT: negazione
```

### Forma compatta (senza if)

```bash
[ -f "$file" ] && echo "File trovato"
[ -f "$file" ] || { echo "Errore: file mancante"; exit 1; }
```

---

## Parte 2 — Bioinformatica: Controllo qualità delle sequenze

### Cos'è il QC in bioinformatica?

**Quality Control (QC)** è la verifica che i dati in ingresso siano validi prima di avviare l'analisi. È il primo step di qualsiasi pipeline seria.

Il principio è semplice: *garbage in, garbage out*. Un'analisi lanciata su un file corrotto o malformato produrrà risultati sbagliati — spesso senza errori visibili, il che è il caso peggiore.

Il QC minimo su un file FASTA include:
1. Il file esiste?
2. Il file non è vuoto?
3. Il formato è corretto (ha almeno un header `>`)?
4. Il numero di sequenze è sufficiente?
5. Ci sono sequenze con troppi caratteri ambigui (`N`, `X`)?

### Un script di QC basilare

```bash
#!/bin/bash
input="sequenze.fasta"

# 1. Il file esiste?
if [ ! -f "$input" ]; then
    echo "ERRORE: file non trovato: $input"
    exit 1
fi

# 2. Il file non è vuoto?
if [ ! -s "$input" ]; then
    echo "ERRORE: il file è vuoto: $input"
    exit 1
fi

# 3. Ha almeno un header FASTA valido?
n_seq=$(grep -c "^>" "$input")
if [ "$n_seq" -eq 0 ]; then
    echo "ERRORE: nessun header FASTA trovato in $input"
    exit 1
fi

echo "QC superato: $n_seq sequenze trovate in $input"
```

`exit 1` termina lo script con un codice di errore — indica al sistema (e agli script che lo chiamano) che qualcosa è andato storto. `exit 0` indica successo.

### Verificare il numero minimo di sequenze

Alcuni tool bioinformatici richiedono almeno N sequenze per funzionare correttamente. Un allineamento multiplo con una sola sequenza, ad esempio, non ha senso.

```bash
min_seq=2

n_seq=$(grep -c "^>" "$input")

if [ "$n_seq" -lt "$min_seq" ]; then
    echo "ERRORE: il file contiene $n_seq sequenze (minimo richiesto: $min_seq)"
    exit 1
fi
```

### Rilevare caratteri ambigui

La presenza di `N` nelle sequenze nucleotidiche indica nucleotidi non determinati:
- In piccola quantità: normale (regioni ripetute, confini di esoni)
- In grande quantità: spesso indica sequenziamento di scarsa qualità o assembly frammentato

```bash
# Quante righe di sequenza contengono N?
n_con_N=$(grep -v "^>" "$input" | grep -c "N")
totale_righe=$(grep -v "^>" "$input" | wc -l)

if [ "$n_con_N" -gt 0 ]; then
    echo "ATTENZIONE: $n_con_N/$totale_righe righe contengono caratteri N"
fi
```

Questo è un **avviso** (warning), non un blocco — le sequenze con N possono essere legittime. La scelta di fermarsi o procedere dipende dall'analisi.

### Distinguere avviso da errore

Un pattern importante nella bioinformatica (e in generale):

```bash
if [ condizione_fatale ]; then
    echo "ERRORE: ..."   # problema grave, non si può procedere
    exit 1
fi

if [ condizione_sospetta ]; then
    echo "ATTENZIONE: ..."   # da tenere d'occhio, ma si può continuare
fi
```

Usare prefissi `ERRORE:` e `ATTENZIONE:` nei messaggi rende i log molto più leggibili.

---

## Key Takeaways

**BASH:**
- `[ -f ]`, `[ -d ]`, `[ -s ]` per test su file
- `-eq`, `-lt`, `-gt`, `-ge`, `-le`, `-ne` per confronti numerici
- `[ "$a" = "$b" ]` per confronti tra stringhe
- `exit 1` segnala errore, `exit 0` successo
- Combina condizioni con `&&`, `||`, `!`

**Bioinformatica:**
- Il QC è sempre il primo step: *garbage in, garbage out*
- QC minimo FASTA: file esiste (`-f`), non è vuoto (`-s`), ha header (`grep -c "^>"`), ha abbastanza sequenze
- `N` in DNA e `X` in proteine = ambiguità — troppi indicano qualità bassa
- Distingui errori bloccanti (`exit 1`) da avvisi non bloccanti (solo `echo`)

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-04-condizionali-qc.md](exercises/ex-04-condizionali-qc.md)
→ Poi vai a: [module-05-loop-batch.md](module-05-loop-batch.md)
