module control_unit (
	input wire clk,
	input wire rst_n,
	input wire [7:0] instr,  //從指令記憶體拿到的指令
                 input wire zero,         // 來自ALU的Zero Flag(for BEQ)
	output reg we_a,        //寫入Reg A使能
	output reg we_b,        //寫入Reg B使能
	output reg [2:0] alu_op,      // 2-bit ALU操作碼
	output reg do_alu,      //執行ALU
	output reg do_store,    // STORE啟用
	output reg [3:0] next_pc  //程式計數器
);

//狀態定義
localparam IDLE = 2'd0;
localparam FETCH = 2'd1;
localparam DECODE = 2'd2;
localparam EXECUTE = 2'd3;

reg [1:0] state, next_state;

//狀態轉移邏輯
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    state <= IDLE;
  else
    state <= next_state;
end

//次態轉移邏輯
always @ (*) begin
  case (state)
    IDLE: next_state = FETCH;
    FETCH: next_state = DECODE;
    DECODE: next_state = EXECUTE;
    EXECUTE: next_state = FETCH;
    default: next_state = IDLE;
  endcase
end

//控制信號邏輯
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
     we_a <= 0;
     we_b <= 0;
     alu_op <= 3'b000;
     do_alu <= 0;
     do_store <= 0;
     next_pc <= 4'd0;
  end else begin
    case  (state)
        FETCH: begin
              //預設控制訊號
              we_a <= 0;
              we_b <= 0;
              alu_op <= 3'b000;
              do_alu <= 0;
              do_store <= 0;
              next_pc <= next_pc + 1;
        end

        DECODE: begin
	      //預設清除控制訊號
	      we_a <= 0;
	      we_b <= 0;
	      alu_op <= 3'b000;
	      do_alu <= 0;
	      do_store <= 0;

	      //根據instr[7:4]解碼
	      case (instr[7:4])
	          4'b0001: we_a <= 1;  // LOAD A
                  4'b0010: we_b <= 1;  // LOAD B
                  4'b0100: begin alu_op <= 3'b000; do_alu <= 1; end  // ADD
                  4'b0101: begin alu_op <= 3'b001; do_alu <= 1; end  // SUB
                  4'b0110: begin alu_op <= 3'b010; do_alu <= 1; end  // AND
                  4'b0111: begin alu_op <= 3'b011; do_alu <= 1; end  // OR
                  4'b1000: begin alu_op <= 3'b100; do_alu <= 1; end  // MUL
                  4'b1001: begin alu_op <= 3'b101; do_alu <= 1; end  // SHL
                  4'b1010: begin alu_op <= 3'b110; do_alu <= 1; end  // SHR
                  4'b1011: begin                                     // BEQ(branch if equal)
                      alu_op <= 3'b111;   // CMP操作
                      do_alu <= 1;
                      if (zero) 
                          next_pc <= instr[3:0];   //若A == B,跳躍
                  end
                  4'b1100: do_store <= 1;   // STORE
                  default: ;  // do nothing
              endcase
        end
     
        EXECUTE: begin
             //清除控制訊號
             we_a <= 0;
             we_b <= 0;
             do_alu <= 0;
             do_store <= 0;
        end
    endcase
  end
end
endmodule
