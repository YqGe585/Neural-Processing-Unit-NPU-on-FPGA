`timescale 1ns / 1ps

module matrix_maxpool_tb;

    // Inputs
    reg clk;
    reg clk_300;
    reg reset;
    reg start;
    reg [11:0] src1_start_address;
    wire [15:0] src1_data;
    wire [15:0] src1_write_data;
    reg [5:0] src1_row_size;
    reg [5:0] src1_col_size;
    reg [5:0] src2_row_size;
    reg [5:0] src2_col_size;
    reg [11:0] dest_start_address;

    // Outputs
    wire done;
    wire [11:0] src1_address;
    wire src1_write_en;
    wire [11:0] dest_address;
    wire [15:0] dest_data;
    wire dest_write_en;

    // Instantiate the Unit Under Test (UUT)
    matrix_maxpool uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .src1_start_address(src1_start_address),
        .src1_address(src1_address),
        .src1_readdata(src1_data),
        .src1_write_en(src1_write_en),
        .src1_row_size(src1_row_size),
        .src1_col_size(src1_col_size),
        .src2_row_size(src2_row_size),
        .src2_col_size(src2_col_size),
        .dest_start_address(dest_start_address),
        .dest_address(dest_address),
        .dest_writedata(dest_data),
        .dest_write_en(dest_write_en)
    );

    M10K_sram src1(
        .clk(clk_300),
        .we(src1_write_en),
        .q(src1_data),
        .d(src1_write_data),
        .address(src1_address)
    );


    M10K_sram dest(
        .clk(clk_300),
        .we(dest_write_en),
        .q(),
        .d(dest_data),
        .address(dest_address)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #60 clk = ~clk;  // 50MHz clock
    end

    initial begin
        clk_300 = 0;
        forever #10 clk_300 = ~clk_300;  // 300MHz clock
    end

    // Initial Conditions and Test Sequence
    initial begin
        // Initialize Inputs
        reset = 1;
        start = 0;
        src1_start_address = 15'd128;
        src1_row_size = 6'd8;  // Example size 32x32 matrix
        src1_col_size = 6'd8;
        src2_row_size = 6'd2;
        src2_col_size = 6'd2;
        dest_start_address = 15'd256;

        // Wait for global reset to finish
        #600;
        reset = 0;
        #600;

        // Start the matrix addition
        start = 1;

        #120

        start = 0;

        // Wait for operation to complete
        wait (done == 1'b1);

        // Check results (this part can be expanded as per specific requirements)
        $display("Test completed. Final address and data: %h, %h", dest_address, dest_data);

        // Finish simulation
        #600;
        $finish;
    end

endmodule