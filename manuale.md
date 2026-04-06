# Manuale BASH — Moduli 1-4

---

## Modulo 1 — La shell e i comandi base

```bash
pwd                  # cartella corrente
ls -la               # elenca file (inclusi nascosti)
cd /percorso         # spostati in una cartella
cd ..                # sali di un livello
cd -                 # torna alla cartella precedente

mkdir -p a/b/c       # crea cartella (e sottocartelle)
touch file.txt       # crea file vuoto
cp origine dest      # copia
mv origine dest      # sposta / rinomina
rm file.txt          # elimina file
rm -r cartella/      # elimina cartella

cat file.txt         # stampa file
head -5 file.txt     # prime 5 righe
tail -5 file.txt     # ultime 5 righe
less file.txt        # sfoglia (q per uscire)
```

---

## Modulo 2 — Variabili

```bash
nome="Dario"         # assegna (nessuno spazio intorno a =)
echo "${nome}"       # usa la variabile (preferire le {})

echo "$nome"         # interpreta la variabile
echo '$nome'         # stringa letterale: $nome

# Variabili speciali
$0                   # nome dello script
$1 $2 ...            # argomenti passati allo script
$#                   # numero di argomenti
$?                   # exit code dell'ultimo comando (0 = successo)
$$                   # PID del processo corrente

# Command substitution
oggi=$(date)         # salva l'output di un comando in una variabile
n=$(ls | wc -l)
```

---

## Modulo 3 — Input/Output, Redirect e Pipe

```bash
# Redirect output
echo "testo" > file.txt      # sovrascrive
echo "testo" >> file.txt     # aggiunge in fondo

# Redirect errori
comando 2> errori.txt        # redirige stderr
comando > out.txt 2>&1       # redirige stdout e stderr insieme

# Redirect input
wc -l < file.txt             # legge da file invece che da tastiera

# Pipe: collega stdout di un comando a stdin del successivo
ls -l | wc -l
cat file.txt | sort | uniq
cat file.txt | sort | uniq -c    # conta le occorrenze

# Comandi utili nelle pipe
sort         # ordina righe
uniq         # rimuove duplicati adiacenti (usare dopo sort)
uniq -c      # conta occorrenze
wc -l        # conta righe
wc -w        # conta parole
grep "testo" # filtra righe che contengono "testo"
head -N      # prime N righe
tail -N      # ultime N righe
tr 'a-z' 'A-Z'  # trasforma caratteri
```

---

## Modulo 4 — Condizionali

```bash
if [ condizione ]; then
    # comandi
elif [ altra_condizione ]; then
    # comandi
else
    # comandi
fi

# Confronto numerico
[ "$a" -eq "$b" ]    # uguale
[ "$a" -ne "$b" ]    # diverso
[ "$a" -lt "$b" ]    # minore
[ "$a" -gt "$b" ]    # maggiore
[ "$a" -le "$b" ]    # minore o uguale
[ "$a" -ge "$b" ]    # maggiore o uguale

# Confronto stringhe
[ "$a" = "$b" ]      # uguale
[ "$a" != "$b" ]     # diverso
[ -z "$a" ]          # stringa vuota
[ -n "$a" ]          # stringa non vuota

# Controllo file
[ -f "$file" ]       # esiste ed è un file
[ -d "$dir" ]        # esiste ed è una cartella
[ -e "$path" ]       # esiste (file o cartella)
[ -x "$file" ]       # è eseguibile

# Operatori logici
[ "$a" -gt 0 ] && [ "$a" -lt 10 ]   # AND
[ "$a" -eq 0 ] || [ "$a" -eq 1 ]    # OR
! [ -f "$file" ]                     # NOT
```

---

## Note importanti

- Usa sempre `bash script.sh` (non `sh`) per eseguire gli script
- Oppure `chmod +x script.sh` e poi `./script.sh` (usa lo shebang)
- Metti sempre le variabili tra virgolette: `"${var}"` evita errori con spazi
- Il heredoc `<< EOF` richiede che `EOF` sia su una riga senza spazi
- `uniq` rimuove solo duplicati adiacenti — usalo sempre dopo `sort`
- `[ ]` è POSIX, `[[ ]]` è solo BASH (non funziona con `sh`)
```
