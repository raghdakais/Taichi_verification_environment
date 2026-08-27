//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  N25Q256A11E
//
//  Verilog Behavioral Model
//  Version 1.4
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
// This file and all files delivered herewith are Micron Confidential Information.
// 
// 
// Disclaimer of Warranty:
// -----------------------
// This software code and all associated documentation, comments
// or other information (collectively "Software") is provided 
// "AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
// ("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
// RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
// FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
// SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
// THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
// MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
// RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
// ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
// OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
// EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
// LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
// SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
// OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
// ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
// EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// Because some jurisdictions prohibit the exclusion or limitation
// of liability for consequential or incidental damages, the above
// limitation may not apply to you.
// 
// Copyright 2013 Micron Technology, Inc. All rights reserved.
//

---------------
VERSION HISTORY
---------------
  -VER-
  Version 1.5
        Date    :   10/21/2014
        Note    :   Updated SFDP file.
  Version 1.4
        Date    :   09/19/2014
        Note    :   Updated SFDP file.
  Version 1.3
        Date    :   04/01/2014
        Note    :   Modified RDID MemoryType_ID from 'hBA to 'hBB
  Version 1.2
        Date    :   12/18/2013
        Note    :   Sync up with changes in core BFM.
  Version 1.1
        Date    :   06/04/2013  
        Note    :   Modified EDID in DevParam.h 
  Version 1.0
        Date    :   01/15/2013  
        Note    :   Release 


----------------------------------------------------------
This README provides information on the following topics :

- VERILOG Behavioral Model description
- Version History
- Install / uninstall information
- File list
- Get support
- Bug reports
- Send feedback / requests for features
- Known issues
- Ordering information


-------------------------------------
VERILOG BEHAVIORAL MODEL DESCRIPTION
-------------------------------------

Behavioral modeling is a technic for the description of an hardware architecture at an 
algorithmic level where the designers do not necessarily think in terms of
logic gates or data flow, but in terms of the algorithm and its performance.
Only after the high-level architecture and algorithm are finalized, the designers 
start focusing on building the digital circuit to implement the algorithm.
To obtain this behavioral model we have used VERILOG Language.

---------------------------------
INSTALL / UNINSTALL INFORMATION
---------------------------------

For installing the model you have to process the *.tar.gz delivery package.  

Compatibility: the model has been tested using modelsim v10.0, NCsim, VCS 


---------
File List

code
  code/N25Qxxx.v

include
  include/Decoders.h
  include/DevParam.h
  include/PLRSDetectors.h
  include/StackDecoder.h
  include/TimingData.h
  include/UserData.h

sim
  sim/do.do
  sim/mem_Q256.vmf
  sim/modelsim.ini
  sim/session.inter.vpd.tcl
  sim/sfdp.vmf
  sim/vlog.opt
  sim/wave.do
  sim/waves.shm/
  sim/waves.dsn
  sim/waves.trn

stim
  stim/dummy_prova.v
  stim/erase.v
  stim/lock1.v
  stim/lock2.v
  stim/lock_test_SR.v
  stim/otp.v
  stim/program_top.v
  stim/program.v
  stim/read_altera_debug.v
  stim/read_dtr.v
  stim/Readme.txt
  stim/read.v
  stim/test_address_mode.v
  stim/test_protocol_Ashif.v
  stim/test_protocol.v
  stim/XIP_Numonyx.v

top
  top/ClockGenerator.v
  top/StimGen_interface.h
  top/StimTasks.v
  top/Testbench.v
---------

-------------
GET SUPPORT
-------------

Please e-mail any questions, comments or problems you might have concerning
this VERILOG Behavioral Model to the Micron sales team 
        
If you are having technical difficulties then please include some basic 
information in your e-mail:

        Simulator Version and Operative System you have used; 
        Memory (RAM);
        Free Disk Space on installation drive.



-------------
BUG REPORTS
-------------

If you experience something you think might be a bug in the VERILOG
Behavioral Model, please report it by sending a message to the Micron 
sales team

Describe what you did (if anything), what happened
and what version of the Model you have. Please use the form
below for bug reports:

Error message :
Memory (RAM) :
Free Disk Space on installation drive :
Simulator Version and Operative System you have used :
Stimulus source file :
Waveform Image file (gif or jpeg format) :




---------------------------------------
SEND FEEDBACK / REQUESTS FOR FEATURES
---------------------------------------

Please let us know how to improve the behavioral model,
by sending a message  to Micron sales team

