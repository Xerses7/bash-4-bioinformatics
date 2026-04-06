# Esercizio 4: Condizionali

## Modulo correlato
[Modulo 4: Condizionali](../module-04-condizionali.md)

## Difficoltà
Media

## Compito
Scrivi uno script che usa condizionali per classificare un'età, controllare una stringa e verificare l'esistenza di file e cartelle.

Vedi gli script di riferimento: [`../../modulo1/esercizio4.sh`](../../modulo1/esercizio4.sh) e [`../../modulo1/esercizio4b.sh`](../../modulo1/esercizio4b.sh)

## Requisiti

- [ ] Assegna un'età a una variabile. Classifica con if/elif/else: minorenne (< 18), adulto (18-64), anziano (≥ 65)
- [ ] Assegna un nome a una variabile. Se la stringa è vuota, stampa un avviso; altrimenti saluta per nome
- [ ] Controlla se il file `/tmp/nomi.txt` esiste e stampa un messaggio appropriato
- [ ] Controlla se `/tmp/cartella_inesistente` esiste come cartella

## Hints

<details>
<summary>Hint 1</summary>
Per il range numerico (es. tra 18 e 64) devi combinare due condizioni con `&&`:
```bash
[ "$eta" -ge 18 ] && [ "$eta" -lt 65 ]
```
</details>

<details>
<summary>Hint 2</summary>
Per verificare se una stringa è vuota usa `-z`:
```bash
[ -z "$nome" ]
```
</details>

<details>
<summary>Hint 3</summary>
Per file usa `-f`, per cartelle usa `-d`.
</details>

## Soluzione (schema)

<details>
<summary>Mostra schema soluzione</summary>

```bash
#!/bin/bash

# Test numerico
eta=25
if [ "$eta" -lt 18 ]; then
    echo "Sei minorenne"
elif [ "$eta" -ge 18 ] && [ "$eta" -lt 65 ]; then
    echo "Sei adulto"
else
    echo "Sei anziano"
fi

# Test su stringa
nome="Dario"
if [ -z "$nome" ]; then
    echo "Il nome è vuoto"
else
    echo "Ciao, ${nome}!"
fi

# Test su file
file="/tmp/nomi.txt"
if [ -f "$file" ]; then
    echo "Il file ${file} esiste"
else
    echo "Il file ${file} non esiste"
fi

# Test su cartella
cartella="/tmp/cartella_inesistente"
if [ -d "$cartella" ]; then
    echo "La cartella esiste"
else
    echo "La cartella non esiste"
fi
```
</details>

---

## Esercizio bonus (riepilogo moduli 1-4)

Completa lo script [`../../modulo1/esercizio_riepilogo.sh`](../../modulo1/esercizio_riepilogo.sh).

È uno script vuoto con commenti che guidano — devi riempire il codice da solo. Copre variabili, command substitution, condizionali, redirect e pipe.
