* Written by R;
*  write.foreign(uu.surv, "inst/extdata/SAS/uusurv.txt", "inst/extdata/SAS/uusurv.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/uusurv.txt" 
     DSD 
     LRECL= 25 ;
INPUT
 id
 delta
 surv
;
RUN;
