//===================================================================================================================== 
//
// cxfilefmt_mex.h :  Data structs defining format of data records in Maestro/Cntrlx trial- and cont-mode data files.
//
// AUTHOR:  saruffner, sglisberger, et al.
//
// DESCRIPTION:
// This is a modified version of the Maestro source code header file CXFILEFMT.H.  It is required to build the MATLAB 
// MEX function readcxdata(), which is used to read Maestro and Cntrlx data files into the MATLAB environment. 
// MATLAB's MEX tool uses the GNU CC compiler; while GCC can handle C++ source code files, MEX handles only C files.
//
// It is the "const <type> IDENTIFIER = <value>" syntax that caused problems with the MEX build.  While such a constant
// definition is acceptable when <value> is a constant, it introduces several problems down the line:
//    1) The compiler cannot handle "const <type> IDENTIFIER = <constant identifier>" when <constant identifier> was 
//       defined using the above syntax.  Here we must replace <constant identifer> with a constant literal or a 
//       #define'd constant name.
//    2) Any constant defined using the above syntax CANNOT be used to indicate the dimensions of an array declared 
//       outside a function.  Nor can they be used in "case <constant>" expressions within a "switch" clause.  We must 
//       define these constants using the #define construct.
//
// Thus, I've replaced all "const <type> IDENTIFIER = <value>" constructs with "#define IDENTIFIER <value>" throughout 
// this file.  I also commented out an #if-endif preprocessor clause specific to MS VC++.
//
// See also:  CXFILEFMT.H in Maestro development folder.  This includes a complete version history for data files 
// created by Maestro and its earlier incarnation, Cntrlx.
//
//
// REVISION HISTORY:
// 28mar2003-- Modified from the original CXFILEFMT.H dtd 27mar2003.  Keep in synch w/ future changes!
// 19nov2003-- Updated to synch with changes to CXFILEFMT.H dtd 19nov2003 (a field added to header record).
// 26jan2005-- Updated to synch with changes to CXFILEFMT.H dtd 25jan2005.  No impact (just added some comments). 
// 07apr2005-- Updated to synch with changes to CXFILEFMT.H dtd 06apr2005, related to the introduction of "tagged 
//             sections" in trials. 
// 29jul2005-- Updated to synch with version# change in CXFILEFMT.H dtd 29jul2005.  No format changes -- version 
//             change marks changes in implementation of noise perturbations so that they can be reproduced by 
//             readcxdata().
// 25jan2006-- Updated to synch with version# change in CXFILEFMT.H dtd 25jan2006.  Several new CXHF_ bit flags and 
//             header information fields added to provide info relevant to the new "R/P Distro" feature.
// 18mar2006-- Updated to synch with version# change in CXFILEFMT.H for Maestro v1.5.0.  No format changes -- version 
//             change marks change in TARGET_HOPEN trial code group to support velocity stabilization over a contiguous 
//             span of trial segments instead of just one.
//===================================================================================================================== 

#if !defined(CXFILEFMT_MEX_H__INCLUDED_)
#define CXFILEFMT_MEX_H__INCLUDED_

#include "cxtrialcodes_mex.h"                         // definition of TRIALCODE structure
#include "cxobj_ifc_mex.h"                            // defns of CXTARGET and STIMULUS structures


// format of the header record that occupies the first kilobyte of trial- and continuous-mode data files
//
// NOTES:
// (0) Continuous-mode data files did not possess this header record until version 1 was introduced.
// (1) T = applies to trial mode only, C = cont mode only, TC = both modes; V = version number.
// (2) If a field is NOT used in one of the modes, it is set to ZERO by default, unless otherwise specified.
// (3) The target translation/rotation factors and the reward pulse lengths saved in the header record represent the 
// values that were in effect when the trial codes were generated.
// (4) In continuous mode, all RELEVANT fields reflect the system state AT THE TIME RECORDING STARTED, except the 
// counters 'nBytesCompressed', 'nScansSaved', and 'nScanIntvUS'.  These latter fields are set when recording ends.
// (5) PORTING issue:  We rely on these data type sizes:  char = 1 byte, short = 2 bytes, int = DWORD = 4 bytes.
//

