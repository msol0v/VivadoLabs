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
    
//Регистровый файл
logic wr_en_RFsig;
logic [4:0] write_addr_i, read_addr1_i, read_addr2_i;
logic [31:0] write_data_i, read_data1_o, read_data2_o;
    register_file RF(
        .clk_i(clk_i),
        .write_enable_i(wr_en_sig),
        .write_addr_i(write_addr_i),
        .read_addr1_i(read_addr1_i),
        .read_addr2_i(read_addr2_i),
        .write_data_i(write_data_i),
        .read_data1_o(read_data1_o),
        .read_data2_o(read_data2_o)
    );
    
//ALU
logic [31:0] ALU_a_i, ALU_b_i, ALU_result_o;
logic [4:0] ALU_alu_op_i;
logic ALU_flag_o;
    alu ALU(
        .a_i(ALU_a_i),
        .b_i(ALU_b_i),
        .alu_op_i(ALU_alu_op_i),
        .flag_o(ALU_flag_o),
        
        .result_o(ALU_result_o)
    );
    
    //Реализация счетчика 
    assign instr_addr = adder_num1;
    assign instr_addr = instr_word_pc_o;
    assign instr_word_pc_i = adder_sum;
    
    //Подключение регистрового файла к АЛУ
    assign ALU_a_i = read_data1_o;
    assign ALU_b_i = read_data2_o;
    
    //Подключаем 27-23 биты инструкции как опирацию АЛУ
    assign ALU_alu_op_i = instr_data[27:23];
    
    //Подключение текущей инструкции к регистровому файлу
    assign read_addr1_i = instr_data[22:18];    //Адреса операндов инструкции
    assign read_addr2_i = instr_data[17:13];
    
    assign write_addr_i = instr_data[4:0];      //Адрес, по которому разместить результат операции
    
    //Управляющий сигнал мультиплексора для выбора того, что записываем в регистровый файл сейчас
    logic [1:0] mux_wd_opcode_instr;
    assign mux_wd_opcode_instr = instr_data[29:28];
    
    //Константа в инструкции 
    logic [22:0] RF_const;
    assign RF_const = instr_data[27:5];
    
    //
endmodule