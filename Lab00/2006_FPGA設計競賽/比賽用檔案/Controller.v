//*************************************************
//** 2019 spring iVCAD
//** Description: System controller
//** Mar. 2018 Henry authored
//** Mar. 2019 Kevin revised
//*************************************************

`timescale 1ns/10ps

module Controller (clk, reset, nt, busy, po);

  parameter INIT = 2'b00;
  parameter READ = 2'b01;
  parameter OPER = 2'b10;
  parameter WRITE = 2'b11;

  input         clk;
  input         reset;
  input         nt;
  
  output 		busy;
  output        po;

  reg    		busy;
  reg           po;
  
  reg    [1:0]  cstate;
  reg    [1:0]  nstate;

  always @(posedge clk or posedge rst) begin
    if (rst) 
    begin
      cstate <= INIT;
    end
    else
      cstate <= nstate;	  
  end

  always @(posedge clk or posedge rst) begin
	if(rst)
	begin
	  RAM_A <= 16'd0;
	end
	else if(cstate == WRITE) begin
	  RAM_A <= RAM_A + 16'd1;
	end
	else begin
	  RAM_A <= RAM_A;
	end
  end

  always @(*) begin
    case (cstate)
      INIT:
      begin
        //RAM_A = 16'd0;
        ROM_A = 14'd0;
        nstate = READ;
        ROM_OE = 1'b0;
        RAM_WE = 1'b0;
        RAM_OE = 1'b0;
        done = 1'b0;
      end
      READ:
      begin
        //RAM_A = RAM_A + 16'd1;
        ROM_A = {RAM_A[15:9],RAM_A[7:1]};
        nstate = WRITE;
        ROM_OE = 1'b1;
        RAM_WE = 1'b0;
        RAM_OE = 1'b1;
        done = 1'b0;		
      end
      WRITE:
      begin
	if(RAM_A == 16'hffff)begin nstate = FINAL; end
	else  begin nstate = READ; end
	//RAM_A = RAM_A;
	ROM_A = ROM_A;
	ROM_OE = 1'b1;
        RAM_WE = 1'b1;
        RAM_OE = 1'b1;
        done = 1'b0;
      end
      FINAL:
      begin
	ROM_OE = 1'b0;
        RAM_WE = 1'b0;
        RAM_OE = 1'b0;
        done = 1'b1;
        nstate = FINAL;
	  //RAM_A = RAM_A;
	  ROM_A = ROM_A;
      end
    endcase
  end
endmodule

