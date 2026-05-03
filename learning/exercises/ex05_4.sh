#!/bin/bash

while IFS= read -r line; do
    echo "Scarico: $line"
done < testloop/lista.txt