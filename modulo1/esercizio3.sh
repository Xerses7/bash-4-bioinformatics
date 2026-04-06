c\x\#!/bin/bash

# Crea un file con dei nomi
cat > /tmp/nomi.txt << EOF
Dario
Alice
Bob
Dario
Carlo
Alice
Dario
EOF

echo "=== File originale ==="
cat /tmp/nomi.txt

echo "=== Nomi unici ordinati ==="
sort /tmp/nomi.txt | uniq

echo "=== Quante righe in totale ==="
wc -l < /tmp/nomi.txt

echo "=== Solo le righe con 'Dario' ==="
grep "Dario" /tmp/nomi.txt
