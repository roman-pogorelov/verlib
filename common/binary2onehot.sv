/*
    // Binary to one hot converter
    binary2onehot
    #(
        .BIN_WIDTH  ()  // Binary bus width
    )
    the_binary2onehot
    (
        .binary     (), // i  [BIN_WIDTH - 1 : 0]
        .onehot     ()  // o  [2**BIN_WIDTH - 1 : 0]
    ); // the_binary2onehot
*/


module binary2onehot
#(
    parameter int unsigned              BIN_WIDTH = 4,              // Binary bus width
    parameter int unsigned              OH_WIDTH  = 2**BIN_WIDTH    // One hot bus width
)
(
    input  logic [BIN_WIDTH - 1 : 0]    binary,
    output logic [OH_WIDTH - 1 : 0]     onehot
);

    // Encoding
    always_comb begin
        onehot = '0;
        onehot[binary] = '1;
    end


endmodule // binary2onehot