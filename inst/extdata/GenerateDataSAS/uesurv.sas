* Written by R;
*  write.foreign(ue.surv, "inst/extdata/SAS/uesurv.txt", "inst/extdata/SAS/uesurv.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/uesurv.txt" 
     DSD 
     LRECL= 27 ;
INPUT
 id
 delta
 surv
;
RUN;
