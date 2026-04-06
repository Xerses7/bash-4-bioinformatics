# Modulo 2: Variabili

## Obiettivo
Usare variabili per memorizzare dati, accedere alle variabili speciali di BASH e catturare l'output di un comando.

## Prerequisiti
[Modulo 1: La shell e i comandi base](module-01-shell-comandi-base.md)

---

## Concetti

### Assegnare una variabile

```bash
nome="Dario"          # assegna (NO spazi intorno a =)
eta=30                # i numeri non richiedono virgolette
```

**Attenzione:** in BASH gli spazi intorno a `=` causano un errore.
```bash
nome = "Dario"    # ERRORE: BASH interpreta "nome" come un comando
```

### Usare una variabile

```bash
echo "$nome"          # stampa il valore
echo "${nome}"        # forma preferita: le {} delimitano il nome
echo "Ciao, ${nome}!" # interpolazione in una stringa
```

Usa sempre le doppie virgolette `"..."` quando usi una variabile. Senza, una variabile con spazi verrebbe spezzata in più parole.

```bash
percorso="my documents"
ls $percorso      # SBAGLIATO: BASH vede "ls my documents" (2 argomenti)
ls "$percorso"    # CORRETTO: BASH vede "ls my documents" (1 argomento)
```

### Differenza tra `"..."` e `'...'`

```bash
nome="Dario"
echo "$nome"      # stampa: Dario        (le variabili vengono espanse)
echo '$nome'      # stampa: $nome        (stringa letterale, niente espansione)
```

### Variabili speciali

Queste variabili sono impostate automaticamente da BASH:

```bash
$0          # nome dello script in esecuzione
$1 $2 ...   # argomenti passati allo script (posizionali)
$#          # numero di argomenti ricevuti
$?          # exit code dell'ultimo comando (0 = successo)
$$          # PID del processo corrente
$USER       # nome dell'utente corrente
$HOME       # cartella home dell'utente
$PWD        # cartella corrente (come pwd)
```

Esempio:
```bash
#!/bin/bash
echo "Script: $0"
echo "Primo argomento: $1"
echo "Quanti argomenti: $#"
```

### Command substitution — catturare l'output di un comando

```bash
oggi=$(date)              # salva l'output di "date" nella variabile "oggi"
n=$(ls | wc -l)           # conta i file nella cartella corrente
cartella=$(pwd)           # salva la cartella corrente
```

La sintassi `$(comando)` esegue il comando e sostituisce l'espressione con il suo output.

```bash
echo "Oggi è: $(date +%A\ %d\ %B\ %Y)"
echo "Sei in: $(pwd)"
echo "Ci sono $(ls | wc -l) file qui"
```

---

## Key Takeaways
- Nessuno spazio intorno a `=` nell'assegnazione
- Usa sempre `"${variabile}"` per sicurezza
- `'...'` blocca l'espansione delle variabili; `"..."` la permette
- `$(comando)` cattura l'output di qualsiasi comando
- `$?` è fondamentale per controllare se un comando è andato a buon fine

---

## Prossimo passo
→ Completa l'esercizio: [exercises/ex-02-variabili.md](exercises/ex-02-variabili.md)
→ Poi vai a: [module-03-io-redirect-pipe.md](module-03-io-redirect-pipe.md)
