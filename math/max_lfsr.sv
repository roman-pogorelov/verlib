/*
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр с линейной обратной связью с максимальным циклом
    //      повторения (цикл повторения равен 2**WIDTH - 1)
    max_lfsr
    #(
        .WIDTH      (), // Разрядность (1 < WIDTH <= 256)
        .INITIAL    ()  // Начальное значение сдвигового регистра (INITIAL != 0)
    )
    the_max_lfsr
    (
        // Сброс и тактирование
        reset       (), // i
        clk         (), // i

        // Разрешение тактирования
        clkena      (), // i

        // Выход
        .data       ()  // o  [WIDTH - 1 : 0]
    ); // max_lfsr
*/

module max_lfsr
#(
    parameter int unsigned          WIDTH   = 32,   // Разрядность (1 < WIDTH <= 256)
    parameter logic [WIDTH - 1 : 0] INITIAL = 1     // Начальное значение сдвигового регистра (INITIAL != 0)
)
(
    // Сброс и тактирование
    input  logic                    reset,
    input  logic                    clk,

    // Разрешение тактирования
    input  logic                    clkena,

    // Выход
    output logic [WIDTH - 1 : 0]    data
);
    //------------------------------------------------------------------------------------
    //      Описание констант
    localparam logic [0 : 255][0 : 2][7 : 0] LFSR4_TABLE = {
        {8'dx,   8'dx,   8'dx  },  // 1
        {8'dx,   8'dx,   8'dx  },  // 2
        {8'dx,   8'dx,   8'dx  },  // 3
        {8'dx,   8'dx,   8'dx  },  // 4
        {8'd4,   8'd3,   8'd2  },  // 5
        {8'd5,   8'd3,   8'd2  },  // 6
        {8'd6,   8'd5,   8'd4  },  // 7
        {8'd6,   8'd5,   8'd4  },  // 8
        {8'd8,   8'd6,   8'd5  },  // 9
        {8'd9,   8'd7,   8'd6  },  // 10
        {8'd10,  8'd9,   8'd7  },  // 11
        {8'd11,  8'd8,   8'd6  },  // 12
        {8'd12,  8'd10,  8'd9  },  // 13
        {8'd13,  8'd11,  8'd9  },  // 14
        {8'd14,  8'd13,  8'd11 },  // 15
        {8'd14,  8'd13,  8'd11 },  // 16
        {8'd16,  8'd15,  8'd14 },  // 17
        {8'd17,  8'd16,  8'd13 },  // 18
        {8'd18,  8'd17,  8'd14 },  // 19
        {8'd19,  8'd16,  8'd14 },  // 20
        {8'd20,  8'd19,  8'd16 },  // 21
        {8'd19,  8'd18,  8'd17 },  // 22
        {8'd22,  8'd20,  8'd18 },  // 23
        {8'd23,  8'd21,  8'd20 },  // 24
        {8'd24,  8'd23,  8'd22 },  // 25
        {8'd25,  8'd24,  8'd20 },  // 26
        {8'd26,  8'd25,  8'd22 },  // 27
        {8'd27,  8'd24,  8'd22 },  // 28
        {8'd28,  8'd27,  8'd25 },  // 29
        {8'd29,  8'd26,  8'd24 },  // 30
        {8'd30,  8'd29,  8'd28 },  // 31
        {8'd30,  8'd26,  8'd25 },  // 32
        {8'd32,  8'd29,  8'd27 },  // 33
        {8'd31,  8'd30,  8'd26 },  // 34
        {8'd34,  8'd28,  8'd27 },  // 35
        {8'd35,  8'd29,  8'd28 },  // 36
        {8'd36,  8'd33,  8'd31 },  // 37
        {8'd37,  8'd33,  8'd32 },  // 38
        {8'd38,  8'd35,  8'd32 },  // 39
        {8'd37,  8'd36,  8'd35 },  // 40
        {8'd40,  8'd39,  8'd38 },  // 41
        {8'd40,  8'd37,  8'd35 },  // 42
        {8'd42,  8'd38,  8'd37 },  // 43
        {8'd42,  8'd39,  8'd38 },  // 44
        {8'd44,  8'd42,  8'd41 },  // 45
        {8'd40,  8'd39,  8'd38 },  // 46
        {8'd46,  8'd43,  8'd42 },  // 47
        {8'd44,  8'd41,  8'd39 },  // 48
        {8'd45,  8'd44,  8'd43 },  // 49
        {8'd48,  8'd47,  8'd46 },  // 50
        {8'd50,  8'd48,  8'd45 },  // 51
        {8'd51,  8'd49,  8'd46 },  // 52
        {8'd52,  8'd51,  8'd47 },  // 53
        {8'd51,  8'd48,  8'd46 },  // 54
        {8'd54,  8'd53,  8'd49 },  // 55
        {8'd54,  8'd52,  8'd49 },  // 56
        {8'd55,  8'd54,  8'd52 },  // 57
        {8'd57,  8'd53,  8'd52 },  // 58
        {8'd57,  8'd55,  8'd52 },  // 59
        {8'd58,  8'd56,  8'd55 },  // 60
        {8'd60,  8'd59,  8'd56 },  // 61
        {8'd59,  8'd57,  8'd56 },  // 62
        {8'd62,  8'd59,  8'd58 },  // 63
        {8'd63,  8'd61,  8'd60 },  // 64
        {8'd64,  8'd62,  8'd61 },  // 65
        {8'd60,  8'd58,  8'd57 },  // 66
        {8'd66,  8'd65,  8'd62 },  // 67
        {8'd67,  8'd63,  8'd61 },  // 68
        {8'd67,  8'd64,  8'd63 },  // 69
        {8'd69,  8'd67,  8'd65 },  // 70
        {8'd70,  8'd68,  8'd66 },  // 71
        {8'd69,  8'd63,  8'd62 },  // 72
        {8'd71,  8'd70,  8'd69 },  // 73
        {8'd71,  8'd70,  8'd67 },  // 74
        {8'd74,  8'd72,  8'd69 },  // 75
        {8'd74,  8'd72,  8'd71 },  // 76
        {8'd75,  8'd72,  8'd71 },  // 77
        {8'd77,  8'd76,  8'd71 },  // 78
        {8'd77,  8'd76,  8'd75 },  // 79
        {8'd78,  8'd76,  8'd71 },  // 80
        {8'd79,  8'd78,  8'd75 },  // 81
        {8'd78,  8'd76,  8'd73 },  // 82
        {8'd81,  8'd79,  8'd76 },  // 83
        {8'd83,  8'd77,  8'd75 },  // 84
        {8'd84,  8'd83,  8'd77 },  // 85
        {8'd84,  8'd81,  8'd80 },  // 86
        {8'd86,  8'd82,  8'd80 },  // 87
        {8'd80,  8'd79,  8'd77 },  // 88
        {8'd86,  8'd84,  8'd83 },  // 89
        {8'd88,  8'd87,  8'd85 },  // 90
        {8'd90,  8'd86,  8'd83 },  // 91
        {8'd90,  8'd87,  8'd86 },  // 92
        {8'd91,  8'd90,  8'd87 },  // 93
        {8'd93,  8'd89,  8'd88 },  // 94
        {8'd94,  8'd90,  8'd88 },  // 95
        {8'd90,  8'd87,  8'd86 },  // 96
        {8'd95,  8'd93,  8'd91 },  // 97
        {8'd97,  8'd91,  8'd90 },  // 98
        {8'd95,  8'd94,  8'd92 },  // 99
        {8'd98,  8'd93,  8'd92 },  // 100
        {8'd100, 8'd95,  8'd94 },  // 101
        {8'd99,  8'd97,  8'd96 },  // 102
        {8'd102, 8'd99,  8'd94 },  // 103
        {8'd103, 8'd94,  8'd93 },  // 104
        {8'd104, 8'd99,  8'd98 },  // 105
        {8'd105, 8'd101, 8'd100},  // 106
        {8'd105, 8'd99,  8'd98 },  // 107
        {8'd103, 8'd97,  8'd96 },  // 108
        {8'd107, 8'd105, 8'd104},  // 109
        {8'd109, 8'd106, 8'd104},  // 110
        {8'd109, 8'd107, 8'd104},  // 111
        {8'd108, 8'd106, 8'd101},  // 112
        {8'd111, 8'd110, 8'd108},  // 113
        {8'd113, 8'd112, 8'd103},  // 114
        {8'd110, 8'd108, 8'd107},  // 115
        {8'd114, 8'd111, 8'd110},  // 116
        {8'd116, 8'd115, 8'd112},  // 117
        {8'd116, 8'd113, 8'd112},  // 118
        {8'd116, 8'd111, 8'd110},  // 119
        {8'd118, 8'd114, 8'd111},  // 120
        {8'd120, 8'd116, 8'd113},  // 121
        {8'd121, 8'd120, 8'd116},  // 122
        {8'd122, 8'd119, 8'd115},  // 123
        {8'd119, 8'd118, 8'd117},  // 124
        {8'd120, 8'd119, 8'd118},  // 125
        {8'd124, 8'd122, 8'd119},  // 126
        {8'd126, 8'd124, 8'd120},  // 127
        {8'd127, 8'd126, 8'd121},  // 128
        {8'd128, 8'd125, 8'd124},  // 129
        {8'd129, 8'd128, 8'd125},  // 130
        {8'd129, 8'd128, 8'd123},  // 131
        {8'd130, 8'd127, 8'd123},  // 132
        {8'd131, 8'd125, 8'd124},  // 133
        {8'd133, 8'd129, 8'd127},  // 134
        {8'd132, 8'd131, 8'd129},  // 135
        {8'd134, 8'd133, 8'd128},  // 136
        {8'd136, 8'd133, 8'd126},  // 137
        {8'd137, 8'd131, 8'd130},  // 138
        {8'd136, 8'd134, 8'd131},  // 139
        {8'd139, 8'd136, 8'd132},  // 140
        {8'd140, 8'd135, 8'd128},  // 141
        {8'd141, 8'd139, 8'd132},  // 142
        {8'd141, 8'd140, 8'd138},  // 143
        {8'd142, 8'd140, 8'd137},  // 144
        {8'd144, 8'd140, 8'd139},  // 145
        {8'd144, 8'd143, 8'd141},  // 146
        {8'd145, 8'd143, 8'd136},  // 147
        {8'd145, 8'd143, 8'd141},  // 148
        {8'd142, 8'd140, 8'd139},  // 149
        {8'd148, 8'd147, 8'd142},  // 150
        {8'd150, 8'd149, 8'd148},  // 151
        {8'd150, 8'd149, 8'd146},  // 152
        {8'd149, 8'd148, 8'd145},  // 153
        {8'd153, 8'd149, 8'd145},  // 154
        {8'd151, 8'd150, 8'd148},  // 155
        {8'd153, 8'd151, 8'd147},  // 156
        {8'd155, 8'd152, 8'd151},  // 157
        {8'd153, 8'd152, 8'd150},  // 158
        {8'd156, 8'd153, 8'd148},  // 159
        {8'd158, 8'd157, 8'd155},  // 160
        {8'd159, 8'd158, 8'd155},  // 161
        {8'd158, 8'd155, 8'd154},  // 162
        {8'd160, 8'd157, 8'd156},  // 163
        {8'd159, 8'd158, 8'd152},  // 164
        {8'd162, 8'd157, 8'd156},  // 165
        {8'd164, 8'd163, 8'd156},  // 166
        {8'd165, 8'd163, 8'd161},  // 167
        {8'd162, 8'd159, 8'd152},  // 168
        {8'd164, 8'd163, 8'd161},  // 169
        {8'd169, 8'd166, 8'd161},  // 170
        {8'd169, 8'd166, 8'd165},  // 171
        {8'd169, 8'd165, 8'd161},  // 172
        {8'd171, 8'd168, 8'd165},  // 173
        {8'd169, 8'd166, 8'd165},  // 174
        {8'd173, 8'd171, 8'd169},  // 175
        {8'd167, 8'd165, 8'd164},  // 176
        {8'd175, 8'd174, 8'd172},  // 177
        {8'd176, 8'd171, 8'd170},  // 178
        {8'd178, 8'd177, 8'd175},  // 179
        {8'd173, 8'd170, 8'd168},  // 180
        {8'd180, 8'd175, 8'd174},  // 181
        {8'd181, 8'd176, 8'd174},  // 182
        {8'd179, 8'd176, 8'd175},  // 183
        {8'd177, 8'd176, 8'd175},  // 184
        {8'd184, 8'd182, 8'd177},  // 185
        {8'd180, 8'd178, 8'd177},  // 186
        {8'd182, 8'd181, 8'd180},  // 187
        {8'd186, 8'd183, 8'd182},  // 188
        {8'd187, 8'd184, 8'd183},  // 189
        {8'd188, 8'd184, 8'd177},  // 190
        {8'd187, 8'd185, 8'd184},  // 191
        {8'd190, 8'd178, 8'd177},  // 192
        {8'd189, 8'd186, 8'd184},  // 193
        {8'd192, 8'd191, 8'd190},  // 194
        {8'd193, 8'd192, 8'd187},  // 195
        {8'd194, 8'd187, 8'd185},  // 196
        {8'd195, 8'd193, 8'd188},  // 197
        {8'd193, 8'd190, 8'd183},  // 198
        {8'd198, 8'd195, 8'd190},  // 199
        {8'd198, 8'd197, 8'd195},  // 200
        {8'd199, 8'd198, 8'd195},  // 201
        {8'd198, 8'd196, 8'd195},  // 202
        {8'd202, 8'd196, 8'd195},  // 203
        {8'd201, 8'd200, 8'd194},  // 204
        {8'd203, 8'd200, 8'd196},  // 205
        {8'd201, 8'd197, 8'd196},  // 206
        {8'd206, 8'd201, 8'd198},  // 207
        {8'd207, 8'd205, 8'd199},  // 208
        {8'd207, 8'd206, 8'd204},  // 209
        {8'd207, 8'd206, 8'd198},  // 210
        {8'd203, 8'd201, 8'd200},  // 211
        {8'd209, 8'd208, 8'd205},  // 212
        {8'd211, 8'd208, 8'd207},  // 213
        {8'd213, 8'd211, 8'd209},  // 214
        {8'd212, 8'd210, 8'd209},  // 215
        {8'd215, 8'd213, 8'd209},  // 216
        {8'd213, 8'd212, 8'd211},  // 217
        {8'd217, 8'd211, 8'd210},  // 218
        {8'd218, 8'd215, 8'd211},  // 219
        {8'd211, 8'd210, 8'd208},  // 220
        {8'd219, 8'd215, 8'd213},  // 221
        {8'd220, 8'd217, 8'd214},  // 222
        {8'd221, 8'd219, 8'd218},  // 223
        {8'd222, 8'd217, 8'd212},  // 224
        {8'd224, 8'd220, 8'd215},  // 225
        {8'd223, 8'd219, 8'd216},  // 226
        {8'd223, 8'd218, 8'd217},  // 227
        {8'd226, 8'd217, 8'd216},  // 228
        {8'd228, 8'd225, 8'd219},  // 229
        {8'd224, 8'd223, 8'd222},  // 230
        {8'd229, 8'd227, 8'd224},  // 231
        {8'd228, 8'd223, 8'd221},  // 232
        {8'd232, 8'd229, 8'd224},  // 233
        {8'd232, 8'd225, 8'd223},  // 234
        {8'd234, 8'd229, 8'd226},  // 235
        {8'd229, 8'd228, 8'd226},  // 236
        {8'd236, 8'd233, 8'd230},  // 237
        {8'd237, 8'd236, 8'd233},  // 238
        {8'd238, 8'd232, 8'd227},  // 239
        {8'd237, 8'd235, 8'd232},  // 240
        {8'd237, 8'd233, 8'd232},  // 241
        {8'd241, 8'd236, 8'd231},  // 242
        {8'd242, 8'd238, 8'd235},  // 243
        {8'd243, 8'd240, 8'd235},  // 244
        {8'd244, 8'd241, 8'd239},  // 245
        {8'd245, 8'd244, 8'd235},  // 246
        {8'd245, 8'd243, 8'd238},  // 247
        {8'd238, 8'd234, 8'd233},  // 248
        {8'd248, 8'd245, 8'd242},  // 249
        {8'd247, 8'd245, 8'd240},  // 250
        {8'd249, 8'd247, 8'd244},  // 251
        {8'd251, 8'd247, 8'd241},  // 252
        {8'd252, 8'd247, 8'd246},  // 253
        {8'd253, 8'd252, 8'd247},  // 254
        {8'd253, 8'd252, 8'd250},  // 255
        {8'd254, 8'd251, 8'd246}   // 256
    };
    localparam logic [7 : 0] TAPS1 = LFSR4_TABLE[WIDTH - 1][0] - 8'd1;
    localparam logic [7 : 0] TAPS2 = LFSR4_TABLE[WIDTH - 1][1] - 8'd1;
    localparam logic [7 : 0] TAPS3 = LFSR4_TABLE[WIDTH - 1][2] - 8'd1;
    
    //------------------------------------------------------------------------------------
    //      Объявление сигналов
    logic [WIDTH - 1 : 0] lfs_reg;
    
    //------------------------------------------------------------------------------------
    //      Сдвиговый регистр с обратной связью
    initial lfs_reg = INITIAL;
    always @(posedge reset, posedge clk)
        if (reset) begin
            lfs_reg <= INITIAL;
        end
        else if (clkena) begin
            lfs_reg[WIDTH - 1] <= lfs_reg[0];
            for (int i = 0; i < WIDTH - 1; i++) begin
                if (((WIDTH < 5) & (i == WIDTH - 2)) | ((WIDTH >= 5) & ((i == TAPS1) | (i == TAPS2) | (i == TAPS3))))
                    lfs_reg[i] <= lfs_reg[i + 1] ^ lfs_reg[0];
                else
                    lfs_reg[i] <= lfs_reg[i + 1];
            end
        end
        else begin
            lfs_reg <= lfs_reg;
        end
    assign data = lfs_reg;
    
endmodule: max_lfsr