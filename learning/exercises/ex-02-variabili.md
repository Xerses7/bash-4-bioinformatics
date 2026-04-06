# Esercizio 2: Variabili e command substitution

## Modulo correlato
[Modulo 2: Variabili](../module-02-variabili.md)

## Difficoltà
Facile

## Compito
Scrivi uno script che usa variabili, variabili speciali e command substitution per stampare informazioni sull'ambiente corrente.

Puoi partire dallo script esistente: [`../../modulo1/variabili.sh`](../../modulo1/variabili.sh)

## Requisiti

- [ ] Assegna il tuo nome a una variabile `nome`
- [ ] Assegna un saluto a una variabile `saluto`
- [ ] Stampa `"<saluto>, <nome>!"`
- [ ] Stampa la data corrente usando command substitution
- [ ] Stampa la cartella corrente usando command substitution
- [ ] Stampa quanti file ci sono nella cartella corrente usando command substitution + pipe

## Hints

<details>
<summary>Hint 1</summary>
Per la data in formato leggibile: `date +"%A %d %B %Y"`
</details>

<details>
<summary>Hint 2</summary>
Per contare i file nella cartella corrente: `ls | wc -l`
Metti questo comando dentro `$(...)` per catturarne l'output.
</details>

## Soluzione (schema)

<details>
<summary>Mostra schema soluzione</summary>

```bash
#!/bin/bash

nome="Dario"
saluto="Ciao"

echo "${saluto}, ${nome}!"
echo "Oggi è: $(date +"%A %d %B %Y")"
echo "Sei nella cartella: $(pwd)"
echo "La cartella contiene $(ls | wc -l) file"
```

Nota: usa sempre `"${variabile}"` con le doppie virgolette per evitare problemi con spazi nei valori.
</details>
