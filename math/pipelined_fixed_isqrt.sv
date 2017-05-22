/*
    //------------------------------------------------------------------------------------
    //      Модуль конвейерного вычисления обратного квадратного корня методом
    //      касательных (метод Ньютона-Рафсона). Результат представляется в формате
    //                          (1 + invsqrt)/(2^exponent)
    //      Латентность модуля 3*ITERATIONS + 8 тактов
    pipelined_fixed_isqrt
    #(
        .WIDTH          (), // Разрядность данных
        .ITERATIONS     ()  // Количество итераций алгоритма Ньютона-Рафсона
    )
    the_pipelined_fixed_isqrt
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Разрешение тактирования
        .clkena         (), // i
        
        // Подкоренное значение (целое без знака)
        .radical        (), // i  [WIDTH - 1 : 0]
        
        // Значащая часть обратного квадратного корня
        // (дробное без знака)
        .invsqrt        (), // o  [WIDTH - 1 : 0]
        
        // Масштабирующий множитель (порядок) обратного
        // квадратного корня (целое без знака)
        .exponent       (), // o  [$clog2(WIDTH) - 2 : 0]
        
        // Признак переполнения (при нулевом значении
        // подкоренного выражения)
        .overflow       ()  // o
    ); // the_pipelined_fixed_isqrt
*/

