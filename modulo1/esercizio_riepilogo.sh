#!/bin/bash

# Questo script analizza i file nella cartella corrente.
# Completa il codice sotto ogni commento.

# --- PARTE 1: Variabili ---

# Assegna il percorso della cartella corrente a una variabile chiamata "cartella"
# (usa command substitution con pwd)


# Assegna il numero di file presenti nella cartella a una variabile chiamata "n_file"
# (usa: ls | wc -l)


# Stampa: "Cartella: <valore di cartella>"


# Stampa: "Numero di file: <valore di n_file>"


# --- PARTE 2: Condizionale ---

# Se n_file è uguale a 0, stampa "La cartella è vuota"
# Altrimenti se n_file è minore di 5, stampa "Pochi file (<n_file>)"
# Altrimenti stampa "Molti file (<n_file>)"
# (nelle ultime due stampe mostra il numero reale di file)


# --- PARTE 3: File di log ---

# Assegna "/tmp/log_esercizio.txt" alla variabile "logfile"


# Scrivi nel logfile (con >) la stringa "Analisi eseguita il: " seguita dalla data corrente
# (usa command substitution con: date "+%Y-%m-%d %H:%M")


# Se il logfile esiste, stampa "Log salvato in: <logfile>"


# --- PARTE 4: Pipe ---

# Crea il file /tmp/parole.txt con questo contenuto (copia il heredoc così com'è):
cat > /tmp/parole.txt << EOF
mela
pera
mela
banana
pera
mela
kiwi
EOF

# Stampa "=== Parole uniche ordinate ==="


# Stampa le parole uniche ordinate (usa sort e uniq)


# Stampa "=== Parola più frequente ==="


# Trova la parola più frequente e stampala con il suo conteggio
# (usa sort, uniq -c, sort -rn, head -1)
