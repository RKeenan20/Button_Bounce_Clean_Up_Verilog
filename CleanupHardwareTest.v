//////////////////////////////////////////////////////////////////////////////////
// Company:       UCD School of Electrical and Electronic Engineering
// Engineer:      Brian Mulkeen
// Project:       Switch Signal Cleanup
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   Top-level module to act as hardware testbench for cleanup block.
//                Defines top-level input and output signals (see comments on ports).
//                Instantiates clock and reset generator block, for 5 MHz clock.
//                Instantiates the a counter and display interface, and the cleanup 
//                block to be tested.
//                Provides output signals for viewing on oscilloscope.
//  Created: 20 October 2017
//////////////////////////////////////////////////////////////////////////////////
module CleanupHardwareTest(
        input clk100,        // 100 MHz clock from oscillator on board
        input rstPBn,        // reset signal, active low, from CPU RESET pushbutton
        input btnU, btnD,    // up and down signals from pushbuttons, active high
        input [1:0] sw,      // up and down signals from switches
        output [3:0] JA,     // output for viewing on oscilloscope
        output [7:0] digit,  // digit controls - active low (7 on left, 0 on right)
        output [7:0] segment // segment controls - active low (a b c d e f g dp)
        );

// ===========================================================================
// Interconnecting Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire reset;             // internal reset signal, active high
    wire [15:0] count;      // counter output signal
    wire up, down;          // counter control signals
    wire upIn, downIn;      // raw control signals from inputs

// ===========================================================================
// Assign signals to the test port for viewing on oscilloscope
    assign JA = {up, down, upIn, downIn};
        
// ===========================================================================
// Generate the input signals, using a combination of switch and pushbutton
    assign upIn = btnU | sw[1];     // up input from BTNU button or switch 1
    assign downIn = btnD | sw[0];   // down input from BTND button or switch 0
    
// ===========================================================================
// Instantiate your cleanup module here, once for each input signal.
    assign up = upIn;       // remove this assignment, replace it with cleanup
    assign down = downIn;   // remove this assignment, replace it with cleanup

// ===========================================================================
// Instantiate clock and reset generator, connect to signals
    clockReset  clkGen  (
            .clk100 (clk100),       // input clock at 100 MHz
            .rstPBn (rstPBn),       // input reset, active low
            .clk5   (clk5),         // output clock, 5 MHz
            .reset  (reset) );      // output reset, active high

//=====================================================================================
// Instantiate 16-bit up-down counter
    countUpDown  counter  (
            .clk (clk5),      // clock signal at 5 MHz
            .rst (reset),     // reset input
            .up  (up),        // count up if 1
            .dn  (down),      // count down on rising edge
            .count (count) ); // counter output

// ==================================================================================
// Instantiate your display interface here.  Use count as the value to be displayed.
    DisplayInterface disp1 (
                .clock(clk5),       // 5 MHz clock signal
                .reset(reset),      // reset signal, active high
                .value(count),      // value to be displayed
                .digit(digit),      // digit outputs
                .segment(segment)); // segment outputs
     
endmodule
