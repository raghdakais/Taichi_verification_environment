`define X8   //X8 or X16


// Timing parameters based on Speed Grade
`ifdef T9                               
    parameter TCK_MIN          =    938; //% tCK        ps    Minimum Clock Cycle Time
    parameter TJIT_PER         =      50; //% tJIT(per)  ps    Period JItter
    parameter TJIT_CC          =     100; //% tJIT(cc)   ps    Cycle to Cycle jitter
    parameter TERR_2PER        =     74; //% tERR(2per) ps    Accumulated Error (2-cycle)
    parameter TERR_3PER        =     87; //% tERR(3per) ps    Accumulated Error (3-cycle)
    parameter TERR_4PER        =     97; //% tERR(4per) ps    Accumulated Error (4-cycle)
    parameter TERR_5PER        =     105; //% tERR(5per) ps    Accumulated Error (5-cycle)
    parameter TERR_6PER        =     111; //% tERR(6per) ps    Accumulated Error (6-cycle)
    parameter TERR_7PER        =     116; //% tERR(7per) ps    Accumulated Error (7-cycle)
    parameter TERR_8PER        =     121; //% tERR(8per) ps    Accumulated Error (8-cycle)
    parameter TERR_9PER        =     125; //% tERR(9per) ps    Accumulated Error (9-cycle)
    parameter TERR_10PER       =     128; //% tERR(10per)ps    Accumulated Error (10-cycle)
    parameter TERR_11PER       =     132; //% tERR(11per)ps    Accumulated Error (11-cycle)
    parameter TERR_12PER       =     134; //% tERR(12per)ps    Accumulated Error (12-cycle)

    
    //Data Timing                       
    parameter TDQSQ            =     75; //% tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TQH              =     0.38; //% tQH        tck    DQ output hold time from DQS, DQS#
	parameter TDS              =      55; //% tDS        ps    DQ and DM input setup time relative to DQS
    parameter TDH              =      60; //% tDH        ps    DQ and DM input hold time relative to DQS
    parameter TDIPW            =     280; //% tDIPW      ps    DQ and DM input Pulse Width
 
    
    //Data Strobe timing        
	parameter TRPRE            =    0.90; //? tRPRE      tCK   DQS Read Preamble
    parameter TRPST            =    0.30; //? tRPST      tCK   DQS Read Postamble
    parameter TQSH             =    0.40; //% tQSH       tCK   DQS Output High Pulse Width
    parameter TQSL             =    0.40; //% tQSL       tCK   DQS Output Low Pulse Width
    parameter TWPRE            =    0.90; //% tWPRE      tCK   DQS Write Preamble
    parameter TWPST            =    0.30; //% tWPST      tCK   DQS Write Postamble
	parameter TDQSCK           =     180; //% tDQSCK     ps    DQS output access time from CK/CK#, +-
    parameter TDQSL            =    0.45; //% tDQSL      tCK   DQS input High Pulse Width, min
    parameter TDQSH            =    0.45; //% tDQSH      tCK   DQS input Low Pulse Width, min
    parameter TDQSS            =    0.27; //% tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    parameter TDSS             =    0.18; //% tDSS       tCK   DQS falling edge to CLK rising (setup time)
    parameter TDSH             =    0.18; //% tDSH       tCK   DQS falling edge from CLK rising (hold time)
    
	//REfresh Timing
    parameter TRFC_MIN         =  260000; //% tRFC       ps    Refresh to Refresh Command interval minimum value
   
	
	
    //Command and Address Timing    
    parameter TAA_MIN          =   13090; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13090; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13090; //% tRP        ps    Precharge command period
    parameter TRC              =   46090; //% tRC        ps    Active to Active/Auto Refresh command time
    parameter TRAS_MIN         =   33000; //% tRAS       ps    Minimum Active to Precharge command time
    
	parameter TDLLK            =     512; //% tDLLK      tCK   DLL locking time
    parameter TRTP             =    7500; //% tRTP       ps    Read to Precharge command delay
    parameter TRTP_TCK         =       4; //% tRTP       tCK   Read to Precharge command delay
    parameter TWTR             =    7500; //% tWTR       ps    Write to Read command delay
    parameter TWTR_TCK         =       4; //% tWTR       tCK   Write to Read command delay
    parameter TWR              =   15000; //% tWR        ps    Write recovery time
	parameter TMRD             =       4; //% tMRD       tCK   Load Mode Register command cycle time
    parameter TMOD             =   15000; //% tMOD       ps    LOAD MODE to non-LOAD MODE command cycle time
    parameter TMOD_TCK         =      12; //% tMOD       tCK   LOAD MODE to non-LOAD MODE command cycle time
    parameter TCCD             =       4; //% tCCD       tCK   Cas to Cas command delay
    
	parameter TRRD             =    5000; //% tRRD       ps     (2KB page size) Active bank a to Active bank b command time
    parameter TRRD_TCK         =       4; //% tRRD       tCK   Active bank a to Active bank b command time
    
   
	

	parameter TFAW             =   25000; //% tFAW       ps     (2KB page size) Four Bank Activate window

    parameter TIS              =     60; //% tIS        ps    Input Setup Time
    parameter TIH              =     105; //% tIH        ps    Input Hold Time
    parameter TIPW             =     470; //% tIPW       ps    Control and Address input Pulse Width  


	//Calibration        
    parameter TZQINIT_TCK      =     512; //% tZQinit    tCK   ZQ Cal (Long) time
    parameter TZQINIT          =  640000; //% tZQinit    ps    ZQ Cal (Long) time
    parameter TZQOPER_TCK      =     256; //% tZQoper    tCK   ZQ Cal (Long) time
    parameter TZQOPER          =  320000; //% tZQoper    ps    ZQ Cal (Long) time
	parameter TZQCS_TCK        =      64; //% tZQCS      tCK   ZQ Cal (Short) time
    parameter TZQCS            =   80000; //% tZQCS      ps    ZQ Cal (Short) time    
    
	//Reset Timing
	parameter TXPR             =  10000+TRFC_MIN; //% tXPR       ps    Exit Reset from CKE assertion to a valid command
    parameter TXPR_TCK         =       5; //% tXPR       tCK   Exit Reset from CKE assertion to a valid command
    
	
	// Self Refresh
    parameter TXS              =  10000+TRFC_MIN; //% tXS        ps    Exit self refesh to a non-read or write command
    parameter TXS_TCK          =       5; //% tXS        tCK   Exit self refesh to a non-read or write command
    parameter TXSDLL           =   TDLLK; //% tXSDLL     tCK   Exit self refresh to a read or write command
    parameter TCKSRE           =   10000; //% tCKSRE     ps    Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRE_TCK       =       5; //% tCKSRE     tCK   Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRX           =   10000; //% tCKSRX     ps    Valid Clock requirement prior to self refresh exit (SRX)
    parameter TCKSRX_TCK       =       5; //% tCKSRX     tCK   Valid Clock requirement prior to self refresh exit (SRX)
	
	
    //Power Down Timing
    parameter TXP              =    6000; //% tXP        ps    Exit power down to a valid command
    parameter TXP_TCK          =       3; //% tXP        tCK   Exit power down to a valid command
    parameter TXPDLL           =   24000; //% tXPDLL     ps    Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TXPDLL_TCK       =      10; //% tXPDLL     tCK   Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TCKE             =    5000; //% tCKE       ps    CKE minimum high or low pulse width
    parameter TCPDED           =       2; //% tCPDED     tCK   Command pass disable/enable delay    
    parameter TPD_MAX          =   70312500; //% tPD        ps    Power-down entry-to-exit timing
   
    parameter TACTPDEN         =       2; //% tACTPDEN   tCK   Timing of last ACT command to power down entry
    parameter TPRPDEN          =       2; //% tPREPDEN   tCK   Timing of last PRE command to power down entry
    parameter TREFPDEN         =       2; //% tREFPDEN   tCK   Timing of last REFRESH command to power down entry

   
    //ODT Timing                
    parameter ODTH4            =       4; //% ODTH4      tCK   ODT minimum HIGH time after ODT assertion or write (BL4)
    parameter ODTH8            =       6; //% ODTH8      tCK   ODT minimum HIGH time after write (BL8)
    parameter TAONPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-on delay (Power-Down with DLL frozen), max
    parameter TAOFPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-off delay (Power-Down with DLL frozen), max
    parameter TAON             =     180; //% tAON       ps    RTT turn-on from ODTLon reference, max
    parameter TAOF             =     0.7; //% tAOF       tCK   RTT turn-off from ODTLoff reference, max
    parameter TADC             =     0.7; //% tADC       tCK   RTT dynamic change skew
    
    
    //Write Level Timing            
    parameter TWLMRD           =      40; //% tWLMRD     tCK   min First DQS pulse rising edge after tDQSS margining mode is programmed
    parameter TWLDQSEN         =      25; //% tWLDQSEN   tCK   min DQS/DQS delay after tDQSS margining mode is programmed
    parameter TWLS             =     125; //% tWLS       ps    min Setup time for tDQS flop
    parameter TWLH             =     125; //% tWLH       ps    min Hold time of tDQS flop
    parameter TWLO             =    7500; //% tWLO       ps    max Write levelization output delay
    parameter TWLOE            =    2000; //% tWLOE      ps    max Write levelization output error
