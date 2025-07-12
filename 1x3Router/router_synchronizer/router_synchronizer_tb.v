`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2025 11:28:33 PM
// Design Name: 
// Module Name: router_synchronizer_tb
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


module router_synchronizer_tb();
reg clock,resetn,detect_add,write_enb_reg;
reg [1:0]data_in;
reg full_0,full_1,full_2;
reg empty_0,empty_1,empty_2;
reg read_enb_0,read_enb_1,read_enb_2;
wire [2:0]write_enb;
wire soft_reset_0,soft_reset_1,soft_reset_2;
wire fifo_full;
wire vld_out_0,vld_out_1,vld_out_2;

parameter cycle = 10;


router_synchronizer dut (.clock(clock),.resetn(resetn),.detect_add(detect_add),.write_enb_reg(write_enb_reg),.data_in(data_in),.full_0(full_0)
,.full_1(full_1),.full_2(full_2),.empty_0(empty_0),.empty_1(empty_1),.empty_2(empty_2),.read_enb_0(read_enb_0),.read_enb_1(read_enb_1),.read_enb_2(read_enb_2)
,.write_enb(write_enb),.soft_reset_0(soft_reset_0),.soft_reset_1(soft_reset_1),.soft_reset_2(soft_reset_2),.fifo_full(fifo_full),.vld_out_0(vld_out_0),.vld_out_1(vld_out_1),.vld_out_2(vld_out_2));

initial begin
    clock = 0;
    forever #(cycle/2) clock =~ clock;
  end 
  
  //initialization 
  
  task initialize();
    begin 
         {detect_add,data_in,full_0,full_1,full_2}=0;
         {write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2}=0;
    end 
  endtask
  
    
  // reset
  task rst();
  begin     
    @(negedge clock)
        resetn = 0;
     @(negedge clock)
        resetn = 1;
   end 
  endtask
  
  //  read enable 
  task read_enable(input r1,r2,r3);
  begin 
    {read_enb_0,read_enb_1,read_enb_2}= {r1,r2,r3};
  end
  endtask
  
  //task input and detect address
  task detect_ad(input [1:0]d1,input detect_add1);
  begin 
        data_in<= d1;
        detect_add <= detect_add1;
  end 
  endtask 
  
  //fifo full
  
  task fifofull(input f1,f2,f3);
  begin 
    full_0 <= f1;
    full_1 <= f2;
    full_2 <= f3;
 end 
 endtask 
 
 //fifo empty 
 task fifo_empty(input e1,e2,e3);
 begin 
    empty_0 <= e1;
    empty_1 <= e1;
    empty_2 <= e3;
 end 
 endtask 
 
 // write enable reg
 
 task write_reg(input w1);
 begin 
    write_enb_reg <= w1;
 end 
 endtask 
 
 initial begin 
    initialize();
    rst();
    @(negedge clock)
    read_enable(1,1,0);
    detect_ad(2'b10,1);
    fifofull(0,0,0);
    write_reg(1);
    fifo_empty(0,0,0);
    
    #1000;
    end 
initial begin 
$dumpfile("router_sync.vcd");
$dumpvars();
end 
endmodule
