#!/bin/bash

# Assegna il valore 70 alla variabile "eta"
eta=70

# Se eta è minore di 18, stampa "Sei minorenne"
if test ${eta} -lt 18; then
    echo "Sei minorenne"
# Altrimenti se eta è tra 18 e 64 (inclusi), stampa "Sei adulto"
elif [ "${eta}" -ge 18 ] && [ "${eta}" -le 64 ]; then
    echo "Sei adulto"
# Altrimenti stampa "Sei anziano"
else 
    echo "Sei anziano"
fi

# Assegna una stringa vuota alla variabile "nome"
nome="" 
# Se nome è vuoto, stampa "Il nome è vuoto"
if [ -z ${nome} ]; then
    echo "Il nome è vuoto"
# Altrimenti stampa "Ciao, " seguito dal nome
else 
    echo "Ciao, ${nome}" 
fi

# Assegna "/tmp/nomi.txt" alla variabile "file"
file="/tmp/nomi.txt"

# Se il file esiste, stampa "Il file esiste"
if [ -f ${file} ]; then
    echo "Il file esiste"
# Altrimenti stamppa "Il file non esiste"
else
    echo "Il file non esiste"
fi