`endif    

`ifdef T11                               
    parameter TCK_MIN          =    1072; //% tCK        ps    Minimum Clock Cycle Time
    parameter TJIT_PER         =      60; //% tJIT(per)  ps    Period JItter
    parameter TJIT_CC          =     120; //% tJIT(cc)   ps    Cycle to Cycle jitter
    parameter TERR_2PER        =     88; //% tERR(2per) ps    Accumulated Error (2-cycle)
    parameter TERR_3PER        =     105; //% tERR(3per) ps    Accumulated Error (3-cycle)
    parameter TERR_4PER        =     117; //% tERR(4per) ps    Accumulated Error (4-cycle)
    parameter TERR_5PER        =     126; //% tERR(5per) ps    Accumulated Error (5-cycle)
    parameter TERR_6PER        =     133; //% tERR(6per) ps    Accumulated Error (6-cycle)
    parameter TERR_7PER        =     139; //% tERR(7per) ps    Accumulated Error (7-cycle)
    parameter TERR_8PER        =     145; //% tERR(8per) ps    Accumulated Error (8-cycle)
    parameter TERR_9PER        =     150; //% tERR(9per) ps    Accumulated Error (9-cycle)
    parameter TERR_10PER       =     154; //% tERR(10per)ps    Accumulated Error (10-cycle)
    parameter TERR_11PER       =     158; //% tERR(11per)ps    Accumulated Error (11-cycle)
    parameter TERR_12PER       =     161; //% tERR(12per)ps    Accumulated Error (12-cycle)

    
    //Data Timing                       
    parameter TDQSQ            =     85; //% tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TQH              =     0.38; //% tQH        tck    DQ output hold time from DQS, DQS#
	parameter TDS              =      70; //% tDS        ps    DQ and DM input setup time relative to DQS
    parameter TDH              =      75; //% tDH        ps    DQ and DM input hold time relative to DQS
    parameter TDIPW            =     320; //% tDIPW      ps    DQ and DM input Pulse Width
 
    
    //Data Strobe timing        
	parameter TRPRE            =    0.90; //? tRPRE      tCK   DQS Read Preamble
    parameter TRPST            =    0.30; //? tRPST      tCK   DQS Read Postamble
    parameter TQSH             =    0.40; //% tQSH       tCK   DQS Output High Pulse Width
    parameter TQSL             =    0.40; //% tQSL       tCK   DQS Output Low Pulse Width
    parameter TWPRE            =    0.90; //% tWPRE      tCK   DQS Write Preamble
    parameter TWPST            =    0.30; //% tWPST      tCK   DQS Write Postamble
	parameter TDQSCK           =     195; //% tDQSCK     ps    DQS output access time from CK/CK#, +-
    parameter TDQSL            =    0.45; //% tDQSL      tCK   DQS input High Pulse Width, min
    parameter TDQSH            =    0.45; //% tDQSH      tCK   DQS input Low Pulse Width, min
    parameter TDQSS            =    0.27; //% tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    parameter TDSS             =    0.18; //% tDSS       tCK   DQS falling edge to CLK rising (setup time)
    parameter TDSH             =    0.18; //% tDSH       tCK   DQS falling edge from CLK rising (hold time)
    
	//REfresh Timing
    parameter TRFC_MIN         =  260000; //% tRFC       ps    Refresh to Refresh Command interval minimum value
   
	
	
    //Command and Address Timing    
    `ifdef DP
    parameter TAA_MIN          =   13125; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13125; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13125; //% tRP        ps    Precharge command period
    parameter TRC              =   47125; //% tRC        ps    Active to Active/Auto Refresh command time
   `else
    parameter TAA_MIN          =   13910; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13910; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13910; //% tRP        ps    Precharge command period
    parameter TRC              =   47910; //% tRC        ps    Active to Active/Auto Refresh command time
    `endif

    parameter TRAS_MIN         =   34000; //% tRAS       ps    Minimum Active to Precharge command time
    
	parameter TDLLK            =     512; //% tDLLK      tCK   DLL locking time
    parameter TRTP             =    7500; //% tRTP       ps    Read to Precharge command delay
    parameter TRTP_TCK         =       4; //% tRTP       tCK   Read to Precharge command delay
    parameter TWTR             =    7500; //% tWTR       ps    Write to Read command delay
    parameter TWTR_TCK         =       4; //% tWTR       tCK   Write to Read command delay
    parameter TWR              =   15000; //% tWR        ps    Write recovery time
	parameter TMRD             =       4; //% tMRD       tCK   Load Mode Register command cycle time
    parameter TMOD             =   15000; //% tMOD       ps    LOAD MODE to non-LOAD MODE command cycle time
    parameter TMOD_TCK         =      12; //% tMOD       tCK   LOAD MODE to non-LOAD MODE command cycle time
    parameter TCCD             =       4; //% tCCD       tCK   Cas to Cas command delay
    
	parameter TRRD             =    5000; //% tRRD       ps     (2KB page size) Active bank a to Active bank b command time
    parameter TRRD_TCK         =       4; //% tRRD       tCK   Active bank a to Active bank b command time
    
   
	
	parameter TFAW             =   27000; //% tFAW       ps     (2KB page size) Four Bank Activate window
    
    parameter TIS              =     65; //% tIS        ps    Input Setup Time
    parameter TIH              =     110; //% tIH        ps    Input Hold Time
    parameter TIPW             =     535; //% tIPW       ps    Control and Address input Pulse Width  


	//Calibration        
    parameter TZQINIT_TCK      =     512; //% tZQinit    tCK   ZQ Cal (Long) time
    parameter TZQINIT          =  640000; //% tZQinit    ps    ZQ Cal (Long) time
    parameter TZQOPER_TCK      =     256; //% tZQoper    tCK   ZQ Cal (Long) time
    parameter TZQOPER          =  320000; //% tZQoper    ps    ZQ Cal (Long) time
	parameter TZQCS_TCK        =      64; //% tZQCS      tCK   ZQ Cal (Short) time
    parameter TZQCS            =   80000; //% tZQCS      ps    ZQ Cal (Short) time    
    
	//Reset Timing
	parameter TXPR             =  10000+TRFC_MIN; //% tXPR       ps    Exit Reset from CKE assertion to a valid command
    parameter TXPR_TCK         =       5; //% tXPR       tCK   Exit Reset from CKE assertion to a valid command
    
	
	// Self Refresh
    parameter TXS              =  10000+TRFC_MIN; //% tXS        ps    Exit self refesh to a non-read or write command
    parameter TXS_TCK          =       5; //% tXS        tCK   Exit self refesh to a non-read or write command
    parameter TXSDLL           =   TDLLK; //% tXSDLL     tCK   Exit self refresh to a read or write command
    parameter TCKSRE           =   10000; //% tCKSRE     ps    Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRE_TCK       =       5; //% tCKSRE     tCK   Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRX           =   10000; //% tCKSRX     ps    Valid Clock requirement prior to self refresh exit (SRX)
    parameter TCKSRX_TCK       =       5; //% tCKSRX     tCK   Valid Clock requirement prior to self refresh exit (SRX)
	
	
    //Power Down Timing
    parameter TXP              =    6000; //% tXP        ps    Exit power down to a valid command
    parameter TXP_TCK          =       3; //% tXP        tCK   Exit power down to a valid command
    parameter TXPDLL           =   24000; //% tXPDLL     ps    Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TXPDLL_TCK       =      10; //% tXPDLL     tCK   Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TCKE             =    5000; //% tCKE       ps    CKE minimum high or low pulse width
    parameter TCPDED           =       2; //% tCPDED     tCK   Command pass disable/enable delay    
    parameter TPD_MAX          =   70312500; //% tPD        ps    Power-down entry-to-exit timing
   
    parameter TACTPDEN         =       1; //% tACTPDEN   tCK   Timing of last ACT command to power down entry
    parameter TPRPDEN          =       1; //% tPREPDEN   tCK   Timing of last PRE command to power down entry
    parameter TREFPDEN         =       1; //% tREFPDEN   tCK   Timing of last REFRESH command to power down entry

   
    //ODT Timing                
    parameter ODTH4            =       4; //% ODTH4      tCK   ODT minimum HIGH time after ODT assertion or write (BL4)
    parameter ODTH8            =       6; //% ODTH8      tCK   ODT minimum HIGH time after write (BL8)
    parameter TAONPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-on delay (Power-Down with DLL frozen), max
    parameter TAOFPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-off delay (Power-Down with DLL frozen), max
    parameter TAON             =     195; //% tAON       ps    RTT turn-on from ODTLon reference, max
    parameter TAOF             =     0.7; //% tAOF       tCK   RTT turn-off from ODTLoff reference, max
    parameter TADC             =     0.7; //% tADC       tCK   RTT dynamic change skew
    
    
    //Write Level Timing            
    parameter TWLMRD           =      40; //% tWLMRD     tCK   min First DQS pulse rising edge after tDQSS margining mode is programmed
    parameter TWLDQSEN         =      25; //% tWLDQSEN   tCK   min DQS/DQS delay after tDQSS margining mode is programmed
    parameter TWLS             =     140; //% tWLS       ps    min Setup time for tDQS flop
    parameter TWLH             =     140; //% tWLH       ps    min Hold time of tDQS flop
    parameter TWLO             =    7500; //% tWLO       ps    max Write levelization output delay
    parameter TWLOE            =    2000; //% tWLOE      ps    max Write levelization output error

	`endif
									  
