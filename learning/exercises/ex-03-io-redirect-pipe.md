# Esercizio 3: Redirect e pipe

## Modulo correlato
[Modulo 3: Input/Output, redirect e pipe](../module-03-io-redirect-pipe.md)

## Difficoltà
Facile / Media

## Compito
Usa redirect e pipe per creare, filtrare e analizzare dati testuali.

Vedi anche lo script di riferimento: [`../../modulo1/esercizio3.sh`](../../modulo1/esercizio3.sh)

## Requisiti

- [ ] Crea un file `/tmp/nomi.txt` con almeno 7 righe (includi duplicati) usando un heredoc
- [ ] Stampa il file originale
- [ ] Stampa i nomi unici in ordine alfabetico
- [ ] Stampa quante righe ha il file in totale
- [ ] Filtra e stampa solo le righe che contengono un nome specifico
- [ ] Salva in `/tmp/nomi_unici.txt` i nomi unici (senza stamparli a schermo)

## Hints

<details>
<summary>Hint 1</summary>
Per creare un file con più righe usa il heredoc:
```bash
cat > /tmp/nomi.txt << EOF
riga1
riga2
EOF
```
</details>

<details>
<summary>Hint 2</summary>
Per nomi unici ordinati: `sort file.txt | uniq`
Per contare righe da file (non da stdin): `wc -l < file.txt`
</details>

<details>
<summary>Hint 3</summary>
Per salvare l'output senza stamparlo: aggiungi `> file_destinazione` alla fine del comando, senza `echo`.
</details>

## Soluzione (schema)

<details>
<summary>Mostra schema soluzione</summary>

```bash
cat > /tmp/nomi.txt << EOF
Dario
Alice
Bob
Dario
Carlo
Alice
Dario
EOF

cat /tmp/nomi.txt
sort /tmp/nomi.txt | uniq
wc -l < /tmp/nomi.txt
grep "Dario" /tmp/nomi.txt
sort /tmp/nomi.txt | uniq > /tmp/nomi_unici.txt
```

Punto chiave: `sort` prima di `uniq`, perché `uniq` rimuove solo duplicati *adiacenti*.
</details>
