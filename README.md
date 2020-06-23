# LazIntranet_Test
Un piccolo esempio di come realizzare un http server embedded in accoppiata con un frontend scritto con Bootstrap Studio.

Prima di compilare consiglio di dare un occhiata alle custom options del progetto. Inoltre si necessita di creare un database vuoto con un unica tabella di nome: table1

Table1 contiene 6 campi
field1 : integer (primary key non autoincrementante)
field2 : text
field3 : text
field4 : text
field5 : text
field6 : text

Per l'accesso al database bisogna compilare i parametri nel metodo Connect della unit "src/other/db/udbabstract.pas"

Se la compilazione va a buon fine, lanciate l'eseguibile creato e aprite il link visualizzato nel browser.
Al login usare le credenziali
user: root@root.com
password: toor 
