//////////////////////////////////////////////////////////////////////////////////
// Company:     UCD School of Electrical and Electronic Engineering
// Engineer:    Brian Mulkeen
//
// Module Name:    counterUpDown
// Project Name:   Cleanup Hardware test system
// Create Date:    17:27:47 09/28/2012
// Revision 1:     20 October 2017, comments modified
//
// This is a 16-bit up-down counter with separate control signals for up and down.
// For demonstration purposes, it has an edge detector on the down control.
//
//////////////////////////////////////////////////////////////////////////////////
module countTimer(
        input clk,              // clock signal
        input rst,              // reset, synchronous, active high
        input enable,
        output enableSample );  // count output

    localparam comparator = 39999;
    reg [15:0] nextCount;      // next count value
    //  Count register
    always @ (posedge clk)
        if (rst) count <= 16'd0;
        else count <= nextCount;

    //Input Mux
    always @(enable, count)
        case(enable)
            1'b1: nextCount = count + 1'b1;
            1'b0: nextCount = 16'b0;
        endcase

    if(count == comparator)
        assign enableSample = 1'b1;
    else
        assign enableSample = 1'b0;

endmodule
