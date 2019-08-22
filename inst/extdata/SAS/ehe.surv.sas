* Written by R;
*  write.foreign(ehe.surv, "inst/extdata/SAS/ehe.surv.txt", "inst/extdata/SAS/ehe.surv.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/ehe.surv.txt" 
     DSD 
     LRECL= 29 ;
INPUT
 id
 delta
 surv
;
RUN;
