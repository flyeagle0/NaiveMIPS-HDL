`default_nettype none
module mmu_top(/*autoport*/
//output
     data_address_o,
     inst_address_o,
     data_uncached,
     inst_uncached,
     data_exp_miss,
     inst_exp_miss,
     data_exp_illegal,
     inst_exp_illegal,
     data_exp_dirty,
     data_exp_invalid,
     inst_exp_invalid,
     tlbp_result,
//input
     rst_n,
     clk,
     data_address_i,
     inst_address_i,
     data_en,
     inst_en,
     user_mode,
     tlb_config,
     tlbwi,
     tlbp,
     asid);

input wire rst_n;
input wire clk;

input wire[31:0] data_address_i;
input wire[31:0] inst_address_i;
input wire data_en;
input wire inst_en;

input wire user_mode;

output wire[31:0] data_address_o;
output wire[31:0] inst_address_o;
output wire data_uncached;
output wire inst_uncached;
output wire data_exp_miss;
output wire inst_exp_miss;
output wire data_exp_illegal;
output wire inst_exp_illegal;
output wire data_exp_dirty;
output wire data_exp_invalid;
output wire inst_exp_invalid;

input wire[83:0] tlb_config;
input wire tlbwi;
input wire tlbp;
input wire[7:0] asid;

output wire[31:0] tlbp_result;

wire data_tlb_map, inst_tlb_map;
wire data_miss, inst_miss, data_dirty;
wire data_valid, inst_valid;

wire[31:0] data_address_direct;
wire[31:0] inst_address_direct;

wire[31:0] data_address_tlb;
wire[31:0] inst_address_tlb;

assign data_exp_miss = (data_miss && data_tlb_map);
assign data_exp_dirty = (data_dirty || !data_tlb_map);
assign data_exp_invalid = (~data_valid & data_tlb_map);
assign inst_exp_miss = (inst_miss && inst_tlb_map);
assign inst_exp_invalid = (~inst_valid & inst_tlb_map);
assign data_address_o = data_tlb_map ? data_address_tlb : data_address_direct;
assign inst_address_o = inst_tlb_map ? inst_address_tlb : inst_address_direct;

mem_map map_inst(/*autoinst*/
           .addr_o(inst_address_direct),
           .invalid(inst_exp_illegal),
           .addr_i(inst_address_i),
           .using_tlb(inst_tlb_map),
           .uncached(inst_uncached),
           .en(inst_en),
           .um(user_mode));
mem_map map_data(/*autoinst*/
           .addr_o(data_address_direct),
           .invalid(data_exp_illegal),
           .addr_i(data_address_i),
           .using_tlb(data_tlb_map),
           .uncached (data_uncached),
           .en(data_en),
           .um(user_mode));

tlb tlb0(
  .tlbConfig(tlb_config),
  .tlbwi(tlbwi),
  .tlbp(tlbp),
  .tlbp_result(tlbp_result),

  .dataDirt(data_dirty),
  .insDirt (),

  .insValid (inst_valid),
  .dataValid(data_valid),

  .nowASID(asid),

  .dataAddrVirt(data_address_i),
  .insAddrVirt(inst_address_i),

  .dataMiss(data_miss),
  .insMiss(inst_miss),

  .dataAddrPhy(data_address_tlb),
  .insAddrPhy(inst_address_tlb),

  .rst_n(rst_n),
  .clk(clk)
);

endmodule
