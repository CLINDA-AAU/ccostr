* Written by R;
*  write.foreign(ee.cost, "inst/extdata/SAS/eecost.txt", "inst/extdata/SAS/eecost.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/eecost.txt" 
     DSD 
     LRECL= 43 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
