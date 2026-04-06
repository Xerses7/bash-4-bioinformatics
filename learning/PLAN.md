# Learning Plan: BASH

## Learner Profile
- **Level:** Principiante con basi non strutturate
- **Goal:** Imparare BASH in modo sistematico, dalla shell agli script avanzati
- **Timeline:** A proprio ritmo

---

## Roadmap

### Modulo 1: La shell e i comandi base
- **Obiettivo:** Navigare il filesystem e usare i comandi fondamentali
- **File:** [module-01-shell-comandi-base.md](module-01-shell-comandi-base.md)
- **Esercizio:** [exercises/ex-01-shell-comandi-base.md](exercises/ex-01-shell-comandi-base.md)
- **Stato:** ✅ Completato

### Modulo 2: Variabili
- **Obiettivo:** Usare variabili, variabili speciali e command substitution
- **File:** [module-02-variabili.md](module-02-variabili.md)
- **Esercizio:** [exercises/ex-02-variabili.md](exercises/ex-02-variabili.md)
- **Stato:** ✅ Completato

### Modulo 3: Input/Output, redirect e pipe
- **Obiettivo:** Capire stdin/stdout/stderr e collegare comandi tra loro
- **File:** [module-03-io-redirect-pipe.md](module-03-io-redirect-pipe.md)
- **Esercizio:** [exercises/ex-03-io-redirect-pipe.md](exercises/ex-03-io-redirect-pipe.md)
- **Stato:** ✅ Completato

### Modulo 4: Condizionali
- **Obiettivo:** Scrivere logica con if/elif/else e i test su file, numeri, stringhe
- **File:** [module-04-condizionali.md](module-04-condizionali.md)
- **Esercizio:** [exercises/ex-04-condizionali.md](exercises/ex-04-condizionali.md)
- **Stato:** ✅ Completato

### Modulo 5: Loop
- **Obiettivo:** Usare for, while e until per iterare
- **File:** [module-05-loop.md](module-05-loop.md)
- **Esercizio:** [exercises/ex-05-loop.md](exercises/ex-05-loop.md)
- **Stato:** 🔜 Prossimo

### Modulo 6: Funzioni
- **Obiettivo:** Definire e chiamare funzioni, passare argomenti e restituire valori
- **File:** [module-06-funzioni.md](module-06-funzioni.md)
- **Esercizio:** [exercises/ex-06-funzioni.md](exercises/ex-06-funzioni.md)

### Modulo 7: Script — struttura, argomenti, exit code
- **Obiettivo:** Scrivere script robusti con shebang, argomenti posizionali e exit code corretti
- **File:** [module-07-script.md](module-07-script.md)
- **Esercizio:** [exercises/ex-07-script.md](exercises/ex-07-script.md)

### Modulo 8: Stringhe e array
- **Obiettivo:** Manipolare stringhe e gestire array in BASH
- **File:** [module-08-stringhe-array.md](module-08-stringhe-array.md)
- **Esercizio:** [exercises/ex-08-stringhe-array.md](exercises/ex-08-stringhe-array.md)

### Modulo 9: Strumenti avanzati — grep, sed, awk
- **Obiettivo:** Usare i tool Unix più potenti per processare testo
- **File:** [module-09-grep-sed-awk.md](module-09-grep-sed-awk.md)
- **Esercizio:** [exercises/ex-09-grep-sed-awk.md](exercises/ex-09-grep-sed-awk.md)

### Modulo 10: Best practice e debugging
- **Obiettivo:** Scrivere script sicuri, leggibili e facili da debuggare
- **File:** [module-10-best-practice.md](module-10-best-practice.md)
- **Esercizio:** [exercises/ex-10-best-practice.md](exercises/ex-10-best-practice.md)

---

## Risorse consigliate
- [Bash Manual (GNU)](https://www.gnu.org/software/bash/manual/bash.html) — riferimento ufficiale completo
- [explainshell.com](https://explainshell.com) — spiega qualsiasi comando bash
- [shellcheck.net](https://www.shellcheck.net) — analizza i tuoi script e trova errori
- [BashFAQ](https://mywiki.wooledge.org/BashFAQ) — risposte alle domande più comuni

## Cheatsheet
- Consulta [`../manuale.md`](../manuale.md) per un riferimento rapido ai moduli 1-4.

---

## Suggerimenti
- Esegui ogni script con `bash script.sh`, oppure con `chmod +x script.sh` + `./script.sh`
- Usa sempre `shellcheck` per controllare i tuoi script prima di eseguirli
- Il modo migliore per imparare BASH è riscrivere gli esempi a mano, non copiarli
