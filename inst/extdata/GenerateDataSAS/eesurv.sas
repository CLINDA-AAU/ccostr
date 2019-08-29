* Written by R;
*  write.foreign(ee.surv, "inst/extdata/SAS/eesurv.txt", "inst/extdata/SAS/eesurv.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/eesurv.txt" 
     DSD 
     LRECL= 26 ;
INPUT
 id
 delta
 surv
;
RUN;