#define CXH_NAME_SZ              40                   // max length of names in header, including terminating null char 
#define CXH_MAXAI                16                   // max # of AI channels that can be recorded
#define CXH_EXTRAS               394                  // # of unused shorts in header record
#define CXH_CURRENTVERSION       7                    // the current version # (as of Maestro version 1.5.0)

                                                      // currently defined header flag bits:
#define CXHF_ISCONTINUOUS        ((DWORD) (1<<0))     //    if set, file was collected in cont mode; else, trial mode 
#define CXHF_SAVEDSPIKES         ((DWORD) (1<<1))     //    if set, 25KHz spike trace saved during this trial
#define CXHF_REWARDEARNED        ((DWORD) (1<<2))     //    [T] if set, subject did not break fixation during trial
#define CXHF_REWARDGIVEN         ((DWORD) (1<<3))     //    [T] if set, the earned reward was actually delivered 
                                                      //       (reward may be randomly withheld).
#define CXHF_FIX1SELECTED        ((DWORD) (1<<4))     //    [T] if set, tgt#1 was selected in a trial's "selByFix*" op
                                                      //    or tgt#1 was INITIALLY selected in a "switchFix" op.
#define CXHF_FIX2SELECTED        ((DWORD) (1<<5))     //    [T] if set, tgt#2 was selected in a trial's "selByFix*" op
                                                      //    or tgt#2 was INITIALLY selected in a "switchFix" op.
#define CXHF_ENDSELECT           ((DWORD) (1<<6))     //    [T] if set, selection forced at end of "selByFix" segment 
#define CXHF_HASTAGSECTS         ((DWORD) (1<<7))     //    [T] if set, trial has one or more tagged sections.  Data 
                                                      //    file should include a CX_TAGSECTRECORD.
#define CXHF_ISRPDISTRO          ((DWORD) (1<<8))     //    [T, V>=6] if set, trial used the "R/P Distro" op.
#define CXHF_GOTRPDRESP          ((DWORD) (1<<9))     //    [T, V>=6] if set, then trial got past "R/P Distro" segment

