#include "starlet.h"
#include "sysdep.h"
#include <asm/unistd.h>

int sys$testcode(void) {
  return INLINE_SYSCALLTEST($setprn,0);
}

int sys$setprn  ( void *prcnam) { 
  return INLINE_SYSCALL($setprn,1,prcnam);
}

int sys$setpri( unsigned int * pidadr, void * prcnam, unsigned int pri, unsigned int * prvpri, unsigned int * pol, unsigned int * prvpol) {
  struct struct_setpri s;
  s.pidadr=pidadr;
  s.prcnam=prcnam;
  s.pri=pri;
  s.prvpri=prvpri;
  s.pol=pol;
  s.prvpol=prvpol;

  return INLINE_SYSCALL($setpri,1,&s);
  //  return INLINE_SYSCALL($setpri,6,pidadr,prcnam,pri,prvpri,pol,prvpol);
  /*return r;*/
  return 1;
};


 int sys$crelnt  (unsigned int *attr, void *resnam, unsigned
                         int *reslen, unsigned int *quota,
                unsigned short *promsk, void *tabnam, void
		  *partab, unsigned char *acmode) {

   struct struct_crelnt s;
   s.attr=attr;
   s.resnam=resnam;
   s.reslen=reslen;
   s.quota=quota;
   s.promsk=promsk;
   s.tabnam=tabnam;
   s.partab=partab;
   s.acmode=acmode;
   
}

int sys$dclast  ( void (*astadr)(unsigned long), unsigned long astprm, unsigned int acmode) { 
  return INLINE_SYSCALL($dclast,3,astadr,astprm,acmode);
}

int sys$waitfr  (unsigned int efn) {
  return INLINE_SYSCALL($waitfr,1,efn);
}

int sys$wfland  (unsigned int efn, unsigned int mask) {
  return INLINE_SYSCALL($wfland,2,efn,mask);
}

int sys$wflor  (unsigned int efn, unsigned int mask) {
  return INLINE_SYSCALL($wflor,2,efn,mask);
}

int sys$clref  (unsigned int efn) {
  return INLINE_SYSCALL($clref,1,efn);
}

int sys$setime  (unsigned long long  *timadr) {
  return INLINE_SYSCALL($setime,1,timadr);
}

int sys$setimr  (unsigned int efn, signed long long *daytim,
		 void (*astadr)(long), unsigned
		 long reqidt, unsigned int flags) {
  return INLINE_SYSCALL($setimr,5,efn,daytim,astadr,reqidt,flags);
}

int sys$cantim  (unsigned long long reqidt, unsigned int acmode) {
  return INLINE_SYSCALL($cantim,2,reqidt,acmode);
}

int sys$numtim  (unsigned short int timbuf [7], unsigned long long * timadr) {
  return INLINE_SYSCALL($numtim,2,timbuf,timadr);
}

int sys$schdwk(unsigned int *pidadr, void *prcnam, signed long long * daytim, signed long long * reptim) {
  return INLINE_SYSCALL($schdwk,4,pidadr,prcnam,daytim,reptim);
}

int sys$gettim (unsigned long long * timadr) {
  return INLINE_SYSCALL($gettim,1,timadr);
}

int sys$hiber(void) {
  return INLINE_SYSCALL($hiber,0);
}

int sys$wake(unsigned long *pidadr, void *prcnam) {
  return INLINE_SYSCALL($wake,2,pidadr,prcnam);
}

int sys$resume (unsigned int *pidadr, void *prcnam) {
  return INLINE_SYSCALL($resume,2,pidadr,prcnam);
}

int sys$exit(unsigned int code) {
  return INLINE_SYSCALL($exit,1,code);
}

int sys$forcex(unsigned int *pidadr, void *prcnam, unsigned int code) {
  return INLINE_SYSCALL($forcex,3,pidadr,prcnam,code);
}

int sys$setef(unsigned int efn) {
  return INLINE_SYSCALL($setef,1,efn);
}

int sys$readef(unsigned int efn, unsigned int *state) {
  return INLINE_SYSCALL($readef,2,efn,state);
}

int sys$synch(unsigned int efn, struct _iosb *iosb) {
  return INLINE_SYSCALL($synch,2,efn,iosb);
}

int sys$asctim  (unsigned short int *timlen, void *timbuf,
		 unsigned long long *timadr, char cvtflg) {
  return INLINE_SYSCALL3($asctim,4,timlen,timbuf,timadr,(unsigned long)cvtflg);
}

int sys$bintim  (void *timbuf, unsigned long long *timadr) {
  return INLINE_SYSCALL3($bintim,2,timbuf,timadr);
}

