`include "constants.svh"

import datapath_control_types::*;
import alu_operation::*;
import memory_access_width::*;

interface datapath_control;
  logic [`REG_ADDR_MASK] rs1;
  logic [`REG_ADDR_MASK] rs2;
  logic [`REG_ADDR_MASK] rd;
  logic regfile_we;
  alu_x_t alu_x;
  alu_y_t alu_y;
  logic [`WORD_MASK] pc;
  logic [`WORD_MASK] immed;
  alu_operation_t alu_op;
  logic mem_valid;
  logic mem_we;
  mem_addr_t mem_addr;
  memory_access_width_t mem_width;
  logic mem_signed;
  regfile_d_t regfile_d;

  logic [`WORD_MASK] mem_rd; 
  logic [`WORD_MASK] alu_w;

  modport datapath (
    input rs1,
    input rs2,
    input rd,
    input regfile_we,
    input alu_x,
    input alu_y,
    input pc,
    input immed,
    input alu_op,
    input mem_valid,
    input mem_we,
    input mem_addr,
    input mem_width,
    input mem_signed,
    input regfile_d,

    output mem_rd,
    output alu_w
  );

  modport control (
    output rs1,
    output rs2,
    output rd,
    output regfile_we,
    output alu_x,
    output alu_y,
    output pc,
    output immed,
    output alu_op,
    output mem_valid,
    output mem_we,
    output mem_addr,
    output mem_width,
    output mem_signed,
    output regfile_d,

    input mem_rd,
    input alu_w
  );
endinterface;
