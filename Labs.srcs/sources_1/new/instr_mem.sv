
//Память инструкций
module instr_mem
import memory_pkg::INSTR_MEM_SIZE_BYTES;
import memory_pkg::INSTR_MEM_SIZE_WORDS;
(
    input logic [31:0] read_addr_i,
    output logic [31:0] read_data_o
);

    logic [31:0] ROM [INSTR_MEM_SIZE_WORDS];
    initial begin 
        $readmemh("program.mem", ROM);
    end
    
    assign read_data_o = ROM[read_addr_i[$clog2(INSTR_MEM_SIZE_BYTES)-1:2]];

endmodule

//Регистровый файл
module register_file
#(
parameter MEM_SIZE_WORDS = 32,
parameter MEM_SIZE_BYTES = MEM_SIZE_WORDS*4
)
(
  input  logic        clk_i,
  input  logic        write_enable_i,

  input  logic [ 4:0] write_addr_i,
  input  logic [ 4:0] read_addr1_i,
  input  logic [ 4:0] read_addr2_i,

  input  logic [31:0] write_data_i,
  output logic [31:0] read_data1_o,
  output logic [31:0] read_data2_o
);
    logic [31:0] rf_mem[MEM_SIZE_WORDS];
    logic [31:0] rd_temp_1, rd_temp_2;
    assign rd_temp_1 = rf_mem[read_addr1_i];
    assign rd_temp_2 = rf_mem[read_addr2_i];
    
    always_comb begin
        if(read_addr1_i == 0) begin 
            read_data1_o = 32'b0;
        end
        
        else begin
            read_data1_o = rd_temp_1;
        end
        
        if(read_addr2_i == 0) begin 
            read_data2_o = 32'b0;
        end
        
        else begin
            read_data2_o = rd_temp_2;
        end
    end
    
    always_ff @(posedge clk_i) begin 
        if(write_enable_i) begin
            rf_mem[write_addr_i] <= write_data_i;
        end
    end
    
endmodule