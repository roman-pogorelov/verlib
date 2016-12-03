/*
    //------------------------------------------------------------------------------------
    //      Преобразователь двоичного кода в позиционный
    binary2onehot
    #(
        .BIN_WIDTH  ()  // Разрядность входа двоичного кода
    )
    the_binary2onehot
    (
        .binary     (), // i  [BIN_WIDTH - 1 : 0]
        .onehot     ()  // o  [2**BIN_WIDTH - 1 : 0]
    ); // the_binary2onehot
*/

module binary2onehot
#(
    parameter int unsigned              BIN_WIDTH = 4,              // Разрядность входа двоичного кода
    parameter int unsigned              OH_WIDTH  = 2**BIN_WIDTH    // Разрядность выхода позиционного кода
)
(
    input  logic [BIN_WIDTH - 1 : 0]    binary,
    output logic [OH_WIDTH - 1 : 0]     onehot
);

    //------------------------------------------------------------------------------------
    //      Схема кодирования
    always_comb begin
        onehot = '0;
        onehot[binary] = '1;
    end

endmodule // binary2onehot