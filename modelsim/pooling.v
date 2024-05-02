module matrix_maxpool(
    input clk,
    input reset,
    input start,
    output reg done,
    input wire [11:0] src1_start_address,
    output reg [11:0] src1_address,
    input wire signed [15:0] src1_readdata,
    output wire src1_write_en,
    input wire [5:0] src1_row_size,
    input wire [5:0] src1_col_size,
    input wire [5:0] src2_row_size,
    input wire [5:0] src2_col_size,
    input wire [11:0] dest_start_address,
    output reg [11:0] dest_address,
    output reg signed [15:0] dest_writedata,
    output reg dest_write_en
);
    reg [5:0] row_count;
    reg [5:0] col_count;
    reg [5:0] row_index;
    reg [5:0] col_index;
    reg signed [15:0] max_pool=0;
   
    assign src1_write_en = 0;
    reg [1:0] state = 2'd2;
    reg [5:0] val = 1;

    always @(posedge clk) begin
    if(reset) begin
        state <= 2'd2;
        row_count<=0;
        col_count<=0;
        row_index <=0;
        col_index <= 0;
        src1_address<=src1_start_address;
        dest_address<=dest_start_address;
        done<=1;
    end
    else begin
        case (state)
            2'd0: begin
                src1_address<=src1_start_address;
                dest_address<=dest_start_address-1;
                max_pool <= 0;
                state<=2'd1;
            end
            2'd1: begin
                if(row_count < src2_row_size-1) begin
                    src1_address <= src1_address + 1;
                    row_count <= row_count+1;
                    if (src1_readdata > max_pool)
                      max_pool <= src1_readdata;
                    dest_write_en <= 0;
                end
                else if (col_count < src2_col_size-1) begin
                    src1_address <= src1_address + 1;
                    col_count <= col_count+1;
                    row_count <= 0;
                    if (src1_readdata > max_pool)
                      max_pool <= src1_readdata;
                    dest_write_en <= 0;
                end
                else begin
                    dest_write_en <= 0;
                    if (src1_readdata > max_pool)
                      max_pool <= src1_readdata;              
                    state <= 2'd3;
                end
            end
            2'd3: begin
                      src1_address <= src1_address + 1;
                      dest_writedata <= max_pool;
                      dest_write_en <= 1;
                      dest_address <= dest_address + 1;
                      val <= val + 1;
                      row_count <= 0;
                      col_count <= 0;
                      max_pool <=0;
                   
 
                    if(val == ((src1_col_size/src2_col_size)*(src1_col_size/src2_col_size)))
                        state <= 2'd2; // Processing complete
                    else
                        state <= 2'd1; // Continue processing next block
                   
                end            
           
           
            2'd2: begin
                if(start == 1) begin
                    state <= 2'd0;
                    dest_write_en <= 0;
                    done <= 0;
                end
                else begin
                    dest_write_en <= 0;
                    row_count<=0;
                    col_count<=0;
                    row_index <= 0;
                    col_index <=0;
                    src1_address<=src1_start_address;
                    dest_address<=dest_start_address;
                    done<=1;
                end
            end
            default: begin
                row_count<=0;
                col_count<=0;
                row_index <= 0;
                col_index <=0;                
                src1_address<=src1_start_address;
                dest_address<=dest_start_address;
                done<=1;
            end
        endcase
    end
    end
endmodule