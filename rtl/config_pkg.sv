
package config_pkg;

localparam ECHO = 8'hEC;
localparam ADD = 8'hAD;
localparam MUL = 8'hAC;
localparam DIV = 8'D1;

typedef enum logic [2:0] {
    OPCODE,
    RESERVED,
    LSB,
    MSB,
    RS1,
    RS2,
    COMPUTE
} state_t;

endpackage
