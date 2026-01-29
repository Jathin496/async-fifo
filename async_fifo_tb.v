`timescale 1ns/1ps
module async_fifo_tb;

    parameter width = 8;
    parameter addr_width = 6;

    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg w_en, r_en;
    reg [width-1:0] wdata;
    reg [width-1:0] temp;

    wire [width-1:0] rdata;
    wire full, empty;

    async_fifo #(
        .width(width),
        .addr_width(addr_width)
    ) dut (
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(wrst_n),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .r_en(r_en),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );

    // clocks
    always #5  wclk = ~wclk;
    always #10 rclk = ~rclk;

    reg [width-1:0] ref_mem [0:31];
    integer wr_cnt, rd_cnt;
    integer i;

    reg r_en_d;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, async_fifo_tb);

        wclk = 0; rclk = 0;
        w_en = 0; r_en = 0;
        wrst_n = 0; rrst_n = 0;
        wdata = 0;
        wr_cnt = 0; rd_cnt = 0;

        repeat (5) @(posedge wclk);
        wrst_n = 1;

        repeat (5) @(posedge rclk);
        rrst_n = 1;

        // ---------------- WRITE ----------------
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge wclk);
            temp  = $random;
            w_en  <= 1;
            wdata <= temp;
            ref_mem[wr_cnt] = temp;  
            $display("[WRITE] Data = %h", temp);
            wr_cnt++;
            @(posedge wclk);
        end
        w_en <= 0;

        repeat (10) @(posedge rclk);

        // ---------------- READ ----------------
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge rclk);
            r_en <= 1;
            @(posedge rclk);
        end
        r_en <= 0;

        repeat (10) @(posedge rclk);
        $display("---- TEST COMPLETED ----");
        $finish;
    end

    // delayed read-valid
    always @(posedge rclk) begin
        r_en_d <= r_en && !empty;
    end

    // checker
    always @(posedge rclk) begin
        if (r_en_d) begin
            if (rdata !== ref_mem[rd_cnt]) begin
                $error("READ FAIL exp=%h got=%h idx=%0d",
                       ref_mem[rd_cnt], rdata, rd_cnt);
            end else begin
                $display("[READ] %h OK", rdata);
            end
            rd_cnt++;
        end
    end

endmodule