typedef struct tagCxFileHdr
{
   char name[CXH_NAME_SZ];          // [T] name of trial (may be truncated). set to "**continuous_mode_run**" in all 
                                    // continuous-mode data files. 
   short trhdir;                    // [V<2, T] trial's H direction (RIGHT==1 or LEFT==2); [V>=2] OBSOLETE!
   short trvdir;                    // [V<2, T] trial's V direction (UP==4 or DOWN==8); [V>=2] OBSOLETE!

   short nchar;                     // [V<1, T] same as 'nBytesCompressed'; [V>=1] OBSOLETE!
   short npdig;                     // [V<1, T] same as 'nScansSaved'; [V>=1] OBSOLETE!

   short nchans;                    // [TC] the # of distinct AI channels recorded 
   short chlist[CXH_MAXAI];         // [TC] the channel scan list -- lists the channel #s (0-15) that were recorded, 
                                    // in the order that they were sampled per scan.  this info is critical in order to 
                                    // properly decompress the analog channel data!

                                    // [T] video display (XY scope or framebuffer) info:
   short d_rows;                    //    height of display in pixels
   short d_cols;                    //    width of display in pixels
   short d_crow;                    //    IGNORE
   short d_ccol;                    //    IGNORE
   short d_dist;                    //    distance from eye to screen, in mm
   short d_dwidth;                  //    width of display, in mm
   short d_dheight;                 //    height of display, in mm
   int d_framerate;                 //    frame rate in units of 0.001Hz

                                    // 16oct2001-- added these fields:
   int iPosScale;                   // [T] 1000 * "global" target position scale factor (set to 1.0 for cont mode)
   int iPosTheta;                   // [T] 1000 * "global" target position rotation angle (deg) 
   int iVelScale;                   // [T] 1000 * "global" target velocity scale factor (set to 1.0 for cont mode)
   int iVelTheta;                   // [T] 1000 * "global" target velocity rotation angle (deg) 
   int iRewLen1;                    // [TC] reward pulse length #1 (msec)
   int iRewLen2;                    // [T] reward pulse length #2 (msec)

                                    // 29jan2002-- new fields added, changes made to incorporate header into cont-mode 
                                    // data files.  versioning introduced.  all fields above were present prior to 
                                    // versioning (version == 0).  the fields in this section were added in version 1. 
   int dayRecorded;                 // [TC] the day (1-31), month(1-12), and year that data was recorded.
   int monthRecorded;               // 
   int yearRecorded;                //
   int version;                     // [TC] file version -- so analysis programs can more easily parse future headers. 
   DWORD flags;                     // [TC] see CXHF_** flag bits 
   int nScanIntvUS;                 // [TC] channel scan intv in microsecs; currently 1000 (1ms) for trial mode and 
                                    // 2000 (2ms) for cont mode, but this allows us to support other intv's later
   int nBytesCompressed;            // [TC] total # of bytes of compressed analog data collected. 
   int nScansSaved;                 // [TC] total # of channel scans saved.
   char spikesFName[CXH_NAME_SZ];   // [V<2, TC] name of spike waveform file saved when this data recorded;
                                    // [V>=2, TC] OBSOLETE! spike trace data saved in this file

                                    // 27mar2003-- these fields were added with the first release of Maestro (V=2). 
   int nSpikeBytesCompressed;       // [V>=2, TC] total # of bytes of compressed 25KHz spike trace data
   int nSpikeSampIntvUS;            // [V>=2, TC] sample intv for the spike trace channel, in microsecs 

                                    // 19nov2003-- Added one field (V=3).
   DWORD dwXYSeed;                  // [V>=3, T] number used to seed random# generation on XY scope controller

                                    // 25jan2006-- (V=6) Added fields relevant only to trials using R/P Distro feature.
   int iRPDStart;                   // [V>=6, T] start of R/P Distro designated seg, in ms rel to start of trial.
   int iRPDDur;                     // [V>=6, T] duration of R/P Distro designated seg, in ms.
   int iRPDResponse;                // [V>=6, T] avg eye vel magnitude during R/P Distro segment, in 0.001 deg/sec
   int iRPDWindows[4];              // [V>=6, T] reward windows for the R/P Distro trial: [a b c d]. [a b], a<=b, is the 
                                    // the first window; if a==b, the window is not defined.  Similarly for the second 
                                    // window, [c d]. Units = 0.001 deg/sec.
                                    // [V>=7, T] only one reward window defined, so now c==d==0 always.

   short xtras[CXH_EXTRAS];         // UNUSED -- always set to zero
} CXFILEHDR, *PCXFILEHDR;


