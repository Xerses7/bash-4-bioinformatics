#!/bin/bash

# --- Test numerico ---
eta=25

if [ "$eta" -lt 18 ]; then
    echo "Sei minorenne"
elif [ "$eta" -ge 18 ] && [ "$eta" -lt 65 ]; then
    echo "Sei adulto"
else
    echo "Sei anziano"
fi

# --- Test su stringa ---
nome="Dario"

if [ -z "$nome" ]; then
    echo "Il nome è vuoto"
else
    echo "Ciao, ${nome}!"
fi

# --- Test su file ---
file="/tmp/nomi.txt"

if [ -f "$file" ]; then
    echo "Il file ${file} esiste"
else
    echo "Il file ${file} non esiste"
fi

# --- Test su cartella ---
cartella="/tmp/cartella_inesistente"

if [ -d "$cartella" ]; then
    echo "La cartella esiste"
else
    echo "La cartella non esiste"
fi
