module alu(
	input wire [7:0] op_a,  // Operand A
	input wire [7:0] op_b,  // Operand B
	input wire [2:0] alu_op,  //  3-bit ALU操作碼
        output reg [7:0] result,  // ALU結果
	output wire zero         // Zero flag(結果是否為0)
);

assign zero = (result == 8'd0);  // Zero flag判斷

// ALU運算邏輯
always @(*) begin
  case (alu_op)
    3'b000: result = op_a + op_b;  // ADD
    3'b001: result = op_a - op_b;  // SUB
    3'b010: result = op_a * op_b;  // MUL
    3'b011: result = op_a << 1;  // SHL (Logical Shift Left)
    3'b100: result = op_a >> 1;  // SHR (Logical Shift Right)
    3'b101: result = (op_a == op_b)? 8'd0: 8'd1;  // Compare (BEQ用途)
    default: result = 8'd0;      // Default safe value 
  endcase
end
endmodule