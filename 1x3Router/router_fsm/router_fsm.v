`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2025 10:45:15 PM
// Design Name: 
// Module Name: router_fsm
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


module router_fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,
                  soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,
                  write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
input [1:0] data_in;
output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
  
  
parameter decode_add     = 3'b000,
          load_first_data 	 = 3'b001,
          load_data 		 = 3'b010,
          wait_till_empty 	 = 3'b011,
          check_parity_error = 3'b100,
          load_parity 		 = 3'b101,
          fifo_full_state 	 = 3'b110,
          load_after_full 	 = 3'b111;
  
  reg [2:0] ps,ns;
          
  always@(posedge clock)
    begin
      if(!resetn)
        ps <= decode_add;
      else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
        ps <= decode_add;
      else 
        ps <= ns;
    end
  
  
  always@(*)
    begin
      ns = decode_add;
      case(ps)
        
        decode_add : 
                  begin
                    if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0)||
                       (pkt_valid && (data_in[1:0]==1) && fifo_empty_1)||
                       (pkt_valid && (data_in[1:0]==2) && fifo_empty_2))
                      
                      ns = load_first_data;
                    
                    else if((pkt_valid && (data_in[1:0]==0) && (~fifo_empty_0))||
                            (pkt_valid && (data_in[1:0]==1) && (~fifo_empty_1))||
                            (pkt_valid && (data_in[1:0]==2) && (~fifo_empty_2)))
                      
                      ns = wait_till_empty;
                    
                    else
                      ns = decode_add;
                  end
        
        load_first_data :  ns = load_data;
        
        load_data       : 
                        begin
			      			if(fifo_full)
				 				ns = fifo_full_state;
                          else if(!fifo_full && !pkt_valid)
				 				ns = load_parity;
			      			else
				 				ns = load_data;
			   			end 
        
        wait_till_empty  : 
                        begin
                          if((!fifo_empty_0) || (!fifo_empty_1) || (!fifo_empty_2))
				 			ns = wait_till_empty;
			      		  else if(fifo_empty_0||fifo_empty_1||fifo_empty_2)
				 			ns = load_first_data;
			      		  else
				 			ns = wait_till_empty;
                         end
        
        check_parity_error:
          				begin
			    			if(fifo_full)
			      	 			ns = fifo_full_state;
			    			else
			         			ns = decode_add;

			   			 end

       load_parity     	  :	ns = check_parity_error;
			 

       fifo_full_state	  :	   
          				begin
                        	if(!fifo_full)
			         			ns = load_after_full;
			      			else if(fifo_full)
			         			ns = fifo_full_state;
			  		 		end
        
        load_after_full:	   
          				begin
          					if((!parity_done) && (!low_packet_valid))
			   					ns = load_data;
          					else if((!parity_done) && (low_packet_valid))
			   					ns = load_parity;
          					else if(parity_done)
			   					ns = decode_add;
			   			 end
        
      endcase
   end
  
  assign detect_add = ((ps == decode_add)?1:0); 

  assign write_enb_reg=((ps == load_data||ps == load_parity|| ps == load_after_full)?1:0);
  assign full_state=((ps == fifo_full_state)?1:0);
  assign lfd_state=((ps == load_first_data)?1:0);
  assign busy=((ps == fifo_full_state||ps == load_after_full||ps == wait_till_empty||ps == load_first_data||ps == load_parity||ps == check_parity_error)?1:0);
  assign ld_state=((ps == load_data)?1:0);
  assign laf_state=((ps == load_after_full)?1:0);
  assign rst_int_reg=((ps== check_parity_error)?1:0);
  
endmodule
  
  
