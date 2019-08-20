//===================================================================================================================== 
//
// readcxdata.h : Constant and type definitions for MATLAB MEX function readcxdata(). 
//
// ****** FOR DESCRIPTION, REVISION HISTORY, ETC, SEE IMPLEMENTATION FILE ******
//
//===================================================================================================================== 

#if !defined(READCXDATA_H__INCLUDED_)
#define READCXDATA_H__INCLUDED_


#include "wintypes.h"                                    // some typical Windows typedefs that we need 

#include "cxfilefmt_mex.h"                               // Maestro/Cntrlx data file fmt (file modified for MEX build)
#include "cxobj_ifc_mex.h"                               // Maestro/Cntrlx object interface (file mod. for MEX build)
#include "cxtrialcodes_mex.h"                            // Maestro/Cntrlx trial codes (file modified for MEX build)


// OBSOLETE trial codes:  CXTRIALCODES.H does not list some OBSOLETE trial codes, which are defined below in case we 
// find them in older data files.  For each code set we indicate N=# of TRIALCODE blocks comprising the set.  Most of 
// these codes are so old that they no longer appear in maintained source code for Cntrlx, so that I have no idea 
// what N is (N=???).  If any of these codes are encountered, we abort any attempt to read the trial codes.  Else, 
// use the value of N to skip over the TRIALCODE blocks pertaining to the obsolete code set.
//
#define     ENDFRAME             9                       // N=???
#define     TARGETOFF            15                      // N=???
#define     TARGET_ACTIVATE      17                      // N=???
#define     TARGET_VOPEN         22                      // N=???
#define     PAN_POS              23                      // N=???
#define     PAN_VEL              24                      // N=???
#define     SCROLL_POS           25                      // N=???
#define     SCROLL_VEL           26                      // N=???
#define     VRORIGIN             31                      // N=3 
#define     TARGET_ZVEL          32                      // N=2
#define     TARGET_ZPOSREL       33                      // N=2
#define     TARGET_ZPOSABS       34                      // N=2
#define     TARGET_ZACC          35                      // N=2
#define     VRCOORDS             37                      // N=???
#define     VSYNC_PULSE          46                      // N=???

// !!!IMPORTANT!!!  
// The usage of the TARGET_PERTURB trial code set was revamped entirely in Maestro.  The # of TRIALCODEs in this set is 
// unchanged compared to Cntrlx, but the meaning of the codes is very different.  Programs that analyze the trial codes 
// must check the data file version # to properly parse this code set.  For file versions >= 2, go by the description 
// in CXTRIALCODES.H.  For file versions < 2, use this description:
//
// # define TARGET_PERTURB   20  // apply sinusoidal perturbation velocity waveform to target -- TURNTABLE, FIBER1 & 
//                               // XYSCOPE targets only (N=5)
//                               // code1 = target#; time1 = target type (not used)
//                               // code2 = horiz perturbation amp; time2 = vert perturbation amp
//                               // code3 = period of sine wave (ms); time3 = phase delay (deg)
//                               // code4 = #complete cycles in waveform; time4 = DC component
//


#define MAXPATHNAMESZ            1024                 // file pathname size -- this should be more than enough!

#define ACTION_SACCUT            100                  // XWORK action types
#define ACTION_CUTIT             101 
#define ACTION_NCHANS            103 
#define ACTION_LEVEL1            104 
#define ACTION_LEVEL2            105 
#define ACTION_MARK              106 
#define ACTION_SETMARK1          107 
#define ACTION_SETMARK2          108 
#define ACTION_RMUNIT            109 
#define ACTION_ADDUNIT           110 
#define ACTION_RMALL             111 
#define ACTION_EDITEVENT         112 

#define FIRSTSPIKESORTCH         3                    // the range of XWORK "sorted spike train" channel #s
#define LASTSPIKESORTCH          15
#define MAXSPIKESORTCH           13                   // the max # of different "sorted spike train" channels

#define HARDTARGS                16                   // in Cntrlx data files with version < 2 (pre-Maestro), targets 
#define TURNTABLE                0                    // were identified by an ID that contained some indication of 
#define REDLED1                  1                    // target type.  Targets w/ IDs listed here are the so-called 
#define FIBER1                   2                    // "hard" targets.  The first 5 are used extensively, the rest 
#define FIBER2                   3                    // have not been used since 1998.  XY scope and FB video tgts 
#define REDLED2                  4                    // have target IDs >= HARDTARGS....  In Maestro data files  
#define RENEAR                   5                    // (vers >= 2), these IDs are no longer used.  In trial codes, 
#define LENEAR                   6                    // targets are identified by their ordinal pos in the trial 
#define REMIDDLE                 7                    // tgt list instead of this tgt ID.  Target definitions are 
#define LEMIDDLE                 8                    // stored in CX_TGTRECORDs in the data file; the defns are 
#define REFAR                    9                    // stored in the same order in which the targets appear in the 
#define LEFAR                    10                   // trial target list.
#define VRE1                     13 
#define VRE2                     14 
#define VIDEO                    15 

