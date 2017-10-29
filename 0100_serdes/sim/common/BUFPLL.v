// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/stan/BUFPLL.v,v 1.11 2012/10/04 22:10:38 robh Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2007 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Phase Locked Loop buffer for Spartan Series
// /___/   /\     Filename : BUFPLL.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
// Revision:
//    06/09/08 - Initial version.
//    08/19/08 - IR 479918 -- added 100 ps latency to sequential paths.
//    02/10/09 - IR 505709 -- correlate SERDESSTROBE to GLCK
//    03/24/09 - CR 514119 -- sync output to LOCKED high signal 
//    06/16/09 - CR 525221 -- added ENABLE_SYNC attribute
//    02/08/11 - CR 584404 -- restart, if LOCK lost or reprogrammed
//    01/11/12 - CR 639574 -- aligned the SERDESTROBE to GCLK when ENABLE_SYNC=TRUE
//    10/04/12 - 680268 -- aligned the SERDESTROBE to IOCLK always and other clean up
// End Revision
///////////////////////////////////////////////////////////////////////////////

`timescale  1 ps / 1 ps

module BUFPLL (IOCLK, LOCK, SERDESSTROBE, GCLK, LOCKED, PLLIN);


    parameter integer DIVIDE = 1;        // {1..8}
    parameter ENABLE_SYNC = "TRUE";



    output IOCLK;
    output LOCK;
    output SERDESSTROBE;

    input GCLK;
    input LOCKED;
    input PLLIN;


// Output signals 
    reg  ioclk_out = 0, lock_out = 0, serdesstrobe_out = 0;

    reg  enable_sync_strobe_out = 0, sync_strobe_out = 0;

// Attribute settings

// Other signals
    reg attr_err_flag = 0;
    tri0  GSR = glbl.GSR;
    localparam MODULE_NAME = "BUFPLL";

    wire gclk_in;
    wire locked_in;
    wire pllin_in;
    
//----------------------------------------------------------------------
//------------------------  Output Ports  ------------------------------
//----------------------------------------------------------------------
    assign IOCLK = ioclk_out;

    assign LOCK =  lock_out;

    assign SERDESSTROBE = serdesstrobe_out;

//----------------------------------------------------------------------
//------------------------   Input Ports  ------------------------------
//----------------------------------------------------------------------
    assign gclk_in = GCLK;

    assign locked_in = LOCKED;

    assign pllin_in = PLLIN;


    initial begin
//-------------------------------------------------
//----- DIVIDE check
//-------------------------------------------------
        case (DIVIDE)
            1,2,3,4,5,6,7,8: begin
                attr_err_flag = 0;
                      end
            default : begin
                      $display("Attribute Syntax Error : The attribute DIVIDE on %s instance %m is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8.", MODULE_NAME, DIVIDE);
                      attr_err_flag = 1;
                      end
        endcase // (DIVIDE)

        //-------- ENABLE_SYNC

        case (ENABLE_SYNC)
            "TRUE", "FALSE" : ;
            default : begin
               $display("Attribute Syntax Error : The attribute ENABLE_SYNC on %s instance %m is set to %s.  Legal values for this attribute are TRUE or FALSE.",  MODULE_NAME, ENABLE_SYNC);
               attr_err_flag = 1;
            end
        endcase

//-------------------------------------------------
//------        Other Initializations      --------
//-------------------------------------------------

    if (attr_err_flag)
       begin
       #1;
       $finish;
       end


    end  // initial begin


// =======================================
// Generate SERDESSTROBE when ENABLE_SYNC 
// =======================================
    reg time_cal = 0;
    time clkin_edge = 0;
    time clkin_period = 0;
    time start_wait_time = 0;
    time end_wait_time = 0;

    always @(posedge pllin_in)
    begin
// CR 584404
      if (!locked_in && ((ENABLE_SYNC == "TRUE") || (time_cal == 1'b1)))
        begin
          time_cal <= 0;
          clkin_edge <= 0;
          clkin_period <= 0;
          start_wait_time <= 0;
          end_wait_time <= 0;
        end
      else if(time_cal == 0) begin
        clkin_edge <= $time;
         if (clkin_edge != 0 ) begin
           clkin_period = $time - clkin_edge;
           if (locked_in) time_cal <= 1;

           if (DIVIDE == 1) 
              start_wait_time <= (clkin_period)* (1.0/4.0);
           else
              start_wait_time <= (clkin_period)* (((2.0*(DIVIDE-1))-1)/4.0);
           end_wait_time <= clkin_period;
         end
      end
    end

    always @(posedge gclk_in)
    begin
        if(((time_cal == 1) || (ENABLE_SYNC == "FALSE")) && (start_wait_time > 0)) begin
          #start_wait_time;
          enable_sync_strobe_out <= 1'b1;
          if ( DIVIDE != 1) begin
              #end_wait_time;
              enable_sync_strobe_out <= 1'b0;
          end
        end
        else
          enable_sync_strobe_out <= 1'b0;
    end
 
             always @(negedge pllin_in) begin
                serdesstrobe_out <= enable_sync_strobe_out;
             end

    always @(pllin_in)
         ioclk_out <= pllin_in;

// =====================
// Generate LOCK 
// =====================
    always @(locked_in)
         lock_out <= locked_in;




//*** Timing Checks Start here

    specify
        ( PLLIN => IOCLK) = (0, 0);
        ( PLLIN => LOCK)  = (0, 0);
        ( PLLIN => SERDESSTROBE) = (100, 100);

    endspecify

endmodule // BUFPLL

