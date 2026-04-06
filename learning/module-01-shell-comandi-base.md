# Modulo 1: La shell e i comandi base

## Obiettivo
Navigare il filesystem da terminale e usare i comandi fondamentali per gestire file e cartelle.

## Prerequisiti
Nessuno — è il punto di partenza.

---

## Concetti

### Cos'è la shell?
La shell è un programma che riceve comandi testuali e li esegue. BASH (*Bourne Again SHell*) è la shell più diffusa su Linux e macOS.

Quando apri un terminale, stai parlando con la shell. Ogni cosa che digiti è un comando che la shell interpreta ed esegue.

### Orientarsi nel filesystem

```bash
pwd          # stampa la cartella corrente (Print Working Directory)
ls           # elenca i file nella cartella corrente
ls -l        # lista dettagliata (permessi, dimensione, data)
ls -la       # include anche i file nascosti (quelli che iniziano con .)
```

### Spostarsi tra cartelle

```bash
cd /percorso/assoluto   # vai a un percorso preciso
cd cartella             # vai in una sottocartella
cd ..                   # sali di un livello
cd -                    # torna alla cartella precedente
cd ~                    # vai alla home
```

**Percorso assoluto vs relativo:**
- `/home/dario/Documenti` → assoluto (parte dalla radice `/`)
- `Documenti/progetti` → relativo (parte dalla cartella corrente)

### Creare e cancellare

```bash
mkdir nuova-cartella          # crea una cartella
mkdir -p a/b/c                # crea l'intera catena di cartelle
touch file.txt                # crea un file vuoto (o aggiorna la data)
rm file.txt                   # cancella un file
rm -r cartella/               # cancella una cartella e tutto il suo contenuto
rmdir cartella/               # cancella solo se vuota
```

### Copiare e spostare

```bash
cp origine destinazione       # copia un file
cp -r cartella/ dest/         # copia una cartella intera
mv origine destinazione       # sposta (o rinomina)
```

### Leggere il contenuto di un file

```bash
cat file.txt                  # stampa tutto il file
head -5 file.txt              # prime 5 righe
tail -5 file.txt              # ultime 5 righe
less file.txt                 # sfoglia (frecce per muoversi, q per uscire)
```

---

## Key Takeaways
- `pwd`, `ls`, `cd` sono i tre comandi di navigazione fondamentali
- `-r` (recursive) è necessario per operazioni su cartelle intere
- `rm` è definitivo: non va nel cestino
- `less` è più utile di `cat` per file lunghi

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-01-shell-comandi-base.md](exercises/ex-01-shell-comandi-base.md)
→ Poi vai a: [module-02-variabili.md](module-02-variabili.md)
