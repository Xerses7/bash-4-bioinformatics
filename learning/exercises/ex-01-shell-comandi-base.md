# Esercizio 1: Navigazione e gestione file

## Modulo correlato
[Modulo 1: La shell e i comandi base](../module-01-shell-comandi-base.md)

## Difficoltà
Facile

## Compito
Esplora il filesystem e gestisci file e cartelle da terminale, senza GUI.

## Requisiti

- [ ] Stampa la cartella corrente
- [ ] Elenca i file nella home, inclusi quelli nascosti
- [ ] Crea una struttura di cartelle `tmp/progetto/src` con un solo comando
- [ ] Crea tre file vuoti dentro `tmp/progetto/src`: `main.sh`, `utils.sh`, `config.sh`
- [ ] Copia `main.sh` in `tmp/progetto/` e rinominalo `main_backup.sh`
- [ ] Mostra le prime 3 righe di un file di testo a tua scelta
- [ ] Cancella tutta la struttura `tmp/` con un solo comando

## Hints

<details>
<summary>Hint 1</summary>
Per creare una catena di cartelle con un solo comando, guarda l'opzione `-p` di `mkdir`.
</details>

<details>
<summary>Hint 2</summary>
Per creare più file vuoti contemporaneamente: `touch file1.sh file2.sh file3.sh`
</details>

<details>
<summary>Hint 3</summary>
Per cancellare ricorsivamente una cartella e tutto il contenuto usa `rm -r`.
</details>

## Soluzione (schema)

<details>
<summary>Mostra schema soluzione</summary>

```bash
pwd
ls -la ~
mkdir -p tmp/progetto/src
touch tmp/progetto/src/main.sh tmp/progetto/src/utils.sh tmp/progetto/src/config.sh
cp tmp/progetto/src/main.sh tmp/progetto/main_backup.sh
head -3 /etc/os-release      # o qualsiasi altro file di testo
rm -r tmp/
```

L'ordine dei comandi conta: non puoi copiare `main.sh` prima di crearlo.
</details>
