module debounce
  (input logic  btn,
   input logic  clck,
   output logic debounced
   );

   logic [9:0]  divide;
   logic [15:0] buffer;

   always_ff @(posedge clck) begin
      if(divide == 0) begin
         buffer[15:1] = buffer[14:0];
         buffer[0] = ~btn;
         debounced = |buffer;
      end
      divide += 1;
   end

endmodule
