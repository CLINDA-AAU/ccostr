* Written by R;
*  write.foreign(uu.cost, "inst/extdata/SAS/uucost.txt", "inst/extdata/SAS/uucost.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/uucost.txt" 
     DSD 
     LRECL= 42 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
