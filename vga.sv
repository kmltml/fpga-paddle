module hsync_controller
  (input logic        reset,
   input logic        clck,
   output logic       sync,
   output logic [9:0] x,
   output logic       lineStart,
   input logic        activeLine);

   logic [9:0]        counter;
   const int          FRONT_PORCH = 16;
   const int          SYNC_WIDTH = 96;
   const int          BACK_PORCH = 48;
   const int          ACTIVE_PIXELS = 640;

   always_ff @(posedge clck) begin
      if(reset) begin
         counter = 0;
      end else begin
         if(counter == FRONT_PORCH + SYNC_WIDTH + BACK_PORCH + ACTIVE_PIXELS - 1) begin
            counter = 0;
         end else begin         
            counter++;
         end
      end
   end

   always_ff @(negedge clck) begin
      if(!reset) begin
         sync = activeLine & (counter < FRONT_PORCH || counter >= FRONT_PORCH + SYNC_WIDTH);
         if(counter == 0) begin
            lineStart = 1;
         end else begin
            lineStart = 0;
         end
         if(counter < FRONT_PORCH + SYNC_WIDTH + BACK_PORCH) begin
            x = 0;
         end else begin
            if(activeLine) begin
               x = counter - (FRONT_PORCH + SYNC_WIDTH + BACK_PORCH);
            end else begin
               x = 0;
            end
         end
      end
   end

endmodule

module vsync_controller
  (input logic        reset,
   input logic        clck,
   input logic        lineStart,
   output logic       vsync,
   output logic [8:0] y,
   output logic       activeLine);

   logic [9:0]        counter;

   const int          FRONT_PORCH = 11;
   const int          SYNC_WIDTH = 2;
   const int          BACK_PORCH = 31;
   const int          ACTIVE_LINES = 480;

   always_ff @(posedge clck) begin
      if(!reset) begin
         if(lineStart) begin
            vsync = counter < FRONT_PORCH || counter >= FRONT_PORCH + SYNC_WIDTH;
            activeLine = counter >= FRONT_PORCH + SYNC_WIDTH + BACK_PORCH;
            if(counter < FRONT_PORCH + SYNC_WIDTH + BACK_PORCH) begin
               y = 0;
            end else begin
               y = counter - (FRONT_PORCH + SYNC_WIDTH + BACK_PORCH);
            end
         end
      end
   end

   always_ff @(negedge clck) begin
      if(reset) begin
         counter = 0;
      end else begin
         if(lineStart) begin
            if(counter == FRONT_PORCH + SYNC_WIDTH + BACK_PORCH + ACTIVE_LINES - 1) begin
               counter = 0;
            end else begin
               counter++;
            end
         end
      end
   end
   
endmodule

module poweronreset
  (input logic  clck,
   output logic reset);
   
   logic [5:0]  counter;

   always_ff @(posedge clck) begin
      if(counter == 0) begin
         reset = 0;
      end else begin
         reset = 1;
         counter++;
      end
   end

endmodule

module vga
  (input logic  clck,
   input logic  left_btn,
   input logic  right_btn,
   output logic hsync,
   output logic vsync,
   output logic r,
   output logic g,
   output logic b);

   logic        reset;
   logic        lineStart;
   logic        activeLine;

   logic [9:0]  x;
   logic [8:0]  y;

   poweronreset por(clck, reset);

   hsync_controller hsc(reset, clck, hsync, x, lineStart, activeLine);
   vsync_controller vsc(reset, clck, lineStart, vsync, y, activeLine);

   logic left;
   logic right;
   debounce ldb(left_btn, clck, left);
   debounce rdb(right_btn, clck, right);

   logic paddle_update;
   logic paddle_pixel;
   paddle pad(left, right, paddle_update, x, y, paddle_pixel);

   logic [2:0] update_counter;
   always_ff @(posedge clck) begin
      case(update_counter)
        0 : begin
           paddle_update = 1;           
        end
        1 : begin
           paddle_update = 0;
        end
      endcase
   end
   always_ff @(negedge clck) begin
      case(update_counter)
        0 : begin
           update_counter = 1;
        end
        1 : begin
           if(activeLine) begin
              update_counter = 2;
           end
        end
        2 : begin
           if(!activeLine) begin
              update_counter = 0;
           end
        end
        default : begin
           update_counter = 1;
        end
      endcase
   end
   
   assign r = paddle_pixel;
   assign g = paddle_pixel;
   assign b = paddle_pixel;
   
endmodule
