
module mem_map(/*autoport*/
//output
         addr_o,
         invalid,
         using_tlb,
         uncached,
//input
         addr_i,
         en,
         um);
input wire[31:0] addr_i;
output reg[31:0] addr_o;
input wire en;
input wire um;
output wire invalid;
output reg using_tlb;
output wire uncached;

assign invalid = (en & um & addr_i[31]);
assign uncached = addr_i[31:29] == 3'b101;
always @(*) begin
    using_tlb <= 1'b0;
    addr_o <= 32'b0;
    if (en) begin
        casez(addr_i[31:29])
        3'b110,         //kseg2
        3'b111,         //kseg3
		  3'b000,
		  3'b001,
		  3'b010,
		  3'b011: begin   //useg
            using_tlb <= 1'b1;
        end
        3'b100,         //kseg0
        3'b101: begin   //kseg1
            addr_o <= {3'b0, addr_i[28:0]};
        end
        endcase
    end
end

endmodule
