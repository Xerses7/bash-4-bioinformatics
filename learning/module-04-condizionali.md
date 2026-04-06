# Modulo 4: Condizionali

## Obiettivo
Scrivere logica condizionale con if/elif/else e usare i test su file, numeri e stringhe.

## Prerequisiti
[Modulo 3: Input/Output, redirect e pipe](module-03-io-redirect-pipe.md)

---

## Concetti

### Struttura if/elif/else

```bash
if [ condizione ]; then
    # comandi se vero
elif [ altra_condizione ]; then
    # comandi se la prima è falsa e questa è vera
else
    # comandi se tutto il resto è falso
fi
```

**Nota:** gli spazi dentro `[ ... ]` sono obbligatori.

```bash
[ "$a" -eq 5 ]    # corretto
["$a" -eq 5]      # ERRORE
```

### Test numerici

```bash
[ "$a" -eq "$b" ]    # uguale (EQual)
[ "$a" -ne "$b" ]    # diverso (Not Equal)
[ "$a" -lt "$b" ]    # minore (Less Than)
[ "$a" -gt "$b" ]    # maggiore (Greater Than)
[ "$a" -le "$b" ]    # minore o uguale (Less or Equal)
[ "$a" -ge "$b" ]    # maggiore o uguale (Greater or Equal)
```

### Test su stringhe

```bash
[ "$a" = "$b" ]      # uguale
[ "$a" != "$b" ]     # diverso
[ -z "$a" ]          # stringa vuota (Zero length)
[ -n "$a" ]          # stringa non vuota (Non-zero length)
```

### Test su file e cartelle

```bash
[ -f "$percorso" ]   # esiste ed è un file regolare
[ -d "$percorso" ]   # esiste ed è una cartella (Directory)
[ -e "$percorso" ]   # esiste (file o cartella)
[ -x "$percorso" ]   # esiste ed è eseguibile
[ -r "$percorso" ]   # esiste ed è leggibile
[ -s "$percorso" ]   # esiste e ha dimensione > 0
```

### Operatori logici

```bash
# AND: entrambe le condizioni devono essere vere
[ "$a" -gt 0 ] && [ "$a" -lt 10 ]

# OR: almeno una condizione deve essere vera
[ "$a" -eq 0 ] || [ "$a" -eq 1 ]

# NOT: inverte il risultato
! [ -f "$file" ]
```

Con `[[ ... ]]` (solo BASH, non POSIX):
```bash
[[ "$a" -gt 0 && "$a" -lt 10 ]]    # AND dentro le doppie parentesi
[[ "$a" = "ciao" || "$a" = "hi" ]] # OR dentro le doppie parentesi
```

### Esempio pratico

```bash
#!/bin/bash

file="$1"

if [ -z "$file" ]; then
    echo "Errore: devi passare un nome file come argomento"
    exit 1
fi

if [ -f "$file" ]; then
    echo "Il file esiste, contiene $(wc -l < "$file") righe"
elif [ -d "$file" ]; then
    echo "$file è una cartella, non un file"
else
    echo "Il file non esiste"
fi
```

### `[ ]` vs `[[ ]]`

| Caratteristica | `[ ]` | `[[ ]]` |
|---|---|---|
| Standard POSIX | ✅ | ❌ (solo BASH) |
| Pattern matching (`=~`) | ❌ | ✅ |
| Parole divise sulle variabili | ❗ rischio | ✅ sicuro |
| AND/OR dentro le parentesi | ❌ | ✅ |

**Regola pratica:** se lo script inizia con `#!/bin/bash`, usa `[[ ]]`. Se vuoi portabilità con `sh`, usa `[ ]`.

---

## Key Takeaways
- Spazi dentro `[ ... ]` sono obbligatori
- Usa `-eq/-ne/-lt/-gt` per numeri, `=` e `!=` per stringhe
- `-f`, `-d`, `-e` controllano l'esistenza di file e cartelle
- `&&` è AND, `||` è OR, `!` è NOT
- `[[ ]]` è più sicuro e potente di `[ ]` (ma solo in BASH)

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-04-condizionali.md](exercises/ex-04-condizionali.md)
→ Poi vai a: [module-05-loop.md](module-05-loop.md)
