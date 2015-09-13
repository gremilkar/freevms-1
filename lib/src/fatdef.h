#ifndef FATDEF_H
#define FATDEF_H

/* Access.h v1.3    Definitions for file access routines */

/*
        This is part of ODS2 written by Paul Nankervis,
        email address:  Paulnank@au1.ibm.com

        ODS2 is distributed freely for all members of the
        VMS community to use. However all derived works
        must maintain comments in their source to acknowledge
        the contibution of the original author.

    Originally part of access.h
*/

#include <vms_types.h>

#define     FAT$C_UNDEFINED     0
#define     FAT$C_FIXED     1
#define     FAT$C_VARIABLE      2
#define     FAT$C_VFC       3
#define     FAT$C_STREAM        4
#define     FAT$C_STREAMLF      5
#define     FAT$C_STREAMCR      6
#define     FAT$C_SEQUENTIAL    0
#define     FAT$C_RELATIVE      1
#define     FAT$C_INDEXED       2
#define     FAT$C_DIRECT        3
#define     FAT$C_SPECIAL       4
#define     FAT$M_FORTRANCC     0x1
#define     FAT$M_IMPLIEDCC     0x2
#define     FAT$M_PRINTCC       0x4
#define     FAT$M_NOSPAN        0x8
#define     FAT$M_MSBRCW        0x10
#define     FAT$C_FIFO      1
#define     FAT$C_CHAR_SPECIAL  2
#define     FAT$C_BLOCK_SPECIAL 3
#define     FAT$C_SYMLINK       4
#define     FAT$K_LENGTH        32
#define     FAT$C_LENGTH        32
#define     FAT$S_FATDEF        32

#define VMSSWAP(l) ((l & 0xffff) << 16 | l >> 16)

struct _fatdef
{
    _ubyte fat$b_rtype;
    _ubyte fat$b_rattrib;
    _uword fat$w_rsize;
    _ulongword fat$l_hiblk; /* funny byte order */
    _ulongword fat$l_efblk; /* funny byte order */
    _uword fat$w_ffbyte;
    _ubyte fat$b_bktsize;
    _ubyte fat$b_vfcsize;
    _uword fat$w_maxrec;
    _uword fat$w_defext;
    _uword fat$w_gbc;
    _ubyte fat$_UU0[8];
    _uword fat$w_versions;
};

#endif
