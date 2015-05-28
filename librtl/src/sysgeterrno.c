
/*
 *  sysgeterrno.c
 *
 *  Copyright (C) 2003 Andrew Allison
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *The author may be contacted at freevms@sympatico.ca
 *
 *  Andrew Allison
 *  50 Denlaw Road
 *  London, Ont
 *  Canada
 *  N6G 3L4
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>


int sys$$geterrno(char *errmsg)
{
    int i, numelements;
    struct  errorcode
    {
        char *msg;
        int errno;
    } errlist[] =
    {
        {"STR$_NORMAL",1},
        {"SS$_ACCVIO",12},
        {"STR$_FACILITY",36},
        {"STR$_DIVBY_ZER",2392140},
        {"STR$_ILLSTRCLA",2392148},
        {"STR$_STRIS_INT",2392156},
        {"STR$_WRONUMARG",2392164},
        {"STR$_INSVIRMEM",2392172},
        {"STR$_STRTOOLON",2392180},
        {"STR$_ERRFREDYN",2392188},
        {"STR$_TRU",2392576},
        {"STR$_NOMATCH",2392584},
        {"STR$_INVDELIM",2392592},
        {"STR$_NOELEM",2392600},
        {"STR$_NEGSTRLEN",2393089},
        {"STR$_ILLSTRPOS",2393097},
        {"STR$_ILLSTRSPE",2393105},
        {"STR$_MATCH",2393113},
        {"LIB$_FACILITY",0},
        {"LIB$_NORMAL",0},
        {"LIB$_STRTRU",0},
        {"LIB$_ONEENTQUE",0},
        {"LIB$_KEYALRINS",0},
        {"LIB$_ERRROUCAL",0},
        {"LIB$_RESTART",0},
        {"LIB$_BADSTA",0},
        {"LIB$_FATERRLIB",0},
        {"LIB$_INSVIRMEM",0},
        {"LIB$_INPSTRTRU",0},
        {"LIB$_INVSTRDES",0},
        {"LIB$_INTLOGERR",0},
        {"LIB$_INVARG",1409588},
        {"LIB$_AMBKEY",0},
        {"LIB$_UNRKEY",0},
        {"LIB$_PUSSTAOVE",0},
        {"LIB$_USEFLORES",0},
        {"LIB$_SIGNO_ARG",0},
        {"LIB$_BADBLOADR",0},
        {"LIB$_BADBLOSIZ",0},
        {"LIB$_NOTFOU",0},
        {"LIB$_ATTCONSTO",0},
        {"LIB$_SYNTAXERR",0},
        {"LIB$_INVTYPE",0},
        {"LIB$_INSEF",0},
        {"LIB$_EF_ALRFRE",0},
        {"LIB$_EF_ALRRES",0},
        {"LIB$_EF_RESSYS",0},
        {"LIB$_INSLUN",0},
        {"LIB$_LUNALRFRE",0},
        {"LIB$_LUNRESSYS",0},
        {"LIB$_SCRBUFOVF",0},
        {"LIB$_INVSCRPOS",0},
        {"LIB$_SECINTFAI",0},
        {"LIB$_INVCHA",0},
        {"LIB$_QUEWASEMP",0},
        {"LIB$_STRIS_INT",0},
        {"LIB$_KEYNOTFOU",0},
        {"LIB$_INVCVT",0},
        {"LIB$_INVDTYDSC",0},
        {"LIB$_INVCLADSC",0},
        {"LIB$_INVCLADTY",0},
        {"LIB$_INVNBDS",0},
        {"LIB$_DESSTROVF",0},
        {"LIB$_INTOVF",0},
        {"LIB$_DECOVF",0},
        {"LIB$_FLTOVF",0},
        {"LIB$_FLTUND",0},
        {"LIB$_ROPRAND",0},
        {"LIB$_WRONUMARG",0},
        {"LIB$_NOSUCHSYM",0},
        {"LIB$_INSCLIMEM",0},
        {"LIB$_AMBSYMDEF",0},
        {"LIB$_NOCLI",0},
        {"LIB$_UNECLIERR",0},
        {"LIB$_INVSYMNAM",1409932},
        {"LIB$_ATTREQREF",0},
        {"LIB$_INVFILSPE",0},
        {"LIB$_INVXAB",0},
        {"LIB$_NO_STRACT",0},
        {"LIB$_BADTAGVAL",0},
        {"LIB$_INVOPEZON",0},
        {"LIB$_PAGLIMEXC",0},
        {"LIB$_NOTIMP",0},
        {"LIB$_BADZONE",0},
        {"LIB$_IVTIME",0},
        {"LIB$_ONEDELTIM",0},
        {"LIB$_NEGTIM",0},
        {"LIB$_INVARGORD",0},
        {"LIB$_ABSTIMREQ",0},
        {"LIB$_DELTIMREQ",0},
        {"LIB$_INVOPER",0},
        {"LIB$_REENTRANCY",0},
        {"LIB$_UNRFORCOD",0},
        {"LIB$_ILLINISTR",0},
        {"LIB$_NUMELEMENTS",0},
        {"LIB$_ELETOOLON",0},
        {"LIB$_ILLCOMPONENT",0},
        {"LIB$_AMBDATTIM",0},
        {"LIB$_INCDATTIM",0},
        {"LIB$_ILLFORMAT",0},
        {"LIB$_UNSUPVER",0},
        {"LIB$_BADFORMAT",0},
        {"LIB$_OUTSTRTRU",0},
        {"LIB$_FILFAIMAT",0},
        {"LIB$_NEGANS",0},
        {"LIB$_QUIPRO",0},
        {"LIB$_QUICONACT",0},
        {"LIB$_ENGLUSED",0},
        {"LIB$_DEFFORUSE",0},
        {"LIB$_MEMALRFRE",0},
        {"LIB$_BADCCC",0},
        {"LIB$_EOMERROR",0},
        {"LIB$_EOMFATAL",0},
        {"LIB$_EOMWARN",0},
        {"LIB$_GSDTYP",0},
        {"LIB$_ILLFMLCNT",0},
        {"LIB$_ILLMODNAM",0},
        {"LIB$_ILLPSCLEN",0},
        {"LIB$_ILLRECLEN",0},
        {"LIB$_ILLRECLN2",0},
        {"LIB$_ILLRECTYP",0},
        {"LIB$_ILLRECTY2",0},
        {"LIB$_ILLSYMLEN",0},
        {"LIB$_NOEOM",0},
        {"LIB$_RECTOOSML",0},
        {"LIB$_SEQUENCE",0},
        {"LIB$_SEQUENCE2",0},
        {"LIB$_STRLVL",0},
        {"LIB$_NOWILD",0},
        {"LIB$_ACTIMAGE",0},
        {"LIB$_CLOSEIN",0},
        {"LIB$_READERR",0},
        {"RMS$_RTB",0},
        {"RMS$_EOF",0},
        {"RMS$_FNF",0},
        {"RMS$_NMF",0},
        {"RMS$_WCC",0},
        {"RMS$_BUG",0},
        {"RMS$_DIR",0},
        {"RMS$_ESS",0},
        {"RMS$_FNM",0},
        {"RMS$_IFI",0},
        {"RMS$_NAM",0},
        {"RMS$_RSS",0},
        {"RMS$_RSZ",0},
        {"RMS$_WLD",0},
        {"SYSTEM$_FACILITY",0},
        {"SS$_NORMAL",1},
        {"SS$_CONTINUE",1},
        {"SS$_WASCLR",1},
        {"SS$_WASSET",9},
        {"SS$_REMEMBER",1},
        {"SS$_ACCVIO",12},
        {"SS$_BADPARAM",20},
        {"SS$_EXQUOTA",28},
        {"SS$_NOPRIV",36},
        {"SS$_ABORT",44},
        {"SS$_BADATTRIB",52},
        {"SS$_BADESCAPE",60},
        {"SS$_BADIMGHDR",68},
        {"SS$_CHANINTLK",76},
        {"SS$_CTRLERR",84},
        {"SS$_DATACHECK",92},
        {"SS$_DEVFOREIGN",100},
        {"SS$_DEVNOTMBX",116},
        {"SS$_DEVNOTMOUNT",124},
        {"SS$_DEVOFFLINE",132},
        {"SS$_DRVERR",140},
        {"SS$_DUPLNAM",148},
        {"SS$_FILACCERR",156},
        {"SS$_FILALRACC",164},
        {"SS$_FILNOTACC",172},
        {"SS$_FILNOTEXP",180},
        {"SS$_FORMAT",188},
        {"SS$_GPTFULL",196},
        {"SS$_GSDFULL",204},
        {"SS$_LCKPAGFUL",212},
        {"SS$_ILLBLKNUM",220},
        {"SS$_ILLCNTRFUNC",228},
        {"SS$_ILLEFC",236},
        {"SS$_ILLIOFUNC",244},
        {"SS$_ILLPAGCNT",252},
        {"SS$_ILLSER",260},
        {"SS$_INCVOLLABEL",268},
        {"SS$_INSFARG",276},
        {"SS$_INSFWSL",284},
        {"SS$_INSFMEM",292},
        {"SS$_INSFRAME",300},
        {"SS$_IVADDR",308},
        {"SS$_IVCHAN",316},
        {"SS$_IVDEVNAM",324},
        {"SS$_IVGSDNAM",332 },
        {"SS$_IVLOGTAB",348 },
        {"SS$_IVQUOTAL",356 },
        {"SS$_IVSECFLG",364 },
        {"SS$_IVSSRQ",372 },
        {"SS$_IVSTSFLG",380 },
        {"SS$_IVTIME",388 },
        {"SS$_LENVIO",396 },
        {"SS$_LKWSETFUL",404},
        {"SS$_MBTOOSML",412},
        {"SS$_MEDOFL",420},
        {"SS$_NODATA",428},
        {"SS$_NOIOCHAN",436},
        {"SS$_NOLOGNAM",444},
        {"SS$_NONEXDRV",452},
        {"SS$_NOTFILEDEV",460},
        {"SS$_NOTINTBLSZ",468},
        {"SS$_NOTLABELMT",476},
        {"SS$_NOTSQDEV",484},
        {"SS$_PAGOWNVIO",492},
        {"SS$_PARITY",500},
        {"SS$_PARTESCAPE",508},
        {"SS$_PFMBSY",516},
        {"SS$_PSTFULL",524},
        {"SS$_RESULTOVF",532},
        {"SS$_SECTBLFUL",540},
        {"SS$_TAPEPOSLOST",548 },
        {"SS$_TIMEOUT",556},
        {"SS$_UNASEFC",564},
        {"SS$_UNSAFE",572},
        {"SS$_VASFULL",580},
        {"SS$_VECINUSE",588},
        {"SS$_VOLINV",596},
        {"SS$_WRITLCK",604},
        {"SS$_NOTAPEOP",612},
        {"SS$_IVCHNLSEC",620},
        {"SS$_NOMBX",628},
        {"SS$_NOLINKS",636},
        {"SS$_NOSOLICIT",644},
        {"SS$_NOSUCHNODE",652},
        {"SS$_REJECT",660},
        {"SS$_TOOMUCHDATA",668},
        {"SS$_BUGCHECK",676},
        {"SS$_FILNOTCNTG",684},
        {"SS$_BADSTACK",692},
        {"SS$_MCHECK",700 },
        {"SS$_DEVACTIVE",708 },
        {"SS$_HANGUP",716 },
        {"SS$_OPINCOMPL",724 },
        {"SS$_ILLSEQOP",732 },
        {"SS$_IVSECIDCTL",740 },
        {"SS$_NOTNETDEV",748 },
        {"SS$_IVPROTECT",756 },
        {"SS$_ACPVAFUL",764 },
        {"SS$_MTLBLLONG",772 },
        {"SS$_BUFBYTALI",780 },
        {"SS$_NOAQB",788},
        {"SS$_WRONGACP",796 },
        {"SS$_BUFNOTALIGN",804 },
        {"SS$_DEVCMDERR",812 },
        {"SS$_DEVREQERR",820 },
        {"SS$_INSFBUFDP",828 },
        {"SS$_INSFMAPREG",836 },
        {"SS$_IVBUFLEN",844 },
        {"SS$_IVMODE",852 },
        {"SS$_MCNOTVALID",860 },
        {"SS$_POWERFAIL",868 },
        {"SS$_SHMGSNOTMAP",876 },
        {"SS$_TOOMANYLNAM",884},
        {"SS$_SHMNOTCNCT",892 },
        {"SS$_NOTCREATOR",900 },
        {"SS$_INTERLOCK	",908 },
        {"SS$_BADQUEUEHDR",916 },
        {"SS$_NOSLOT",924 },
        {"SS$_SUSPENDED",932},
        {"SS$_EXPORTQUOTA",940},
        {"SS$_NOSHMBLOCK",948 },
        {"SS$_BADQFILE",956 },
        {"SS$_NOQFILE",964 },
        {"SS$_QFACTIVE",972 },
        {"SS$_QFNOTACT",980 },
        {"SS$_DUPDSKQUOTA",988 },
        {"SS$_NODISKQUOTA",996 },
        {"SS$_EXDISKQUOTA",1004},
        {"SS$_IDMISMATCH",1012 },
        {"SS$_NOWRT",1020 },
        {"SS$_BADISD",8196 },
        {"SS$_RELINK",8204},
        {"SS$_NOTINSTALL",8212 },
        {"SS$_SHARTOOBIG",8220 },
        {"SS$_NOP1VA",8228 },
        {"SS$_MULTRMS",8236 },
        {"SS$_VECFULL",8244 },
        {"SS$_IVLVEC",8252 },
        {"SS$_INSFSPTS",8260 },
        {"SS$_DISCONNECT",8268 },
        {"SS$_PRIVINSTALL",8276 },
        {"SS$_PROTINSTALL",8284} ,
        {"SS$_BADVEC",8292 },
        {"SS$_REMRSRC",8300},
        {"SS$_PROTOCOL",8308 },
        {"SS$_THIRDPARTY",8316 },
        {"SS$_NOSUCHUSER",8324 },
        {"SS$_SHUT",8332 },
        {"SS$_UNREACHABLE ",8340},
        {"SS$_INVLOGIN",8348 },
        {"SS$_NOSUCHOBJ",8356 },
        {"SS$_EXCPUTIM",8364 },
        {"SS$_OPRABORT",8372 },
        {"SS$_SHRIDMISMAT",8380},
        {"SS$_COMMHARD",8388},
        {"SS$_IVCHAR",8396},
        {"SS$_DEVINACT",8404},
        {"SS$_CONNECFAIL",8412},
        {"SS$_LINKABORT",8420},
        {"SS$_LINKDISCON",8428},
        {"SS$_LINKEXIT",8436},
        {"SS$_PATHLOST",8444},
        {"SS$_CLEARED",8452},
        {"SS$_RESET",8460},
        {"SS$_UNSOLICIT",8468},
        {"SS$_TOOMANYREDS",8476},
        {"SS$_IVLOCKID",8484},
        {"SS$_SUBLOCKS",8492},
        {"SS$_PARNOTGRANT",8500},
        {"SS$_CVTUNGRANT",8508},
        {"SS$_FORCEDERROR",8516},
        {"SS$_ILLSELF",8524},
        {"SS$_ILLCDTST",8532},
        {"SS$_NOLISTENER",8540},
        {"SS$_EXGBLPAGFIL",8548},
        {"SS$_BADRCT",8556},
        {"SS$_DIRNOTEMPTY",8564},
        {"SS$_FORCEDEXIT",8572},
        {"SS$_NOTPRINTED",8580},
        {"SS$_JBCERROR",8588},
        {"SS$_NOLICENSE",8596},
        {"SS$_VCBROKEN",8604},
        {"SS$_VCCLOSED",8612},
        {"SS$_INSFCDT",8620},
        {"SS$_DEVNOTDISM",8628},
        {"SS$_NOSHRIMG",8636},
        {"SS$_DUPUNIT",8644},
        {"SS$_BADACLCTX",8652},
        {"SS$_SERIOUSEXCP",8660},
        {"SS$_TEMPLATEDEV",8668},
        {"SS$_IVACL",8676},
        {"SS$_NOSUCHID",8684},
        {"SS$_NOLCLMEDA",8692},
        {"SS$_NOREGAVIL",8700},
        {"SS$_NOREGSUIT",8708},
        {"SS$_NOSUCHPGM",8716},
        {"SS$_PGMLDFAIL",8724},
        {"SS$_PGMSTDALN",8732},
        {"SS$_IVIDENT",8740},
        {"SS$_DUPIDENT",8748},
        {"SS$_INCSEGTRA",8756},
        {"SS$_NODELEAVE",8764},
        {"SS$_KERNELINV",8772},
        {"SS$_EXLNMQUOTA",8780},
        {"SS$_PARENT_DEL",8788},
        {"SS$_PARNOTSYS",8796},
        {"SS$_INSSWAPSPACE",8804},
        {"SS$_VOLOERR",8812},
        {"SS$_DATALATE",8820},
        {"SS$_OVRMAXARG",8828},
        {"SS$_SHACHASTA",8836},
        {"SS$_TERMNETDEV",8844},
        {"SS$_NOLOGTAB",8852},
        {"SS$_WRONGNAME",8860},
        {"SS$_NOVOLACC",8868},
        {"SS$_NOFILACC",8876},
        {"SS$_INVEXHLIST",8884},
        {"SS$_NOACLSUPPORT",8892},
        {"SS$_INVSECLASS",8900},
        {"SS$_INCSHAMEM",8908},
        {"SS$_DEVNOTSHR",8916 },
        {"SS$_RUCONFLICT",8924 },
        {"SS$_DATALOST",8932 },
        {"SS$_REMOTE_PROC",8940},
        {"SS$_CPUNOTACT",8948 },
        {"SS$_SRVMMAT",8956 },
        {"SS$_EXLICENSE",8964 },
        {"SS$_INVLICENSE",8972 },
        {"SS$_LICENSE_LEVEL",8980 },
        {"SS$_INV_HW_ID",8988 },
        {"SS$_BADCONTEXT",8996 },
        {"SS$_TOOMUCHCTX",9004 },
        {"SS$_VA_IN_USE",9012 },
        {"SS$_NODELETE",9020 },
        {"SS$_NOSUCHCPU",9028 },
        {"SS$_IMGVEXC",9036 },
        {"SS$_NOSAVPEXC",9044 },
        {"SS$_NOSUCHTID",9052 },
        {"SS$_NOSUCHRM",9060 },
        {"SS$_NOCURTID",9068 },
        {"SS$_WRONGSTATE",9076},
        {"SS$_VETO",9084},
        {"SS$_PWDSYNTAX",9092},
        {"SS$_PWDNOTDIF",9100},
        {"SS$_INVPWDLEN",9108},
        {"SS$_SYSVERDIF",9116},
        {"SS$_HWM_STALL",9124},
        {"SS$_NOSUSPEND",9132},
        {"SS$_NOSUCHPART",9140},
        {"SS$_RMALRDCL",9148},
        {"SS$_ALRCURTID",9156},
        {"SS$_INVLOG",9164},
        {"SS$_BADLOGVER",9172},
        {"SS$_OPINPROG",9180},
        {"SS$_WRONGACMODE",9188},
        {"SS$_SUBTRACED",9196},
        {"SS$_ARCHIVING",9204},
        {"SS$_ARCHIVED",9212},
        {"SS$_SITEPWDFAIL",9220},
        {"SS$_NOSUCHCPB",9228},
        {"SS$_CPUCAP",9236},
        {"SS$_LOADER",9244},
        {"SS$_HSTBUFACC",9252},
        {"SS$_INCONOLCK",9260},
        {"SS$_INVEVENT",9268 },
        {"SS$_NOSUCHFAC",9276},
        {"SS$_NOCALLPRIV",9284},
        {"SS$_INSFLPGS",9292},
        {"SS$_INSFRPGS",9300},
        {"SS$_BADREASON",9308},
        {"SS$_NOSUCHBID",9316},
        {"SS$_NOTORIGIN",9324},
        {"SS$_NOLOG",9332},
        {"SS$_TPDISABLED",9340},
        {"SS$_BRANCHENDED",9348},
        {"SS$_BRANCHSTARTED",9356 },
        {"SS$_NOSUCHREPORT",9364},
        {"SS$_BADTIME",9372},
        {"SS$_PARTJOINED",9380},
        {"SS$_NOPRESUME",9388},
        {"SS$_RECOVERCANCEL",9396},
        {"SS$_CURTIDCHANGE",9404},
        {"SS$_NOREADER",9412},
        {"SS$_NOWRITER",9420},
        {"SS$_DEVNOTWS",9428},
        {"SS$_PLHLDR",1028},
        {"SS$_ASTFLT",1036},
        {"SS$_BREAK",1044},
        {"SS$_CMODSUPR",1052},
        {"SS$_CMODUSER",1060},
        {"SS$_COMPAT",1068},
        {"SS$_OPCCUS",1076},
        {"SS$_OPCDEC",1084},
        {"SS$_PAGRDERR",1092},
        {"SS$_RADRMOD",1100},
        {"SS$_ROPRAND",1108},
        {"SS$_SSFAIL",1116},
        {"SS$_TBIT",1124 },
        {"SS$_DEBUG",1132 },
        {"SS$_ARTRES",1140},
        {"SS$_INTOVF",1148},
        {"SS$_INTDIV",1156},
        {"SS$_FLTOVF",1164},
        {"SS$_FLTDIV",1172},
        {"SS$_FLTUND",1180},
        {"SS$_DECOVF",1188},
        {"SS$_SUBRNG",1196},
        {"SS$_FLTOVF_F",1204},
        {"SS$_FLTDIV_F",1212},
        {"SS$_FLTUND_F",1220},
        {"SS$_INHCHMK",1228},
        {"SS$_INHCHME",1236},
        {"SS$_VECDIS",1244},
        {"SS$_VARITH",1252},
        {"SS$_ILLVECOP",1260},
        {"SS$_VECALIGN",1268},
        {"SS$_BUFFEROVF",1537},
        {"SS$_CONTROLO",1545},
        {"SS$_CONTROLY",1553},
        {"SS$_CREATED",1561},
        {"SS$_MSGNOTFND",1569},
        {"SS$_NOTRAN",1577 },
        {"SS$_SUPERSEDE",1585},
        {"SS$_WASECC",1593},
        {"SS$_DEVALRALLOC",1601},
        {"SS$_REMOTE",1609},
        {"SS$_CONTROLC",1617},
        {"SS$_NOTMODIFIED",1625},
        {"SS$_RDDELDATA",1633},
        {"SS$_OVRDSKQUOTA",1641},
        {"SS$_OBSOLETE_1",1649},
        {"SS$_FILEPURGED",1657},
        {"SS$_NOTALLPRIV",1665},
        {"SS$_SYNCH",1673},
        {"SS$_CONCEALED",1681},
        {"SS$_INCOMPAT",1689},
        {"SS$_DBGOPCREQ",1697},
        {"SS$_ALRDYCLOSED",1705},
        {"SS$_LNMCREATED",1713},
        {"SS$_ACEIDMATCH",1721},
        {"SS$_DBGEVENT",1729},
        {"SS$_REMOVED",1737},
        {"SS$_QUEUED",1745},
        {"SS$_SUBDISABLED",1753},
        {"SS$_FORGET",1761},
        {"SS$_PREPARED",1769},
        {"SS$_NOMOREITEMS",1777},
        {"SS$_VOLATILE",1785},
        {"SS$_ACCONFLICT",2048},
        {"SS$_BADCHKSUM",2056},
        {"SS$_BADFILEHDR",2064},
        {"SS$_BADFILENAME",2072},
        {"SS$_BADFILEVER",2080},
        {"SS$_BADIRECTORY ",2088},
        {"SS$_CANCEL",2096},
        {"SS$_DATAOVERUN",2104},
        {"SS$_DEVALLOC",2112},
        {"SS$_DEVASSIGN",2120},
        {"SS$_DEVICEFULL",2128},
        {"SS$_DEVNOTALLOC ",2136},
        {"SS$_DIRFULL",2144},
        {"SS$_DUPFILENAME",2152},
        {"SS$_ENDOFFILE",2160},
        {"SS$_ENDOFTAPE",2168},
        {"SS$_EXTIDXFILE",2176},
        {"SS$_FCPREADERR",2184},
        {"SS$_FCPREWNDERR",2192},
        {"SS$_FCPSPACERR",2200},
        {"SS$_FCPWRITERR",2208},
        {"SS$_FILELOCKED",2216},
        {"SS$_FILENUMCHK",2224},
        {"SS$_FILESEQCHK",2232},
        {"SS$_FILESTRUCT",2240},
        {"SS$_HEADERFULL",2248},
        {"SS$_IDXFILEFULL",2256},
        {"SS$_MBFULL",2264},
        {"SS$_NOHOMEBLK",2272},
        {"SS$_NONEXPR",2280},
        {"SS$_NONLOCAL",2288},
        {"SS$_NOHANDLER",2296},
        {"SS$_NOSIGNAL",2304},
        {"SS$_NOSUCHDEV",2312},
        {"SS$_NOSUCHFILE",2320},
        {"SS$_RESIGNAL",2328},
        {"SS$_UNWIND",2336},
        {"SS$_UNWINDING",2344},
        {"SS$_NOMOREFILES",2352},
        {"SS$_BEGOFFILE",2360},
        {"SS$_BLOCKCNTERR",2368} ,
        {"SS$_MUSTCLOSEFL",2376},
        {"SS$_WAITUSRLBL",2384},
        {"SS$_ILLUSRLBLRD",2392},
        {"SS$_ILLUSRLBLWT",2400},
        {"SS$_ILLLBLAST",2408},
        {"SS$_ENDOFUSRLBL",2416},
        {"SS$_NOSUCHSEC",2424 },
        {"SS$_CLIFRCEXT",2432 },
        {"SS$_FCPREPSTN",2440 },
        {"SS$_TOOMANYVER",2448 },
        {"SS$_NOTVOLSET",2456 },
        {"SS$_ENDOFVOLUME",2464},
        {"SS$_NOMOREPROC",2472 },
        {"SS$_NODEVAVL",2480 },
        {"SS$_NOTQUEUED",2488 },
        {"SS$_DGQINCOMP",2496 },
        {"SS$_DIRALLOC",2504 },
        {"SS$_ACLEMPTY",2512 },
        {"SS$_NOENTRY",2520 },
        {"SS$_NOMOREACE",2528 },
        {"SS$_RIGHTSFULL",2536 },
        {"SS$_VALNOTVALID",2544},
        {"SS$_ACLFULL",2552 },
        {"SS$_NOMORENODE",2560 },
        {"SS$_NOMORELOCK",2568 },
        {"SS$_BEGOFTAPE",2576},
        {"SS$_OBJLOCKHELD",2584},
        {"SS$_CPUSTARTIP",2592} ,
        {"SS$_ALLSTARTED",2600},
        {"SS$_ALRDYSTRT",2608},
        {"SS$_ALRDYSTPPD",2616},
        {"SS$_NSTPPD",2624},
        {"SS$_UNKRESULT",2632},
        {"SS$_ITEMNOTFOUND",2640},
        {"SS$_NOMOREDEV",2648},
        {"SS$_EFNOTSET",2656},
        {"SS$_PRIMNOSTP",2664},
        {"SS$_BOOTREJECT",2672},
        {"SS$_RMTPATH",2680},
        {"SS$_OBJECT_EXISTS",2688},
        {"SS$_NOSUCHOBJECT",2696},
        {"SS$_NOVOLDESC",2704},
        {"SS$_NOPTBLDIR",2712},
        {"SS$_DRVEXISTS",2720},
        {"SS$_DEVEXISTS",2728},
        {"SS$_GOTO_UNWIND",2736},
        {"SS$_EXIT_UNWIND",2744},
        {"SS$_SMALLHEADER",2752},
        {"SS$_FDT_COMPL",2760},
        {"SS$_EOTIN",3075},
        {"SS$_CHAINW",3083},
        {"SS$_NOTINSEC",3091},
        {"SS$_NONXPAG",3099},
        {"SS$_LOGNAME",3107},
        {"SS$_CPUSTARTD",3115},
        {"SS$_CPUSTOPPING",3123 },
        {"SS$_NOTALLCANCELED ",3131 },
        {"SS$_NOTHINGDONE ",3139} ,
        {"SS$_LINEABRT",3586},
        {"SS$_DEADLOCK",3594},
        {"SS$_NOLOCKID",3602},
        {"SS$_EXDEPTH",3610},
        {"SS$_PARTMAPPED",3618},
        {"SS$_CANCELGRANT",3626},
        {"SS$_RETRY",3634},
        {"SS$_BADACL",3642},
        {"SS$_ACEEXISTS",3650},
        {"SS$_UNSUPPORTED",3658},
        {"SS$_NORIGHTSDB",3666},
        {"SS$_LOGSTALL",3674},
        {"SS$_LOGFULL",3682},
        {"SS$_PWDINDIC",3690},
        {"SS$_PWDINHIS",3698},
        {"SS$_PWDWEAK",3706},
        {"SS$_USEGENPWD",3714},
        {"SS$_INVBUSNAM",3722},
        {"SS$_INVCOMPTYPE",3730},
        {"SS$_INVCOMPID",3738},
        {"SS$_INVCOMPLIST",3746},
        {"SS$_NOCOMPLSTS",3754},
        {"SS$_INVSECDOMAIN",3762} ,
        {"SS$_BADCHECKSUM",3770} ,
        {"SS$_ARBTOOBIG",3778},
        {"SS$_ORBTOOBIG",3786},
        {"SS$_NOSUCHVOL",3882},
        {"SS$_UNSUPVOLSET",9908},
        {"SS$_BADMEDIA",10116},
        {"SS$_IVPARAM ",10148},
        {"SS$_NOPRIVSTRT",10240},
        {"SS$_NOCMKRNL",10244},
        {"SS$_NOCMEXEC",10252},
        {"SS$_NOSYSNAM",10260},
        {"SS$_NOGRPNAM",10268},
        {"SS$_NOALLSPOOL",10276},
        {"SS$_NODETACH",10284},
        {"SS$_NODIAGNOSE",10292},
        {"SS$_NOLOG_IO",10300},
        {"SS$_NOGROUP",10308},
        {"SS$_NOACNT",10316},
        {"SS$_NOPRMCEB",10324},
        {"SS$_NOPRMMBX",10332},
        {"SS$_NOPSWAPM",10340},
        {"SS$_NOALTPRI",10348},
        {"SS$_NOSETPRV",10356},
        {"SS$_NOTMPMBX",10364},
        {"SS$_NOWORLD",10372},
        {"SS$_NOMOUNT",10380},
        {"SS$_NOOPER",10388},
        {"SS$_NOEXQUOTA",10396},
        {"SS$_NONETMBX",10404},
        {"SS$_NOVOLPRO",10412},
        {"SS$_NOPHY_IO",10420},
        {"SS$_NOBUGCHK",10428},
        {"SS$_NOPRMGBL",10436},
        {"SS$_NOSYSGBL",10444},
        {"SS$_NOPFNMAP",10452},
        {"SS$_NOSHMEM",10460 },
        {"SS$_NOSYSPRV",10468},
        {"SS$_NOBYPASS",10476},
        {"SS$_NOSYSLCK",10484},
        {"SS$_UNUSED_4",10492},
        {"SS$_UNUSED_5",10500},
        {"SS$_NODOWNGRADE",10508 },
        {"SS$_NOUPGRADE",10516},
        {"SS$_NOGRPPRV",10524},
        {"SS$_NOREADALL",10532},
        {"SS$_NOSHARE",10540},
        {"SS$_NOSECURITY",10548},
        {"SS$_NOPRIVEND",10751},
        {"SS$_EXQUOTASTRT",10752},
        {"SS$_EXASTLM",10756},
        {"SS$_EXBIOLM",10764},
        {"SS$_EXBYTLM",10772},
        {"SS$_EXDIOLM",10780},
        {"SS$_EXFILLM",10788},
        {"SS$_EXPGFLQUOTA",10796},
        {"SS$_EXPRCLM",10804},
        {"SS$_EXTQELM",10812},
        {"SS$_EXENQLM",10820},
        {"SS$_EXQUOTAEND",11007},
        {"SS$_SYSAPMIN",32256},
        {"SS$_SYSAPMAX",32767}
    };

    numelements = sizeof (errlist) / sizeof (errlist[0]);
    for (i=0; i < numelements; i++)
    {
        if (strcmp (errmsg,errlist[i].msg) == 0 )
            return errlist[i].errno;
    }

    return 0;
}
