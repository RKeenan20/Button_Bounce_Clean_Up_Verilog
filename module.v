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

                      reg [2:0] currentState, nextState; //States
                      wire delayPassed;                  //Output from the Counter/timer
                      reg timerStart;                    //Input to the counter for MUX

                      //Defining states as localparams
                      localparam [2:0]  IDLE = 3'b000,
                                        BTNPRESSED = 3'b001,
                                        DELAY1 = 3'b010,
                                        BTNstillPRESSED = 3'b011,
                                        BUTTONNOTPRESSED = 3'b100;

                      //State Register
                      always @(posedge clk5)
                          if(reset)
                            currentState <= IDLE;
                          else
                            currentState <= nextState;

                      //Next State Logic - Dependent on 2 inputs
                      always @(currentState, raw, delayPassed )
                        case(currentState)
                          3'b000: begin
                                    timerStart = 1'b0;    //Output to counter is zero
                                    if(raw)
                                      nextState = BTNPRESSED;  //Button is now pressed
                                    else
                                      nextState = IDLE;       //Loop in IDLE
                                  end
                          3'b001: begin
                                    nextState = DELAY1; //Pass straight through regardless of inputs
                                    timerStart = 1'b0;  //Not starting counter
                                  end
                          3'b010: begin
                                    timerStart = 1'b1;  //Start Counter
                                    if(!delayPassed)
                                      nextState = DELAY1; //Stay in state until 8ms has passed
                                    else
                                      nextState = BTNstillPRESSED;
                                  end
                          3'b011: begin
                                    timerStart = 1'b0;
                                    if(!raw)
                                      nextState = BUTTONNOTPRESSED; //Do not transition until user stops pressing button
                                    else
                                      nextState = BTNstillPRESSED;
                                  end
                          3'b100: begin
                                    timerStart = 1'b1; //Start counter again to compensate for bounce on release of button
                                    if(!delayPassed)
                                      nextState = BUTTONNOTPRESSED;
                                    else
                                      nextState = IDLE;
                                  end
                          default:begin
                                    nextState = IDLE;    //Compensating for the other states
                                    timerStart = 1'b0;
                                  end
                        endcase

                      //Instantiation of counter to count to 8ms and output a 1
                      countTimer delayCounter(.clk(clk5),.rst(reset),.timerStart(timerStart), .timerOut(delayPassed));

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
