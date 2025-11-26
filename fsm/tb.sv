
//==================================
// Testbench fsm assertion based
// Module tb
//====================================


module tb_top;

  // Señales del DUT
  logic clk;
  logic rst;
  logic din;
  logic dout;

  // Instancia del DUT
  FSM dut (
    .clk(clk),
    .rst(rst),
    .din(din),
    .dout(dout)
  );

  // Clock signal 
  initial clk = 0;
  always #5 clk = ~clk; 

  // Auxiliary
  task reset_dut();
    rst = 1;
    din = 0;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
  endtask

  task apply_input(logic in);
    din = in;
    @(posedge clk);
  endtask

  // Main stimulus
  initial begin
    $display("Inicio de simulación");
    reset_dut();

    // Test sequence
    apply_input(0); // idle → s0
    apply_input(1); // s0 → s1
    apply_input(1); // s1 → s0, dout shall be 1
    apply_input(0); // s0 → s0
    apply_input(1); // s0 → s1
    apply_input(0); // s1 → s1
    apply_input(1); // s1 → s0, dout shall be 1

    // End of simulation
    #20;
    $finish;
  end

  // Monitor simple
  always @(posedge clk) begin
    $display("Time=%0t | rst=%b din=%b dout=%b", $time, rst, din, dout);
  end
  
  // Assertions
  
    // Clocking block for sync
  clocking cb @(posedge clk);
    input rst, din, dout;
  endclocking

  // Assertions block

  // After reset, the state should be 'idle'
  property p_reset_idle;
    @(posedge clk) rst |-> dut.state == dut.idle;
  endproperty
  assert property(p_reset_idle)
    else $error("FSM no entra en 'idle' tras reset");

  // 2. Transition from idle to s0 when rst == 0
  property p_idle_to_s0;
    @(posedge clk) dut.state == dut.idle && !rst |-> dut.next_state == dut.s0;
  endproperty
  assert property(p_idle_to_s0)
    else $error("FSM no transita de 'idle' a 's0' correctamente");

  // 3. In state s1 with din == 1, dout must be 1
  property p_s1_din1_dout1;
    @(posedge clk) dut.state == dut.s1 && din == 1 |-> dout == 1;
  endproperty
  assert property(p_s1_din1_dout1)
    else $error("FSM no genera 'dout == 1' en estado 's1' con 'din == 1'");

  // 4. In any other case, dout must be 0
  property p_dout_zero_else;
    @(posedge clk) !(dut.state == dut.s1 && din == 1) |-> dout == 0;
  endproperty
  assert property(p_dout_zero_else)
    else $error("FSM genera 'dout == 1' fuera de condición válida");

  // 5. Transition from s0 to s1 if din == 1
  property p_s0_to_s1;
    @(posedge clk) dut.state == dut.s0 && din == 1 |-> dut.next_state == dut.s1;
  endproperty
  assert property(p_s0_to_s1)
    else $error("FSM no transita de 's0' a 's1' con 'din == 1'");
  

endmodule
