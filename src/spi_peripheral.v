/*
 * Copyright (c) 2025 Anindya Barua
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module spi_peripheral (
    input  wire        clk,            // system clock (10 MHz)
    input  wire        rst_n,          // active-low reset
    input  wire        spi_sclk,       // ui_in[0]
    input  wire        spi_mosi,       // ui_in[1]
    input  wire        spi_cs,         // ui_in[2]
    input  wire        spi_miso,       // ui_in[3] (tied off)

    // registers that drive PWM & top level
    output reg  [7:0]  en_reg_out_7_0,
    output reg  [7:0]  en_reg_out_15_8,
    output reg  [7:0]  en_reg_pwm_7_0,
    output reg  [7:0]  en_reg_pwm_15_8,
    output reg  [7:0]  pwm_duty_cycle
);
  
  // 2-stage synchronizers
  reg [1:0] sclk_s, mosi_s, cs_s;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sclk_s <= 2'b00;
      mosi_s <= 2'b00;
      cs_s   <= 2'b11;
    end else begin
      sclk_s <= { sclk_s[0], spi_sclk };
      mosi_s <= { mosi_s[0], spi_mosi };
      cs_s   <= { cs_s[0],   spi_cs   };
    end
  end

  wire sclk_rising =  (sclk_s == 2'b01);
  wire cs_fall     =  (cs_s   == 2'b10);
  wire cs_rise     =  (cs_s   == 2'b01);

  // shift-register + bit counter
  reg [15:0] shift_reg;
  reg [4:0]  bit_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 16'd0;
      bit_cnt   <= 5'd0;
    end else if (cs_fall) begin
      // start of new 16-bit frame
      shift_reg <= 16'd0;
      bit_cnt   <= 5'd0;
    end else if (cs_s[1]==1'b0 && sclk_rising) begin
      shift_reg <= { shift_reg[14:0], mosi_s[1] };
      bit_cnt   <= bit_cnt + 5'd1;
    end
  end

  // commit to the five registers on CS rising
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      en_reg_out_7_0    <= 8'd0;
      en_reg_out_15_8   <= 8'd0;
      en_reg_pwm_7_0    <= 8'd0;
      en_reg_pwm_15_8   <= 8'd0;
      pwm_duty_cycle    <= 8'd0;
    end else if (cs_rise && bit_cnt == 5'd16) begin
      if (shift_reg[15] && shift_reg[14:8] <= 7'h04) begin
        case (shift_reg[14:8])
          7'h00: en_reg_out_7_0  <= shift_reg[7:0];
          7'h01: en_reg_out_15_8 <= shift_reg[7:0];
          7'h02: en_reg_pwm_7_0  <= shift_reg[7:0];
          7'h03: en_reg_pwm_15_8 <= shift_reg[7:0];
          7'h04: pwm_duty_cycle  <= shift_reg[7:0];
        endcase
      end
    end
  end

  // tie off MISO
  wire _unused = &{ spi_miso, 1'b0 };

endmodule

`default_nettype wire