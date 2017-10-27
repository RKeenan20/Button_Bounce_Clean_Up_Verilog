//
//Company:     UCD School of Electrical and Electronic Engineering
// Engineer:    Brian Mulkeen
//
// Module Name:    counterUpDown
// Project Name:   Cleanup Hardware test system
// Create Date:    17:27:47 09/28/2012
// Revision 1:     20 October 2017, comments modified
//
// Our Button Clean up module so we can prevent/ignore bounce
// We have instantiated a counter module for which we will use for delays to ignore possible bounce.


module buttonCleanup( input clk5,
                      input reset,
                      input raw,
                      output reg clean );

                      (* dont_touch = "true" *)reg [2:0] currentState, nextState;
                      wire enableSample;
                      reg timerStart;

                      localparam [2:0]  IDLE = 3'b000,
                                        BTNPRESSED = 3'b001,
                                        DELAY1 = 3'b010,
                                        SAMPLETIME = 3'b011,
                                        BUTTONNOTPRESSED = 3'b100;


                      always @(posedge clk5, posedge reset)
                          if(reset)
                            currentState <= IDLE;
                          else
                            currentState <= nextState;

                      //Next State Logic
                      always @(currentState, raw, enableSample )
                        case(currentState)
                          3'b000: begin
                                    timerStart = 1'b0;
                                    if(raw)
                                      nextState = BTNPRESSED;
                                    else
                                      nextState = IDLE;
                                  end
                          3'b001: begin
                                    nextState = DELAY1;
                                    timerStart = 1'b0;
                                  end
                          3'b010: begin
                                    timerStart = 1'b1;
                                    if(!enableSample)
                                      nextState = DELAY1;
                                    else
                                      nextState = SAMPLETIME;
                                  end
                          3'b011: begin
                                    timerStart = 1'b0;
                                    if(!raw)
                                      nextState = BUTTONNOTPRESSED;
                                    else
                                      nextState = SAMPLETIME;
                                  end
                          3'b100: begin
                                    timerStart = 1'b1;
                                    if(!enableSample)
                                      nextState = BUTTONNOTPRESSED;
                                    else
                                      nextState = IDLE;
                                  end
                          default:begin
                                    nextState = IDLE; //Compensating for the other states
                                    timerStart = 1'b0;
                                  end
                        endcase


                      countTimer delayCounter(.clk(clk5),.rst(reset),.enable(timerStart), .enableSample(enableSample));

                      //Output Logic - > Only one output from our module but two from our state machine.
                      always @(currentState)
                        case(currentState)
                          3'b000: clean = 1'b0;
                          3'b001: clean = 1'b1;
                          3'b010: clean = 1'b0;
                          3'b011: clean = 1'b0;
                          3'b100: clean = 1'b0;
                          default: clean = 1'b0;
                        endcase

endmodule
