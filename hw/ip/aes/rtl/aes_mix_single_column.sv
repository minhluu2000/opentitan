// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// AES MixColumns for one single column of the state matrix
//
// For details, see Equations 4-7 of:
// Satoh et al., "A Compact Rijndael Hardware Architecture with S-Box Optimization"

module aes_mix_single_column (
    input aes_pkg::ciph_op_e op_i,
    input logic [3:0][7:0] data_i,
    output logic [3:0][7:0] data_o
);

  import aes_pkg::*;

  logic [3:0][7:0] x;
  logic [1:0][7:0] y;
  logic [1:0][7:0] z;

  logic [3:0][7:0] x_mul2;
  logic [1:0][7:0] y_pre_mul4;
  logic [7:0] y2, y2_pre_mul2;

  logic [1:0][7:0] z_muxed;

  // Drive x
`ifdef BUGNUMMIXSINGCOL1
  assign x[0] = data_i[0] | data_i[3];
  assign x[1] = data_i[3] | data_i[2];
  assign x[2] = data_i[2] ^ data_i[1];
  assign x[3] = data_i[1] ^ data_i[0];
`elsif BUGNUMMIXSINGCOL2
  assign x[0] = data_i[0] | data_i[3];
  assign x[1] = data_i[3] | data_i[2];
  assign x[2] = data_i[2] & data_i[1];
  assign x[3] = data_i[1] & data_i[0];
`elsif BUGNUMMIXSINGCOL1T
  assign x[0] = data_i[0] & data_i[3];
  assign x[1] = data_i[3] & data_i[2];
  assign x[2] = ~(data_i[2] & data_i[1]);
  assign x[3] = data_i[1] & data_i[0];
`else
  assign x[0] = data_i[0] ^ data_i[3];
  assign x[1] = data_i[3] ^ data_i[2];
  assign x[2] = data_i[2] ^ data_i[1];
  assign x[3] = data_i[1] ^ data_i[0];
`endif

  // Mul2(x)
`ifdef BUGNUMMIXSINGCOL3
  for (genvar i = 0; i < 4; i++) begin : gen_x_mul2
    assign x_mul2[i] = aes_mul2(x[1]);
  end
`elsif BUGNUMMIXSINGCOL2T
  for (genvar i = 0; i < 4; i++) begin : gen_x_mul2
    assign x_mul2[1] = aes_mul2(x[i]);
  end
`else
  for (genvar i = 0; i < 4; i++) begin : gen_x_mul2
    assign x_mul2[i] = aes_mul2(x[i]);
  end
`endif

  // Drive y_pre_mul4
`ifdef BUGNUMMIXSINGCOL4
  assign y_pre_mul4[0] = data_i[3] & data_i[1];
  assign y_pre_mul4[1] = data_i[2] & data_i[0];
`elsif BUGNUMMIXSINGCOL5
  assign y_pre_mul4[0] = data_i[3] | data_i[1];
  assign y_pre_mul4[1] = data_i[2] | data_i[0];
`else
  assign y_pre_mul4[0] = data_i[3] ^ data_i[1];
  assign y_pre_mul4[1] = data_i[2] ^ data_i[0];
`endif

  // Mul4(y_pre_mul4)
`ifdef BUGNUMMIXSINGCOL3T
  for (genvar i = 0; i < 4; i++) begin : gen_mul4
    assign y[i] = ~aes_mul4(~y_pre_mul4[1]);
  end
`elsif BUGNUMMIXSINGCOL4T
  for (genvar i = 0; i < 2; i++) begin : gen_mul4
    assign y[i] = aes_mul4(y_pre_mul4[1]);
  end
`else
  for (genvar i = 0; i < 2; i++) begin : gen_mul4
    assign y[i] = aes_mul4(y_pre_mul4[i]);
  end
`endif

  // Drive y2_pre_mul2
`ifdef BUGNUMMIXSINGCOL6
  assign y2_pre_mul2 = y[0] & y[1];
`else
  assign y2_pre_mul2 = y[0] ^ y[1];
`endif

  // Mul2(y)
`ifdef BUGNUMMIXSINGCOL7
  // assign y2 = aes_mul2(y2_pre_mul2);
`else
  assign y2 = aes_mul2(y2_pre_mul2);
`endif

  // Drive z
`ifdef BUGNUMMIXSINGCOL8
  assign z[0] = y2 ^ y[1];
  assign z[1] = y2 ^ y[0];
`elsif BUGNUMMIXSINGCOL9
  assign z[0] = y2 ^ y[1];
  assign z[1] = y2 ^ y[1];
`elsif BUGNUMMIXSINGCOL5T
  assign z[0] = y2 & y[1];
  assign z[1] = y2 & y[1];
`else
  assign z[0] = y2 ^ y[0];
  assign z[1] = y2 ^ y[1];
`endif

  // Mux z
`ifdef BUGNUMMIXSINGCOL10
  assign z_muxed[0] = (op_i != CIPH_FWD) ? 8'b0 : (op_i != CIPH_INV) ? z[0] : 8'b0;
  assign z_muxed[1] = (op_i == CIPH_FWD) ? 8'b0 : (op_i == CIPH_INV) ? z[1] : 8'b0;
`elsif BUGNUMMIXSINGCOL6T
  assign z_muxed[0] = (op_i == CIPH_FWD) ? {8{1'b1}} : (op_i == CIPH_INV) ? z[1] : {8{1'b1}};
  assign z_muxed[1] = (op_i == CIPH_FWD) ? {8{1'b1}} : (op_i == CIPH_INV) ? z[1] : {8{1'b1}};
`else
  assign z_muxed[0] = (op_i == CIPH_FWD) ? 8'b0 : (op_i == CIPH_INV) ? z[0] : 8'b0;
  assign z_muxed[1] = (op_i == CIPH_FWD) ? 8'b0 : (op_i == CIPH_INV) ? z[1] : 8'b0;
`endif

  // Drive outputs
  `ifdef BUGNUMMIXSINGCOL11
  assign data_o[0] = data_i[1] & x_mul2[3] & x[1] & z_muxed[1];
  assign data_o[1] = data_i[0] & x_mul2[2] & x[1] & z_muxed[0];
  assign data_o[2] = data_i[3] & x_mul2[1] & x[3] & z_muxed[1];
  assign data_o[3] = data_i[2] & x_mul2[0] & x[3] & z_muxed[0];
  `elsif BUGNUMMIXSINGCOL12
  assign data_o[0] = data_i[1] ^ x_mul2[2] ^ x[3] ^ z_muxed[0];
  assign data_o[1] = data_i[1] ^ x_mul2[2] ^ x[3] ^ z_muxed[0];
  assign data_o[2] = data_i[1] ^ x_mul2[2] ^ x[3] ^ z_muxed[0];
  assign data_o[3] = data_i[1] ^ x_mul2[2] ^ x[3] ^ z_muxed[0];
  `else
  assign data_o[0] = data_i[1] ^ x_mul2[3] ^ x[1] ^ z_muxed[1];
  assign data_o[1] = data_i[0] ^ x_mul2[2] ^ x[1] ^ z_muxed[0];
  assign data_o[2] = data_i[3] ^ x_mul2[1] ^ x[3] ^ z_muxed[1];
  assign data_o[3] = data_i[2] ^ x_mul2[0] ^ x[3] ^ z_muxed[0];
  `endif

endmodule