#define HGPOS                    0                    // index of AI channel dedicated to horizontal gaze pos
#define VEPOS                    1                    // index of AI channel dedicated to vertical eye pos
#define HEVEL                    2                    // index of AI channel dedicated to horizontal eye velocity
#define VEVEL                    3                    // index of AI channel dedicated to vertical eye velocity
#define POSAIRAW_TODEG           0.025                // multiply AI 12bit DAC sample by this factor to get degrees
#define VELAIRAW_TODEGPERSEC     0.0918892            // multiply AI 12bit DAC sample by this factor to get deg/sec


//===================================================================================================================== 
// Contents of a Maestro/Cntrlx data file 
//
// This "all-in-one" data structure encapsulates the data file contents.  Once the MEX function readCxData() has 
// finished reading in and appropriately parsing the data file into this structure, we translate the data stored here 
// into the MATLAB compatible output structure that is returned by the function.
//
//===================================================================================================================== 

typedef struct tagCxDataFile
{
   int nRecords;                                // # of records in file (including header)
   CXFILEHDR fileHdr;                           // the data file's header record.  see CXFILEFMT.H for complete desc,
                                                // including complete version history. 

      // !!! IMPORTANT !!! ContMode data files recorded prior to version 1 lacked any header whatsoever.  We create 
      // a virtual header in this case.  User MUST provide information on the data channels recorded in order to parse 
      // the compressed AI data stored in CX_AIRECORDs!!!

   int nAIBytes;                                // buffer for compressed AI data extracted from CX_AIRECORDs.  This is 
   int nAIBufSz;                                // the raw data sampled from selected AI channels at 1KHz in TrialMode 
   char* pcAIData;                              // and 500Hz in ContMode. 

   int nFastBytes;                              // buffer for compressed AI data from dedicated "fast" channel that 
   int nFastBufSz;                              // records spike waveform at 25KHz in Trial or Cont modes.  Culled from 
   char* pcFastData;                            // CX_SPIKEWAVERECORDs.  [Applies only to data files w/ version>=2.] 

   int nSpikes;                                 // occurrence times (ms) of events on timer DI<0>, reserved for 
   int nSpikesBufSz;                            // recording spike arrival times.  Culled from CX_EVENT0RECORDs.
   double* pdSpikes; 

   int nEvents;                                 // occurrence times (ms) of events on timer DI<1>, which may record 
   int nEventsBufSz;                            // a 2nd spike train or marker pulses.  Culled from CX_EVENT1RECORDs. 
   double* pdEvents; 

   int nOthers;                                 // occurrence times of events on timer DI<2..15>, in (pulse#, T)-pairs, 
   int nOthersBufSz;                            // where pulse# = [2..15] and T = milliseconds since recording started. 
   double* pdOthers;                            // Culled from CX_OTHEREVENTRECORDs.

   int nSortedSpikes[MAXSPIKESORTCH];           // spike counts in each "sorted spike train" channel found in data file 
   int nSortedBufSz[MAXSPIKESORTCH];            // buffer sizes allocated for each channel found
   double* pdSortedSpikes[MAXSPIKESORTCH];      // the allocated buffers for each channel found

   int nEdits;                                  // buffer that holds all XWORK actions culled from ACTIONBUFF records.
   int nEditsBufSz;                             // since an individual "action object" may be stored across two 
   int* piEdits;                                // consecutive records, we must read in all such records before 
                                                // processing them.

   int nTargets;                                // #target definitions or IDs
   int nTgtsBufSz;                              // size of target defn buffers
   CXFILETGT* pTargets;                         // the target definitions [data file version >= 2]

   int nTrialTgts;                              // old-style target IDs of targets participating in a CNTRLX trial
   int oldTgtIDs[MAX_TRIALTARGS]; 

                                                // information extracted ONLY from TrialMode data files: 
   int nCodes;                                  //    buffer holding the trial codes that define a CNTRLX trial.  we 
   int nCodesBufSz;                             //    read in all trial codes from any CX_TRIALCODERECORDs in the file 
   TRIALCODE* pCodes;                           //    before attempting to process the codes to calc tgt trajectories. 
   int nSections;                               //    the number of "tagged sections" defined on trial [file ver >= 4].
   TRIALSECT sections[MAX_SEGMENTS];            //    tagged section records culled from data file [file ver >= 4].

                                                // this trial info is prepared by processTrialCodes():
   int nSegments;                               //    number of segments in trial
   int segStart[MAX_SEGMENTS];                  //    start time for each segment; units = trial ticks.
   int tRecordStarted;                          //    trial time at which recording started, in trial ticks.
   int tTrialLen;                               //    total trial length in ticks (NOT just recorded time!)
   BOOL bSkipOccurred;                          //    if TRUE, then trial included a "skip on saccade" op -- in which 
                                                //    case the trial times here may be incorrect!
   
   int nStims;                                  // relevant stimulus run defn found in data file.  only in ContMode 
   int nStimsBufSz;                             // files with version >= 2.  first CXFILESTIM_U obj in buffer contains 
   CXFILESTIM_U* pStimBuf;                      // header params for run, remaining ones are stim channel defns.

} CXFILEDATA, *PCXFILEDATA;