// T12 is equivalent to the JEDEC DDR3-1600 speed bin                                            // ------     ----- -----------
`ifdef T12                               
    parameter TCK_MIN          =    1250; //% tCK        ps    Minimum Clock Cycle Time
    parameter TJIT_PER         =      70; //% tJIT(per)  ps    Period JItter
    parameter TJIT_CC          =     140; //% tJIT(cc)   ps    Cycle to Cycle jitter
    parameter TERR_2PER        =     103; //% tERR(2per) ps    Accumulated Error (2-cycle)
    parameter TERR_3PER        =     122; //% tERR(3per) ps    Accumulated Error (3-cycle)
    parameter TERR_4PER        =     136; //% tERR(4per) ps    Accumulated Error (4-cycle)
    parameter TERR_5PER        =     147; //% tERR(5per) ps    Accumulated Error (5-cycle)
    parameter TERR_6PER        =     155; //% tERR(6per) ps    Accumulated Error (6-cycle)
    parameter TERR_7PER        =     163; //% tERR(7per) ps    Accumulated Error (7-cycle)
    parameter TERR_8PER        =     169; //% tERR(8per) ps    Accumulated Error (8-cycle)
    parameter TERR_9PER        =     175; //% tERR(9per) ps    Accumulated Error (9-cycle)
    parameter TERR_10PER       =     180; //% tERR(10per)ps    Accumulated Error (10-cycle)
    parameter TERR_11PER       =     184; //% tERR(11per)ps    Accumulated Error (11-cycle)
    parameter TERR_12PER       =     188; //% tERR(12per)ps    Accumulated Error (12-cycle)

    
    //Data Timing                       
    parameter TDQSQ            =     100; //% tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TQH              =     0.38; //% tQH        tck    DQ output hold time from DQS, DQS#
	parameter TDS              =      25; //% tDS        ps    DQ and DM input setup time relative to DQS
    parameter TDH              =      55; //% tDH        ps    DQ and DM input hold time relative to DQS
    parameter TDIPW            =     360; //% tDIPW      ps    DQ and DM input Pulse Width
 
    
    //Data Strobe timing        
	parameter TRPRE            =    0.90; //? tRPRE      tCK   DQS Read Preamble
    parameter TRPST            =    0.30; //? tRPST      tCK   DQS Read Postamble
    parameter TQSH             =    0.40; //% tQSH       tCK   DQS Output High Pulse Width
    parameter TQSL             =    0.40; //% tQSL       tCK   DQS Output Low Pulse Width
    parameter TWPRE            =    0.90; //% tWPRE      tCK   DQS Write Preamble
    parameter TWPST            =    0.30; //% tWPST      tCK   DQS Write Postamble
	parameter TDQSCK           =     225; //% tDQSCK     ps    DQS output access time from CK/CK#, +-
    parameter TDQSL            =    0.45; //% tDQSL      tCK   DQS input High Pulse Width, min
    parameter TDQSH            =    0.45; //% tDQSH      tCK   DQS input Low Pulse Width, min
    parameter TDQSS            =    0.27; //% tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    parameter TDSS             =    0.18; //% tDSS       tCK   DQS falling edge to CLK rising (setup time)
    parameter TDSH             =    0.18; //% tDSH       tCK   DQS falling edge from CLK rising (hold time)
    
	//REfresh Timing
    parameter TRFC_MIN         =  260000; //% tRFC       ps    Refresh to Refresh Command interval minimum value
   
	
	
    //Command and Address Timing    
    `ifdef DP
    parameter TAA_MIN          =   13125; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13125; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13125; //% tRP        ps    Precharge command period
    parameter TRC              =   48125; //% tRC        ps    Active to Active/Auto Refresh command time
    `else
    parameter TAA_MIN          =   13750; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13750; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13750; //% tRP        ps    Precharge command period
    parameter TRC              =   48750; //% tRC        ps    Active to Active/Auto Refresh command time
    `endif
    parameter TRAS_MIN         =   35000; //% tRAS       ps    Minimum Active to Precharge command time
    parameter TDLLK            =     512; //% tDLLK      tCK   DLL locking time
    parameter TRTP             =    7500; //% tRTP       ps    Read to Precharge command delay
    parameter TRTP_TCK         =       4; //% tRTP       tCK   Read to Precharge command delay
    parameter TWTR             =    7500; //% tWTR       ps    Write to Read command delay
    parameter TWTR_TCK         =       4; //% tWTR       tCK   Write to Read command delay
    parameter TWR              =   15000; //% tWR        ps    Write recovery time
	parameter TMRD             =       4; //% tMRD       tCK   Load Mode Register command cycle time
    parameter TMOD             =   15000; //% tMOD       ps    LOAD MODE to non-LOAD MODE command cycle time
    parameter TMOD_TCK         =      12; //% tMOD       tCK   LOAD MODE to non-LOAD MODE command cycle time
    parameter TCCD             =       4; //% tCCD       tCK   Cas to Cas command delay
    
	
	parameter TRRD             =    6000; //% tRRD       ps     (2KB page size) Active bank a to Active bank b command time
    parameter TRRD_TCK         =       4; //% tRRD       tCK   Active bank a to Active bank b command time
    
   
	
	parameter TFAW             =   30000; //% tFAW       ps     (2KB page size) Four Bank Activate window
    
    parameter TIS              =     60; //% tIS        ps    Input Setup Time
    parameter TIH              =     130; //% tIH        ps    Input Hold Time
    parameter TIPW             =     560; //% tIPW       ps    Control and Address input Pulse Width  


	//Calibration        
    parameter TZQINIT_TCK      =     512; //% tZQinit    tCK   ZQ Cal (Long) time
    parameter TZQINIT          =  640000; //% tZQinit    ps    ZQ Cal (Long) time
    parameter TZQOPER_TCK      =     256; //% tZQoper    tCK   ZQ Cal (Long) time
    parameter TZQOPER          =  320000; //% tZQoper    ps    ZQ Cal (Long) time
	parameter TZQCS_TCK        =      64; //% tZQCS      tCK   ZQ Cal (Short) time
    parameter TZQCS            =   80000; //% tZQCS      ps    ZQ Cal (Short) time    
    
	//Reset Timing
	parameter TXPR             =  10000+TRFC_MIN; //% tXPR       ps    Exit Reset from CKE assertion to a valid command
    parameter TXPR_TCK         =       5; //% tXPR       tCK   Exit Reset from CKE assertion to a valid command
    
	
	// Self Refresh
    parameter TXS              =  10000+TRFC_MIN; //% tXS        ps    Exit self refesh to a non-read or write command
    parameter TXS_TCK          =       5; //% tXS        tCK   Exit self refesh to a non-read or write command
    parameter TXSDLL           =   TDLLK; //% tXSDLL     tCK   Exit self refresh to a read or write command
    parameter TCKSRE           =   10000; //% tCKSRE     ps    Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRE_TCK       =       5; //% tCKSRE     tCK   Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRX           =   10000; //% tCKSRX     ps    Valid Clock requirement prior to self refresh exit (SRX)
    parameter TCKSRX_TCK       =       5; //% tCKSRX     tCK   Valid Clock requirement prior to self refresh exit (SRX)
	
	
    //Power Down Timing
    parameter TXP              =    6000; //% tXP        ps    Exit power down to a valid command
    parameter TXP_TCK          =       3; //% tXP        tCK   Exit power down to a valid command
    parameter TXPDLL           =   24000; //% tXPDLL     ps    Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TXPDLL_TCK       =      10; //% tXPDLL     tCK   Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TCKE             =    5000; //% tCKE       ps    CKE minimum high or low pulse width
    parameter TCPDED           =       1; //% tCPDED     tCK   Command pass disable/enable delay    
    parameter TPD_MAX          =   70312500; //% tPD        ps    Power-down entry-to-exit timing
   
    parameter TACTPDEN         =       1; //% tACTPDEN   tCK   Timing of last ACT command to power down entry
    parameter TPRPDEN          =       1; //% tPREPDEN   tCK   Timing of last PRE command to power down entry
    parameter TREFPDEN         =       1; //% tREFPDEN   tCK   Timing of last REFRESH command to power down entry

   
    //ODT Timing                
    parameter ODTH4            =       4; //% ODTH4      tCK   ODT minimum HIGH time after ODT assertion or write (BL4)
    parameter ODTH8            =       6; //% ODTH8      tCK   ODT minimum HIGH time after write (BL8)
    parameter TAONPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-on delay (Power-Down with DLL frozen), max
    parameter TAOFPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-off delay (Power-Down with DLL frozen), max
    parameter TAON             =     225; //% tAON       ps    RTT turn-on from ODTLon reference, max
    parameter TAOF             =     0.7; //% tAOF       tCK   RTT turn-off from ODTLoff reference, max
    parameter TADC             =     0.7; //% tADC       tCK   RTT dynamic change skew
    
    
    //Write Level Timing            
    parameter TWLMRD           =      40; //% tWLMRD     tCK   min First DQS pulse rising edge after tDQSS margining mode is programmed
    parameter TWLDQSEN         =      25; //% tWLDQSEN   tCK   min DQS/DQS delay after tDQSS margining mode is programmed
    parameter TWLS             =     165; //% tWLS       ps    min Setup time for tDQS flop
    parameter TWLH             =     165; //% tWLH       ps    min Hold time of tDQS flop
    parameter TWLO             =    7500; //% tWLO       ps    max Write levelization output delay
    parameter TWLOE            =    2000; //% tWLOE      ps    max Write levelization output error
