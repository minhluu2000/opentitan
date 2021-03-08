// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package lc_ctrl_reg_pkg;

  // Param list
  parameter int NumTokenWords = 4;
  parameter int CsrLcStateWidth = 4;
  parameter int CsrLcCountWidth = 5;
  parameter int CsrLcIdStateWidth = 2;
  parameter int NumDeviceIdWords = 8;
  parameter int NumAlerts = 2;

  // Address widths within the block
  parameter int BlockAw = 7;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_prog_error;
    struct packed {
      logic        q;
      logic        qe;
    } fatal_state_error;
  } lc_ctrl_reg2hw_alert_test_reg_t;

  typedef struct packed {
    logic [7:0]  q;
    logic        qe;
  } lc_ctrl_reg2hw_claim_transition_if_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_cmd_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_token_mreg_t;

  typedef struct packed {
    logic [3:0]  q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_target_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } ready;
    struct packed {
      logic        d;
    } transition_successful;
    struct packed {
      logic        d;
    } transition_count_error;
    struct packed {
      logic        d;
    } transition_error;
    struct packed {
      logic        d;
    } token_error;
    struct packed {
      logic        d;
    } flash_rma_error;
    struct packed {
      logic        d;
    } otp_error;
    struct packed {
      logic        d;
    } state_error;
    struct packed {
      logic        d;
    } otp_partition_error;
  } lc_ctrl_hw2reg_status_reg_t;

  typedef struct packed {
    logic [7:0]  d;
  } lc_ctrl_hw2reg_claim_transition_if_reg_t;

  typedef struct packed {
    logic        d;
  } lc_ctrl_hw2reg_transition_regwen_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_transition_token_mreg_t;

  typedef struct packed {
    logic [3:0]  d;
  } lc_ctrl_hw2reg_transition_target_reg_t;

  typedef struct packed {
    logic [3:0]  d;
  } lc_ctrl_hw2reg_lc_state_reg_t;

  typedef struct packed {
    logic [4:0]  d;
  } lc_ctrl_hw2reg_lc_transition_cnt_reg_t;

  typedef struct packed {
    logic [1:0]  d;
  } lc_ctrl_hw2reg_lc_id_state_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_device_id_mreg_t;

  // Register -> HW type
  typedef struct packed {
    lc_ctrl_reg2hw_alert_test_reg_t alert_test; // [151:148]
    lc_ctrl_reg2hw_claim_transition_if_reg_t claim_transition_if; // [147:139]
    lc_ctrl_reg2hw_transition_cmd_reg_t transition_cmd; // [138:137]
    lc_ctrl_reg2hw_transition_token_mreg_t [3:0] transition_token; // [136:5]
    lc_ctrl_reg2hw_transition_target_reg_t transition_target; // [4:0]
  } lc_ctrl_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    lc_ctrl_hw2reg_status_reg_t status; // [416:408]
    lc_ctrl_hw2reg_claim_transition_if_reg_t claim_transition_if; // [407:400]
    lc_ctrl_hw2reg_transition_regwen_reg_t transition_regwen; // [399:399]
    lc_ctrl_hw2reg_transition_token_mreg_t [3:0] transition_token; // [398:271]
    lc_ctrl_hw2reg_transition_target_reg_t transition_target; // [270:267]
    lc_ctrl_hw2reg_lc_state_reg_t lc_state; // [266:263]
    lc_ctrl_hw2reg_lc_transition_cnt_reg_t lc_transition_cnt; // [262:258]
    lc_ctrl_hw2reg_lc_id_state_reg_t lc_id_state; // [257:256]
    lc_ctrl_hw2reg_device_id_mreg_t [7:0] device_id; // [255:0]
  } lc_ctrl_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] LC_CTRL_ALERT_TEST_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] LC_CTRL_STATUS_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] LC_CTRL_CLAIM_TRANSITION_IF_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_REGWEN_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_CMD_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_TOKEN_0_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_TOKEN_1_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_TOKEN_2_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_TOKEN_3_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] LC_CTRL_TRANSITION_TARGET_OFFSET = 7'h 24;
  parameter logic [BlockAw-1:0] LC_CTRL_LC_STATE_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] LC_CTRL_LC_TRANSITION_CNT_OFFSET = 7'h 2c;
  parameter logic [BlockAw-1:0] LC_CTRL_LC_ID_STATE_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_0_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_1_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_2_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_3_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_4_OFFSET = 7'h 44;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_5_OFFSET = 7'h 48;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_6_OFFSET = 7'h 4c;
  parameter logic [BlockAw-1:0] LC_CTRL_DEVICE_ID_7_OFFSET = 7'h 50;

  // Reset values for hwext registers and their fields
  parameter logic [1:0] LC_CTRL_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] LC_CTRL_ALERT_TEST_FATAL_PROG_ERROR_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_ALERT_TEST_FATAL_STATE_ERROR_RESVAL = 1'h 0;
  parameter logic [8:0] LC_CTRL_STATUS_RESVAL = 9'h 0;
  parameter logic [7:0] LC_CTRL_CLAIM_TRANSITION_IF_RESVAL = 8'h 0;
  parameter logic [0:0] LC_CTRL_TRANSITION_REGWEN_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_TRANSITION_REGWEN_TRANSITION_REGWEN_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_TRANSITION_CMD_RESVAL = 1'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_1_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_2_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_3_RESVAL = 32'h 0;
  parameter logic [3:0] LC_CTRL_TRANSITION_TARGET_RESVAL = 4'h 0;
  parameter logic [3:0] LC_CTRL_LC_STATE_RESVAL = 4'h 0;
  parameter logic [4:0] LC_CTRL_LC_TRANSITION_CNT_RESVAL = 5'h 0;
  parameter logic [1:0] LC_CTRL_LC_ID_STATE_RESVAL = 2'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_1_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_2_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_3_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_4_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_5_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_6_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_7_RESVAL = 32'h 0;

  // Register index
  typedef enum int {
    LC_CTRL_ALERT_TEST,
    LC_CTRL_STATUS,
    LC_CTRL_CLAIM_TRANSITION_IF,
    LC_CTRL_TRANSITION_REGWEN,
    LC_CTRL_TRANSITION_CMD,
    LC_CTRL_TRANSITION_TOKEN_0,
    LC_CTRL_TRANSITION_TOKEN_1,
    LC_CTRL_TRANSITION_TOKEN_2,
    LC_CTRL_TRANSITION_TOKEN_3,
    LC_CTRL_TRANSITION_TARGET,
    LC_CTRL_LC_STATE,
    LC_CTRL_LC_TRANSITION_CNT,
    LC_CTRL_LC_ID_STATE,
    LC_CTRL_DEVICE_ID_0,
    LC_CTRL_DEVICE_ID_1,
    LC_CTRL_DEVICE_ID_2,
    LC_CTRL_DEVICE_ID_3,
    LC_CTRL_DEVICE_ID_4,
    LC_CTRL_DEVICE_ID_5,
    LC_CTRL_DEVICE_ID_6,
    LC_CTRL_DEVICE_ID_7
  } lc_ctrl_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] LC_CTRL_PERMIT [21] = '{
    4'b 0001, // index[ 0] LC_CTRL_ALERT_TEST
    4'b 0011, // index[ 1] LC_CTRL_STATUS
    4'b 0001, // index[ 2] LC_CTRL_CLAIM_TRANSITION_IF
    4'b 0001, // index[ 3] LC_CTRL_TRANSITION_REGWEN
    4'b 0001, // index[ 4] LC_CTRL_TRANSITION_CMD
    4'b 1111, // index[ 5] LC_CTRL_TRANSITION_TOKEN_0
    4'b 1111, // index[ 6] LC_CTRL_TRANSITION_TOKEN_1
    4'b 1111, // index[ 7] LC_CTRL_TRANSITION_TOKEN_2
    4'b 1111, // index[ 8] LC_CTRL_TRANSITION_TOKEN_3
    4'b 0001, // index[ 9] LC_CTRL_TRANSITION_TARGET
    4'b 0001, // index[10] LC_CTRL_LC_STATE
    4'b 0001, // index[11] LC_CTRL_LC_TRANSITION_CNT
    4'b 0001, // index[12] LC_CTRL_LC_ID_STATE
    4'b 1111, // index[13] LC_CTRL_DEVICE_ID_0
    4'b 1111, // index[14] LC_CTRL_DEVICE_ID_1
    4'b 1111, // index[15] LC_CTRL_DEVICE_ID_2
    4'b 1111, // index[16] LC_CTRL_DEVICE_ID_3
    4'b 1111, // index[17] LC_CTRL_DEVICE_ID_4
    4'b 1111, // index[18] LC_CTRL_DEVICE_ID_5
    4'b 1111, // index[19] LC_CTRL_DEVICE_ID_6
    4'b 1111  // index[20] LC_CTRL_DEVICE_ID_7
  };

endpackage