//
// constants defining the fields in the output structure returned by MEX function readcxdata()
//

const char* outputFields[] =  // the MATLAB-compatible output structure returned by MEX function readcxdata():
{
   "trialname",               //    name of trial as it appears in data file; ignore for ContMode data files
   "key",                     //    contents of data file header record (see below)
   "data",                    //    sampled data from analog input channels (1KHz in TrialMode, 500Hz in ContMode)
   "spikes",                  //    event arrival times on DI<0> relative to recording start time, in milliseconds
   "events",                  //    event arrival times on DI<1>, in milliseconds
   "other",                   //    Mx2 matrix: (pulse#, arrival time in millisecs) for pulses recorded on DI<2..15>
   "mark1",                   //    list of ACTION_SETMARK1 actions taken on data using XWORK analysis program
   "mark2",                   //    list of ACTION_SETMARK2 actions taken on data using XWORK
   "cut",                     //    all saccade cuts performed on data using XWORK
   "marks",                   //    list of ACTION_MARK actions taken on data using XWORK
   "marked",                  //    nonzero if the data was modified by at least one ACTION_MARK action
   "targets",                 //    trial target trajectories -- TrialMode only (see below)

                              // available for Maestro data files with version >= 2...
   "tgtdefns",                //    defining parameters of relevant targets (see below)
   "stimulusrun",             //    ContMode stimulus run defined when recording started (see below)
   "spikewave",               //    sampled data from AI<15>, dedicated to 25KHz recording of spike waveform

   "sortedSpikes",            //    XWORK-created "sorted spike trains", a 1x13 cell array containing sorted spike 
                              //    trains culled from the high-resolution spike waveform that may be recorded along 
                              //    with the other analog and digital data.  cell [1:13] contains the spike train 
                              //    on XWORK spike-sorting "channel" [3:15].  if no spike-sorting was performed on 
                              //    a given channel, the corresponding cell will hold an empty matrix; otherwise it 
                              //    will hold a double array of the spike arrival times, formatted in the same way 
                              //    as the "spikes" field described above.

                              // available for Maestro data files with version >= 4...
   "tagSections"              //    tagged sections defined on a Maestro trial (see below).
   
};
const int NUMOUTFIELDS = 17;  // the # of fields in the output structure

const char* headerFields[] =  // defines MATLAB structure mirroring the contents of the data file header record (the 
{                             // field names are the same as corresponding members of the CXFILEHDR structure -- see 
                              // include file CXFILEFMT.H for a detailed description).
   "trhdir", "trvdir", 
   "nchar", "npdig",
   "nchans", "chlist",
   "d_rows", "d_cols", "d_crow", "d_ccol", "d_dist", "d_dwidth", "d_dheight", "d_framerate",
   "iPosScale", "iPosTheta", "iVelScale", "iVelTheta",
   "iRewLen1", "iRewLen2",
   "dayRecorded", "monthRecorded", "yearRecorded", 
   "version", "flags", 
   "nScanIntvUS", "nBytesCompressed", "nScansSaved",
   "spikesFName",
   "nSpikeBytesCompressed", "nSpikeSampIntvUS",
   "dwXYSeed",
   "iRPDStart", "iRPDDur", "iRPDResponse", "iRPDWindows"
};
const int NUMHDRFIELDS = 36;  // the # of fields in the header