`endif     
    
    
// T15 is equivalent to the JEDEC DDR3-1333 (9-9-9) speed bin
`ifdef T15                              
    parameter TCK_MIN          =    1499.2; //% tCK        ps    Minimum Clock Cycle Time
    parameter TJIT_PER         =      80; //% tJIT(per)  ps    Period JItter
    parameter TJIT_CC          =     160; //% tJIT(cc)   ps    Cycle to Cycle jitter
    parameter TERR_2PER        =     118; //% tERR(2per) ps    Accumulated Error (2-cycle)
    parameter TERR_3PER        =     140; //% tERR(3per) ps    Accumulated Error (3-cycle)
    parameter TERR_4PER        =     155; //% tERR(4per) ps    Accumulated Error (4-cycle)
    parameter TERR_5PER        =     168; //% tERR(5per) ps    Accumulated Error (5-cycle)
    parameter TERR_6PER        =     177; //% tERR(6per) ps    Accumulated Error (6-cycle)
    parameter TERR_7PER        =     186; //% tERR(7per) ps    Accumulated Error (7-cycle)
    parameter TERR_8PER        =     193; //% tERR(8per) ps    Accumulated Error (8-cycle)
    parameter TERR_9PER        =     200; //% tERR(9per) ps    Accumulated Error (9-cycle)
    parameter TERR_10PER       =     205; //% tERR(10per)ps    Accumulated Error (10-cycle)
    parameter TERR_11PER       =     210; //% tERR(11per)ps    Accumulated Error (11-cycle)
    parameter TERR_12PER       =     215; //% tERR(12per)ps    Accumulated Error (12-cycle)

    
    //Data Timing                       
    parameter TDQSQ            =     125; //% tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TQH              =     0.38; //% tQH        tck    DQ output hold time from DQS, DQS#
	parameter TDS              =      45; //% tDS        ps    DQ and DM input setup time relative to DQS
    parameter TDH              =      75; //% tDH        ps    DQ and DM input hold time relative to DQS
    parameter TDIPW            =     400; //% tDIPW      ps    DQ and DM input Pulse Width
 
    
    //Data Strobe timing        
	parameter TRPRE            =    0.90; //? tRPRE      tCK   DQS Read Preamble
    parameter TRPST            =    0.30; //? tRPST      tCK   DQS Read Postamble
    parameter TQSH             =    0.40; //% tQSH       tCK   DQS Output High Pulse Width
    parameter TQSL             =    0.40; //% tQSL       tCK   DQS Output Low Pulse Width
    parameter TWPRE            =    0.90; //% tWPRE      tCK   DQS Write Preamble
    parameter TWPST            =    0.30; //% tWPST      tCK   DQS Write Postamble
	parameter TDQSCK           =     255; //% tDQSCK     ps    DQS output access time from CK/CK#, +-
    parameter TDQSL            =    0.45; //% tDQSL      tCK   DQS input High Pulse Width, min
    parameter TDQSH            =    0.45; //% tDQSH      tCK   DQS input Low Pulse Width, min
    parameter TDQSS            =    0.25; //% tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    parameter TDSS             =    0.2; //% tDSS       tCK   DQS falling edge to CLK rising (setup time)
    parameter TDSH             =    0.2; //% tDSH       tCK   DQS falling edge from CLK rising (hold time)
    
	//REfresh Timing
    parameter TRFC_MIN         =  260000; //% tRFC       ps    Refresh to Refresh Command interval minimum value
   
	
	
    //Command and Address Timing    
    `ifdef DP
    parameter TAA_MIN          =   13500; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13500; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13500; //% tRP        ps    Precharge command period
    parameter TRC              =   49500; //% tRC        ps    Active to Active/Auto Refresh command time
    `else
    parameter TAA_MIN          =   13125; //% TAA       ps    Internal READ command to first data
    parameter TRCD             =   13125; //% tRCD       ps    Active to Read/Write command time        
    parameter TRP              =   13125; //% tRP        ps    Precharge command period
    parameter TRC              =   49125; //% tRC        ps    Active to Active/Auto Refresh command time
    `endif
    parameter TRAS_MIN         =   36000; //% tRAS       ps    Minimum Active to Precharge command time
	parameter TDLLK            =     512; //% tDLLK      tCK   DLL locking time
    parameter TRTP             =    7500; //% tRTP       ps    Read to Precharge command delay
    parameter TRTP_TCK         =       4; //% tRTP       tCK   Read to Precharge command delay
    parameter TWTR             =    7500; //% tWTR       ps    Write to Read command delay
    parameter TWTR_TCK         =       4; //% tWTR       tCK   Write to Read command delay
    parameter TWR              =   15000; //% tWR        ps    Write recovery time
	parameter TMRD             =       4; //% tMRD       tCK   Load Mode Register command cycle time
    parameter TMOD             =   15000; //% tMOD       ps    LOAD MODE to non-LOAD MODE command cycle time
    parameter TMOD_TCK         =      12; //% tMOD       tCK   LOAD MODE to non-LOAD MODE command cycle time
    parameter TCCD             =       4; //% tCCD       tCK   Cas to Cas command delay
    
    parameter TRRD             =    6000; //% tRRD       ps     (2KB page size) Active bank a to Active bank b command time
    parameter TRRD_TCK         =       4; //% tRRD       tCK   Active bank a to Active bank b command time
    
   
	
	parameter TFAW             =   30000; //% tFAW       ps     (2KB page size) Four Bank Activate window
    
    parameter TIS              =     80; //% tIS        ps    Input Setup Time
    parameter TIH              =     150; //% tIH        ps    Input Hold Time
    parameter TIPW             =     620; //% tIPW       ps    Control and Address input Pulse Width  


	//Calibration        
    parameter TZQINIT_TCK      =     512; //% tZQinit    tCK   ZQ Cal (Long) time
    parameter TZQINIT          =  640000; //% tZQinit    ps    ZQ Cal (Long) time
    parameter TZQOPER_TCK      =     256; //% tZQoper    tCK   ZQ Cal (Long) time
    parameter TZQOPER          =  320000; //% tZQoper    ps    ZQ Cal (Long) time
	parameter TZQCS_TCK        =      64; //% tZQCS      tCK   ZQ Cal (Short) time
    parameter TZQCS            =   80000; //% tZQCS      ps    ZQ Cal (Short) time    
    
	//Reset Timing
	parameter TXPR             =  10000+TRFC_MIN; //% tXPR       ps    Exit Reset from CKE assertion to a valid command
    parameter TXPR_TCK         =       5; //% tXPR       tCK   Exit Reset from CKE assertion to a valid command
    
	
	// Self Refresh
    parameter TXS              =  10000+TRFC_MIN; //% tXS        ps    Exit self refesh to a non-read or write command
    parameter TXS_TCK          =       5; //% tXS        tCK   Exit self refesh to a non-read or write command
    parameter TXSDLL           =   TDLLK; //% tXSDLL     tCK   Exit self refresh to a read or write command
    parameter TCKSRE           =   10000; //% tCKSRE     ps    Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRE_TCK       =       5; //% tCKSRE     tCK   Valid Clock requirement after self refresh entry (SRE)
    parameter TCKSRX           =   10000; //% tCKSRX     ps    Valid Clock requirement prior to self refresh exit (SRX)
    parameter TCKSRX_TCK       =       5; //% tCKSRX     tCK   Valid Clock requirement prior to self refresh exit (SRX)
	
	
    //Power Down Timing
    parameter TXP              =    6000; //% tXP        ps    Exit power down to a valid command
    parameter TXP_TCK          =       3; //% tXP        tCK   Exit power down to a valid command
    parameter TXPDLL           =   24000; //% tXPDLL     ps    Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TXPDLL_TCK       =      10; //% tXPDLL     tCK   Exit precharge power down to READ or WRITE command (DLL-off mode)
    parameter TCKE             =    5625; //% tCKE       ps    CKE minimum high or low pulse width
    parameter TCPDED           =       1; //% tCPDED     tCK   Command pass disable/enable delay    
    parameter TPD_MAX          =   70312500; //% tPD        ps    Power-down entry-to-exit timing
   
    parameter TACTPDEN         =       1; //% tACTPDEN   tCK   Timing of last ACT command to power down entry
    parameter TPRPDEN          =       1; //% tPREPDEN   tCK   Timing of last PRE command to power down entry
    parameter TREFPDEN         =       1; //% tREFPDEN   tCK   Timing of last REFRESH command to power down entry

   
    //ODT Timing                
    parameter ODTH4            =       4; //% ODTH4      tCK   ODT minimum HIGH time after ODT assertion or write (BL4)
    parameter ODTH8            =       6; //% ODTH8      tCK   ODT minimum HIGH time after write (BL8)
    parameter TAONPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-on delay (Power-Down with DLL frozen), max
    parameter TAOFPD           =    8500; //% tAONPD     ps    Asynchronous RTT turn-off delay (Power-Down with DLL frozen), max
    parameter TAON             =     250; //% tAON       ps    RTT turn-on from ODTLon reference, max
    parameter TAOF             =     0.7; //% tAOF       tCK   RTT turn-off from ODTLoff reference, max
    parameter TADC             =     0.7; //% tADC       tCK   RTT dynamic change skew
    
    
    //Write Level Timing            
    parameter TWLMRD           =      40; //% tWLMRD     tCK   min First DQS pulse rising edge after tDQSS margining mode is programmed
    parameter TWLDQSEN         =      25; //% tWLDQSEN   tCK   min DQS/DQS delay after tDQSS margining mode is programmed
    parameter TWLS             =     195; //% tWLS       ps    min Setup time for tDQS flop
    parameter TWLH             =     195; //% tWLH       ps    min Hold time of tDQS flop
    parameter TWLO             =    9000; //% tWLO       ps    max Write levelization output delay
    parameter TWLOE            =    2000; //% tWLOE      ps    max Write levelization output error
      
    
`endif 

 
    // Timing Parameters

    // Mode Register
    parameter CL_MIN           =       5; //% CL         tCK   Minimum CAS Latency
    parameter CL_MAX           =      14; //% CL         tCK   Maximum CAS Latency
    parameter AL_MIN           =       0; //% AL         tCK   Minimum Additive Latency
    parameter AL_MAX           =       2; //% AL         tCK   Maximum Additive Latency
    parameter WR_MIN           =       5; //% WR         tCK   Minimum Write Recovery
    parameter WR_MAX           =      16; //% WR         tCK   Maximum Write Recovery
    parameter BL_MIN           =       4; //% BL         tCK   Minimum Burst Length
    parameter BL_MAX           =       8; //% BL         tCK   Maximum Burst Length
    parameter CWL_MIN          =       5; //% CWL        tCK   Minimum CAS Write Latency
    parameter CWL_MAX          =       10; //% CWL        tCK   Maximum CAS Write Latency

    // Clock
    parameter TCK_MAX          =    3300; //% tCK        ps    Maximum Clock Cycle Time
    parameter TCH_AVG_MIN      =    0.47; //% tCH        tCK   Minimum Clock High-Level Pulse Width
    parameter TCL_AVG_MIN      =    0.47; //% tCL        tCK   Minimum Clock Low-Level Pulse Width
    parameter TCH_AVG_MAX      =    0.53; //% tCH        tCK   Maximum Clock High-Level Pulse Width
    parameter TCL_AVG_MAX      =    0.53; //% tCL        tCK   Maximum Clock Low-Level Pulse Width
    parameter TCH_ABS_MIN      =    0.43; //% tCH        tCK   Minimum Clock High-Level Pulse Width
    parameter TCL_ABS_MIN      =    0.43; //% tCL        tCK   Maximum Clock Low-Level Pulse Width
    parameter TCKE_TCK         =       3; //% tCKE       tCK   CKE minimum high or low pulse width
    parameter TAA_MAX          =   20000; //? TAA        ps    Internal READ command to first data, no use
    
   
    
    parameter TRAS_MAX         =    70e6; //% tRAS       ps    Maximum Active to Precharge command time, 9*tREFI
    parameter TRFC_MAX         =70312500; //% tRFC       ps    Refresh to Refresh Command Interval maximum value, 9*tREFI(7.8us)
    
    
    // Size Parameters based on Part Width
    `ifdef X8
    parameter DQ_BITS          =       8; // Set this parameter to control how many Data bits are used       **Same as part bit width**
    parameter DQS_BITS         =       1; // Set this parameter to control how many Dqs bits are used
    parameter DM_BITS          =       1; // Set this parameter to control how many Data Mask bits are used
    parameter ADDR_BITS        =      16; // MAX Address Bits    
    parameter ROW_BITS         =      16; // Set this parameter to control how many Address bits are used
    
   `else //X16
    parameter DQ_BITS          =      16; // Set this parameter to control how many Data bits are used       **Same as part bit width**  
    parameter DQS_BITS         =       2; // Set this parameter to control how many Dqs bits are used
    parameter DM_BITS          =       2; // Set this parameter to control how many Data Mask bits are used
    parameter ADDR_BITS        =      15; // MAX Address Bits
    parameter ROW_BITS         =      15; // Set this parameter to control how many Address bits are used
   `endif
    
    parameter COL_BITS         =      10; // Set this parameter to control how many Column bits are used
    parameter DQ_PER_DQS         =    DQ_BITS/DQS_BITS;
    
    // Size Parameters
    parameter BA_BITS          =       3; // Set this parmaeter to control how many Bank Address bits are used
    parameter BANKS            =       1<<(BA_BITS);
    parameter AP_bit           =      10; // the address bit that controls auto-precharge and precharge-all
    parameter BC_bit           =      12; // the address bit that controls burst chop
    parameter BL_BITS          =       3; // the number of bits required to count to BL_MAX
    parameter BO_BITS          =       2; // the number of Burst Order Bits
    parameter MAX_BITS         = BA_BITS + ROW_BITS + COL_BITS - BL_BITS;
	parameter MAX_BITS_INIT    = BA_BITS + ROW_BITS + COL_BITS;
    parameter MEM_BITS         = MAX_BITS; // Set this parameter to control how many write data bursts can be stored in memory.  The default is 2^10=1024.
    parameter MEM_SIZE         = (1<<MEM_BITS);
  
    parameter MAX_PIPE         = 4*CL_MAX;


    // Simulation parameters
    parameter RZQ              =     240; // termination resistance
    parameter STOP_ON_ERROR    =       0; // If set to 1, the model will halt on command sequence/major errors
    parameter DEBUG            =       1; // Turn on Debug messages
    parameter BUS_DELAY        =       0; // delay in ps
    parameter RANDOM_OUT_DELAY =       0; // If set to 1, the model will put a random amount of delay on DQ/DQS during reads
    parameter RANDOM_SEED    = 711689044; //seed value for random generator.

    parameter RDQSEN_PRE       =       2; // DQS driving time prior to first read strobe
    parameter RDQSEN_PST       =       1; // DQS driving time after last read strobe
    parameter RDQS_PRE         =       2; // DQS low time prior to first read strobe
    parameter RDQS_PST         =       1; // DQS low time after last read strobe
    parameter RDQEN_PRE        =       0; // DQ/DM driving time prior to first read data
    parameter RDQEN_PST        =       0; // DQ/DM driving time after last read data
    parameter WDQS_PRE         =       2; // DQS half clock periods prior to first write strobe
    parameter WDQS_PST         =       1; // DQS half clock periods after last write strobe


    parameter SAME_BANK  = 2'd0; // same bank, same group
    parameter DIFF_BANK  = 2'd1; // different bank, same group
    parameter DIFF_GROUP = 2'd2; // different bank, different group

    parameter [2:0]     MR3 = 3;
    parameter [2:0]     MR2 = 2;
    parameter [2:0]     MR1 = 1;
    parameter [2:0]     MR0 = 0;
        
// For Simualtion
// MRS Address and Bit definition
    
    parameter   ZQ_LONG  = 1,
                ZQ_SHORT = 0,
                AP_0     = 0,
                AP_1     = 1,
                BC_0     = 0,
                BC_1     = 1;
                                
    parameter   BANK_0   = 0,
                BANK_1   = 1,
                BANK_2   = 2,
                BANK_3   = 3,
                BANK_4   = 4,
                BANK_5   = 5,
                BANK_6   = 6,
                BANK_7   = 7;
                

    parameter [ADDR_BITS-1:0]    
                MR_ZERO        =    {ADDR_BITS{1'b0}},
                MR0_BL_8       =     'h0_000,
                MR0_BL_48      =     'h0_001,
                MR0_BL_4       =     'h0_002,
                
                MR0_RBT_INT    =     'h0_008,
                MR0_RBT_SEQ    =     'h0_000,

				MR0_CAS_LAT_5  =     'h0_010, 
                MR0_CAS_LAT_6  =     'h0_020,
                MR0_CAS_LAT_7  =     'h0_030,
                MR0_CAS_LAT_8  =     'h0_040,
                MR0_CAS_LAT_9  =     'h0_050,
                MR0_CAS_LAT_10 =     'h0_060,
                MR0_CAS_LAT_11 =     'h0_070,
                MR0_CAS_LAT_13 =     'h0_014,
                MR0_CAS_LAT_14 =     'h0_024,
                
                MR0_TM_Normal  =     'h0_000,
                
                MR0_DLL_RST    =     'h0_100,     
                
                MR0_WR_5       =     'h0_200,
                MR0_WR_6       =     'h0_400,
                MR0_WR_7       =     'h0_600,
                MR0_WR_8       =     'h0_800,
                MR0_WR_10      =     'h0_A00,
                MR0_WR_12      =     'h0_C00,
                MR0_WR_14      =     'h0_E00,
                MR0_WR_16      =     'h0_000,
                
                
                MR0_PPD_FAST   =     'h1_000,
                MR0_PPD_SLOW   =     'h0_000,
                
                MR1_DLL_EN     =     'h0_000,
                MR1_DLL_DIS    =     'h0_001,
                    
                MR1_DIC_RZQ6   =     'h0_000,
                MR1_DIC_RZQ7   =     'h0_002,
                
                MR1_AL_CL_0    =     'h0_000,
                MR1_AL_CL_1    =     'h0_008,
                MR1_AL_CL_2    =     'h0_010,
                
                MR1_RttNom_DIS  =    'h0_000,
                MR1_RttNom_RZQ4 =    'h0_004,
                MR1_RttNom_RZQ2 =    'h0_040,
                MR1_RttNom_RZQ6 =    'h0_044,
                MR1_RttNom_RZQ12 =   'h0_200,
                MR1_RttNom_RZQ8 =    'h0_204,
                
                MR1_TDQS_DIS    =    'h0_000,
                MR1_TDQS_EN     =    'h0_100,
                
                MR1_Level_EN    =    'h0_080,
                MR1_Level_DIS   =    'h0_000,
                
                MR1_Qoff_EN     =    'h0_000,
                MR1_Qoff_DIS    =    'h1_000,
                
                    
                MR2_PASR_FULL   =    'h0_000,
                MR2_PASR_1B2    =    'h0_001,      
                MR2_PASR_1B4    =    'h0_002,
                MR2_PASR_1B8    =    'h0_003,
                MR2_PASR_3B4    =    'h0_004,
                MR2_PASR_1B2x   =    'h0_005,
                MR2_PASR_1B4x   =    'h0_006,
                MR2_PASR_1B8x   =    'h0_007,
                
                MR2_CWL_5       =    'h0_000,
                MR2_CWL_6       =    'h0_008,
                MR2_CWL_7       =    'h0_010,
                MR2_CWL_8       =    'h0_018,
                MR2_CWL_9       =    'h0_020,
                MR2_CWL_10      =    'h0_028,
				 
				 
                MR2_ASR_EN      =    'h0_040,
                MR2_ASR_MANU    =    'h0_000,
                
                MR2_SRT_NRM     =    'h0_000,
                MR2_SRT_EXT     =    'h0_080,

                MR2_RttWR_OFF   =    'h0_000,                                
                MR2_RttWR_RZQ4  =    'h0_200,
                MR2_RttWR_RZQ2  =    'h0_400,

                MR3_MPR_LOC_PRE =    'h0_000,
                MR3_MPR_NORMAL  =    'h0_000,   
                MR3_MPR_DATA    =    'h0_004;    

    parameter   [8*DM_BITS-1:0]   
                NO_MASK         = 0,    
                DM_MASK_0       = 3,
                DM_MASK_0_L     = 1,
                DM_MASK_0_H     = 2,
                
                DM_MASK_1       = DM_MASK_0<<2,
                DM_MASK_2       = DM_MASK_1<<2,
                DM_MASK_3       = DM_MASK_2<<2,
                DM_MASK_4       = DM_MASK_3<<2,
                DM_MASK_5       = DM_MASK_4<<2,
                DM_MASK_6       = DM_MASK_5<<2,
                DM_MASK_7       = DM_MASK_6<<2,
                
                DM_MASK_1_H     = DM_MASK_0_H<<2,
                DM_MASK_2_H     = DM_MASK_1_H<<2,
                DM_MASK_3_H     = DM_MASK_2_H<<2,
                DM_MASK_4_H     = DM_MASK_3_H<<2,
                DM_MASK_5_H     = DM_MASK_4_H<<2,
                DM_MASK_6_H     = DM_MASK_5_H<<2,
                DM_MASK_7_H     = DM_MASK_6_H<<2,
                
                DM_MASK_1_L     = DM_MASK_0_L<<2,
                DM_MASK_2_L     = DM_MASK_1_L<<2,
                DM_MASK_3_L     = DM_MASK_2_L<<2,
                DM_MASK_4_L     = DM_MASK_3_L<<2,
                DM_MASK_5_L     = DM_MASK_4_L<<2,
                DM_MASK_6_L     = DM_MASK_5_L<<2,
                DM_MASK_7_L     = DM_MASK_6_L<<2;
