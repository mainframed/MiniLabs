/* REXX */

/*            _,cyyyyyc,_
  -------- . ?$$$$$$$$$$$7  ------------------------------------------\
         .    %$$$$$$$$$7            z/OS System Enumeration Script   |
            `  ?$$$$$$$7                                              |
          '    .?$$$$$7              Arguments: ALL, APF, CAT, JOB,   |
   sof        '  "'`'"                          PATH, SEC, SVC, VERS, |
                _qQ$Qp_         .  .            WHO, TSTA             |
       .        $$$$$$$   . :  .:  .                                  |
   I$$$$$$$$$$L `?jlj7' j$l$l$$il$$I Description: Enumerates z/OS sys |
   :$$$$$$$$$i$b.     .d$$$$$$$$$$$:              information for use |
    ?$$$$$I$$%"~ `     ~*$$$$$$$$$7               in penetration test |
     ?$$$$\"~ `.          ~#$$$$$7                                    |
      `7"~ `.   `            ~#7'    By: Philip Young                 |
        `.                    .          Soldier of Fortran           |
           .                             @mainframed767               |
---z-o-s---e-n-u-m-e-r-a-t-i-o-n-------------------------------------*/


/*--------------------------------------------------------------------*\
|*                                                                    *|
|* z/OS System Enumeration Script                                     *|
|*                                                                    *|
|* Description:  Enumerates system information for z/OS               *|
|*               which might be useful for a penetration test.        *|
|*                                                                    *|
|* Arg: <TYPE> The type of enumeration to be conducted. Supports the  *|
|*             following arguments:                                   *|
|*             ALL  - Diplay all information                          *|
|*             APF  - APF Authorized Datasets Information             *|
|*             CAT  - Display Catalog                                 *|
|*             JOB  - Display Executing Job Name                      *|
|*             PATH - Display Dataset Concatenation Info              *|
|*             SEC  - Security Manager Information                    *|
|*             SVC  - Display SVC Information                         *|
|*             VERS - Operating System Version Info                   *|
|*             WHO  - Who is currently logged on through TSO/OMVS     *|
|*             TSTA - Display TESTAUTH authorization                  *|
|*                                                                    *|
|*                                                                    *|
|* Sources:                                                           *|
|*     Mark Zelden's IPLINFO Rexx:                                    *|
|*        http://www.mzelden.com/mvsfiles/iplinfo.txt                 *|
|*     File # 221 EDP Auditor REXX tools updated from Lee Conyers     *|
|*        http://www.cbttape.org/ftp/cbt/CBT221.zip                   *|
|*     Ayoub Elaassal's ELV.SELF                                      *|
|*        https://github.com/ayoul3/Privesc                           *|
|*     Jim Taylor's SETRRCVT                                          *|
|*        https://github.com/jaytay79/zos                             *|
|*     File # 496 REXX exec to do LISTA (display allocations)         *|
|*        http://www.cbttape.org/ftp/cbt/CBT496.zip                   *|
|*                                                                    *|
\*--------------------------------------------------------------------*/
                                        


PARSE SOURCE s1 s2 prg s3 name s4 s5 space .
PARSE UPPER ARG type

if space == 'ISPF' then do
  say ''
  say ''
  say ''
end

if prg /== '?' & space /== 'OMVS' then
  prgname = name||'('||prg||')'
else
  prgname = name

SELECT
  WHEN type == 'APF' THEN
    x = APF()
  WHEN type == 'VERS' THEN
    x = VERSION()
  WHEN type == 'SEC' THEN
    x = SECURITY()
  WHEN type == 'WHO' THEN
    x = USERS()
  WHEN type == 'SVC' THEN
    x = SVC()
  WHEN type == 'JOB' THEN
    x = JOBNAME()
  WHEN type == 'PATH' THEN DO
    if space /== 'OMVS' THEN
      x = PATH()
    else
      say 'DDNAME not supported in OMVS'
  END
  WHEN type == 'CAT' THEN
    x = CAT()
  WHEN type == 'TSTA' THEN
    x = TSTA()
  WHEN type = 'ALL' THEN DO
    say 'z/OS System Enumeration'
    say ''
    say 'Executing from:' prgname
    say ''
    say '-----------------------------------------'
    x = VERSION()
    say '-----------------------------------------'
    say ''
    x = SECURITY()
    say '-----------------------------------------'
    say ''
    x = JOBNAME()
    say '-----------------------------------------'
    say ''
    x = USERS()
    say '-----------------------------------------'
    say ''
    x = APF()
    say '-----------------------------------------'
    say ''
    x = SVC()
    say '-----------------------------------------'
    say '' 
    x = TSTA()
    say '-----------------------------------------'
    say '' 
    if space /== 'OMVS' THEN
      x = PATH(1)
  END
  OTHERWISE DO
