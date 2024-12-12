module image_loader(
    output reg [0:783] input_data  // 每个像素用1位表示
);

reg [0:783] input_data_mem [0:0];  // 定义一个数组来存储图像数据

// 使用 $readmemh 读取图像数据
initial begin
    $readmemh("image_2.txt", input_data_mem);
    input_data = input_data_mem[0];  // 将数组中的数据赋值给输出寄存器
end

endmodule