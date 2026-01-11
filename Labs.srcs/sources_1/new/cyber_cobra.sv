module program_counter
(
    input logic clk_i,
    input logic [31:0] instr_word_i,
    input logic rst_i,
    
    output logic [31:0] instr_word_o
);
    logic [31:0] pc_reg;
    assign instr_word_o = pc_reg;
    always_ff @(posedge clk_i) begin 
        if(rst_i) begin 
            pc_reg <= instr_word_i;
        end
        else begin
            pc_reg <= 32'd0;
        end
    end
endmodule


module CYBERcobra
(
    input logic clk_i,
    input logic rst_i,
    input logic [15:0] sw_i,
    output logic [32:0] out_o
);
//Первым делом подключим сумматор к программному счетчику (регистр адреса текущей инструкции в памяти инструкций)
logic [31:0] adder_num1, adder_num2, adder_sum; //Сигналы сумматора для дальнейшего подключения

    adder_32 adder_pc(
        .a_i(adder_num1),
        .b_i(adder_num2),
        .carry_i(0),
        .sum_o(adder_sum)
    );
    
//Добавляем PC
logic [31:0] instr_word_pc_i, instr_word_pc_o;
    program_counter PC(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .instr_word_i(instr_word_pc_i),
        .instr_word_o(instr_word_pc_o)
    );
    
//Добавляем память инструкций
logic [31:0] instr_addr, instr_data;
    instr_mem instruction_mem(
        .read_addr_i(instr_addr),
        .read_data_o(instr_data)
    );
    
    //Реализация счетчика 
    assign instr_addr = adder_num1;
    assign instr_addr = instr_word_pc_o;
    assign instr_word_pc_i = adder_sum;
endmodule