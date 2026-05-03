# Learning Plan: BASH per la Bioinformatica delle Sequenze

## Learner Profile
- **Level:** Basi BASH non strutturate + esperienza pratica con dati biologici (FASTA, BLAST, Galaxy)
- **Goal:** Padroneggiare BASH e contemporaneamente capire i fondamenti computazionali della bioinformatica delle sequenze
- **Timeline:** A proprio ritmo
- **Approccio:** Doppio binario — ogni modulo insegna un concetto BASH e un concetto bioinformatico correlato, con difficoltà crescente su entrambe le tracce

---

## Come funziona questo corso

Ogni modulo ha due sezioni parallele:

- **BASH** — concetti e comandi con esempi pratici
- **Bioinformatica** — il concetto biologico/computazionale corrispondente, applicato con gli stessi strumenti BASH

La difficoltà cresce in modo coordinato: i primi moduli usano file FASTA semplici e comandi base; gli ultimi costruiscono pipeline complete per l'analisi di sequenze, robuste e riproducibili come quelle usate in laboratori reali.

---

## Roadmap

### Modulo 1: La shell e i comandi base | Il formato FASTA
- **BASH:** Navigare il filesystem, cat, head, tail, less, wc
- **Bio:** Struttura e anatomia di un file FASTA, come ispezionare sequenze biologiche dal terminale
- **File:** [module-01-shell-fasta.md](module-01-shell-fasta.md)
- **Esercizio:** [exercises/ex-01-shell-fasta.md](exercises/ex-01-shell-fasta.md)
- **Stato:** ✅ Completato

### Modulo 2: Variabili | Metadati delle sequenze
- **BASH:** Variabili, command substitution, variabili speciali ($1, $#, $?)
- **Bio:** Header FASTA, accession number NCBI, estrarre e usare metadati da file di sequenze
- **File:** [module-02-variabili-metadati.md](module-02-variabili-metadati.md)
- **Esercizio:** [exercises/ex-02-variabili-metadati.md](exercises/ex-02-variabili-metadati.md)
- **Stato:** ✅ Completato

### Modulo 3: I/O, Redirect e Pipe | Filtrare dataset di sequenze
- **BASH:** stdin/stdout/stderr, >, >>, |, tee, grep base
- **Bio:** Combinare file FASTA, filtrare per specie o parola chiave, gestire dataset grandi senza caricarli in memoria
- **File:** [module-03-io-pipe-filtri.md](module-03-io-pipe-filtri.md)
- **Esercizio:** [exercises/ex-03-io-pipe-filtri.md](exercises/ex-03-io-pipe-filtri.md)
- **Stato:** ✅ Completato

### Modulo 4: Condizionali | Controllo qualità delle sequenze
- **BASH:** if/elif/else, test su file, numeri e stringhe
- **Bio:** QC basilare: verificare esistenza e integrità del file, numero minimo di sequenze, presenza di caratteri ambigui
- **File:** [module-04-condizionali-qc.md](module-04-condizionali-qc.md)
- **Esercizio:** [exercises/ex-04-condizionali-qc.md](exercises/ex-04-condizionali-qc.md)
- **Stato:** ✅ Completato

### Modulo 5: Loop | Elaborazione batch di sequenze
- **BASH:** for, while, until
- **Bio:** Processare decine di file FASTA in sequenza, iterare su database di sequenze, analisi batch automatizzate
- **File:** [module-05-loop-batch.md](module-05-loop-batch.md)
- **Esercizio:** [exercises/ex-05-loop-batch.md](exercises/ex-05-loop-batch.md)
- **Stato:** ✅ Completato

### Modulo 6: Funzioni | Strumenti riutilizzabili per sequenze
- **BASH:** Funzioni, argomenti, valori di ritorno, scope delle variabili
- **Bio:** Costruire funzioni per operazioni comuni: contare sequenze, estrarre header, validare formato FASTA, calcolare statistiche
- **File:** [module-06-funzioni-tools.md](module-06-funzioni-tools.md)
- **Esercizio:** [exercises/ex-06-funzioni-tools.md](exercises/ex-06-funzioni-tools.md)

### Modulo 7: Script robusti | Pipeline da riga di comando
- **BASH:** Shebang, argomenti posizionali, getopts, exit code, usage message
- **Bio:** Scrivere script con interfaccia CLI professionale — opzioni --input, --output, --min-length — come i tool bioinformatici reali
- **File:** [module-07-script-pipeline.md](module-07-script-pipeline.md)
- **Esercizio:** [exercises/ex-07-script-pipeline.md](exercises/ex-07-script-pipeline.md)

### Modulo 8: Stringhe e array | Manipolazione diretta di sequenze
- **BASH:** Manipolazione di stringhe, array indicizzati e associativi
- **Bio:** Parsing FASTA in puro BASH, calcolo GC content, reverse complement, composizione nucleotidica
- **File:** [module-08-stringhe-sequenze.md](module-08-stringhe-sequenze.md)
- **Esercizio:** [exercises/ex-08-stringhe-sequenze.md](exercises/ex-08-stringhe-sequenze.md)

### Modulo 9: grep, sed, awk | Parsing di formati bioinformatici
- **BASH:** grep con regex, sed per trasformazioni, awk per file tabellari
- **Bio:** Parsing di GFF3, BED, BLAST tabular output (formato -outfmt 6), estrazione di annotazioni genomiche
- **File:** [module-09-grep-sed-awk-formati.md](module-09-grep-sed-awk-formati.md)
- **Esercizio:** [exercises/ex-09-grep-sed-awk-formati.md](exercises/ex-09-grep-sed-awk-formati.md)

### Modulo 10: Best practice e debugging | Pipeline production-ready
- **BASH:** set -euo pipefail, logging, trap, shellcheck, test degli script
- **Bio:** Pipeline completa FASTA → QC → filtraggio → analisi → report, robusta e riproducibile
- **File:** [module-10-best-practice-pipeline.md](module-10-best-practice-pipeline.md)
- **Esercizio:** [exercises/ex-10-best-practice-pipeline.md](exercises/ex-10-best-practice-pipeline.md)

---

## Risorse consigliate

### BASH
- [Bash Manual (GNU)](https://www.gnu.org/software/bash/manual/bash.html) — riferimento ufficiale completo
- [explainshell.com](https://explainshell.com) — spiega qualsiasi comando bash
- [shellcheck.net](https://www.shellcheck.net) — analizza i tuoi script e trova errori

### Bioinformatica delle sequenze
- [NCBI FASTA format](https://www.ncbi.nlm.nih.gov/genbank/fastaformat/) — specifiche ufficiali del formato FASTA
- [Rosalind](https://rosalind.info) — problemi di bioinformatica di difficoltà crescente, risolvibili con BASH e Python (ottimo complemento)
- [seqkit](https://bioinf.shenwei.me/seqkit/) — tool da riga di comando per sequenze, BASH-friendly (utile dal Modulo 5 in poi)
- [NCBI Entrez](https://www.ncbi.nlm.nih.gov/search/) — per scaricare dataset FASTA reali con cui esercitarti

---

## Note sulla struttura del corso

I file di esempio usati negli esercizi sono volutamente piccoli e autocontenuti: puoi crearli con un semplice `cat >`. Dal Modulo 5 in poi useremo dataset più realistici (ma ancora gestibili), e dal Modulo 9 introdurremo formati come GFF3 e BLAST tabular che incontrerai spesso nel lavoro reale.

Rosalind.info è un ottimo posto dove applicare ciò che impari: ha problemi di bioinformatica di difficoltà crescente, molti risolvibili con BASH.