// format of data/information records in Maestro/Cntrlx data files
//
//       RECORD TAG (bytes0..7)        RECORD CONTENTS
//       ----------------------        ---------------
//       0  0  0  0  0  0  0  0        Compressed slow-sampled AI data. 
//       1  0  0  0  0  0  0  0        Interevent intervals for events on timer device's DI<0> -- usually spikes!
//       2  0  0  0  0  0  0  0        Interevent intervals events on timer device's DI<1>.
//       3  0  0  0  0  0  0  0        Event masks & times for all other events, DI<15..2>.
//       4  0  0  0  0  0  0  0        Trial codes.
//     [64  0  X  X  X  X  X  X        Target defn/stimulus run info for VERSION <=1.  OBSOLETE.]
//      65  0  0  0  0  0  0  0        Definitions of participating targets.
//      66  0  0  0  0  0  0  0        Definition of active stimulus run (ContMode data files only).
//      67  0  0  0  0  0  0  0        Compressed spike trace data.
//      68  0  0  0  0  0  0  0        Trial tagged section info.
//
//       5  0  0  0  0  0  0  0        Editing action record appended to data file by XWORK
//      N+5 0  0  0  0  0  0  0        For N=3-15, these XWORK-created records represent interevent intervals for 
//                                     "spikes" sorted from the high-resolution spike waveform associated with a 
//                                     recording IAW algorithms defined by the XWORK user.  Format is identical to 
//                                     that of spike event records (tag=1).
//
//    1) Compressed AI data (record tag 0).  The compressed, slow-sampled AI data are stored chronologically in one or 
//    more records.  Since no compressed byte will have the value 0, we mark the end of the compressed data stream by 
//    filling the empty portion of the last record with zeros.  Analysis programs must have knowledge of the 
//    compression algorithm in order to decode these records. 
//
//    2) Event records (record tags 1-3).  Maestro/Cntrlx records digital events (occurrence of rising edge) on any of 
//    16 inputs DI<15..0> on the event timer device.  We store separate event records for events on DI<0> (usually 
//    reserved for recording spikes), events on DI<1> (usually reserved for a second spike channel or a marker pulse), 
//    and events on any of DI<15..2>.  In the first two cases, we save 32-bit interevent intervals (where one tick = 
//    10microsec), thusly:
//          CXFILEREC.u.iData[0] = interval between event# 0 and 1,
//          CXFILEREC.u.iData[1] = interval between event# 1 and 2, 
//          ....
//          CXFILEREC.u.iData[N] = interval between event# N and N+1, ....
//    where "event# 0" corresponds to the time at which recording began.  The unfilled portion of the last record is 
//    filled with the integer 0x7FFFFFFF, which serves as an "endOfData" marker.  Events on DI<15..2> are all stored in 
//    record tag 3.  Here we must save both the event mask and the absolute 32-bit event time (again, one tick = 10us), 
//    as follows:
//          CXFILEREC.u.iData[0] = event mask for event#0 on any of DI<15..2> (multiple simultaneous events possible!) 
//          CXFILEREC.u.iData[1] = time of occurrence of event#0
//          ....
//          CXFILEREC.u.iData[N] = event mask for event#(N/2) on any of DI<15..2>
//          CXFILEREC.u.iData[N+1] = time of occurrence of event #(N/2), ...
//    In this case, the "endOfData" marker is the sequence of two integers {0, 0x7FFFFFFF}, repeated until we reach the 
//    end of the record.
//
//    3) Trial codes (record tag 4).  We store the trial code array CODES[] that defines a trial in chronological order 
//    in one or more records as needed.  So: 
//          CXFILEREC.u.tc[0] = TC[0],
//          CXFILEREC.u.tc[1] = TC[1], 
//          ....
//    If the last trial code record is only partially full, we set the remaining bytes to zero.  Note that the last 
//    trial code is always ENDTRIAL, so there is no need to define a "endOfTrialCodes" byte!  New trial codes have been 
//    introduced over the development history of Maestro and its UNIX-based predecessor Cntrlx.  See CXTRIALCODES.H and 
//    review Cntrlx's revision history for details...  Of particular note is the TARGET_PERTURB trial code, since 
//    support for perturbations was entirely overhauled in Maestro.
//
//    3a) Trial tagged sections (record tag 68). [VERSION >= 4].  A TrialMode data file will have one of these records 
//    if any tagged sections are defined on the trial that was executed.  The record contains a set of TRIALSECT 
//    structures, one for each distinct section in the trial.  All unused bytes in the record are set to zero, so the 
//    first TRIALSECT structure with an empty tag name marks the end of the section list!
//
//    4) Target definitions (record tag 65). [VERSION >= 2]  In a TrialMode data file, these records will contain the 
//    definitions of all targets participating in the trial.  Each target is "persisted" as a CXFILETGT data structure, 
//    which is defined here.  The target definition itself is encapsulated by the CXTARGET structure, which is fully 
//    described in the Maestro object interface file CXOBJ_IFC.H; additional info in the CXFILETGT struct applies only 
//    to ContMode data files.  More than one target definition can appear in each target defn record, and the target 
//    definitions are listed in the same order that they appear in the trial definition.  This ordering is SIGNIFICANT, 
//    since each target participating in a trial is identified in the TRIALCODEs by the target's ordinal position in 
//    the trial target list!!!
//       In a ContMode data file, this record type is used to report the definitions of any targets in the active 
//    target list, followed by any targets participating in an XYseq.  Again, we use the CXFILETGT data structure to 
//    describe each target, and the targets are stored in the record in the same order they appear in the active list 
//    and XYseq target list.  Unlike for TrialMode targets, we also provide target position and some state information 
//    for ContMode targets.  For XYseq targets, the target position gives the initial and final position of each tgt 
//    during the stimulus run, since the XYseq stimulus does not permit target window motion (only pattern motion).
// 
//       If the last target defn record is only partially full, we set the remaining bytes to zero.  The remaining 
//    "dummy" target records will contain invalid data (in particular, 0 is an invalid target type).
//
//    5) Stimulus run definition (record tag 66). [VERSION >= 2]  A ContMode "stimulus run" is defined by some general 
//    header parameters, a series of STIMCHAN channels (not all of which may be turned on), and a set of XY scope tgts 
//    participating in the run's XYseq stimulus channel (if there is one).  The XYseq target set is reported in the 
//    target definition record(s), as described above.  The stimulus run header, along with the defns of those stimulus 
//    channels which were turned ON, are persisted using this record type.  The header and each stimulus channel defn 
//    are stored as one or more CXFILESTIM_U structures within the 1024-byte record.  The first CXFILESTIM_U object in  
//    the record is always the header info, while the remaining objects in the first (and, if necessary, a second) 
//    record are the stimulus channel definitions.
//
//       !!! CAVEAT:  Target and stimulus run information saved here merely represent Maestro's state AT THE TIME 
//       !!! RECORDING BEGAN.  Active target position and state can be interactively changed by the user as recording 
//       !!! progresses.  Also, we save the current stimulus run information even if it is not actually running 
//       !!! because, in typical usage, Maestro will "preload" the stimulus run, then start recording, then start the 
//       !!! previously loaded run!  We include a flag that indicates whether or not the currently efined run is 
//       !!! actually in progress.
//
//    6) Compressed spike trace data (record tag 67). [VERSION >= 2] Maestro dedicates a single channel to record the 
//    raw electrode signal from which "spikes" (or "units", aka action potentials) are extracted.  The channel is 
//    sampled at 25KHz in order to adequately capture each action potential.  "Fast" channel data is recorded at the 
//    same time as the "slow-sampled" AI channels (record 0) by a single AI device, and is compressed in the same way.
//    
//
#define CX_AIRECORD              ((BYTE) 0)           // record tag for compressed, slow-sampled AI data 
#define CX_EVENT0RECORD          ((BYTE) 1)           // record tag for interevent intervals on DI<0>
#define CX_EVENT1RECORD          ((BYTE) 2)           // record tag for interevent intervals on DI<1>
#define CX_OTHEREVENTRECORD      ((BYTE) 3)           // record tag event info on all other events, DI<15..2>
#define CX_TRIALCODERECORD       ((BYTE) 4)           // record tag for trial codes
#define CX_XWORKACTIONREC        ((BYTE) 5)           // record tag reserved for XWORK "action" record
#define CX_SPIKESORTREC_FIRST    ((BYTE) 8)           // range of record tags for XWORK spike sorting channels 3-15
#define CX_SPIKESORTREC_LAST     ((BYTE) 20)          //
#define CX_V1TGTRECORD           ((BYTE)64)           // record tag for tgt defn/stim run record for file vers <= 1
#define CX_TGTRECORD             ((BYTE)65)           // record tag for target definitions
#define CX_STIMRUNRECORD         ((BYTE)66)           // record tag for stimulus run definition
#define CX_SPIKEWAVERECORD       ((BYTE)67)           // record tag for compressed, 25KHz-sampled spike trace 
#define CX_TAGSECTRECORD         ((BYTE)68)           // record tag for trial tagged section record


