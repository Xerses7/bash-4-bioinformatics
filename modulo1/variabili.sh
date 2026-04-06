  #!/bin/bash     
                                                                                                                                                                         
  nome="Dario"    
  saluto="Ciao"                                                                                                                                                          
                  
  echo "${saluto}, ${nome}!"                                                                                                                                             
  echo "Oggi è: $(date +%A\ %d\ %B\ %Y)"
  echo "Sei nella cartella: $(pwd)"                                                                                                                                      
 echo "La cartella contiene $(ls | wc -l) file"          

