module forward_pass(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire input_data[0:783],  // 假设每个输入像素用16位定点，Q8.8
    output reg  done,
    output reg  [15:0] output_data[0:9]     // 输出层10个元素
);

// 内部寄存器与状态机变量
reg [15:0] W1 [0:783][0:9];
reg [15:0] b1 [0:9];
reg [15:0] W2 [0:9][0:9];
reg [15:0] b2 [0:9];

// 中间计算结果
reg [31:0] acc;  // 累加器，长度可根据需要扩展
reg [15:0] hidden[0:9]; // 存放第一层输出

reg [15:0] W1_flat [0:784*10-1];
reg [15:0] W2_flat [0:10*10-1];

reg [3:0]  state;
integer i, j;

localparam IDLE = 0;
localparam LAYER1 = 1;
localparam LAYER1_FINISH = 2;
localparam LAYER2 = 3;
localparam LAYER2_FINISH = 4;
localparam DONE = 5;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        done <= 0;
    end else begin
        case (state)
        IDLE: begin
            if (start) begin
               // 开始计算第一层：z1 = W1*x + b1
               // 初始化计数器、寄存器
               i <= 0; 
               state <= LAYER1;
            end
        end

        LAYER1: begin
            // 计算第i个神经元
            // acc = sum over k of W1[k][i]*x[k]
            acc = 0;
            for (j = 0; j < 784; j = j+1) begin
                // 定点乘法： (W1*X)>>8 假设Q8.8 * Q8.8 = Q16.16，再适当右移
                // 简化：acc += (W1[j][i]*input_data[j]) >> 8;
                // 实际中需流水化，这里简化为组合逻辑描述（仿真用）
                acc = acc + (W1[j][i]*input_data[j])>> 8;
            end
            // 加上偏置 b1[i]
            acc = acc + b1[i];

            // ReLU
            if (acc[31] == 1'b1) begin
                // 负数
                hidden[i] <= 16'h0000;
            end else begin
                hidden[i] <= acc[15:0]; // 截断为Q8.8
            end

            if (i == 9) begin
               state <= LAYER1_FINISH;
            end else begin
               i <= i + 1;
            end
        end

        LAYER1_FINISH: begin
            // 开始第二层计算
            i <= 0;
            state <= LAYER2;
        end

        LAYER2: begin
            // 对第i个输出单元计算：z2[i] = sum over m of W2[m][i]*hidden[m] + b2[i]
            acc = 0;
            for (j = 0; j < 10; j = j+1) begin
                acc = acc + (W2[j][i]*hidden[j])>> 8;
            end
            acc = acc + b2[i];
            output_data[i] <= acc[15:0]; // 输出的Q8.8格式值

            if (i == 9) begin
               state <= LAYER2_FINISH;
            end else begin
               i <= i + 1;
            end
        end

        LAYER2_FINISH: begin
            for(j=0;j<10;j=j+1)begin
					if(output_data[i]<0)begin
						output_data[i]=0-output_data[i];
					end
				end	
            done <= 1;
            state <= DONE;
        end

        DONE: begin
            // 保持输出稳定
        end

        endcase
    end
end

// 权重与偏置的初始化可以用initial块读mem文件
initial begin
    $readmemh("w1.txt", W1_flat);
    $readmemh("b1.txt", b1);
    $readmemh("w2.txt", W2_flat);
    $readmemh("b2.txt", b2);
    for (i = 0; i < 784; i = i + 1) begin
        for (j = 0; j < 10; j = j + 1) begin
            W1[i][j] = W1_flat[i*10 + j];
        end
    end
	for (i = 0; i < 10; i = i + 1) begin
        for (j = 0; j < 10; j = j + 1) begin
            W2[i][j] = W2_flat[i*10 + j];
        end
    end
end

endmodule