#define EOD_EVENTRECORD          0x7fffffff           // "end of data" marker for digital event & spike-sorting records 

#define CX_RECORDBYTES           1016                 // amount of data storable in data rec (not including idTag) 
#define CX_RECORDSHORTS          (CX_RECORDBYTES/sizeof(SHORT))
#define CX_RECORDINTS            (CX_RECORDBYTES/sizeof(INT))
#define CX_RECORDCODES           (CX_RECORDBYTES/sizeof(TRIALCODE))
#define CX_RECORDSECTS           (CX_RECORDBYTES/sizeof(TRIALSECT))


typedef struct tagCxFileTgtRec                        // persistent storage format for Maestro target information 
{                                                     // in CX_TGTRECORD:
   CXTARGET def;                                      //    the target definition

   DWORD dwState;                                     //    [ContMode only] tgt state (CXFTF_* flags)
   float fPosX, fPosY;                                //    [ContMode only] tgt pos in deg 
} CXFILETGT, *PCXFILETGT;

#define CX_RECORDTARGETS         (CX_RECORDBYTES/sizeof(CXFILETGT))

#define CXFTF_ISACVTGT           ((DWORD) (1<<0))     // flag set for tgts in active list; cleared for XYseq tgts 
#define CXFTF_TGTON              ((DWORD) (1<<1))     // active tgt was ON at start of recording
#define CXFTF_TGTISFIX1          ((DWORD) (1<<2))     // active tgt was designated "fixTgt1" at start of recording 
#define CXFTF_TGTISFIX2          ((DWORD) (1<<3))     // active tgt was designated "fixTgt2" at start of recording


