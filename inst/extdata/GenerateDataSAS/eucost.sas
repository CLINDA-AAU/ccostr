* Written by R;
*  write.foreign(eu.cost, "inst/extdata/SAS/eucost.txt", "inst/extdata/SAS/eucost.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/eucost.txt" 
     DSD 
     LRECL= 43 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
