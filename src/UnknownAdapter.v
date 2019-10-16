module UnknownAdapter
  (
   input       clock,
   input       mode,
   input [3:0] id,
   output      led1, // red
   output      led2, // trig 1
   output      led3, // trig 2
   output      ld1,
   output      ld2,
   output      ld3,
   output      ld4,
   output      ld5,
   output      ld6,
   output      ld7,
   output      ld8
   );

   reg [24:0]  counter;

   always@(posedge clock) begin
      counter <= counter + 1;
   end

   assign led1 = counter[24];
   assign led2 = 1'b0;
   assign led3 = 1'b0;

   assign ld1 = counter[24];
   assign ld2 = 1'b0;
   assign ld3 = 1'b0;
   assign ld4 = mode;
   assign ld5 = id[3];
   assign ld6 = id[2];
   assign ld7 = id[1];
   assign ld8 = id[0];

endmodule
