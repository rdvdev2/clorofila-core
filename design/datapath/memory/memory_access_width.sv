package memory_access_width;

typedef enum {
	BYTE = 2'b00,
	HALF = 2'b01,
	WORD = 2'b10
} memory_access_width_t;

function integer memory_access_width_to_bytes(input memory_access_width_t maw);
	memory_access_width_to_bytes = 2 ** integer'(maw);
endfunction;

endpackage;