const char *trajFields[] =    // trajectory data for targets participating in a trial (TrialMode files only):
{
   "hpos",                    //    target pos & vel trajectories, as calculated from trial codes.  pos in deg, vel in 
   "vpos",                    //    deg/sec.  each field is an MxN matrix, where the #tgts in trial = M, and the 
   "hvel",                    //    recorded trial length = N "ticks" (1ms).  row 0 is the trajectory for the first 
   "vvel",                    //    tgt in the trial tgt list, row 1 for the second tgt, and so...

   "patvelH",                 //    analogously for target pattern velocity trajectories. these really only apply to 
   "patvelV",                 //    certain extended video targets on the XY scope and framebuffer platforms.

   "targnums",                //    old-style IDs of targets that participated in the trial (data file version < 2).
                              //    listed in same order that trajectories are stored above.  Prepared for all data 
                              //    file versions, to avoid breaking existing programs that were based on an earlier 
                              //    version of this MEX function.

   "nTrialLen",               //    complete trial length in # of trial ticks
   "tRecordOn"                //    the trial time at which recording began (may be > 0)
};
const int NUMTRAJFIELDS = 9;  // the # of fields in the target trajectories' structure

const char *tgtFields[] =     // target definitions extracted from Maestro data files (version >= 2)
{
   "category",                //    CX_FIBER*, CX_REDLED*, CX_CHAIR, CX_XYTARG, CX_FBTARG, etc.
   "name",                    //    the target's human-readable name in Maestro
   "params",                  //    defining parameter structure -- only for CX_XYTARG and CX_FBTARG types; format
                              //    echoes that of the XYPARMS and FBPARMS structs defined in CXOBJ_IFC.H. 
   "dwState",                 //    [ContMode only] target state in ContMode -- relevant flags defined in CXFILEFMT.H 
   "hPos",                    //    [ContMode only] horizontal target pos when recording started.
   "vPos"                     //    [ContMode only] vertical target pos when recording started. 
};
const int NUMTGTFIELDS = 6;

const char *xyTgtParams[] =   // defining parameters for a Maestro XY scope target ("category" = CX_XYTARG).  This is 
{                             // essentially the XYPARMS struct as defined in CXOBJ_IFC.H...
   "type",                    //    target type
   "ndots",                   //    # of dots in target

   "iDotLfUnits",             //    [FCDOTLIFE only] dot life units:  DOTLFINMS or DOTLFINDEG
   "fDotLife",                //    [FCDOTLIFE only] maximum lifetime of each target dot

   "fRectW",                  //    tgt window dimensions in deg subtended at eye; meaning varies w/ tgt type...
   "fRectH",
   "fInnerW",
   "fInnerH"
};
const int NUMXYTGTPARMS = 8;

const char *fbTgtParams[] =   // defining parameters for a Maestro framebuf video target ("category" = CX_FBTARG). 
{                             // This is essentially the FBPARMS struct as defined in CXOBJ_IFC.H...
   "type",                    //    target type
   "shape",                   //    shape of target aperture
   "csMean",                  //    RGB color specification:  mean and contrast for R(=0), G(=1), and B(=2) axes 
   "csCon",                   //   mean is 0-1000 (uniform scale); contrast is a percentage (0-100%)
   "fRectW",                  // dimensions of bounding rect in deg subtended at eye 
   "fRectH",
   "fSigma",                  // standard deviation of circular Gaussian window for STATICGABOR target 
   "fGratSF",                 // grating spatial frequency in cycles/deg subtended at eye (1x2 matrix, for 2 gratings) 
   "fGratAxis",               // grating's drift axis in deg CCW (1x2 matrix)
   "fGratPhase"               // grating's initial spatial phase in deg (1x2 amtrix)
};
const int NUMFBTGTPARMS = 10;

const char *runFields[] =     // stimulus run definition extracted from Maestro data files
{
   "bRunning",                //    was stimulus run in progress when recording started?
   "iDutyPeriod",             //    duty period in milliseconds
   "iDutyPulse",              //    DOUT ch# for duty cycle marker pulse (0 = no marker) 
   "nAutoStop",               //    auto-stop after this many cycles elapsed (0 = disabled) 
   "fHOffset",                //    horizontal position offset in deg subtended at eye
   "fVOffset",                //    vertical position offset in deg subtended at eye
   "nXYTgts",                 //    #XY scope targets participating in an XYseq stimulus 
   "stimuli"                  //    definitions of the active stimulus channels participating in the run (see below) 
};
const int NUMRUNFIELDS = 8;