typedef struct tagCxFileStimRunHdr                    // persistent storage format for header information describing 
{                                                     // a ContMode stimulus run:
   BOOL     bRunning;                                 //    was stimulus run in progress when recording started?
   int      iDutyPeriod;                              //    duty period in milliseconds
   int      iDutyPulse;                               //    DOUT ch# for duty cycle marker pulse (0 = no marker) 
   int      nAutoStop;                                //    auto-stop after this many cycles elapsed (0 = disabled) 
   float    fHOffset;                                 //    horizontal position offset in deg subtended at eye
   float    fVOffset;                                 //    vertical position offset in deg subtended at eye
   int      nStimuli;                                 //    # of stimulus channels THAT ARE TURNED ON for this run 
   int      nXYTgts;                                  //    #XY scope targets participating in an XYseq stimulus 
} CXFILESTIMRUNHDR, *PCXFILESTIMRUNHDR;

typedef union tagCxFileStimRun                        // persistent storage format for Maestro stimulus run defn in 
{                                                     // CX_STIMRUNRECORD:
   CXFILESTIMRUNHDR  hdr;                             //    first "chunk" in the record holds the run's hdr info
   STIMULUS          stim;                            //    all remaining "chunks" are defns of "on" stim channels 
} CXFILESTIM_U, *PCXFILESTIM_U;

#define CX_RECORDSTIMS           (CX_RECORDBYTES/sizeof(CXFILESTIM_U))


typedef struct tagCxFileRec                           // generic format for Maestro file data/info records 
{ 
   BYTE  idTag[8];                                    // byte 0 holds the record tag CX_***RECORD. other bytes = 0. 
   union                                              // the data, in various forms...
   {
      BYTE byteData[CX_RECORDBYTES];
      SHORT shData[CX_RECORDSHORTS];
      INT iData[CX_RECORDINTS];
      TRIALCODE tc[CX_RECORDCODES];                   //    for CX_TRIALCODERECORD
      TRIALSECT sects[CX_RECORDSECTS];                   //    for CX_TAGSECTRECORD
      CXFILETGT tgts[CX_RECORDTARGETS];               //    for CX_TGTRECORD
      CXFILESTIM_U stims[CX_RECORDSTIMS];             //    for CX_STIMRUNRECORD
   } u;
} CXFILEREC, *PCXFILEREC;

#endif   // !defined(CXFILEFMT_MEX_H__INCLUDED_)



