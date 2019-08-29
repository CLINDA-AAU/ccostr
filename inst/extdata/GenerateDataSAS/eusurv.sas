* Written by R;
*  write.foreign(eu.surv, "inst/extdata/SAS/eusurv.txt", "inst/extdata/SAS/eusurv.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/eusurv.txt" 
     DSD 
     LRECL= 26 ;
INPUT
 id
 delta
 surv
;
RUN;
