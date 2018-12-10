module debounce
  (input logic  btn,
   input logic  clck,
   output logic debounced
   );

   logic [10:0] buffer;

   assign debounced = |buffer;

   always_ff @(posedge clck) begin
      buffer[10:1] = buffer[9:0];
      buffer[0] = ~btn;
   end

endmodule