say "              _,cyyyyyc,_"
say "  -------- . ?$$$$$$$$$$$7  -----------------------------------------"
say "         .    %$$$$$$$$$7            z/OS System Enumeration Script  "
say "            `  ?$$$$$$$7"
say "          '    .?$$$$$7              Arguments: ALL, APF, CAT, JOB,"
say "   sof        '  """'`'"""                        PATH, SEC, SVC, VERS,"
say "                _qQ$Qp_         .  .            WHO, TSTA"
say "       .        $$$$$$$   . :  .:  ."
say "   I$$$$$$$$$$L `?jlj7' j$l$l$$il$$I"
say "   :$$$$$$$$$i$b.     .d$$$$$$$$$$$:"
say "    ?$$$$$I$$%'~ `     ~*$$$$$$$$$7"               
say "     ?$$$$\'~ `.          ~#$$$$$7"
say "      `7'~ `.   `            ~#7'"
say "        `.                    ."
say "           ."
say "---z-o-s---e-n-u-m-e-r-a-t-i-o-n-------------------------------------"
    say 'args:'
    say "'ALL'  Display ALL Information"
    say "'APF'  Display APF Authorized Datasets"
    say "'CAT'  Display Catalogs (File Enumeration)"
    say "'JOB'  Display Executing Job Name"
    say "'PATH' Display Dataset Concatenation"
    say "'SEC'  Display Security Manager Infomation"
    say "'SVC'  Display All SVCs"
    say "'VERS' Display System Information"
    say "'WHO'  Display Logged On TSO/OMVS Users"
    say "'TSTA' Display TESTAUTH authorization"
    say ''
    say 'Example:'
    if space /== 'OMVS' then
     say prgname "'WHO'"
    else
     say prgname 'WHO'
    exit 8
  END
END
   
return 0


JOBNAME:
/* from: http://www.spgmbh.de/src/por_jobname_en.htm */
CVT = STORAGE(10,4)      /* FLCCVT-PSA DATA AREA */
TCBP = STORAGE(D2X(C2D(CVT)),4)       /* CVTTCBP */
TCB = STORAGE(D2X(C2D(TCBP)+4),4)
TIOT = STORAGE(D2X(C2D(TCB)+12),4)     /* TCBTIO */
say 'Exec JOBNAME: 'STRIP(STORAGE(D2X(C2D(TIOT)),8)) /* TIOCNJOB */
return 0

USERS:
numeric digits 10

cvt=ptr(16)                            /* Get CVT                    */ 
asvt=ptr(cvt+556)+512                  /* Get asvt                   */ 

tso_users.0 = 0 
tasks.0 = 0
tasks_users.0 = 0
omvs.0 = 0
omvs_users.0 = 0
jobs.0 = 0
jobs_users.0 = 0
system.0 = 0

asvtmaxu=ptr(asvt+4)                   /* Get max asvt entries       */ 
Do a = 0 to asvtmaxu - 1                                                
  ascb=stg(asvt+16+a*4,4)              /* Get ptr to ascb (Skip master) */   
                
  If bitand(ascb,'80000000'x) = '00000000'x Then /* If in use        */ 
    Do                                                                  
      ascb=c2d(ascb)                   /* Get ascb address           */ 
      cscb=ptr(ascb+56)                /* Get CSCB address           */ 
      chtrkid=stg(cscb+28,1)           /* Check addr space type      */ 
      ascbjbni=ptr(ascb+172)           /* Get ascbjbni               */ 
      ascbjbns=ptr(ascb+176)           /* Get ascbjbns               */ 
      asxb = ptr(ascb+108)
      
      acee = ptr(asxb+200)      
      
      ftcb = ptr(asxb+4)
      ltcb = ptr(asxb+8)
      
      ascboucb = ptr(ascb+144,4)
      oucbsubn = stg(ascboucb+176,4)
      oucbtrxn = stg(ascboucb+200,8) /* transaction name */
      oucbusrd = stg(ascboucb+208,8) /* userid */
            
      If ascbjbns<>0 & chtrkid = '02'x Then  /* started task */
        Do                                                             
          assb = ptr(ascb+336)
          jsab = ptr(assb+168)
          if jsab = 0 then
            usid = ""
          else
            usid = stg(jsab+44,8)
          
          tmp = tasks.0 + 1
          tasks.tmp = stg(ascbjbns,8)
          tasks_users.tmp = usid
          tasks.0 = tmp   
               
          
        End
      If ascbjbns<>0 & chtrkid = '01'x Then  /* TSO user */
        Do                                                             
          tmp = tso_users.0 + 1
          tso_users.tmp = stg(ascbjbns,8)
          tso_users.0 = tmp
          
        End
      If ascbjbns<>0 & chtrkid = '04'x Then  /* System */
        Do                                                             
          tmp = system.0 + 1
          system.tmp = stg(ascbjbns,8)
          system.0 = tmp
          
        End
      If strip(oucbsubn) = 'OMVS' Then /* OMVS user */
        Do
          tmp = omvs.0 + 1
          omvs.tmp = oucbtrxn
          omvs_users.tmp = oucbusrd
          omvs.0 = tmp
        End                                                            
      If ascbjbni<>0 & chtrkid = '03'x Then  /* JOBS */
        Do                                                             
          If strip(oucbsubn) = 'OMVS' Then iterate
          assb = ptr(ascb+336)
          jsab = ptr(assb+168)
          usid = stg(jsab+44,8)
          
          if jsab = 0 then
            usid = ""
          else
            usid = stg(jsab+44,8)
            
          tmp = jobs.0 + 1
          jobs.tmp = stg(ascbjbni,8)
          jobs_users.tmp = usid
          jobs.0 = tmp
        
          
        End
    End                                                                
End

say "**** Started Task - Owner *****"
DO i = 1 to tasks.0
   say tasks.i " - " tasks_users.i 
END                                                       

say ""
say "**** TSO Users - Owner ****"
DO i = 1 to tso_users.0
   say tso_users.i " - " tso_users.i 
END

say ""
say "**** OMVS Users - Owner ****"
DO i = 1 to omvs.0
   say omvs.i " - " omvs_users.i
END

say ""
say "**** Jobs - Owner ****"
DO i = 1 to jobs.0
   say jobs.i " - " jobs_users.i 
END

return 0                          

SECURITY:
say 'External Security Manager:'
/* Special thanks for IPLINFO for this information */
/* Get JES Infomation */
numeric digits 20
CVT = C2D(STORAGE(10,4)) /* CVT Pointer */
CVTRAC = C2D(STORAGE(D2X(CVT + 992),4))
ID = STORAGE(D2X(CVTRAC),4) 
If ID = 'RCVT' THEN DO /* RACF */
 RACFVRM  = Storage(D2x(CVTRAC + 616),4)         
 RCVTDSDT = C2d(Storage(D2x(CVTRAC + 224),4))
 DSDTNUM = C2d(Storage(D2x(RCVTDSDT+4),4))             
 DSDTPRIM = STRIP(Storage(D2x(RCVTDSDT+177),44),'T')
 DSDTBACK = STRIP(Storage(D2x(RCVTDSDT+353),44),'T')
 SAY 'Product: RACF'
 SAY 'Version: FMID HRF'RACFVRM
 SAY 'Datasets:'
 IF DSDTNUM = 1 THEN DO
  SAY '  Primary:' DSDTPRIM
  SAY '  Backup: ' DSDTBACK
 END
 ELSE DO /* It's a split RACF database */
  OFFSET = 0
  DB = ''
  DO i = 1 TO DSDTNUM
   DSDTPRIM  = STRIP(Storage(D2x(RCVTDSDT+177+OFFSET),44),'T')       
   DSDTBACK  = STRIP(Storage(D2x(RCVTDSDT+353+OFFSET),44),'T')
   OFFSET = OFFSET + 352
   SAY '  ('i') Primary:' DSDTPRIM 
   SAY '  ('i') Backup: ' DSDTBACK
  END
 END
 RACFSTR = SETROPTS()
END
ELSE IF ID = 'RTSS' THEN DO /* Top Secret */
 RCVTDSN = Strip(Storage(D2x(CVTRAC + 56),44))
 SAY 'Product: Top Secret'
 SAY 'Dataset:' RCVTDSN
 /* I wish there was more here but for now this will do */
END
ELSE DO /* ACF2 */
 /* Straight from IPLINFO */
 /* All credit to Mark */
 CVTJESCT = C2D(STORAGE(D2X(CVT + 296),4))
 SSCVT = C2D(STORAGE(D2X(CVTJESCT + 24),4))
 Do while SSCVT <> 0                                                           
  SSCTSNAM = Storage(D2x(SSCVT+8),4)       /* subsystem name       */         
  If SSCTSNAM = 'ACF2' then do                                                
   ACCVT    = C2d(Storage(D2x(SSCVT + 20),4)) /* ACF2 CVT         */         
   ACCPFXP  = C2d(Storage(D2x(ACCVT - 4),4))  /* ACCVT prefix     */         
   ACCPIDL  = C2d(Storage(D2x(ACCPFXP + 8),2))  /* Len ident area */         
   LEN_ID   = ACCPIDL-4 /* don't count ACCPIDL and ACCPIDO in len */         
   ACCPIDS  = Strip(Storage(D2x(ACCPFXP + 12),LEN_ID)) /*sys ident*/         
   ACF2DSNS = C2d(Storage(D2x(ACCVT + 252) ,4)) /* ACF2 DSNs      */         
   ACF2DNUM = C2d(Storage(D2x(ACF2DSNS + 16),2)) /* # OF DSNs     */         
   Leave                                                                     
  End                                                                         
  SSCVT    = C2d(Storage(D2x(SSCVT+4),4))    /* next sscvt or zero   */         
 End
 SAY 'Product: ACF2'
 SAY 'Version:' ACCPIDS
 SAY 'Dataset(s):'
 Do ADSNS = 1 to ACF2DNUM                                                    
  ADSOFF   = ACF2DSNS + 24 + (ADSNS-1)*64                                   
  ACF2TYPE = Storage(D2x(ADSOFF) , 8)                                       
  ACF2DSN  = Storage(D2x(ADSOFF + 16),44)  
  SAY '  ' ACF2TYPE '-' ACF2DSN                                 
 End 
END
return 0

APF:
/* Thanks to FILE221 on CBT Tape for mapping this out */
/* Lists APF Authorized datasets */
say 'APF Authorized Libraries'
say ''

IF space == 'OMVS' THEN DO
 SAY '! APF Dataset Checking Not Supported in UNIX'
 MISSING = '******'
 SAY ''
END

say 'VOLUME | EXISTS | DATASET '
say '-------|--------|---------'
RETCODE = 0

numeric digits 20 /* need this for D2X/C2D  */
CVT = C2D(STORAGE(10,4)) /* CVT Pointer */
CVTAUTHL = C2D(STORAGE(D2X(CVT + 484),4))
IF CVTAUTHL = C2D('7FFFF001'x) THEN DO 
 /* The APF Table is Dynamic, not Static */
 CVTECVT = C2D(STORAGE(D2X(CVT + 140),4))
 ECVTCSVT = C2D(STORAGE(D2X(CVTECVT + 228),4))
 APF_PTR = c2d(storage(d2x(ECVTCSVT+12),4))
 CUR = c2d(storage(d2x(APF_PTR+8),4))      
 LAST = c2d(storage(d2x(APF_PTR+12),4))    
 DO FOREVER
  DATASET = storage(d2x(CUR+24),44)
  MISSING = '  Yes '
  IF SUBSTR(DATASET,1,1) \= '00'x THEN DO /* Its not deleted */
   VOL_SMS = storage(d2x(CUR+4),1)
   IF bitand(VOL_SMS,'80'x) = '80'x THEN DO
    VOLUME = 'SMS   '
    /* Check to see if the dataset exists */
    /* example code from http://mzelden.com/mvsfiles/apfver.txt */
    IF space /== 'OMVS' THEN
     RETCODE = Listdsi(''''STRIP(DATASET)''''  norecall)
   END
   ELSE DO
    VOLUME = STORAGE(D2X(CUR+68),6)
    IF space /== 'OMVS' THEN
     RETCODE = Listdsi(''''STRIP(DATASET)'''',
              'volume('STRIP(VOLUME)')'  norecall)
   END
   If RETCODE <> 0 then do
    IF SYSREASON = 24 THEN
     MISSING = '  No  '
    ELSE
     MISSING = SPACE(D2C(SYSREASON),8, ' ')
     /* For Explanation of these codes visit:
        https://www.ibm.com/support/knowledgecenter/SSLTBW_2.1.0/
        com.ibm.zos.v2r1.ikja300/ldsi.htm#ldsi__ldrs */
   END
   /* Here we list the found items */
   SAY strip(VOLUME) "|" MISSING "|" STRIP(DATASET) 
  END
  IF CUR = LAST THEN LEAVE
  ELSE CUR = C2D(STORAGE(D2X(CUR+8),4))
 END /* Do */
END /* End of Dynamic */
ELSE DO /* It's Static instead */
 NUMAPF = C2D(STORAGE(D2X(CVTAUTHL),2)) 
 LEN = C2D(STORAGE(D2X(CVTAUTHL+2),1)) 
 CUR = CVTAUTHL + 3          
 DO I = 1 TO NUMAPF                            
  VOLUME = STORAGE(D2X(CUR),6)  
  DATASET = STORAGE(D2X(CUR + 7),LEN)
  CUR = CUR + LEN + 1          
  LEN = C2D(STORAGE(D2X(CUR-1),1)) 
  SAY STRIP(VOLUME) "|" STRIP(DATASET)
 END
END

RETURN 0

VERSION:
/* Special thanks for IPLINFO for this information */
/* Get JES Infomation */
say 'Operating System Information'
numeric digits 20
CVT = C2D(STORAGE(10,4)) /* CVT Pointer */
CVTEXT2  = C2d(Storage(D2x(CVT + 328),4))
CVTJESCT = C2D(STORAGE(D2X(CVT + 296),4))
CVTVERID = STORAGE(D2X(CVT - 24),16)
ECVT     = C2d(Storage(D2x(CVT + 140),4))
/* OS */
PRODNAME = Storage(D2x(CVT - 40),7)
PRODNAM2 = Storage(D2x(ECVT+496),16)       /* point to product name*/         
PRODNAM2 = Strip(PRODNAM2,'T')             /* del trailing blanks  */         
VER      = Storage(D2x(ECVT+512),2)        /* point to version     */         
REL      = Storage(D2x(ECVT+514),2)        /* point to release     */         
MOD      = Storage(D2x(ECVT+516),2)        /* point to mod level   */         
VRM      = VER'.'REL'.'MOD                                                    
FMIDNUM  = Storage(D2x(CVT - 32),7)        /* point to fmid        */         
SAY 'The OS version is 'PRODNAM2 VRM' - FMID' ,                             
         FMIDNUM' ('PRODNAME').'         

/* Job Entry */ 
JESSSCT = C2D(STORAGE(D2X(CVTJESCT + 24),4))
JESPJESN = STORAGE(D2X(CVTJESCT + 28),4)
SSCTSNAM = STORAGE(D2X(JESSSCT + 8),4)
DO UNTIL JESSSCT = 0
 IF JESPJESN = SSCTSNAM THEN DO
   SSCTSSVT = C2D(Storage(D2X(JESSSCT+16),4))         
   SSCTSUSE = C2D(Storage(D2X(JESSSCT+20),4))         
   SSCTSUS2 = C2D(Storage(D2X(JESSSCT+28),4))
  LEAVE
 END
 JESSSCT = C2D(Storage(D2X(JESSSCT+4),4))
END

IF JESPJESN = 'JES3' THEN DO
 JESVERS   = SYSVAR('SYSJES')                    
 JESNODE  = SYSVAR('SYSNODE')
END
ELSE IF JESPJESN = 'JES2' THEN DO
 JESVERS = Strip(Storage(D2x(SSCTSUSE),8))
  Select                                                               
    When Substr(JESVERS,1,8) == 'z/OS 2.2' then , /* z/OS 2.2        */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+664),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,8) == 'z/OS 2.1' | ,  /* z/OS 2.1          */
      Substr(JESVERS,1,8) == 'z/OS1.13'   | ,   /* z/OS 1.13         */
      Substr(JESVERS,1,8) == 'z/OS1.12'   | ,   /* z/OS 1.12         */
      Substr(JESVERS,1,8) == 'z/OS1.11' then,   /* z/OS 1.11         */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+656),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,8) == 'z/OS1.10' | , /* z/OS 1.10          */
      Substr(JESVERS,1,8) == 'z/OS 1.9' then,   /* z/OS 1.9          */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+708),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,8) == 'z/OS 1.8' then, /* z/OS 1.8         */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+620),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,8) == 'z/OS 1.7' then, /* z/OS 1.7         */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+616),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,8) == 'z/OS 1.5' | , /* z/OS 1.5 & 1.6     */
      Substr(JESVERS,1,8) == 'z/OS 1.4' then  /* z/OS 1.4            */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+532),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,7) == 'OS 2.10' | , /* OS/390 2.10 and     */
      Substr(JESVERS,1,8) == 'z/OS 1.2' then, /* z/OS 1.2            */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+452),8)) /* JES2 NODE    */
    When Substr(JESVERS,1,6) == 'OS 1.1' | , /* OS/390 1.1 or        */
      Substr(JESVERS,1,4) == 'SP 5' then ,   /* ESA V5 JES2          */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+336),8)) /*  JES2 NODE   */
    When Substr(JESVERS,1,5) == 'OS 1.' | ,  /* OS/390 1.2           */
      Substr(JESVERS,1,5) == 'OS 2.' then,   /*  through OS/390 2.9  */
      JESNODE  = Strip(Storage(D2x(SSCTSUS2+372),8)) /* JES2 NODE    */
    Otherwise ,                              /* Lower than ESA V5    */
      If ENV = 'OMVS' then JESNODE = '*not_avail*'                     
      else JESNODE  = SYSVAR('SYSNODE')      /* TSO/E VAR for JESNODE*/
  End  /* select */                                                    
END

/* DF */
/* From IPLINFO */
CVTDFA   = C2d(Storage(D2x(CVT + 1216),4))         
DFAPROD  = C2d(Storage(D2x(CVTDFA +16),1))
If DFAPROD = 0 then do                       /* DFP not DF/SMS       */         
  DFAREL   = C2x(Storage(D2x(CVTDFA+2),2))   /* point to DFP release */         
  DFPVER   = Substr(DFAREL,1,1)              /* DFP Version          */         
  DFPREL   = Substr(DFAREL,2,1)              /* DFP Release          */         
  DFPMOD   = Substr(DFAREL,3,1)              /* DFP Mod Lvl          */         
  DFPRD    = 'DFP'                           /* product is DFP       */         
  DFLEV    = DFPVER || '.' || DFPREL || '.' || DFPMOD                           
End                                                                             
Else do                                      /* DFSMS not DFP        */         
  DFARELS  = C2x(Storage(D2x(CVTDFA+16),4))  /* point to DF/SMS rel  */         
  DFAVER   = X2d(Substr(DFARELS,3,2))        /* DF/SMS Version       */         
  DFAREL   = X2d(Substr(DFARELS,5,2))        /* DF/SMS Release       */         
  DFAMOD   = X2d(Substr(DFARELS,7,2))        /* DF/SMS Mod Lvl       */         
  DFPRD    = 'DFSMS'                         /* product is DF/SMS    */         
  DFLEV    = DFAVER || '.' || DFAREL || '.' || DFAMOD                           
  If DFAPROD = 2 then DFLEV = 'OS/390' DFLEV                                    
  If DFAPROD = 3 then do                                                        
    DFLEV    = 'z/OS' DFLEV                                                     
    /* Next section of code doesn't work because CRT is in key 5 */             
       /*                                                                       
    CVTCBSP  = C2d(Storage(D2x(CVT + 256),4))      /* point to AMCBS */         
    CRT      = C2d(Storage(D2x(CVTCBSP + 124),4))  /* point to CRT   */         
    CRTFMID  = Storage(D2x(CRT + 472),7)           /* DFSMS FMID     */         
       */                                                                       
  End /* if DFAPROD = 3 */                                                      
End   
/* TSO */
CVTTVT   = C2d(Storage(D2x(CVT + 156),4))    /* point to TSO vect tbl*/         
TSVTLVER = Storage(D2x(CVTTVT+100),1)        /* point to TSO Version */         
TSVTLREL = Storage(D2x(CVTTVT+101),2)        /* point to TSO Release */         
TSVTLREL = Format(TSVTLREL)                  /* Remove leading 0     */         
TSVTLMOD = Storage(D2x(CVTTVT+103),1)        /* point to TSO Mod Lvl */         
TSOLEV   = TSVTLVER || '.' || TSVTLREL || '.' || TSVTLMOD             
/* VTAM */
CHKVTACT = Storage(D2x(CVTEXT2+64),1)        /* VTAM active flag     */         
If bitand(CHKVTACT,'80'x) = '80'x then do      /* vtam is active     */         
  CVTATCVT = C2d(Storage(D2x(CVTEXT2 + 65),3)) /* point to VTAM AVT  */         
  ISTATCVT = C2d(Storage(D2x(CVTATCVT + 0),4)) /* point to VTAM CVT  */         
  ATCVTLVL = Storage(D2x(ISTATCVT + 0),8)      /* VTAM Rel Lvl VOVRP */         
  VTAMVER  = Substr(ATCVTLVL,3,1)              /* VTAM Version   V   */         
  VTAMREL  = Substr(ATCVTLVL,4,1)              /* VTAM Release    R  */         
  VTAMMOD  = Substr(ATCVTLVL,5,1)              /* VTAM Mod Lvl     P */         
  If VTAMMOD = ' ' then VTAMLEV =  VTAMVER || '.' || VTAMREL                    
    else VTAMLEV =  VTAMVER || '.' || VTAMREL || '.' || VTAMMOD                 
/*                                                                   */         
  ATCNETID = Strip(Storage(D2x(ISTATCVT + 2080),8))  /* VTAM NETID   */         
  ATCNQNAM = Strip(Storage(D2x(ISTATCVT + 2412),17)) /* VTAM SSCPNAME*/         
  VTAM_ACTIVE = 'YES'                                                           
End /* if bitand (vtam is active) */                                            
Else VTAM_ACTIVE = 'NO' 

SAY 'TSO:' TSOLEV
SAY 'JES:' JESPJESN JESVERS 'Node:' JESNODE
IF VTAM_ACTIVE = 'YES' THEN 
  SAY 'VTAM:' VTAMLEV '(NETID:' ATCNETID') (SSCPNAME:' ATCNQNAM')'
return 0

SVC:
/* File 221 ListSVCT */
/* and #NUCLKUP */

numeric digits 20 /* need this for D2X/C2D  */
/* from: 
https://groups.google.com/forum/#!topic/
bit.listserv.ibm-main/XmgU5suwx9c
CVT : CVTABEND ---> SCVTSECT : 
                    SCVTSVCT ---> SVC table (mapped by IHASVC)
*/
say 'Installed SVCs:'
/* SVCEP = SVC ENTRY POINT ADDRESS */
say 'SVCEP    | SVC | HX | TYPE | APF | ESR'
say '---------|-----|----|------|-----|----'

CVT = C2D(STORAGE(10,4)) /* CVT Pointer */
CVTABEND = C2D(STORAGE(D2X(CVT + 200),4))
SCVTSVCT = C2D(STORAGE(D2X(CVTABEND + 132),4))
CVTNUCMP = C2D(STORAGE(D2X(CVT + 1200),4))
NUCMADDR = C2D(STORAGE(D2X(CVTNUCMP + 8),4))

NUCMAP = CVTNUCMP + 16
DO WHILE NUCMAP <= NUCMADDR
 IF STORAGE(D2X(NUCMAP),8) = 'IGCERROR' THEN DO
  IGCERROR = STORAGE(D2X(NUCMAP + 8),4)
  LEAVE
 END
 NUCMAP = NUCMAP + 16
END

Do i = 0 to 255
 ADDR = BITAND(STORAGE(D2X(SCVTSVCT+(i*8)),4),'7FFFFFFF'x)
 IF IGCERROR /= ADDR THEN DO
  SVCTYPE = STORAGE(D2X(SCVTSVCT+(i*8)+4),1)
  /* Determine Type */
  IF BITAND(SVCTYPE,'80'x) = '80'x THEN TYPE = '2'
  ELSE IF BITAND(SVCTYPE,'C0'x) = 'C0'x THEN TYPE = '3/4'
  ELSE IF BITAND(SVCTYPE,'20'x) = '20'x THEN TYPE = '6'
  ELSE IF BITAND(SVCTYPE,'F0'x) = '00'x THEN TYPE = '1'
  ELSE TYPE = '?'
  /* Is APF? */
  IF BITAND(SVCTYPE,'08'x) = '08'x THEN APF = 'Y'
  ELSE APF = "N"
  IF BITAND(SVCTYPE,'04'x) = '04'x THEN ESR = 'Y'
  ELSE ESR = "N"
  
  SAY C2X(STORAGE(D2X(SCVTSVCT+(i*8)),4)) "|",
      RIGHT(i,3,0) "|" RIGHT(D2X(i),2,0) "| ",
      TYPE "  | " APF " | " ESR
  /* CALL HEXDUMP(STORAGE(D2X(SCVTSVCT+(i*8)),8)) */
 END
END
RETURN 0

PATH: PROCEDURE
/* Identify DDNAME Allocated Datasets */
/* from CBT FILE 496 */
/* Like the $PATH in UNIX */
say 'DDNAME Allocated Datasets'
lvl = C2D(ARG(1))
Numeric Digits 10
/*address TSO*/
PSALCCAV = C2D(STORAGE(21C, 4))
TCBTIO = C2D(STORAGE(D2X(PSALCCAV + 12), 4)) /* Points to TIOT PAGE 338 */
TIOT = TCBTIO + 24
TIOELNGH = 0
DD = ''
IF lvl < 1 THEN DO 
  say 'Non-Verbose. Only displaying SYSPROC/SYSEXEC'
  say 'DD       | DATASET Name'
  say '---------|-------------'
end
else DO
  say 'DD       | VOLUME | DATASET Name'
  say '---------|--------|-------------'
END
DO FOREVER
 TIOT = TIOT + TIOELNGH
 TIOELNGH = C2D(STORAGE(D2X(TIOT))) /* STORAGE returns one byte by default */
 IF TIOELNGH = 0 THEN LEAVE /* We've hit the end */
 TIOEDDNM = STORAGE(D2X(TIOT+4),8)
 IF TIOEDDNM \= '        ' THEN DD = TIOEDDNM
 DSNADDR = D2X(SWAREQ(Storage(d2x(TIOT + 12),3)))
 DATASET = STRIP(STORAGE(DSNADDR, 44))
 VOLUME = STORAGE(D2X(X2D(DSNADDR)+118),6)
  IF lvl < 1 THEN DO
    IF DD ='SYSPROC ' | DD ='SYSEXEC ' THEN
      SAY DD "|" DATASET
  END
  ELSE
    SAY DD "|" VOLUME "|" DATASET 
END
RETURN 0 

CAT:
/* Master Catalog routing from IPLINFO */
CVT      = C2d(Storage(10,4))
ECVT     = C2d(Storage(D2x(CVT + 140),4))
ECVTIPA  = C2d(Storage(D2x(ECVT + 392),4)) /* point to IPA         */         
IPASCAT  = Storage(D2x(ECVTIPA + 224),63)
MCATDSN  = Strip(Substr(IPASCAT,11,44))    /* master catalog dsn   */         
MCATVOL  = Substr(IPASCAT,1,6) 
say 'Master Catalog:' MCATDSN 'Volume:' MCATVOL
return 0

TSTA:
/* Try to use TESTAUTH, failures are not logged (RACROUTE with LOG=NONE) */
ADDRESS 'TSO' 'NEWSTACK'
QUEUE "END"
RC = OUTTRAP('OUT.')
ADDRESS 'TSO' "TESTAUTH 'SYS1.LINKLIB(ICEPRML)'"
RC = OUTTRAP('OFF')
ADDRESS 'TSO' 'DELSTACK'
IF OUT.0 = 0 THEN
  SAY 'You ARE authorized to use TESTAUTH <-'
ELSE
  SAY OUT.1
return 0

SETROPTS:
/*********************************************************************/
/* Rexx to pull out all useful SETROPTS info from storage.           */
/* No SPECIAL or AUDITOR needed!                                     */
/*                                                                   */
/* Author:  Jim Taylor                                               */
/*            https://github.com/jaytay79/zos                        */
/*                                                                   */
/* Sources: Mark Zelden's IPLINFO Rexx:                              */
/*            http://www.mzelden.com/mvsfiles/iplinfo.txt            */
/*          Mark Wilson's "RACF for Systems Programmers" course:     */
/*            http://www.rsm.co.uk                                   */
/*          z/OS Security Server RACF Data Areas manual:             */
/*            http://publibz.boulder.ibm.com/epubs/pdf/ich2c400.pdf  */
/*          Bruce Wells' XSETRPWD                                    */
/*            ftp://public.dhe.ibm.com/s390/zos/racf/irrxutil/       */
/*********************************************************************/
numeric digits 20
say ""
say 'SETROPTS Info:'
/* Get info from storage, most of this section is a straight lift    */
/* from IPLINFO!                                                     */
CVT      = C2d(Storage(10,4))                /* point to CVT         */
CVTVERID = Storage(D2x(CVT - 24),16)         /* "user" software vers.*/
PRODNAME = Storage(D2x(CVT - 40),7)          /* point to mvs version */
CVTRAC   = C2d(Storage(D2x(CVT + 992),4))    /* point to RACF CVT    */
RCVT     = CVTRAC                            /* use RCVT name        */
RCVx     = C2D(STORAGE(D2X(CVT+X2D('3E0')),4)) /* ugly mess for bits */
RCVTID   = Storage(D2x(RCVT),4)              /* point to RCVTID      */
If RCVTID = 'RCVT' then SECNAM = 'RACF'      /* RCVT is RACF         */
RACFVRM  = Storage(D2x(RCVT + 616),4)        /* RACF Ver/Rel/Mod     */
RACFVER  = Substr(RACFVRM,1,1)               /* RACF Version         */
RACFREL  = Substr(RACFVRM,2,2)               /* RACF Release         */
If Bitand(CVTOSLV2,'01'x) <> '01'x then ,    /* below OS/390 R10     */
  RACFREL  = Format(RACFREL)                 /* Remove leading 0     */
RACFMOD  = Substr(RACFVRM,4,1)               /* RACF MOD level       */
RACFLEV  = RACFVER || '.' || RACFREL || '.' || RACFMOD
RCVTDSN = Strip(Storage(D2x(RCVT + 56),44))  /* RACF prim dsn        */

  RCVTDSDT  = C2d(Storage(D2x(RCVT + 224),4))  /* point to RACFDSDT  */
  DSDTNUM   = C2d(Storage(D2x(RCVTDSDT+4),4))  /* num RACF dsns      */
  DSDTPRIM  = Storage(D2x(RCVTDSDT+177),44)    /* point to prim ds   */
  DSDTPRIM  = Strip(DSDTPRIM,'T')              /* del trail blanks   */
  DSDTBACK  = Storage(D2x(RCVTDSDT+353),44)    /* point to back ds   */
  DSDTBACK  = Strip(DSDTBACK,'T')              /* del trail blanks   */
  RCVTUADS = Strip(Storage(D2x(RCVT + 100),44)) /* UADS dsn          */
  say  '  The UADS dataset is' RCVTUADS'.'
say ""
/* Below section pulls in bit string values for various settings     */
RCVTPRO  = RCVx + 393                          /* point to RCVTPRO   */
RCVTEROP = RCVx + 154                          /* point to RCVTEROP  */
RCVTAUOP = RCVx + 151                          /* point to RCVTAUOP  */
RCVTPROX = X2B(C2X(STORAGE(D2X(RCVTPRO),4)))   /* get the bits       */
RCVTEROX = X2B(C2X(STORAGE(D2X(RCVTEROP),4)))  /* get the bits       */
RCVTAUOX = X2B(C2X(STORAGE(D2X(RCVTAUOP),8)))  /* get the bits       */
if substr(RCVTEROX,3,1) = 0 then
 say "RACF Command violations are logged"
 else say "RACF Command violations are not logged"
if SUBSTR(RCVTPROX,1,1) = 1 then do
  say "PROTECT-ALL is on"
  if SUBSTR(RCVTPROX,2,1) = 1 then say " PROTECT-ALL WARNING mode"
    else say " PROTECT-ALL FAILURE mode"
  end
 else say "PROTECT-ALL is off"
if SUBSTR(RCVTPROX,3,1) = 1 then do
  say "ERASE-ON-SCRATCH is active, current options:"
  if SUBSTR(RCVTPROX,4,1) = 1 then say " ERASE-ON-SCRATCH BY SECLEVEL is on"
    else say " ERASE-ON-SCRATCH BY SECLEVEL is off"
  if SUBSTR(RCVTPROX,5,1) = 1 then say " ERASE-ON-SCRATCH for all",
     "datasets is on"
    else say " ERASE-ON-SCRATCH for all datasets is off"
 end
 else say "ERASE-ON-SCRATCH is off"
if SUBSTR(RCVTAUOX,2,1) = 1 then say "GROUP changes are audited"
 else say "GROUP changes are not audited"
if SUBSTR(RCVTAUOX,3,1) = 1 then say "USER changes are audited"
 else say "USER changes are not audited"
if SUBSTR(RCVTAUOX,4,1) = 1 then say "DATASET changes are audited"
 else say "DATASET changes are not audited"
if SUBSTR(RCVTAUOX,5,1) = 1 then say "DASDVOL changes are audited"
 else say "DASDVOL changes are not audited"
if SUBSTR(RCVTAUOX,6,1) = 1 then say "TAPEVOL changes are audited"
 else say "TAPEVOL changes are not audited"
if SUBSTR(RCVTAUOX,7,1) = 1 then say "TERMINAL changes are audited"
 else say "TERMINAL changes are not audited"
if substr(RCVTEROX,4,1) = 0 then say "SPECIAL users are audited"
 else say "SPECIAL users are not audited"
if SUBSTR(RCVTAUOX,8,1) = 1 then say "OPERATIONS users are audited"
 else say "OPERATIONS users are NOT audited"
say ""
/* Get the RVARY password info */
RCVTSWPW = Strip(Storage(D2x(RCVT + 440),8))  /* rvary switch pw     */
if c2x(RCVTSWPW) = "0000000000000000" then
 say "RVARY SWITCH password is set to default value of YES"
 else say "RVARY SWITCH password DES hash:" c2x(RCVTSWPW)
RCVTINPW = Strip(Storage(D2x(RCVT + 448),8))  /* rvary status pw     */
if c2x(RCVTINPW) = "0000000000000000" then
 say "RVARY STATUS password is set to default value of YES"
 else say "RVARY STATUS password DES hash:" c2x(RCVTINPW)
say ""
/* Get password and other related settings */
RCVTPINV  = C2d(Storage(D2x(RCVT + 155),1))  /* point to RCVTPINV   */
say "Global password change interval:" RCVTPINV "days"
/* Note that if a rule is set to 8 "*"s then it defaults to "0"s    */
/* which means the rule appears blank.                              */
/* Workaround for this is to look at the max length of each rule to */
/* see if it is truly a blank rule line or not!                     */
RCVTSNT1 = Strip(Storage(D2x(RCVT + 246),8))  /* PW syntax rule 1    */
RCVTSNT1S = Strip(Storage(D2x(RCVT + 244),1)) /* rule 1 min          */
RCVTSNT1E = Strip(Storage(D2x(RCVT + 245),1)) /* rule 1 max          */
 RCVTSNT1 = pwcheck(RCVTSNT1,RCVTSNT1E)       /* check rule 1        */
RCVTSNT2 = Strip(Storage(D2x(RCVT + 256),8))  /* PW syntax rule 2    */
RCVTSNT2S = Strip(Storage(D2x(RCVT + 254),1)) /* rule 2 min          */
RCVTSNT2E = Strip(Storage(D2x(RCVT + 255),1)) /* rule 2 max          */
 RCVTSNT2 = pwcheck(RCVTSNT2,RCVTSNT2E)       /* check rule 2        */
RCVTSNT3 = Strip(Storage(D2x(RCVT + 266),8))  /* PW syntax rule 3    */
RCVTSNT3S = Strip(Storage(D2x(RCVT + 264),1)) /* rule 3 min          */
RCVTSNT3E = Strip(Storage(D2x(RCVT + 265),1)) /* rule 3 max          */
 RCVTSNT3 = pwcheck(RCVTSNT3,RCVTSNT3E)       /* check rule 3        */
RCVTSNT4 = Strip(Storage(D2x(RCVT + 276),8))  /* PW syntax rule 4    */
RCVTSNT4S = Strip(Storage(D2x(RCVT + 274),1)) /* rule 4 min          */
RCVTSNT4E = Strip(Storage(D2x(RCVT + 275),1)) /* rule 4 max          */
 RCVTSNT4 = pwcheck(RCVTSNT4,RCVTSNT4E)       /* check rule 4        */
RCVTSNT5 = Strip(Storage(D2x(RCVT + 286),8))  /* PW syntax rule 5    */
RCVTSNT5S = Strip(Storage(D2x(RCVT + 284),1)) /* rule 5 min          */
RCVTSNT5E = Strip(Storage(D2x(RCVT + 285),1)) /* rule 5 max          */
 RCVTSNT5 = pwcheck(RCVTSNT5,RCVTSNT5E)       /* check rule 5        */
RCVTSNT6 = Strip(Storage(D2x(RCVT + 296),8))  /* PW syntax rule 6    */
RCVTSNT6S = Strip(Storage(D2x(RCVT + 294),1)) /* rule 6 min          */
RCVTSNT6E = Strip(Storage(D2x(RCVT + 295),1)) /* rule 6 max          */
 RCVTSNT6 = pwcheck(RCVTSNT6,RCVTSNT6E)       /* check rule 6        */
RCVTSNT7 = Strip(Storage(D2x(RCVT + 306),8))  /* PW syntax rule 7    */
RCVTSNT7S = Strip(Storage(D2x(RCVT + 304),1)) /* rule 7 min          */
RCVTSNT7E = Strip(Storage(D2x(RCVT + 305),1)) /* rule 7 max          */
 RCVTSNT7 = pwcheck(RCVTSNT7,RCVTSNT7E)       /* check rule 7        */
RCVTSNT8 = Strip(Storage(D2x(RCVT + 316),8))  /* PW syntax rule 8    */
RCVTSNT8S = Strip(Storage(D2x(RCVT + 314),1)) /* rule 8 min          */
RCVTSNT8E = Strip(Storage(D2x(RCVT + 315),1)) /* rule 8 max          */
 RCVTSNT8 = pwcheck(RCVTSNT8,RCVTSNT8E)       /* check rule 8        */
say "Password syntax rules:"
if c2x(RCVTSNT1E) <> "00" then do
  say " Rule 1:" RCVTSNT1
  Say "    Min length:" c2x(RCVTSNT1S)
  Say "    Max length:" c2x(RCVTSNT1E)
  end
if c2x(RCVTSNT2E) <> "00" then do
  say " Rule 2:" RCVTSNT2
  Say "    Min length:" c2x(RCVTSNT2S)
  Say "    Max length:" c2x(RCVTSNT2E)
  end
if c2x(RCVTSNT3E) <> "00" then do
  say " Rule 3:" RCVTSNT3
  Say "    Min length:" c2x(RCVTSNT3S)
  Say "    Max length:" c2x(RCVTSNT3E)
  end
if c2x(RCVTSNT4E) <> "00" then do
  say " Rule 4:" RCVTSNT4
  Say "    Min length:" c2x(RCVTSNT4S)
  Say "    Max length:" c2x(RCVTSNT4E)
  end
if c2x(RCVTSNT5E) <> "00" then do
  say " Rule 5:" RCVTSNT5
  Say "    Min length:" c2x(RCVTSNT5S)
  Say "    Max length:" c2x(RCVTSNT5E)
  end
if c2x(RCVTSNT6E) <> "00" then do
  say " Rule 6:" RCVTSNT6
  Say "    Min length:" c2x(RCVTSNT6S)
  Say "    Max length:" c2x(RCVTSNT6E)
  end
if c2x(RCVTSNT7E) <> "00" then do
  say " Rule 7:" RCVTSNT7
  Say "    Min length:" c2x(RCVTSNT7S)
  Say "    Max length:" c2x(RCVTSNT7E)
  end
if c2x(RCVTSNT8E) <> "00" then do
  say " Rule 8:" RCVTSNT8
  Say "    Min length:" c2x(RCVTSNT8S)
  Say "    Max length:" c2x(RCVTSNT8E)
  end
if c2x(RCVTSNT1E) = "00" & c2x(RCVTSNT2E) = "00",
   & c2x(RCVTSNT3E) = "00" & c2x(RCVTSNT4E) = "00",
   & c2x(RCVTSNT5E) = "00" & c2x(RCVTSNT6E) = "00",
   & c2x(RCVTSNT7E) = "00" & c2x(RCVTSNT8E) = "00",
   then  say " ** No password rules defined! **"
else say " LEGEND:",
    "A-ALPHA C-CONSONANT L-ALPHANUM N-NUMERIC V-VOWEL W-NOVOWEL" ,
    "*-ANYTHING  c-MIXED CONSONANT m-MIXED NUMERIC v-MIXED VOWEL",
    "$-NATIONAL s-SPECIAL"
RCVTSLEN = C2D(Strip(Storage(D2x(RCVT + 244),1))) /* min possible    */
if RCVTSLEN = 0 then RCVTSLEN = 1                 /* password length */
Say "Minimum possible password length:" RCVTSLEN
RCVTELEN = C2D(Strip(Storage(D2x(RCVT + 245),1))) /* max possible    */
if RCVTELEN = 0 then RCVTELEN = 8                 /* password length */
Say "Maximum possible password length:" RCVTELEN
RCVTRVOK = C2D(Strip(Storage(D2x(RCVT + 241),1))) /* logon attempts  */
if RCVTRVOK = 0 then RCVTRVOK = "unlimited"
Say "Invalid logon attempts allowed:" RCVTRVOK
RCVTINAC = C2D(Strip(Storage(D2x(RCVT + 243),1))) /* inactive intvl  */
if RCVTINAC = "0" then
 say "No inactive interval"
 else say "Inactive interval:" RCVTINAC "days"
RCVTHIST = C2D(Strip(Storage(D2x(RCVT + 240),1))) /* pw generations  */
if RCVTHIST = "0" then
 say "No password history in use"
 else say "Password history:" RCVTHIST "generations"
/* Misc password related bit string flags */
RCVTFLG3 = RCVx + 633                          /* point to RCVTFLG3  */
RCVTFLGX = X2B(C2X(STORAGE(D2X(RCVTFLG3),8)))  /* get the bits       */
if SUBSTR(RCVTFLGX,2,1) = 1 then say "Mixed case passwords enabled"
 else say "Mixed case passwords disabled"
if SUBSTR(RCVTFLGX,5,1) = 1 then
 say "Special characters are allowed in passwords"
 else say "Special characters are not allowed in passwords"
if SUBSTR(RCVTFLGX,6,1) = 1 then
 say "Enhanced password options under OA43999 are available"
 else say "Enhanced password options under OA43999 are not available"
if SUBSTR(RCVTFLGX,7,1) = 1 then say "Multi factor auth is available"
 else say "Multi factor auth is not available"
RCVTFLG4 = RCVx + 640                          /* point to RCVTFLG4  */
RCVTFLGY = X2B(C2X(STORAGE(D2X(RCVTFLG4),8)))  /* get the bits       */
if SUBSTR(RCVTFLGY,2,1) = 1 then say " MFA3 is available (OA50930)"
 else say " MFA3 is not available (OA50930)"
/* Checks for new password encryption */
RCVTPALG = C2D(Strip(Storage(D2x(RCVT + 635),1))) /* pw encryption   */
if RCVTPALG = "1" then say "KDFAES encryption is active"
 else say "Legacy encryption is active"
/* ----------------------------------------------------------------- */
/* See if new password exit is active.                               */
/* ----------------------------------------------------------------- */
pwx01hex = Storage(D2x(RCVT + 236),4)
RCVTPWDX = C2d(BITAND(pwx01hex,'7FFFFFFF'x))
If RCVTPWDX = 0 Then
  YesOrNo = 'is NOT'
else
  YesOrNo = 'IS'
say "There" YesOrNo "a new password exit (ICHPWX01) installed."
return 0

/* pwcheck function to check for an empty rule but with a max length */
pwcheck: parse arg pw length
if c2x(pw) = "0000000000000000" & c2x(length) <> "00" then
 return "********"
 else return pw

/*--------------------------------------------------------------------*\
|*                                                                    *|
|* MODULE NAME = SWAREQ                                               *|
|*                                                                    *|
|* DESCRIPTIVE NAME = Convert an SVA to a 31-bit address              *|
|*                                                                    *|
|* STATUS = R200                                                      *|
|*                                                                    *|
|* FUNCTION = The SWAREQ function simulates the SWAREQ macro to       *|
|*            convert an SWA Virtual Address (SVA) to a full 31-bit   *|
|*            address which can be used to access SWA control blocks  *|
|*            in the SWA=ABOVE environment.  The input is a 3-byte    *|
|*            SVA; the output value is a 10-digit decimal number.     *|
|*                                                                    *|
|* AUTHOR   =  Gilbert Saint-Flour <gsf@pobox.com>                    *|
|*                                                                    *|
|* DEPENDENCIES = TSO/E V2                                            *|
|*                                                                    *|
|* SYNTAX   =  SWAREQ(sva)                                            *|
|*                                                                    *|
|*             sva must contain a 3-byte SVA.                         *|
|*                                                                    *|
\*--------------------------------------------------------------------*/
SWAREQ: PROCEDURE
NUMERIC DIGITS 20                         /* allow up to 2**64    */
sva=C2D(ARG(1))                           /* convert to decimal   */
tcb = C2D(STORAGE(21C,4))                 /* TCB         PSATOLD  */
jscb = C2D(STORAGE(D2X(tcb+180),4))       /* JSCB        TCBJSCB  */
qmpl = C2D(STORAGE(D2X(jscb+244),4))      /* QMPL        JSCBQMPI */
/* See if qmat can be above the bar */
qmsta= C2X(STORAGE(D2X(qmpl+16),1))       /* JOB STATUS BYTE      */
if SUBSTR(X2B(qmsta),6,1) then            /* is QMQMAT64 bit on?  */
do                                        /* yes, qmat can be ATB */
  IF RIGHT(X2B(C2X(ARG(1))),1) \= '1' THEN/* SWA=BELOW ?          */
    RETURN C2D(ARG(1))+16                 /* yes, return sva+16   */
  qmat=C2D(STORAGE(D2X(qmpl+10),2))*(2**48) +,/* QMAT+0  QMADD01  */
       C2D(STORAGE(D2X(qmpl+18),2))*(2**32) +,/* QMAT+2  QMADD23  */
       C2D(STORAGE(D2X(qmpl+24),4))       /* QMAT+4      QMADD    */
  RETURN C2D(STORAGE(D2X(qmat+(sva*12)+64),4))+16
end
else
do                                        /* no, qmat is BTB      */
  IF RIGHT(C2X(ARG(1)),1) \= 'F' THEN     /* SWA=BELOW ?          */
    RETURN C2D(ARG(1))+16                 /* yes, return sva+16   */
  qmat = C2D(STORAGE(D2X(qmpl+24),4))     /* QMAT        QMADD    */
  DO WHILE sva>65536
    qmat = C2D(STORAGE(D2X(qmat+12),4))   /* next QMAT   QMAT+12  */
    sva=sva-65536                         /* 010006F -> 000006F   */
  END
  RETURN C2D(STORAGE(D2X(qmat+sva+1),4))+16
end
/*-------------------------------------------------------------------*/



HEXDUMP: PROCEDURE
say 'HEXDUMP:'
HEXOUT = ''
j = 1
Do i = 1 to LENGTH(ARG(1))
 HEXOUT = HEXOUT ||" " || C2X(SUBSTR(ARG(1),i,1))
 IF i // 8 = 0 THEN DO
  if i = 8 THEN j = 1
  ELSE j = i - 8
  SAY HEXOUT "|" SUBSTR(ARG(1),j,8)
  HEXOUT = ''
 END
END
IF LENGTH(ARG(1)) // 8 /= 0 THEN
SAY HEXOUT "|" SUBSTR(ARG(1),j,LENGTH(ARG(1)))
RETURN 0
/*-------------------------------------------------------------------*/ 
ptr:  Return c2d(storage(d2x(Arg(1)),4))     /* Return a pointer */     
/*-------------------------------------------------------------------*/ 
stg:  Return storage(d2x(Arg(1)),Arg(2))     /* Return storage */       
