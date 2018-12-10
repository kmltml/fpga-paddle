module ball
  (input logic       clck,
   input logic       reset,
   input logic [9:0] vgax,
   input logic [8:0] vgay,
   input logic       update,
   output logic      pixel);

   const int    SCREEN_WIDTH  = 640;
   const int    SCREEN_HEIGHT = 480;
   const int    BALL_SIZE = 10;
   
   logic [9:0]  x;
   logic [9:0]  y;
   logic [3:0]  xv;
   logic [3:0]  yv;

   always_ff @(posedge clck) begin
      if(reset) begin
         x = SCREEN_WIDTH / 2 - BALL_SIZE / 2;
         y = SCREEN_HEIGHT / 2 - BALL_SIZE / 2;
         xv = 5;
         yv = 5;
      end else begin
         if(update) begin
            x = x + xv - 4;
            y = y + yv - 4;
            if(xv < 4 && x < 8 - xv) begin
               xv = 8 - xv;
            end else if(xv > 4 && x >= SCREEN_WIDTH - BALL_SIZE - (xv - 4)) begin
               xv = 8 - xv;
            end
            if(yv < 4 && y < 8 - yv) begin
               yv = 8 - yv;
            end else if(yv > 4 && y >= SCREEN_HEIGHT - BALL_SIZE - (yv - 4)) begin
               yv = 8 - yv;
            end
         end
      end
   end // always_ff @ (negedge clck or reset)

   always_ff @(posedge clck) begin
      pixel = vgax >= x && vgax <= x + BALL_SIZE && vgay >= y && vgay <= y + BALL_SIZE;
   end

endmodule
