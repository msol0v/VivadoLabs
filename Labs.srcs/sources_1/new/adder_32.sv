module adder_32(
    input logic [31:0] a_i,
    input logic [31:0] b_i,
    input logic carry_i,
    output logic [31:0] sum_o,
    output logic carry_o
);

    logic [31:0] carry_temp;
    fulladder adders_array[31:0](
        .a_i(a_i),
        .b_i(b_i),
        .carry_i({carry_temp[30:0], carry_i}),
        .sum_o(sum_o),
        .carry_o(carry_temp)
    );
    
    assign carry_o = carry_temp[31];

endmodule