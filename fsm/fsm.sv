//=========================================================
// Module: FSM
// Description: Sequential Finite State Machine (FSM)
// with three states (idle, s0, s1), controlled by 'din'.
// The output 'dout' is activated only in state s1 with din=1.
//=========================================================

module fsm (
  input  logic clk,    
  input  logic rst,       
  input  logic din,       
  output logic dout);     

 
  // Defining states through enumeration

 typedef enum logic [2:0] {
    idle = 3'b001,         // Initial state after reset
    s0   = 3'b010,         // Intermediate state with no output
    s1   = 3'b100          // State that can generate a high output
  } state_t;

  state_t state, next_state;

  // Sequential logic: state transition
  
  always_ff @(posedge clk) begin
    if (rst)
      state <= idle;      
    else
      state <= next_state; // Update status
  end

  // Combinational logic: next state and output calculation
  
  always_comb begin
    // Default values
    next_state = idle;
    dout       = 1'b0;

    case (state)
      // IDLE state: transition to S0 if rst is disabled
      idle: begin
        dout = 1'b0;
        if (rst)
          next_state = idle;
        else
          next_state = s0;
      end

      // State S0: transition to S1 if din=1, remains if din=0
      s0: begin
        if (din) begin
          next_state = s1;
          dout = 1'b0;
        end else begin
          next_state = s0;
          dout = 1'b0;
        end
      end

      // State S1: transition to S0 if din=1 (dout=1), remains if din=0
      s1: begin
        if (din) begin
          next_state = s0;
          dout = 1'b1; // Única condición donde dout=1
        end else begin
          next_state = s1;
          dout = 1'b0;
        end
      end

      // Default state: return to IDLE
      default: begin
        next_state = idle;
        dout = 1'b0;
      end
    endcase
  end

endmodule
