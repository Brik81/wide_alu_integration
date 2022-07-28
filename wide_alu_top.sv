//-----------------------------------------------------------------------------
// Title         : wide_alu_top  Sample IP for PULP-Training IP Integration Exercise
//-----------------------------------------------------------------------------
// File          : wide_alu_top.sv
// Author        : BRIK
// Created       : 26/07/2022
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2020 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIwggND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------
import wide_alu_reg_pkg::*;
import wide_alu_pkg::*;


module wide_alu_top #(
                      localparam ALU_WIDTH = 256,
                      localparam DEACCEL_COUNTER_WIDTH = 8,
                      parameter type reg_req_t = logic,
                      parameter type reg_rsp_t = logic
 )(

        input   logic                  clk_i,
        input   logic                  rst_ni,
        input   logic                  test_mode_i,
        input   reg_req_t              reg_req_i,
        output  reg_rsp_t              reg_rsp_o

);

   wide_alu_reg_pkg::wide_alu_reg2hw_t reg2hw;
   wide_alu_reg_pgk::wide_alu_hw2reg_t hw2reg;
  wide_alu_reg_top #(
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
       ) i_wide_alu_regs (
            .clk_i  (clk_i),
            .rst_ni (rst_ni),
            .reg_req_i(reg_req_i),
            .reg_rsp_o(reg_rsp_o),
            .reg2hw(reg2hw),
            .hw2reg(hw2reg),
            .devmode_i(1'b1)
       );
   

   wide_alu_pkg::optype_e reg2hwop;


    always_comb begin
      reg2hwop = ADD;
      case(reg2hw.ctrl2.opsel.q)
        3'h0: begin
           reg2hwop = ADD;
        end
        3'h1: begin
           reg2hwop = SUB;
        end
        3'h2: begin
           reg2hwop = MUL;
        end
        3'h3: begin
           reg2hwop = XOR;
        end
        3'h4: begin
           reg2hwop = AND;
        end
        3'h5: begin
           reg2hwop = OR;
        end
      endcase
    end


 
   wide_alu i_wide_alu(
                       .clk_i        (clk_i),
                       .rst_ni       (rst_ni),
                       .trigger_i    (reg2hw.ctrl1.trigger.q & reg2hw.ctrl1.trigger.qe),
                       .clear_err_i  (reg2hw.ctrl1.trigger.q & reg2hw.ctrl1.trigger.qe),
                       .op_a_i       (reg2hw.op_a),
                       .op_b_i       (reg2hw.op_b),
                       .result_o            (hw2reg.result), 
                       .deaccel_factor_we_i (reg2hw.ctrl2.delay.qe),
                       .deaccel_factor_i    (reg2hw.ctrl2.delay.q),
                       .deaccel_factor_o    (hw2reg.ctrl2.delayl.d),
                       .op_sel_we_i         (reg2hw.ctrl2.opsel.qe), 
                       .op_sel_i            (reg2hwop),
                       .op_sel_o            (hw2reg.ctrl2.opsel.d),
                       .status_o            (hw2reg.status.d)
                      
                       );
   
endmodule: wide_alu_top
