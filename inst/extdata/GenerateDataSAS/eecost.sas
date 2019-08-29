
libname local "C:\Users\larsn\Documents\GitHub\ccostr\inst\extdata\SAS";

DATA  local.eecost ;
INFILE  "eecost.txt" 
     DSD 
     LRECL= 43 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;

DATA  local.eesurv ;
INFILE  "eesurv.txt" 
     DSD 
     LRECL= 26 ;
INPUT
 id
 delta
 surv
;
RUN;

DATA  local.uucost ;
INFILE  "uucost.txt" 
     DSD 
     LRECL= 42 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;

DATA  local.uusurv ;
INFILE  "uusurv.txt" 
     DSD 
     LRECL= 25 ;
INPUT
 id
 delta
 surv
;
RUN;

DATA  local.uesurv ;
INFILE  "uesurv.txt" 
     DSD 
     LRECL= 27 ;
INPUT
 id
 delta
 surv
;
RUN;

DATA  local.uecost ;
INFILE  "uecost.txt" 
     DSD 
     LRECL= 44 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;

DATA  local.eusurv ;
INFILE  "eusurv.txt" 
     DSD 
     LRECL= 26 ;
INPUT
 id
 delta
 surv
;
RUN;

DATA  local.eucost ;
INFILE  "eucost.txt" 
     DSD 
     LRECL= 43 ;
INPUT
 cid
 start
 stop
 cost
;
RUN;
