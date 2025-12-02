// Assertion module
// assert_fifo.sv

module assert_fifo (
  input clk, rst, wr, rd, 
  input [7:0] din,input [7:0] dout,
  input empty, full);
  
  
  // 1.0 status of full and empty flags when rst asserted

  // 1.1 Check on edge
  
   RST_1: assert property (@(posedge clk) $rose(rst) |-> (full == 1'b0 && empty == 1'b1))$info("A1 Suc at %0t",$time);
   
  // 1.2. Check on level
   
   RST_2: assert property (@(posedge clk) rst |-> (full == 1'b0 && empty == 1'b1))$info("A2 Suc at %0t",$time);  
  
  // 2.0 operation of full and empty flag
     
   FULL_1: assert property (@(posedge clk) disable iff(rst) $rose(full) |=> (fifo.wrop == 0)[*1:$] ##1 !full)$info("full Suc at %0t",$time); 
   
   FULL_2 : assert property (@(posedge clk) disable iff(rst) (fifo.cnt == 15) |-> full)$info("full Suc at %0t",$time);
          
   EMPTY_1:  assert property (@(posedge clk) disable iff(rst) $rose(empty) |=> (fifo.rdop == 0)[*1:$] ##1 !empty)$info("full Suc at %0t",$time); 
   
   EMPTY_2: assert property (@(posedge clk) disable iff(rst) (fifo.cnt == 0) |-> empty)$info("empty Suc at %0t",$time); 
     
      
   //  3.0 Read while empty
  
    READ_EMPTY: assert property (@(posedge clk) disable iff(rst) empty |-> !rd)$info("Suc at %0t",$time);  

    // 4.0 Write while FULL
     
    WRITE_FULL: assert property (@(posedge clk) disable iff(rst) full |-> !wr)$info("Suc at %0t",$time);
  
      
    // 5.0 Write+Read pointer behavior with rd and wr signal

    // if wr high and full is low, wrop must incr
       
    WPTR1: assert property (@(posedge clk)  !rst && wr && !full |=> $changed(fifo.wrop));
         
    // if wr is low, wrop must constant
    WPTR2: assert property (@(posedge clk) !rst && !wr |=> $stable(fifo.wrop));
    
    // if rd is high, wrop must stay constant
    WPTR3: assert property (@(posedge clk)  !rst && rd |=> $stable(fifo.wrop)) ;
    
    RPTR1: assert property (@(posedge clk)  !rst && rd && !empty |=> $changed(fifo.rdop));
         
    RPTR2: assert property (@(posedge clk) !rst && !rd |=> $stable(fifo.rdop));
    
    RPTR3: assert property (@(posedge clk)  !rst && wr |=> $stable(fifo.rdop));
 
    // 6.0 State of all the i/o ports for all clock edge
  
  always@(posedge clk)
    begin
      assert (!$isunknown(dout));
      assert (!$isunknown(rst));
      assert (!$isunknown(wr));
      assert (!$isunknown(rd));
      assert (!$isunknown(din));
    end

   /// 7.0 Data must match
    
   property p1;
     integer waddr;
     logic [7:0] data;

     (wr, waddr = tb.i, data = din) |-> ##[1:30] rd ##0 (waddr == tb.i - 1, $display("din: %0d dout :%0d",data, dout));
   endproperty
  
  assert property (@(posedge clk) disable iff(rst) p1) $info("Suc at %0t",$time);

endmodule