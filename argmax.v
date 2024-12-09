module argmax (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire signed [15:0] z2 [0:9],  // 输出层10个元素
    output reg [3:0] max_index,           // 最大值的索引（0-9）
    output reg done
);
    integer i;
    reg signed [15:0] current_max;
    reg [3:0] current_index;

    reg [2:0] state;
    localparam IDLE = 0, FIND_MAX = 1, DONE_STATE = 2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            max_index <= 0;
            current_max <= 0;
            current_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        current_max <= z2[0];
                        current_index <= 0;
                        i <= 1;
                        state <= FIND_MAX;
                    end
                end

                FIND_MAX: begin
                    if (i < 10) begin
                        if (z2[i] > current_max) begin
                            current_max <= z2[i];
                            current_index <= i;
                        end
                        i <= i + 1;
                    end else begin
                        max_index <= current_index;
                        state <= DONE_STATE;
                    end
                end

                DONE_STATE: begin
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
