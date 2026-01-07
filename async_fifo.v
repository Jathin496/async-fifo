module async_fifo #(
    parameter width = 8,
    parameter addr_width = 6
)(
    input wire wclk,
    input wire rclk,
    input wire wrst_n,
    input wire rrst_n,
    input wire w_en,
    input wire r_en,
    input wire [width-1:0] wdata,
    output reg  [width-1:0] rdata,
    output wire full,
    output wire empty
);

    localparam depth = 1 << addr_width;

    //FIFO memory
    reg [width-1:0] mem [0:depth-1];

    reg [addr_width:0] wptr_bin, rptr_bin;
    reg [addr_width:0] wptr_gray, rptr_gray;
    
    reg [addr_width:0] wclk_rptr_gray_ff1, wclk_rptr_gray_ff2;
    reg [addr_width:0] rclk_wptr_gray_ff1, rclk_wptr_gray_ff2;

    wire [addr_width:0] wclk_rptr_gray = wclk_rptr_gray_ff2;
    wire [addr_width:0] rclk_wptr_gray = rclk_wptr_gray_ff2;

    //binary and gray
    wire [addr_width:0] wptr_bin_next;
    wire [addr_width:0] rptr_bin_next;
    wire [addr_width:0] wptr_gray_next;
    wire [addr_width:0] rptr_gray_next;

    assign wptr_bin_next  = wptr_bin + 1;
    assign rptr_bin_next  = rptr_bin + 1;

    assign wptr_gray_next = (wptr_bin_next >> 1) ^ wptr_bin_next;
    assign rptr_gray_next = (rptr_bin_next >> 1) ^ rptr_bin_next;

    //write clock domain
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= 0;
            wptr_gray <= 0;
        end else begin
            if (w_en && !full) begin
                mem[wptr_bin[addr_width-1:0]] <= wdata;
                wptr_bin  <= wptr_bin_next;
                wptr_gray <= wptr_gray_next;
            end
        end
    end

    //read clock domain
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= 0;
            rptr_gray <= 0;
            rdata     <= 0;
        end else begin
            if (r_en && !empty) begin
                rdata     <= mem[rptr_bin[addr_width-1:0]];
                rptr_bin  <= rptr_bin_next;
                rptr_gray <= rptr_gray_next;
            end
        end
    end

    //pointer synchronization
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rclk_wptr_gray_ff1 <= 0;
            rclk_wptr_gray_ff2 <= 0;
        end else begin
            rclk_wptr_gray_ff1 <= wptr_gray;
            rclk_wptr_gray_ff2 <= rclk_wptr_gray_ff1;
        end
    end

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wclk_rptr_gray_ff1 <= 0;
            wclk_rptr_gray_ff2 <= 0;
        end else begin
            wclk_rptr_gray_ff1 <= rptr_gray;
            wclk_rptr_gray_ff2 <= wclk_rptr_gray_ff1;
        end
    end

    //status flags
    assign empty = (rptr_gray == rclk_wptr_gray);

    assign full  = (wptr_gray ==
                   {~wclk_rptr_gray[addr_width:addr_width-1],
                     wclk_rptr_gray[addr_width-2:0]});

endmodule