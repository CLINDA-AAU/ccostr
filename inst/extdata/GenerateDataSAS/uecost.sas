* Written by R;
*  write.foreign(ue.cost, "inst/extdata/SAS/uecost.txt", "inst/extdata/SAS/uecost.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/uecost.txt" 
     DSD 
     LRECL= 44 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