const char *stimFields[] =    // defn of a single stimulus channel within a stimulus run (data file vers >= 2):
{
   "bOn",                     //    should always be TRUE, since only active channels are saved in data file
   "iMarker",                 //    OFF (0), or DOUT ch# on which marker pulse is delivered at stimulus start 
   "iType",                   //    type of stimulus:  see STIM_IS** constants in CXOBJ_IFC.H
   "iStdMode",                //    motion mode for the "standard" stim types: MODE_ISSINE or _ISPULSE
   "tStart",                  //    start time of stimulus trajectory within the run's duty cycle, in millisecs 
   "params"                   //    structure containing type-specific stimulus channel parameters (see below)
};
const int NUMSTIMFIELDS = 6;

const char *xyseqFields[] =   // parameters specific to the STIM_ISXYSEQ stimulus channel (aka XYSEQSTIM struct):
{
   "iOpMode",                 //    motion mode -- MODE_ISSPARSEDIR, etc.
   "iRefresh",                //    XY scope refresh period, in millisecs
   "nSegs",                   //    # of distinct segments of random motion
   "iSegDur",                 //    duration of each segment, in ms (must be multiple of refresh period)
   "iSeed",                   //    seed for generating random directions or velocities 
   "nChoices",                //    # of different directions (or velocities) randomized
   "fAngle",                  //    offset angle (for direction modes) or direction of motion (for vel modes)
   "fVel",                    //    velocity of motion (for dir modes) or max velocity (for vel modes)
   "fOffsetV"                 //    offset velocity (for vel modes only)
};
const int NUMXYSEQFIELDS = 9;

const char *sgmFields[] =     // parameters specific to the STIM_ISPSGM stimulus channel (aka SGMPARMS struct):
{
   "iOpMode",                 //    motion mode -- one of the SGM_* defined constants
   "bExtTrig",                //    if TRUE, use external trig to initiate pulse seq; else, s/w start.
   "iAmp1", "iAmp2",          //    pulse amplitude.  range [-1280..1270mV], res = 10mV.
   "iPW1", "iPW2",            //    pulse width.  range [150..2500us], res = 10us.
   "iPulseIntv",              //    interpulse interval.  range [1..250ms].
   "iTrainIntv",              //    intertrain interval.  range [10..2500ms], res = 10ms.
   "nPulses",                 //    #pulses per train.  range [1..31].  (SGM_TRAIN mode only)
   "nTrains"                  //    #trains per stimulus.  range [1..250].  (SGM_TRAIN mode only)
};
const int NUMSGMFIELDS = 10;

const char *sineFields[] =    // parameters specific for sinewave stimulus channels (aka SINESTIM struct):
{
   "iPeriod",                 //    # of complete cycles in stimulus (>=1)
   "fAmp",                    //    velocity amplitude, in deg/sec: [-9999 .. 9999].
   "fPhase",                  //    phase in deg: [-180.0 .. 180.0]
   "fDirec"                   //    direction of motion, CCW angle from x-axis [-180.0..180.0] 
};
const int NUMSINEFIELDS = 4;

const char *pulseFields[] =   // parameters specific for trapezoidal pulse stimulus channels (aka PULSESTIM struct):
{
   "bBlank",                  //    if TRUE, active targets are blanked during pulse (for CHAIR stimulus)
   "iPulseDur",               //    duration of pulse in ms (>= 2ms)
   "iRampDur",                //    duration of rising-edge and falling-edge ramps (>= 2ms)
   "fAmp",                    //    velocity amplitude, in deg/sec: [-9999 .. 9999].
   "fDirec"                   //    direction of motion, CCW angle from x-axis [-180.0..180.0] 
};
const int NUMPULSEFIELDS = 5;

const char *tagSectFields[] = // information provided for each tagged section defined on a Maestro trial:
{
   "tag",                     //    the name of the tagged section
   "firstSeg", "lastSeg",     //    the range of trial segments spanned by the tagged section (zero-based indices) 
   "tStart",                  //    the time at which the tagged section began, RELATIVE to when recording started.
                              //    Units = # of trial "ticks".  Will be -1 if unable to determine!
   "tLen"                     //    length of tagged section, in # of trial "ticks".  -1 if unable to determine!
};
const int NUMTAGSECTFIELDS = 5;

#endif   // !defined(READCXDATA_H__INCLUDED_)