module pipelined_fixed_isqrt
#(
    parameter int unsigned                  WIDTH       = 16,   // Разрядность данных
    parameter int unsigned                  ITERATIONS  = 3     // Количество итераций алгоритма Ньютона-Рафсона
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Разрешение тактирования
    input  logic                            clkena,
    
    // Подкоренное значение (целое без знака)
    input  logic [WIDTH - 1 : 0]            radical,
    
    // Значащая часть обратного квадратного корня
    // (дробное без знака)
    output logic [WIDTH - 1 : 0]            invsqrt,
    
    // Масштабирующий множитель (порядок) обратного
    // квадратного корня (целое без знака)
    output logic [$clog2(WIDTH) - 2 : 0]    exponent,
    
    // Признак переполнения (при нулевом значении
    // подкоренного выражения)
    output logic                            overflow
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned         SCALER_LATENCY = 3;         // Латентность модуля масштабирования
    localparam int unsigned         APPROX_LATENCY = 4;         // Латентность модуля аппроксимации
    localparam int unsigned         NEWTON_LATENCY = 3;         // Латентность модуля выполнения одной итерации алгоритма Ньютона-Рафсона
    //
    localparam int unsigned         RDLY = APPROX_LATENCY +     // Длина линии задержки подкоренного выражения
                                    (ITERATIONS - 1)*NEWTON_LATENCY;
    localparam int unsigned         SDLY = APPROX_LATENCY +     // Длина линии задержки масштаба подкоренного выражения
                                    ITERATIONS*NEWTON_LATENCY;
    localparam int unsigned         ODLY = APPROX_LATENCY +     // Длина линии задержки признака переполнения
                                    ITERATIONS*NEWTON_LATENCY + 1;
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0]                       radical_scaled;
    logic [RDLY - 1 : 0][WIDTH - 1 : 0]         radical_scaled_reg;
    logic [$clog2(WIDTH) - 1 : 0]               radical_scale;
    logic [SDLY - 1 : 0][$clog2(WIDTH) - 2 : 0] radical_scale_reg;
    logic [WIDTH - 1 : 0]                       poly_approx;
    logic [ITERATIONS - 1 : 0][WIDTH + 1 : 0]   newton_approx;
    logic [WIDTH - 1 : 0]                       invsqrt_reg;
    logic [$clog2(WIDTH) - 2 : 0]               exponent_reg;
    logic [ODLY - 1 : 0]                        overflow_reg;
    
    //------------------------------------------------------------------------------------
    //      Модуль нормализации входных данных. Масштабирует входное целое без знака.
    //      В результате масштабирования получается дробное без знака их диапазона
    //      [0.25; 1). Латентность модуля - 3 такта
    pipelined_fixed_isqrt__scaler
    #(
        .WIDTH          (WIDTH)             // Разрядность данных
    )
    the_pipelined_fixed_isqrt__scaler
    (
        // Сброс и тактирование
        .reset          (reset),            // i
        .clk            (clk),              // i
        
        // Разрешение тактирования
        .clkena         (clkena),           // i
        
        // Входные данные (целое без знака)
        .idata          (radical),          // i  [WIDTH - 1 : 0]
        
        // Выходные данные (дробное без знака из промежутка [0.25; 1))
        .odata          (radical_scaled),   // o  [WIDTH - 1 : 0]
        
        // Выходной порядок обратного масштабирования
        .scale          (radical_scale)     // o  [$clog2(WIDTH) - 1 : 0]
    ); // the_pipelined_fixed_isqrt__scaler
    
    //------------------------------------------------------------------------------------
    //      Регистр задержки масштабированного подкоренного значения
    always @(posedge reset, posedge clk)
        if (reset)
            radical_scaled_reg <= '0;
        else if (clkena)
            radical_scaled_reg <= {radical_scaled_reg[RDLY - 2 : 0], radical_scaled};
        else
            radical_scaled_reg <= radical_scaled_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр задержки масштаба подкоренного значения (масштабированного)
    always @(posedge reset, posedge clk)
        if (reset)
            radical_scale_reg <= '0;
        else if (clkena)
            radical_scale_reg <= {radical_scale_reg[SDLY - 2 : 0], radical_scale[$clog2(WIDTH) - 1 : 1]};
        else
            radical_scale_reg <= radical_scale_reg;
    
    //------------------------------------------------------------------------------------
    //      Модуль аппроксимации выражения 1/sqrt(x) на полуинтервале [0.25; 1)
    //      полиномом 3-ей степени. Латентность модуля - 4 такта.
    pipelined_fixed_isqrt__approximator
    #(
        .WIDTH      (WIDTH)             // Разрядность данных
    )
    the_pipelined_fixed_isqrt__approximator
    (
        // Сброс и тактирование
        .reset      (reset),            // i
        .clk        (clk),              // i
        
        // Разрешение тактирования
        .clkena     (clkena),           // i
        
        // Входные данные (дробное без знака из промежутка [0.25; 1))
        .idata      (radical_scaled),   // i  [WIDTH - 1 : 0]
        
        // Выходные данные (дробная часть дробного без знака из 
        // промежутка (1; 2) - целая чать всегда полагается равной 1)
        .odata      (poly_approx)       // o  [WIDTH - 1 : 0]
    ); // the_pipelined_fixed_isqrt__approximator
    
    //------------------------------------------------------------------------------------
    //      Генерация модулей, реализующих последовательные итерации алгоритма
    //      Ньютона-Рафсона
    generate
        genvar itr;
        for (itr = 0; itr < ITERATIONS; itr++) begin: newton_iterations_gen
        
            //------------------------------------------------------------------------------------
            //      Модуль выполнения одной итерации алгоритма Ньютона-Рафсона вычисления
            //      значения функции 1/sqrt(x). Латентность модуля - 4 такта.
            pipelined_fixed_isqrt__newton_iteration
            #(
                .WIDTH      (WIDTH)                                                         // Разрядность дробной части
            )
            the_pipelined_fixed_isqrt__newton_iteration
            (
                // Сброс и тактирование
                .reset      (reset),                                                        // i
                .clk        (clk),                                                          // i
                
                // Разрешение тактирования
                .clkena     (clkena),                                                       // i
                
                // Значение подкоренного выражения (дробное 
                // без знака из промежутка [0.25; 1))
                .radical    (radical_scaled_reg[APPROX_LATENCY + itr*NEWTON_LATENCY - 1]),  // i  [WIDTH - 1 : 0]
                
                // Предыдущее приближенное значение (дробное без знака:
                // два старших разряда - целая часть остальные - дробная)
                .papprox    (itr ? newton_approx[itr - 1] : {2'b01, poly_approx}),          // i  [WIDTH + 1 : 0]
                
                // Следующее приближенное значение (дробное без знака:
                // два старших разряда - целая часть остальные - дробная)
                .napprox    (newton_approx[itr])                                            // o  [WIDTH + 1 : 0]
            ); // the_pipelined_fixed_isqrt__newton_iteration
            
        end // newton_iterations_gen
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр значащей чати обратного квадратного корня
    always @(posedge reset, posedge clk)
        if (reset)
            invsqrt_reg <= '0;
        else if (clkena)
            if (newton_approx[ITERATIONS - 1][WIDTH + 1])
                invsqrt_reg <= newton_approx[ITERATIONS - 1][WIDTH : 1];
            else
                invsqrt_reg <= newton_approx[ITERATIONS - 1][WIDTH - 1 : 0];
        else
            invsqrt_reg <= invsqrt_reg;
    assign invsqrt = invsqrt_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр масштабирующего множителя (порядка) обратного квадратного корня
    always @(posedge reset, posedge clk)
        if (reset)
            exponent_reg <= '0;
        else if (clkena)
            exponent_reg <= radical_scale_reg[SDLY - 1] - newton_approx[ITERATIONS - 1][WIDTH + 1];
        else
            exponent_reg <= exponent_reg;
    assign exponent = exponent_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр задержки признака переполнения
    always @(posedge reset, posedge clk)
        if (reset)
            overflow_reg <= '0;
        else if (clkena)
            overflow_reg <= {overflow_reg[ODLY - 2 : 0], (radical_scaled == 0)};
        else
            overflow_reg <= overflow_reg;
    assign overflow = overflow_reg[ODLY - 1];
    
    // synthesis translate_off
    
    //------------------------------------------------------------------------------------
    //      Функция для перевода дробного с фиксированной точкой в формат
    //      с плавающей точкой
    function real fi2real(input logic [WIDTH - 1 : 0] value);
        automatic real w = 0.5;
        automatic real a = 0.0;
        
        for (int i = 0; i < WIDTH; i++) begin
            if (value[WIDTH - i - 1]) begin
                a = a + w;
            end
            w = w/2.0;
        end
        fi2real = a;
    endfunction
    
    //------------------------------------------------------------------------------------
    //      Отладочные сигналы
    real isqrt_real;
    assign isqrt_real = (fi2real(invsqrt[WIDTH - 1 : 0]) + 1.0) / (2**int'(exponent));
    
    // synthesis translate_on
    
endmodule: pipelined_fixed_isqrt




/*
    //------------------------------------------------------------------------------------
    //      Модуль нормализации входных данных. Масштабирует входное целое без знака.
    //      В результате масштабирования получается дробное без знака их диапазона
    //      [0.25; 1). Латентность модуля - 3 такта
    pipelined_fixed_isqrt__scaler
    #(
        .WIDTH          ()  // Разрядность данных
    )
    the_pipelined_fixed_isqrt__scaler
    (
        // Сброс и тактирование
        .reset          (), // i
        .clk            (), // i
        
        // Разрешение тактирования
        .clkena         (), // i
        
        // Входные данные (целое без знака)
        .idata          (), // i  [WIDTH - 1 : 0]
        
        // Выходные данные (дробное без знака из промежутка [0.25; 1))
        .odata          (), // o  [WIDTH - 1 : 0]
        
        // Выходной порядок обратного масштабирования
        .scale          ()  // o  [$clog2(WIDTH) - 1 : 0]
    ); // the_pipelined_fixed_isqrt__scaler
*/

module pipelined_fixed_isqrt__scaler
#(
    parameter int unsigned                  WIDTH = 7   // Разрядность данных
)
(
    // Сброс и тактирование
    input  logic                            reset,
    input  logic                            clk,
    
    // Разрешение тактирования
    input  logic                            clkena,
    
    // Входные данные (целое без знака)
    input  logic [WIDTH - 1 : 0]            idata,
    
    // Выходные данные (дробное без знака из промежутка [0.25; 1))
    output logic [WIDTH - 1 : 0]            odata,
    
    // Выходной порядок обратного масштабирования
    output logic [$clog2(WIDTH) - 1 : 0]    scale
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned     NWIDTH = WIDTH + WIDTH[0];  // Нормализованная разрядность
    
    //------------------------------------------------------------------------------------
    //      Функция реверса разрядов
    function logic [NWIDTH - 1 : 0] reverse(input logic [NWIDTH - 1 : 0] data);
        for (int i = 0; i < NWIDTH; i++)
            reverse[i] = data[NWIDTH - i - 1];
    endfunction
    
    //------------------------------------------------------------------------------------
    //      Функция преобразования позиционного кода в двоичный
    function logic [$clog2(NWIDTH) - 1 : 0] onehot2binary(input logic [NWIDTH - 1 : 0] onehot);
        automatic logic [$clog2(NWIDTH) - 1 : 0] binary;
        for (int i = 0; i < $clog2(NWIDTH); i++) begin
            automatic logic [NWIDTH - 1 : 0] mask;
            for (int j = 0; j < NWIDTH; j++) begin
                mask[j] = j[i];
            end
            binary[i] = |(mask & onehot);
        end
        onehot2binary = binary;
    endfunction
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [NWIDTH - 1 : 0]          idata_ext;
    logic [NWIDTH - 1 : 0]          msb_pos_reg;
    logic [$clog2(NWIDTH) - 1 : 0]  msb_num;
    logic [$clog2(NWIDTH) - 1 : 0]  shift_cnt_reg;
    logic [1 : 0][NWIDTH - 1 : 0]   data_dly_reg;
    logic [NWIDTH - 1 : 0]          scaled_data_reg;
    logic [$clog2(NWIDTH) - 1 : 0]  scale_reg;
    
    //------------------------------------------------------------------------------------
    //      Расширение входных данных при нечетной разрядности
    assign idata_ext = {{WIDTH[0]{1'b0}}, idata};
    
    //------------------------------------------------------------------------------------
    //      Регистр позиции первого единичного разряда, начиная со старшего
    always @(posedge reset, posedge clk)
        if (reset)
            msb_pos_reg <= '0;
        else if (clkena)
            msb_pos_reg <= reverse(idata_ext) & (~reverse(idata_ext) + 1'b1);
        else
            msb_pos_reg <= msb_pos_reg;
    /*
    //------------------------------------------------------------------------------------
    //      Преобразователь позиционного кода в двоичный
    onehot2binary
    #(
        .WIDTH      (NWIDTH)        // Разрядность входа позиционного кода
    )
    msb_onehot2binary
    (
        .onehot     (msb_pos_reg),  // i  [WIDTH - 1 : 0]
        .binary     (msb_num)       // o  [$clog2(WIDTH) - 1 : 0]
    ); // msb_onehot2binary
    */
    
    //------------------------------------------------------------------------------------
    //      Преобразование позиционного кода в двоичный
    assign msb_num = onehot2binary(msb_pos_reg);
    
    //------------------------------------------------------------------------------------
    //      Счетчик необходимой величины сдвига
    always @(posedge reset, posedge clk)
        if (reset)
            shift_cnt_reg <= '0;
        else if (clkena)
            shift_cnt_reg <= {msb_num[$clog2(NWIDTH) - 1 : 1], 1'b0};
        else
            shift_cnt_reg <= shift_cnt_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр задержки данных на период расчета порядка масштабирования
    always @(posedge reset, posedge clk)
        if (reset)
            data_dly_reg <= '0;
        else if (clkena)
            data_dly_reg <= {data_dly_reg[0], idata_ext};
        else
            data_dly_reg <= data_dly_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр масштабированных данных
    always @(posedge reset, posedge clk)
        if (reset)
            scaled_data_reg <= '0;
        else if (clkena)
            scaled_data_reg <= data_dly_reg[1] << shift_cnt_reg;
        else
            scaled_data_reg <= scaled_data_reg;
    assign odata = scaled_data_reg[NWIDTH - 1 : WIDTH[0]];
    
    //------------------------------------------------------------------------------------
    //      Регистр выходного порядка масштабирования
    always @(posedge reset, posedge clk)
        if (reset)
            scale_reg <= '0;
        else if (clkena)
            scale_reg <= NWIDTH[$clog2(NWIDTH) - 1 : 0] - shift_cnt_reg;
        else
            scale_reg <= scale_reg;
    assign scale = scale_reg;
    
endmodule: pipelined_fixed_isqrt__scaler




/*
    //------------------------------------------------------------------------------------
    //      Модуль аппроксимации выражения 1/sqrt(x) на полуинтервале [0.25; 1)
    //      полиномом 3-ей степени. Латентность модуля - 4 такта.
    pipelined_fixed_isqrt__approximator
    #(
        .WIDTH      ()  // Разрядность данных
    )
    the_pipelined_fixed_isqrt__approximator
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Входные данные (дробное без знака из промежутка [0.25; 1))
        .idata      (), // i  [WIDTH - 1 : 0]
        
        // Выходные данные (дробная часть дробного без знака из 
        // промежутка (1; 2) - целая чать всегда полагается равной 1)
        .odata      ()  // o  [WIDTH - 1 : 0]
    ); // the_pipelined_fixed_isqrt__approximator
*/

module pipelined_fixed_isqrt__approximator
#(
    parameter int unsigned          WIDTH = 8  // Разрядность данных
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Входные данные (дробное без знака из промежутка [0.25; 1))
    input  logic [WIDTH - 1 : 0]    idata,
    
    // Выходные данные (дробная часть дробного без знака из 
    // промежутка (1; 2) - целая чать всегда полагается равной 1)
    output logic [WIDTH - 1 : 0]    odata
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam int unsigned         EWIDTH = 3;                 // Добавочная разрядность для представления целой части коэффициентов
    //
    // localparam logic [55 : 0]       P0 = 56'h62187F7C4EB054;    // 3.0654904773596265
    // localparam logic [55 : 0]       P1 = 56'hB69F0CCCB0C530;    // 5.7069152829991818
    // localparam logic [55 : 0]       P2 = 56'hBF0E0D39900B58;    // 5.9704652904768905
    // localparam logic [55 : 0]       P3 = 56'h4AEC94DDE21F94;    // 2.3413795789392560
    //
    localparam logic [55 : 0]       P0 = 56'h628d83ab5fe2d4;    // 3.0949042083210760
    localparam logic [55 : 0]       P1 = 56'hb5a5383962d130;    // 5.7703255615749489
    localparam logic [55 : 0]       P2 = 56'hb83b0a5bce3f50;    // 5.9308838451699994
    localparam logic [55 : 0]       P3 = 56'h44f88f59b7e684;    // 2.2529995891016239
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH + EWIDTH - 1 : 0]      p0;
    logic [WIDTH + EWIDTH - 1 : 0]      p1;
    logic [WIDTH + EWIDTH - 1 : 0]      p2;
    logic [WIDTH + EWIDTH - 1 : 0]      p3;
    //
    logic [2*WIDTH - 1 : 0]             x2;
    logic [2*WIDTH - 1 : 0]             x3;
    logic [2*WIDTH + EWIDTH - 1 : 0]    p1x1;
    logic [2*WIDTH + EWIDTH - 1 : 0]    p2x2;
    logic [2*WIDTH + EWIDTH - 1 : 0]    p3x3;
    //
    logic [WIDTH - 1 : 0]               x1_reg;
    logic [WIDTH - 1 : 0]               x2_reg;
    logic [WIDTH - 1 : 0]               x3_reg;
    //
    logic [WIDTH + EWIDTH - 1 : 0]      p1x1_reg;
    logic [WIDTH + EWIDTH - 1 : 0]      p2x2_reg;
    logic [WIDTH + EWIDTH - 1 : 0]      p3x3_reg;
    //
    logic [WIDTH + EWIDTH - 1 : 0]      p1x1_p0_reg;
    logic [WIDTH + EWIDTH - 1 : 0]      p2x2_p1x1_p0_reg;
    logic [WIDTH + EWIDTH - 1 : 0]      p3x3_p2x2_p1x1_p0_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование коэффициентов заданной разрядности
    generate
        // Если разрядность данных меньше максимальной
        if (WIDTH + EWIDTH < 56) begin
            assign p0 = P0[55 : 56 - (WIDTH + EWIDTH)] + P0[56 - (WIDTH + EWIDTH + 1)];
            assign p1 = P1[55 : 56 - (WIDTH + EWIDTH)] + P1[56 - (WIDTH + EWIDTH + 1)];
            assign p2 = P2[55 : 56 - (WIDTH + EWIDTH)] + P2[56 - (WIDTH + EWIDTH + 1)];
            assign p3 = P3[55 : 56 - (WIDTH + EWIDTH)] + P3[56 - (WIDTH + EWIDTH + 1)];
        end
            
        // Если разрядность данных больше либо равна максимальной
        else begin
            assign p0 = {P0, {WIDTH + EWIDTH - 56{1'b0}}};
            assign p1 = {P1, {WIDTH + EWIDTH - 56{1'b0}}};
            assign p2 = {P2, {WIDTH + EWIDTH - 56{1'b0}}};
            assign p3 = {P3, {WIDTH + EWIDTH - 56{1'b0}}};
        end
    endgenerate
    
    //------------------------------------------------------------------------------------
    //      Регистр x
    always @(posedge reset, posedge clk)
        if (reset)
            x1_reg <= '0;
        else if (clkena)
            x1_reg <= idata;
        else
            x1_reg <= x1_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель x^2
    assign x2 = idata * (* multstyle = "dsp" *) idata;
    
    //------------------------------------------------------------------------------------
    //      Регистр x^2
    always @(posedge reset, posedge clk)
        if (reset)
            x2_reg <= '0;
        else if (clkena)
            x2_reg <= x2[2*WIDTH - 1 : WIDTH];
        else
            x2_reg <= x2_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель p1*x
    assign p1x1 = p1 * (* multstyle = "dsp" *) idata;
    
    //------------------------------------------------------------------------------------
    //      Регистр p1*x
    always @(posedge reset, posedge clk)
        if (reset)
            p1x1_reg <= '0;
        else if (clkena)
            p1x1_reg <= p1x1[2*WIDTH + EWIDTH - 1 : WIDTH];
        else
            p1x1_reg <= p1x1_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель x^3
    assign x3 = x1_reg * (* multstyle = "dsp" *) x2_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр x^3
    always @(posedge reset, posedge clk)
        if (reset)
            x3_reg <= '0;
        else if (clkena)
            x3_reg <= x3[2*WIDTH - 1 : WIDTH];
        else
            x3_reg <= x3_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель p2*x^2
    assign p2x2 = p2 * (* multstyle = "dsp" *) x2_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр p2*x^2
    always @(posedge reset, posedge clk)
        if (reset)
            p2x2_reg <= '0;
        else if (clkena)
            p2x2_reg <= p2x2[2*WIDTH + EWIDTH - 1 : WIDTH];
        else
            p2x2_reg <= p2x2_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сумматор -p1*x + p0
    always @(posedge reset, posedge clk)
        if (reset)
            p1x1_p0_reg <= '0;
        else if (clkena)
            p1x1_p0_reg <= p0 - p1x1_reg;
        else
            p1x1_p0_reg <= p1x1_p0_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель p3*x^3
    assign p3x3 = p3 * (* multstyle = "dsp" *) x3_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр p3*x^3
    always @(posedge reset, posedge clk)
        if (reset)
            p3x3_reg <= '0;
        else if (clkena)
            p3x3_reg <= p3x3[2*WIDTH + EWIDTH - 1 : WIDTH];
        else
            p3x3_reg <= p3x3_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сумматор p2*x^2 - p1*x + p0
    always @(posedge reset, posedge clk)
        if (reset)
            p2x2_p1x1_p0_reg <= '0;
        else if (clkena)
            p2x2_p1x1_p0_reg <= p2x2_reg + p1x1_p0_reg;
        else
            p2x2_p1x1_p0_reg <= p2x2_p1x1_p0_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сумматор -p3*x^3 + p2*x^2 -p1*x + p0
    always @(posedge reset, posedge clk)
        if (reset)
            p3x3_p2x2_p1x1_p0_reg <= '0;
        else if (clkena)
            p3x3_p2x2_p1x1_p0_reg <= p2x2_p1x1_p0_reg - p3x3_reg;
        else
            p3x3_p2x2_p1x1_p0_reg <= p3x3_p2x2_p1x1_p0_reg;
    
    //------------------------------------------------------------------------------------
    //      Формирование выходных данных
    assign odata = p3x3_p2x2_p1x1_p0_reg[WIDTH - 1 : 0];
    
endmodule: pipelined_fixed_isqrt__approximator



/*
    //------------------------------------------------------------------------------------
    //      Модуль выполнения одной итерации алгоритма Ньютона-Рафсона вычисления
    //      значения функции 1/sqrt(x). Латентность модуля - 4 такта.
    pipelined_fixed_isqrt__newton_iteration
    #(
        .WIDTH      ()  // Разрядность дробной части
    )
    the_pipelined_fixed_isqrt__newton_iteration
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Разрешение тактирования
        .clkena     (), // i
        
        // Значение подкоренного выражения (дробное 
        // без знака из промежутка [0.25; 1))
        .radical    (), // i  [WIDTH - 1 : 0]
        
        // Предыдущее приближенное значение (дробное без знака:
        // два старших разряда - целая часть остальные - дробная)
        .papprox    (), // i  [WIDTH + 1 : 0]
        
        // Следующее приближенное значение (дробное без знака:
        // два старших разряда - целая часть остальные - дробная)
        .napprox    ()  // o  [WIDTH + 1 : 0]
    ); // the_pipelined_fixed_isqrt__newton_iteration
*/

module pipelined_fixed_isqrt__newton_iteration
#(
    parameter int unsigned          WIDTH       // Разрядность дробной части
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,
    
    // Разрешение тактирования
    input  logic                    clkena,
    
    // Значение подкоренного выражения (дробное 
    // без знака из промежутка [0.25; 1))
    input  logic [WIDTH - 1 : 0]    radical,
    
    // Предыдущее приближенное значение (дробное без знака:
    // два старших разряда - целая часть, остальные - дробная)
    input  logic [WIDTH + 1 : 0]    papprox,
    
    // Следующее приближенное значение (дробное без знака:
    // два старших разряда - целая часть, остальные - дробная)
    output logic [WIDTH + 1 : 0]    napprox
);
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [2*WIDTH + 1 : 0]         xy;
    logic [2*WIDTH + 3 : 0]         y2;
    logic [2*WIDTH + 5 : 0]         xy3;
    //
    logic [WIDTH + 1 : 0]           xy_reg;
    logic [WIDTH + 3 : 0]           y2_reg;
    logic [WIDTH + 1 : 0]           y1_reg;
    logic [WIDTH + 2 : 0]           xy3_reg;
    logic [WIDTH + 2 : 0]           cy_reg;
    logic [WIDTH + 2 : 0]           cy_xy3_reg;
    logic [WIDTH + 1 : 0]           napprox_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель x*y(n)
    assign xy = radical * (* multstyle = "dsp" *) papprox;
    
    //------------------------------------------------------------------------------------
    //      Умножитель y(n)^2
    assign y2 = papprox * (* multstyle = "dsp" *) papprox;
    
    //------------------------------------------------------------------------------------
    //      Регистр x*y(n)
    always @(posedge reset, posedge clk)
        if (reset)
            xy_reg <= '0;
        else if (clkena)
            xy_reg <= xy[2*WIDTH + 1 : WIDTH];
        else
            xy_reg <= xy_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр y(n)*y(n)
    always @(posedge reset, posedge clk)
        if (reset)
            y2_reg <= '0;
        else if (clkena)
            y2_reg <= y2[2*WIDTH + 3 : WIDTH];
        else
            y2_reg <= y2_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр y(n)
    always @(posedge reset, posedge clk)
        if (reset)
            y1_reg <= '0;
        else if (clkena)
            y1_reg <= papprox;
        else
            y1_reg <= y1_reg;
    
    //------------------------------------------------------------------------------------
    //      Умножитель xy(n)^2*y(n)
    assign xy3 = xy_reg * (* multstyle = "dsp" *) y2_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр xy(n)^2*y(n)
    always @(posedge reset, posedge clk)
        if (reset)
            xy3_reg <= '0;
        else if (clkena)
            xy3_reg <= xy3[2*WIDTH + 2: WIDTH];
        else
            xy3_reg <= xy3_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сумматор 3*y(n)
    always @(posedge reset, posedge clk)
        if (reset)
            cy_reg <= '0;
        else if (clkena)
            cy_reg <= {1'b0, y1_reg} + {y1_reg, 1'b0};
        else
            cy_reg <= cy_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр сумматор 3*y(n) - xy(n)^3
    always @(posedge reset, posedge clk)
        if (reset)
            cy_xy3_reg <= '0;
        else if (clkena)
            cy_xy3_reg <= cy_reg - xy3_reg;
        else
            cy_xy3_reg <= '0;
    
    //------------------------------------------------------------------------------------
    //      Формирование следующего приближенного значения
    assign napprox = cy_xy3_reg[WIDTH + 2 : 1];
    
endmodule: pipelined_fixed_isqrt__newton_iteration
