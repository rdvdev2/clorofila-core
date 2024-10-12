`include "constants.svh"

typedef enum {
    LOAD = 'b0000011,
    STORE = 'b0100011
} opcode_t;

module decoder (
    input logic [`INST_MASK] ir,
    output logic valid,
    output opcode_t opcode,
    output logic [`REG_ADDR_MASK] rs1,
    output logic [`REG_ADDR_MASK] rs2,
    output logic [`REG_ADDR_MASK] rd,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [`IMMED_MASK] immed
);

typedef enum { R, I, S, B, U, J } encoding_t;

// Fixed offset fields
always_comb
begin
    opcode = opcode_t'(ir[6:0]);
    rs1 = ir[19:15];
    rs2 = ir[24:20];
    rd = ir[11:7];
    funct3 = ir[14:12];
    funct7 = ir[31:25];
end

// Determine the encoding from the opcode, and invalidate in case of unknown opcode
encoding_t encoding;
always_comb
begin
    valid = '1;

    case (opcode)
        LOAD: encoding = I;
        STORE: encoding = S;
        default: valid = '0;
    endcase
end

// Reconstruct and sign-extend the immediate
always_comb
begin
    case (encoding)
        I: immed = {{21{ir[31]}}, ir[30:25], ir[24:21], ir[20]};
        S: immed = {{21{ir[31]}}, ir[30:25], ir[11:8], ir[7]};
        B: immed = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
        U: immed = {ir[31], ir[30:20], ir[19:12], 12'b0};
        J: immed = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:25], ir[24:21], 1'b0};
    endcase
end

endmodule;