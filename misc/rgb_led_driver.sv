/*
    //------------------------------------------------------------------------------------
    //      Модуль управления RGB-светодиодом посредством ШИМ-модуляции
    //                  Fpwm = Fclk/(DIVISOR*COUNT)
    rgb_led_driver
    #(
        .DIVISOR    (), // Делитель определяющий интервал времени между переключением счетчика ШИМ
        .COUNT      (), // Количество состояний счетчика ШИМ (счет идет от 0 до COUNT - 1)
        .INVERT     ()  // Режим прямого/инверсного управления (0/1)
    )
    the_rgb_led_driver
    (
        // Сброс и тактирование
        .reset      (), // i
        .clk        (), // i
        
        // Общее включение
        .ctrl_on    (), // i
        
        // Интерфейс управления цветом
        .ctrl_r     (), // i  [$clog2(COUNT + 1) - 1 : 0]
        .ctrl_g     (), // i  [$clog2(COUNT + 1) - 1 : 0]
        .ctrl_b     (), // i  [$clog2(COUNT + 1) - 1 : 0]
        
        // Интерфейс управления RGB-светодиодом
        .led_r      (), // o
        .led_g      (), // o
        .led_b      ()  // o
    ); // the_rgb_led_driver
*/
module rgb_led_driver
#(
    parameter int unsigned                      DIVISOR = 1,    // Делитель, определяющий интервал времени между переключением счетчика ШИМ
    parameter int unsigned                      COUNT   = 7,    // Количество состояний счетчика ШИМ (счет идет от 0 до COUNT - 1)
    parameter int unsigned                      INVERT  = 1     // Режим прямого/инверсного управления (0/1)
)
(
    // Сброс и тактирование
    input  logic                                reset,
    input  logic                                clk,
    
    // Общее включение
    input  logic                                ctrl_on,
    
    // Интерфейс управления цветом
    input  logic [$clog2(COUNT + 1) - 1 : 0]    ctrl_r,
    input  logic [$clog2(COUNT + 1) - 1 : 0]    ctrl_g,
    input  logic [$clog2(COUNT + 1) - 1 : 0]    ctrl_b,
    
    // Интерфейс управления RGB-светодиодом
    output logic                                led_r,
    output logic                                led_g,
    output logic                                led_b
);
    //------------------------------------------------------------------------------------
    //      Описание сигналов
    logic [$clog2(DIVISOR) - 1 : 0]             ena_cnt;    // Счетчик генерации сигналов разрешения переключения счетчика ШИМ
    logic                                       ena_reg;    // Регистр разрешения переключения счетчика ШИМ
    //
    logic [$clog2(COUNT + 1) - 1 : 0]           r_reg;      // Регистр управления интенсивностю свечения красного светодиода
    logic [$clog2(COUNT + 1) - 1 : 0]           g_reg;      // Регистр управления интенсивностю свечения зеленого светодиода
    logic [$clog2(COUNT + 1) - 1 : 0]           b_reg;      // Регистр управления интенсивностю свечения синего светодиода
    //
    logic [$clog2(COUNT) - 1 : 0]               pwm_cnt;    // Счетчик ШИМ
    //
    logic                                       led_r_reg;  // Регистр управления красным светодиодом
    logic                                       led_g_reg;  // Регистр управления зеленым светодиодом
    logic                                       led_b_reg;  // Регистр управления синим светодиодом
    
    //------------------------------------------------------------------------------------
    //      Счетчик генерации сигналов разрешения переключения счетчика ШИМ
    always @(posedge reset, posedge clk)
        if (reset)
            ena_cnt <= '0;
        else if (ena_cnt == (DIVISOR - 1))
            ena_cnt <= '0;
        else
            ena_cnt <= ena_cnt + 1'b1;
    
    //------------------------------------------------------------------------------------
    //      Регистр разрешения переключения счетчика ШИМ
    always @(posedge reset, posedge clk)
        if (reset)
            ena_reg <= '0;
        else
            ena_reg <= ~|ena_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления интенсивностю свечения красного светодиода
    always @(posedge reset, posedge clk)
        if (reset)
            r_reg <= '0;
        else if (~|ena_cnt)
            if (ctrl_r > COUNT)
                r_reg <= COUNT[$clog2(COUNT) - 1 : 0];
            else
                r_reg <= ctrl_r;
        else
            r_reg <= r_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления интенсивностю свечения зеленого светодиода
    always @(posedge reset, posedge clk)
        if (reset)
            g_reg <= '0;
        else if (~|ena_cnt)
            if (ctrl_g > COUNT)
                g_reg <= COUNT[$clog2(COUNT) - 1 : 0];
            else
                g_reg <= ctrl_g;
        else
            g_reg <= g_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления интенсивностю свечения синего светодиода
    always @(posedge reset, posedge clk)
        if (reset)
            b_reg <= '0;
        else if (~|ena_cnt)
            if (ctrl_b > COUNT)
                b_reg <= COUNT[$clog2(COUNT) - 1 : 0];
            else
                b_reg <= ctrl_b;
        else
            b_reg <= b_reg;
    
    //------------------------------------------------------------------------------------
    //      Счетчик ШИМ
    always @(posedge reset, posedge clk)
        if (reset)
            pwm_cnt <= '0;
        else if (ena_reg)
            if (pwm_cnt == (COUNT - 1))
                pwm_cnt <= '0;
            else
                pwm_cnt <= pwm_cnt + 1'b1;
        else
            pwm_cnt <= pwm_cnt;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления красным светодиодом
    initial led_r_reg = INVERT ? '1 : '0;
    always @(posedge reset, posedge clk)
        if (reset)
            led_r_reg <= INVERT ? '1 : '0;
        else if (ctrl_on)
            led_r_reg <= INVERT ? ~(r_reg > pwm_cnt) : (r_reg > pwm_cnt);
        else
            led_r_reg <= INVERT ? '1 : '0;
    assign led_r = led_r_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления зеленым светодиодом
    initial led_g_reg = INVERT ? '1 : '0;
    always @(posedge reset, posedge clk)
        if (reset)
            led_g_reg <= INVERT ? '1 : '0;
        else if (ctrl_on)
            led_g_reg <= INVERT ? ~(g_reg > pwm_cnt) : (g_reg > pwm_cnt);
        else
            led_g_reg <= INVERT ? '1 : '0;
    assign led_g = led_g_reg;
    
    //------------------------------------------------------------------------------------
    //      Регистр управления синим светодиодом
    initial led_b_reg = INVERT ? '1 : '0;
    always @(posedge reset, posedge clk)
        if (reset)
            led_b_reg <= INVERT ? '1 : '0;
        else if (ctrl_on)
            led_b_reg <= INVERT ? ~(b_reg > pwm_cnt) : (b_reg > pwm_cnt);
        else
            led_b_reg <= INVERT ? '1 : '0;
    assign led_b = led_b_reg;
    
endmodule: rgb_led_driver