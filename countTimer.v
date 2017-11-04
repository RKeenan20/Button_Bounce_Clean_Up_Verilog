//////////////////////////////////////////////////////////////////////////////////
// Company:     UCD School of Electrical and Electronic Engineering
// Engineer:    Robert Keenan & Ciaran Nolan
//
// Module Name:    countTimer
// Project Name:   Button Signal Cleanup

//////////////////////////////////////////////////////////////////////////////////
module countTimer(
        input clk,              // clock signal
        input rst,              // reset, synchronous, active high
        input timerStart,           //Enable to start the counter
        output reg timerOut );  //Output 1 when 8ms has passed, 0 otherwise

    localparam comparator = 39999;  //Comparator Value to count to 8ms and then output
    reg [15:0] nextCount;      //next count value

    //  Count register - 16 bit
    always @ (posedge clk)
        if (rst) count <= 16'b0;
        else count <= nextCount;

    //Input Mux - Dependent on the Start Value from the State Machine
    always @(timerStart, count)
        case(timerStart)
            1'b1: nextCount = count + 1'b1;
            1'b0: nextCount = 16'b0;
        endcase
    //Comparator
    always @(count)
        if(count == comparator) timerOut = 1'b1;    //IF count==39999, output 1
        else timerOut = 1'b0;

endmodule
