module paddle
  (input logic       left,
   input logic       right,
   input logic       update,
   input logic       clck, 
   input logic [9:0] vgax,
   input logic [8:0] vgay,
   output logic      pixel);

   const int         SCREEN_WIDTH = 640;
   const int         PADDLE_WIDTH = 50;
   const int         PADDLE_MIN_Y = 440;
   const int         PADDLE_MAX_Y = 460;
   const int         X_SPEED = 2;
   
   logic [9:0]       x;

   always_ff @(posedge update) begin
      if(!left && right) begin
         if(x + X_SPEED + PADDLE_WIDTH >= SCREEN_WIDTH) begin
            x = SCREEN_WIDTH - PADDLE_WIDTH;
         end else begin
            x += X_SPEED;
         end
      end else if(left && !right) begin
         if(x <= X_SPEED + 2) begin
            x = 2;
         end else begin
            x -= X_SPEED;
         end
      end
   end

   always_ff @(posedge clck) begin
      pixel = vgay >= PADDLE_MIN_Y && vgay <= PADDLE_MAX_Y && vgax >= x && vgax <= x + PADDLE_WIDTH;
   end
   

endmodule
