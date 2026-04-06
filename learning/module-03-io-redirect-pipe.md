# Modulo 3: Input/Output, Redirect e Pipe

## Obiettivo
Capire i tre canali I/O di Unix (stdin, stdout, stderr), redirigere l'output su file e collegare comandi tra loro con le pipe.

## Prerequisiti
[Modulo 2: Variabili](module-02-variabili.md)

---

## Concetti

### I tre canali I/O

Ogni processo Unix ha tre canali di comunicazione:

| Canale | Nome | Numero | Descrizione |
|--------|------|--------|-------------|
| stdin  | Standard Input  | 0 | Input (di solito la tastiera) |
| stdout | Standard Output | 1 | Output normale |
| stderr | Standard Error  | 2 | Messaggi di errore |

### Redirect dell'output

```bash
echo "testo" > file.txt       # sovrascrive il file (crea se non esiste)
echo "altro" >> file.txt      # aggiunge in fondo (append)
```

### Redirect degli errori

```bash
comando 2> errori.txt         # redirige solo stderr su file
comando > out.txt 2>&1        # redirige stdout e stderr nello stesso file
comando > out.txt 2> err.txt  # separa stdout e stderr su file diversi
```

`2>&1` significa: "manda il canale 2 (stderr) verso dove va il canale 1 (stdout)".

### Redirect dell'input

```bash
wc -l < file.txt              # legge da file invece che da tastiera
```

### Pipe — collegare comandi

La pipe `|` prende lo stdout di un comando e lo passa come stdin al successivo.

```bash
ls -l | wc -l                         # quanti file nella cartella
cat file.txt | sort                   # ordina le righe del file
cat file.txt | sort | uniq            # rimuove i duplicati
cat file.txt | sort | uniq -c        # conta le occorrenze di ogni riga
```

Visualizzalo così:
```
[comando1] --stdout--> [comando2] --stdout--> [comando3]
```

### Comandi utili nelle pipe

```bash
sort             # ordina le righe alfabeticamente (o numericamente con -n)
uniq             # rimuove righe duplicate adiacenti (usare DOPO sort)
uniq -c          # aggiunge il conteggio davanti a ogni riga unica
wc -l            # conta le righe
wc -w            # conta le parole
wc -c            # conta i caratteri
grep "pattern"   # filtra solo le righe che contengono il pattern
head -N          # mostra solo le prime N righe
tail -N          # mostra solo le ultime N righe
tr 'a-z' 'A-Z'  # trasforma caratteri (qui: minuscolo → maiuscolo)
```

### Esempio pratico

```bash
# Trova i 3 file modificati più di recente, mostra solo i nomi
ls -lt | tail -n +2 | head -3 | awk '{print $NF}'

# Conta quante righe del file contengono "errore" (case-insensitive)
grep -i "errore" log.txt | wc -l
```

---

## Key Takeaways
- stdout (1) è l'output normale, stderr (2) sono gli errori
- `>` sovrascrive, `>>` aggiunge
- `2>&1` unisce stderr a stdout
- La pipe `|` è uno dei costrutti più potenti di Unix
- `sort | uniq` è una coppia classica per deduplicare

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-03-io-redirect-pipe.md](exercises/ex-03-io-redirect-pipe.md)
→ Poi vai a: [module-04-condizionali.md](module-04-condizionali.md)
