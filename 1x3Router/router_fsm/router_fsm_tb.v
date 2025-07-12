`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 06:25:04 PM
// Design Name: 
// Module Name: router_fsm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module router_fsm_tb();

reg clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
reg [1:0] data_in;
wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

parameter cycle=10;

router_fsm DUT(.clock(clock),.resetn(resetn),.pkt_valid(pkt_valid),.data_in(data_in),.fifo_full(fifo_full),.fifo_empty_0(fifo_empty_0),.fifo_empty_1(fifo_empty_1),.fifo_empty_2(fifo_empty_2),.soft_reset_0(soft_reset_0),.soft_reset_1(soft_reset_1),.soft_reset_2(soft_reset_2),.parity_done(parity_done),.low_packet_valid(low_packet_valid),.write_enb_reg(write_enb_reg),.detect_add(detect_add),.ld_state(ld_state),.laf_state(laf_state),.lfd_state(lfd_state),.full_state(full_state),.rst_int_reg(rst_int_reg),.busy(busy));
  
  parameter decode_addr       = 3'b000,
            load_first_data 	 = 3'b001,
            load_data 		     = 3'b010,
            wait_till_empty 	 = 3'b011,
            check_parity_error   = 3'b100,
            load_parity 		 = 3'b101,
            fifo_full_state 	 = 3'b110,
            load_after_full 	 = 3'b111;
  
  reg [3*8:0]string_cmd;

  always@(DUT.ps)
      begin
        case (DUT.ps)
	    decode_addr     :  string_cmd = "DA";
	    load_first_data    :  string_cmd = "LFD";
	    load_data    	   :  string_cmd = "LD";
	    wait_till_empty    :  string_cmd = "WTE";
	    check_parity_error :  string_cmd = "CPE";
	    load_parity   	   :  string_cmd = "LP";
	    fifo_full_state    :  string_cmd = "FFS";
	    load_after_full    :  string_cmd = "LAF";
	    endcase
      end
  
  
  
   initial
   begin
    clock=1'b1;
    forever #cycle clock = ~clock;
   end

   task initialize;
   begin
   {pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full,parity_done,low_packet_valid}=0;
   end
   endtask

   task rst;
   begin
   @(negedge clock)
    resetn=1'b0;
   @(negedge clock)
    resetn=1'b1;
   end
   endtask

   task t1;
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end              
   @(negedge clock) //LD
   @(negedge clock) //LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask

   task t2;
   begin
   @(negedge clock)//LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end
   @(negedge clock)//LD
   @(negedge clock)//FFS
   fifo_full<=1;
   @(negedge clock)//LAF
   fifo_full<=0;
   @(negedge clock)//LP
   begin
   parity_done<=0;
   low_packet_valid<=1;
   end
   @(negedge clock)//CPE
   @(negedge clock)//DA
   fifo_full<=0;
   end
   endtask

   task t3;
   begin
   @(negedge clock) //LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end
   @(negedge clock) //LD
   @(negedge clock) // FFS
   fifo_full<=1;
   @(negedge clock) // LAF
   fifo_full<=0;
   @(negedge clock)  // LD
   begin
      low_packet_valid<=0;
	parity_done<=0;

   end  // LP
   @(negedge clock)
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask
   
   task t4;
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end        
   @(negedge clock)   // LD
   @(negedge clock)   // LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock)   // CPE 
   @(negedge clock)   // FFS
   fifo_full<=1;
   @(negedge clock)   // LAF
   fifo_full<=0;
  @(negedge clock)    // DA
   parity_done=1;
   end
   endtask


   initial
   begin
   rst;
   initialize;
  
    t1;
	rst;
	#30
    t2;
	rst;
	#30
	t3;
	rst;
	#30
    t4;
	rst;
   
   end

  initial $monitor("Reset=%b, State=%s, det_add=%b, write_enb_reg=%b, full_state=%b, lfd_state=%b, busy=%b, ld_state=%b, laf_state=%b, rst_int_reg=%b, low_packet_valid=%b",resetn,string_cmd,detect_add,write_enb_reg,full_state,lfd_state,busy,ld_state,laf_state,rst_int_reg,low_packet_valid);
   
   initial
   begin
   $dumpfile("router_fsm.vcd");
   $dumpvars();
   #1000 $finish;
   end
   endmodule 