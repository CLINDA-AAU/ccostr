* Written by R;
*  write.foreign(ehe.cost, "inst/extdata/SAS/ehe.cost.txt", "inst/extdata/SAS/ehe.cost.sas",  ;

DATA  rdata ;
INFILE  "inst/extdata/SAS/ehe.cost.txt" 
     DSD 
     LRECL= 46 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
