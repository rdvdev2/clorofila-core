package datapath_control_types;

	typedef enum {
		ALU_X_REGFILE,
		ALU_X_PC
	} alu_x_t;

	typedef enum {
		ALU_Y_REGFILE,
		ALU_Y_IMMED
	} alu_y_t;

	typedef enum {
		MEM_ADDR_ALU,
		MEM_ADDR_PC
	} mem_addr_t;

endpackage;
