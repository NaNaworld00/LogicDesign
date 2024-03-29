
//	==================================================
//	Copyright (c) 2019 Sookmyung Women's University.
//	--------------------------------------------------
//	FILE 			: dut.v
//	DEPARTMENT		: EE
//	AUTHOR			: WOONG CHOI
//	EMAIL			: woongchoi@sookmyung.ac.kr
//	--------------------------------------------------
//	RELEASE HISTORY
//	--------------------------------------------------
//	VERSION			DATE
//	0.0			2019-11-18
//	--------------------------------------------------
//	PURPOSE			: Digital Clock
//	==================================================

//	--------------------------------------------------
//	Numerical Controlled Oscillator
//	Hz of o_gen_clk = Clock Hz / num
//	--------------------------------------------------
module	nco(	
		o_gen_clk,
		i_nco_num,
		clk,
		rst_n);

output		o_gen_clk	;	// 1Hz CLK

input	[31:0]	i_nco_num	;
input		clk		;	// 50Mhz CLK
input		rst_n		;

reg	[31:0]	cnt		;
reg		o_gen_clk	;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt		<= 32'd0;
		o_gen_clk	<= 1'd0	;
	end else begin
		if(cnt >= i_nco_num/2-1) begin
			cnt 	<= 32'd0;
			o_gen_clk	<= ~o_gen_clk;
		end else begin
			cnt <= cnt + 1'b1;
		end
	end
end

endmodule

//	--------------------------------------------------
//	Flexible Numerical Display Decoder
//	--------------------------------------------------
module	fnd_dec(
		o_seg,
		i_num);

output	[6:0]	o_seg		;	// {o_seg_a, o_seg_b, ... , o_seg_g}

input	[3:0]	i_num		;
reg	[6:0]	o_seg		;
//making
always @(i_num) begin 
 	case(i_num) 
 		4'd0:	o_seg = 7'b111_1110; 
 		4'd1:	o_seg = 7'b011_0000; 
 		4'd2:	o_seg = 7'b110_1101; 
 		4'd3:	o_seg = 7'b111_1001; 
 		4'd4:	o_seg = 7'b011_0011; 
 		4'd5:	o_seg = 7'b101_1011; 
 		4'd6:	o_seg = 7'b101_1111; 
 		4'd7:	o_seg = 7'b111_0000; 
 		4'd8:	o_seg = 7'b111_1111; 
 		4'd9:	o_seg = 7'b111_0011; 
		default:o_seg = 7'b000_0000; 
	endcase 
end


endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	double_fig_sep(
		o_left,
		o_right,
		i_double_fig);

output	[3:0]	o_left		;
output	[3:0]	o_right		;

input	[5:0]	i_double_fig	;

assign		o_left	= i_double_fig / 10	;
assign		o_right	= i_double_fig % 10	;

endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		clk,
		i_mode,
		i_position,
		rst_n,
		i_alarm_en,
		i_timer_en);    //add i_mode & i_position --> to make new i_six_dp
  
output	[5:0]	o_seg_enb		;
output		     o_seg_dp		 ;
output	[6:0]	o_seg		    ;
	
input	[41:0]	i_six_digit_seg		;
input	[1:0]	 i_position		     ;
input	[2:0]	 i_mode			        ;
input		clk			                 ;
input		rst_n			               ;
input  i_alarm_en             ;
input	 i_timer_en					;

wire		gen_clk			;	
nco		u_nco(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node		;

always @(posedge gen_clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	[5:0]	o_seg_enb		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg_enb = 6'b111110;
		4'd1:	o_seg_enb = 6'b111101;
		4'd2:	o_seg_enb = 6'b111011;
		4'd3:	o_seg_enb = 6'b110111;
		4'd4:	o_seg_enb = 6'b101111;
		4'd5:	o_seg_enb = 6'b011111;
		default:o_seg_enb = 6'b111111;
		
	endcase
end


reg 	[5:0]	i_six_dp		;	  
reg			     o_seg_dp		; //add


//ADD CONDITION : decide i_six_dp when i_mode is 2'b01 and 2'b10 
     
reg  [2:0] find_alarm = 3'b000;
reg  [2:0] find_alarm_x = 3'b000;


always @(posedge clk) begin
  find_alarm_x = find_alarm ;
end

wire		clk_1hz			;
nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));
		
always @(posedge clk_1hz or negedge rst_n) begin
  if(rst_n == 1'b0) begin
    find_alarm = 3'b000;
  end else begin
    find_alarm = {find_alarm_x[0],i_alarm_en};
  end
end
always @(i_mode,i_position, find_alarm) begin
	    if ( i_mode == 3'b001 ) begin
	       case (i_position)
		      3'b000:	  i_six_dp = 6'b000001;
		      3'b001:	  i_six_dp = 6'b000100;
		      3'b010:	  i_six_dp = 6'b010000;
		      default: i_six_dp = 6'b000000;
		     endcase
	     end else begin
	         if ( i_mode == 3'b010 ) begin
	           case (i_position)
		          3'b000:	  i_six_dp = 6'b000010;
		          3'b001:	  i_six_dp = 6'b001000;
		          3'b010:	  i_six_dp = 6'b100000;
		          default: i_six_dp = 6'b000000;
		         endcase
			end else begin
		            i_six_dp = 6'b000000;
		       end
		     //i_mode is not 2'b10 and 2'b01, i_six_dp have to be 6'b000000
    if( (find_alarm == 3'b001)||(find_alarm == 3'b010)) begin
           i_six_dp = 6'b111111;        
      end
end   
end


 //if i_alarm_en ==1 and find_alarm == 0, i_six_dp = 111111 and find_alarm is increasement.... so, find_alarm == 0 > find_alarm ==>1
		      // if i_alarm_en ==1 but find_alarm ==1, i_six_dp is not changed. 


always @(cnt_common_node) begin
		case (cnt_common_node)
			4'd0:	o_seg_dp = i_six_dp[0];
			4'd1:	o_seg_dp = i_six_dp[1];
			4'd2:	o_seg_dp = i_six_dp[2];
			4'd3:	o_seg_dp = i_six_dp[3];
			4'd4:	o_seg_dp = i_six_dp[4];
			4'd5:	o_seg_dp = i_six_dp[5];
			default:o_seg_dp = 1'b0;
		endcase
end



//i_mode = 1, find_alarm = 1 or i_mode = 0

reg	[6:0]	o_seg			            ;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg = i_six_digit_seg[6:0];
		4'd1:	o_seg = i_six_digit_seg[13:7];
		4'd2:	o_seg = i_six_digit_seg[20:14];
		4'd3:	o_seg = i_six_digit_seg[27:21];
		4'd4:	o_seg = i_six_digit_seg[34:28];
		4'd5:	o_seg = i_six_digit_seg[41:35];
		default:o_seg = 7'b111_1110; // 0 display
	endcase
end

endmodule






//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hms_cnt(
		o_hms_cnt,
		o_max_hit,
		i_max_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_cnt		;
output		     o_max_hit		;

input	[5:0]	i_max_cnt		 ;
input		     clk			      ;
input		     rst_n			    ;

reg	[5:0]	o_hms_cnt		   ;
reg		     o_max_hit		;



always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_cnt <= 6'd0;
		o_max_hit <= 1'b0;
	end else begin
		if(o_hms_cnt >= i_max_cnt) begin
			o_hms_cnt <= 6'd0;
			o_max_hit <= 1'b1;
		end else begin
			o_hms_cnt <= o_hms_cnt + 1'b1;
			o_max_hit <= 1'b0;
		end
	end
end

endmodule

module	hms_cntdwn(
		o_hms_cnt,
		o_min_hit,
		i_min_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_cnt		;
output		     o_min_hit		;

input	[5:0]	i_min_cnt		 ;
input		     clk			      ;
input		     rst_n			    ;

reg	[5:0]	o_hms_cnt		   ;
reg		     o_min_hit		;



always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_cnt <= 6'd0;
		o_min_hit <= 1'b0;
	end else begin
		if(o_hms_cnt <= i_min_cnt) begin
			o_hms_cnt <= 6'd0;
			o_min_hit <= 1'b1;
		end else begin
			o_hms_cnt <= o_hms_cnt - 1'b1;
			o_min_hit <= 1'b0;
		end
	end
end

endmodule

module  debounce(
		o_sw,
		i_sw,
		clk);
output		o_sw			;

input		i_sw			;
input		clk			;

reg		dly1_sw			;
always @(posedge clk) begin
	dly1_sw <= i_sw;
end

reg		dly2_sw			;
always @(posedge clk) begin
	dly2_sw <= dly1_sw;
end

assign		o_sw = dly1_sw | ~dly2_sw;

endmodule

//	--------------------------------------------------
//	Clock Controller
//	--------------------------------------------------
module	controller(
		o_mode,
		o_position,
		o_world_position,
		o_alarm_en,
		o_timer_en,
		o_stwat_en,
		o_sec_clk,
		o_min_clk,
		o_hou_clk,
		o_alarm_sec_clk,
		o_alarm_min_clk,
		o_alarm_hou_clk,
		o_timer_sec_clk,
		o_timer_min_clk,
		o_timer_hou_clk,
		o_stwat_sec_clk,
		o_stwat_min_clk,
		o_stwat_hou_clk,
		i_max_hit_sec,
		i_max_hit_min,
		i_max_hit_hou,
		i_max_hit_cnt_sec,
		i_max_hit_cnt_min,
		i_max_hit_cnt_hou,
		i_min_hit_sec,
		i_min_hit_min,
		i_min_hit_hou,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw5,
		i_sw6,
		clk,
		rst_n);


output	[2:0]	o_mode			;
output	[1:0]	o_position		;
output   [1:0] o_world_position ;
output		o_alarm_en		;
output		o_timer_en		;
output		o_stwat_en		;
output		o_sec_clk		;
output		o_min_clk		;
output		o_hou_clk		;
output		o_alarm_sec_clk		;
output		o_alarm_min_clk		;
output		o_alarm_hou_clk		;
output		o_timer_sec_clk		;
output		o_timer_min_clk		;
output		o_timer_hou_clk		;
output		o_stwat_sec_clk		;
output		o_stwat_min_clk		;
output		o_stwat_hou_clk		;

input		i_max_hit_sec		;
input		i_max_hit_min		;
input		i_max_hit_hou		;
input		i_min_hit_sec		;
input		i_min_hit_min		;
input		i_min_hit_hou		;
input		i_max_hit_cnt_sec		;
input		i_max_hit_cnt_min		;
input		i_max_hit_cnt_hou		;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;
input		i_sw3			;
input 	i_sw4   		;
input		i_sw5			;
input		i_sw6			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 3'b000 ;
parameter	MODE_SETUP	= 3'b001 ;
parameter	MODE_ALARM	= 3'b010 ;
parameter 	MODE_WORLD 	= 3'b011 ;
parameter	MODE_TIMER	= 3'b100 ;
parameter	MODE_STWAT	= 3'b101	;
parameter	POS_SEC		= 2'b00	;
parameter	POS_MIN		= 2'b01	;
parameter 	POS_HOU  	= 2'b10 ;
parameter 	WOR_USA    = 2'b00 ; //TIME OF USA
parameter 	WOR_ENG    = 2'b01 ; //TIME OF ENGLAND
parameter 	WOR_AUS    = 2'b10 ; //TIME OF AUSTRALIA

wire		clk_100hz		;
nco		u0_nco(
		.o_gen_clk	( clk_100hz	),
		.i_nco_num	( 32'd500000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		sw0			;
debounce	u0_debounce(
		.o_sw		( sw0		),
		.i_sw		( i_sw0		),
		.clk		( clk_100hz	));

wire		sw1			;
debounce	u1_debounce(
		.o_sw		( sw1		),
		.i_sw		( i_sw1		),
		.clk		( clk_100hz	));

wire		sw2			;
debounce	u2_debounce(
		.o_sw		( sw2		),
		.i_sw		( i_sw2		),
		.clk		( clk_100hz	));

wire		sw3			;
debounce	u3_debounce(
		.o_sw		( sw3		),
		.i_sw		( i_sw3		),
		.clk		( clk_100hz	));

wire		sw4			;
debounce	u4_debounce(
		.o_sw		( sw4		),
		.i_sw		( i_sw4		),
		.clk		( clk_100hz	));

wire		sw5			;
debounce	u5_debounce(
		.o_sw		( sw5		),
		.i_sw		( i_sw5		),
		.clk		( clk_100hz	));
		
wire		sw6			;
debounce	u6_debounce(
		.o_sw		( sw6		),
		.i_sw		( i_sw6		),
		.clk		( clk_100hz	));

reg	[2:0]	o_mode			;
always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		if(o_mode >= MODE_STWAT) begin
			o_mode <= MODE_CLOCK;
		end else begin
			o_mode <= o_mode + 1'b1;
		end
	end
end

reg	[1:0]	o_position		;
always @(posedge sw1 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_position <= POS_SEC;
	end else begin
		if(o_position >= POS_HOU) begin
			o_position <= POS_SEC;
		end else begin
			o_position <= o_position + 1'b1;
		end
	end
end

reg		o_alarm_en		;
always @(posedge sw3 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_alarm_en <= 1'b0;
	end else begin
		o_alarm_en <= o_alarm_en + 1'b1;
	end
end

reg	[1:0]	o_world_position		; //ADD TIME OF OTHER COUNTRIES WITH NEW BUTTON sw4 

always @(posedge sw4 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_world_position <= WOR_USA;
	end else begin
		if(o_world_position >= WOR_AUS) begin
			o_world_position <= WOR_USA;
		end else begin
			o_world_position <= o_world_position + 1'b1;
		end
	end
end

reg		o_timer_en		;
reg [5:0] o_hms_cnt		;
reg [5:0] o_max_hit		;
reg [5:0] i_max_cnt		;
always @(posedge sw5 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_timer_en <= 1'b0;
		o_hms_cnt <= 6'd0;
		o_max_hit <= 1'b0;
	end else begin
		o_timer_en <= o_timer_en + 1'b1;
	end
end

reg		o_stwat_en		;
always @(posedge sw6 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_stwat_en <= 1'b0;
		o_hms_cnt <= 1'b0;
		o_max_hit <= 1'b0;
	end else begin
		o_stwat_en <= o_stwat_en + 1'b1;
	end
end


wire		clk_1hz			;
nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		o_sec_clk		;
reg		o_min_clk		;
reg  		o_hou_clk  		;
reg		o_alarm_sec_clk		;
reg		o_alarm_min_clk		;
reg  		o_alarm_hou_clk 		;
reg		o_timer_sec_clk		;
reg		o_timer_min_clk		;
reg		o_timer_hou_clk		;
reg		o_stwat_sec_clk		;
reg		o_stwat_min_clk		;
reg		o_stwat_hou_clk		;

always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_hou_clk = i_max_hit_min;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hou_clk = 1'b0;
			o_timer_sec_clk = 1'b0;
			o_timer_min_clk = 1'b0;
			o_timer_hou_clk = 1'b0;
			o_stwat_sec_clk = 1'b0;
			o_stwat_min_clk = 1'b0;
			o_stwat_hou_clk = 1'b0;
		end
		MODE_SETUP : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = ~sw2;
					o_min_clk = 1'b0;
					o_hou_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
			      o_timer_min_clk = 1'b0;
			      o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = 1'b0;
					o_min_clk = ~sw2;
					o_hou_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_HOU : begin
				  o_sec_clk = 1'b0;
					o_min_clk = 1'b0;
					o_hou_clk = ~sw2;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
			endcase
		end
		MODE_ALARM : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = ~sw2;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = ~sw2;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_HOU : begin
				  o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = ~sw2;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
			endcase
		end
		MODE_WORLD : begin
		  o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_hou_clk = i_max_hit_min;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hou_clk = 1'b0;
			o_timer_sec_clk = 1'b0;
			o_timer_min_clk = 1'b0;
			o_timer_hou_clk = 1'b0;
			o_stwat_sec_clk = 1'b0;
			o_stwat_min_clk = 1'b0;
			o_stwat_hou_clk = 1'b0;
		end
		MODE_TIMER : begin
		    case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = ~sw2;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = ~sw2;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				POS_HOU : begin
				   o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = ~sw2;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
			endcase
		end
		MODE_STWAT : begin
			 case(o_stwat_en)
				1'b0 : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = 1'b0;
			      o_stwat_min_clk = 1'b0;
			      o_stwat_hou_clk = 1'b0;
				end
				1'b1 : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hou_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hou_clk = 1'b0;
					o_timer_sec_clk = 1'b0;
					o_timer_min_clk = 1'b0;
					o_timer_hou_clk = 1'b0;
					o_stwat_sec_clk = clk_1hz;
			      o_stwat_min_clk = i_max_hit_cnt_sec;
			      o_stwat_hou_clk = i_max_hit_cnt_min;
				end
			endcase
	   end		
		default: begin
			o_sec_clk = 1'b0;
			o_min_clk = 1'b0;
			o_hou_clk = 1'b0;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hou_clk = 1'b0;
			o_timer_sec_clk = 1'b0;
			o_timer_min_clk = 1'b0;
			o_timer_hou_clk = 1'b0;
			o_stwat_sec_clk = 1'b0;
			o_stwat_min_clk = 1'b0;
			o_stwat_hou_clk = 1'b0;
		end
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	houminsec(	
		o_sec,
		o_min,
		o_hou,
		o_max_hit_sec,
		o_max_hit_min,
		o_max_hit_hou,
		o_max_hit_cnt_sec,
		o_max_hit_cnt_min,
		o_max_hit_cnt_hou,
		o_min_hit_sec,
		o_min_hit_min,
		o_min_hit_hou,
		o_alarm,
		o_timer,
		o_stwat,
		i_mode,
		i_position,
		i_world_position,
		i_sec_clk,
		i_min_clk,
		i_hou_clk,
		i_alarm_sec_clk,
		i_alarm_min_clk,
		i_alarm_hou_clk,
		i_alarm_en,
		i_timer_sec_clk,
		i_timer_min_clk,
		i_timer_hou_clk,
		i_timer_en,
		i_stwat_sec_clk,
		i_stwat_min_clk,
		i_stwat_hou_clk,
		i_stwat_en,
		clk,
		rst_n);

output	[5:0]	o_sec		;
output	[5:0]	o_min		;
output  [5:0]	o_hou  		;
output		o_max_hit_sec	;
output		o_max_hit_min	;
output  	o_max_hit_hou 	;
output		o_max_hit_cnt_sec	;
output		o_max_hit_cnt_min	;
output  	o_max_hit_cnt_hou 	;
output	o_min_hit_sec	;
output	o_min_hit_min	;
output	o_min_hit_hou	;
output		o_alarm		;
output	o_timer			;
output	o_stwat			;

input	[2:0]	i_mode		;
input	[1:0]	i_position	;
input   [1:0]	i_world_position ;
input		i_sec_clk	;
input		i_min_clk	;
input 	    	i_hou_clk 	;
input		i_alarm_sec_clk	;
input		i_alarm_min_clk	;
input  	   	i_alarm_hou_clk ;
input		i_alarm_en	;
input		i_timer_sec_clk	;
input		i_timer_min_clk	;
input  	   	i_timer_hou_clk ;
input		i_timer_en	;
input		i_stwat_sec_clk	;
input		i_stwat_min_clk	;
input  	   	i_stwat_hou_clk ;
input		i_stwat_en	;	

input		clk		  ;
input		rst_n		;


parameter	MODE_CLOCK = 3'b000	;
parameter	MODE_SETUP = 3'b001	;
parameter	MODE_ALARM = 3'b010	;
parameter 	MODE_WORLD = 3'b011 	;
parameter	MODE_TIMER = 3'b100	;
parameter	MODE_STWAT = 3'b101	;
parameter	POS_SEC	   = 2'b00	;
parameter	POS_MIN	   = 2'b01	;
parameter	POS_HOU    = 2'b10 ;
parameter 	WOR_USA    = 2'b00 ;
parameter 	WOR_ENG    = 2'b01 ;
parameter 	WOR_AUS    = 2'b10 ;


//	MODE_CLOCK
wire	[5:0]	sec		;
wire		max_hit_sec	;
hms_cnt		u_hms_cnt_sec(
		.o_hms_cnt	( sec			),
		.o_max_hit	( o_max_hit_sec		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_sec_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	min		;
wire		max_hit_min	;
hms_cnt		u_hms_cnt_min(
		.o_hms_cnt	( min			),
		.o_max_hit	( o_max_hit_min		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_min_clk		),
		.rst_n		( rst_n			));
wire 	[5:0] 	hou  		;
wire  		max_hit_hou 	;
hms_cnt		u_hms_cnt_hou(
		.o_hms_cnt	( hou			),
		.o_max_hit	( o_max_hit_hou		),
		.i_max_cnt	( 6'd23			),
		.clk		( i_hou_clk		),
		.rst_n		( rst_n			));
//	MODE_ALARM
wire	[5:0]	alarm_sec	;
hms_cnt		u_hms_cnt_alarm_sec(
		.o_hms_cnt	( alarm_sec		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_min	;
hms_cnt		u_hms_cnt_alarm_min(
		.o_hms_cnt	( alarm_min		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_hou	;
hms_cnt		u_hms_cnt_alarm_hou(
		.o_hms_cnt	( alarm_hou		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd23			),
		.clk		( i_alarm_hou_clk	),
		.rst_n		( rst_n			));

//	MODE_TIMER
wire	[5:0]	timer_sec	;
hms_cnt		u_hms_cnt_timer_sec(
		.o_hms_cnt	( timer_sec		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_min	;
hms_cnt		u_hms_cnt_timer_min(
		.o_hms_cnt	( timer_min		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_hou	;
hms_cnt		u_hms_cnt_timer_hou(
		.o_hms_cnt	( timer_hou		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd23			),
		.clk		( i_timer_hou_clk	),
		.rst_n		( rst_n			));
		
//MODE_STWAT
wire	[5:0]	stwat_sec	;
hms_cnt		u_hms_cnt_stwat_sec(
		.o_hms_cnt	( stwat_sec		),
		.o_max_hit	( o_max_hit_cnt_sec),
		.i_max_cnt	( 6'd59			),
		.clk		( i_stwat_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	stwat_min	;
hms_cnt		u_hms_cnt_stwat_min(
		.o_hms_cnt	( stwat_min		),
		.o_max_hit	( o_max_hit_cnt_min),
		.i_max_cnt	( 6'd59			),
		.clk		( i_stwat_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	stwat_hou	;
hms_cnt		u_hms_cnt_stwat_hou(
		.o_hms_cnt	( stwat_hou		),
		.o_max_hit	( o_max_hit_cnt_hou),
		.i_max_cnt	( 6'd23			),
		.clk		( i_stwat_hou_clk	),
		.rst_n		( rst_n			));

reg	[5:0]	o_sec		;
reg	[5:0]	o_min		;
reg 	[5:0] o_hou 		;

always @ (*) begin
	case(i_mode)
		MODE_CLOCK: begin
			o_sec	= sec;
			o_min	= min;
			o_hou = hou;
		end
		MODE_SETUP:	begin
			o_sec	= sec;
			o_min	= min;
			o_hou = hou;
		end
		MODE_ALARM:	begin
			o_sec	= alarm_sec;
			o_min	= alarm_min;
			o_hou = alarm_hou;
		end
		MODE_WORLD: begin //MODE OF TIME OF OTHER COUNTRIES
		    case(i_world_position)
		      WOR_USA : begin //TIME OF USA --> TIME DIFFERENCE OF 14 HOUR
		        o_sec	= sec;
			      o_min	= min;
			      o_hou = hou + 6'd14 ;
			    end
			    WOR_ENG : begin //TIME OF ENGLAND --> TIME DIFFERENCE OF 9 HOUR
			      o_sec	= sec;
			      o_min	= min;
			      o_hou = hou + 6'd09 ;
			    end
			    WOR_AUS : begin //TIME OF AUSTRALIA --> TIME DIFFERENCE OF 2 HOUR
			      o_sec	= sec;
			      o_min	= min;
			      o_hou = hou + 6'd02 ;
			    end
			  endcase
		end
		MODE_TIMER: begin
			o_sec = timer_sec;
			o_min = timer_min;
			o_hou = timer_hou;
		end
	   MODE_STWAT: begin
			o_sec = stwat_sec;
			o_min = stwat_min;
			o_hou = stwat_hou;
		end	
	endcase
end



reg		o_alarm		;
always @ (posedge clk or negedge rst_n) begin
	if ((rst_n == 1'b0)) begin
		o_alarm <= 1'b0;
	    end else begin
		    if( (sec == alarm_sec) && (min == alarm_min) && (hou == alarm_hou)) begin
		  	   o_alarm <= 1'b1 & i_alarm_en;
		    end else begin
			     o_alarm <= o_alarm & i_alarm_en;
			   end
	end
end

reg		o_timer		;
always @(posedge clk or negedge rst_n) begin
	if ((rst_n == 1'b0)) begin
		o_timer <= 1'b0;
	   end else begin
		if((6'd0 == timer_sec) && (6'd0 == timer_min) && (6'd0 == timer_hou)) begin
			  o_timer <= 1'b1 & i_timer_en;
		end else begin
			  o_timer <= o_timer & i_timer_en;
		end
	end
end

endmodule

module	buzz(
		o_buzz,
		o_buzz_z,
		i_buzz_en,
		clk,
		rst_n,
		i_buzz_enz);

output		o_buzz		;
output		o_buzz_z		;

input		i_buzz_en	;
input		i_buzz_enz  ;
input		clk		;
input		rst_n		;

parameter	A = 56818	;
parameter	A_s = 53629	;
parameter	A_b = 107258;
parameter	C = 95556	;
parameter	D = 85131	;
parameter	E = 75843	;
parameter	F = 71586	;
parameter	G = 63776	;

wire		clk_bit		;
nco	u_nco_bit(	
		.o_gen_clk	( clk_bit	),
		.i_nco_num	( 25000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg	[5:0]	cnt		;
always @ (posedge clk_bit or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt <= 6'd00;
		end else begin
		if (i_buzz_en == 1'b0) begin
		cnt <= 6'd00;
		end else begin
		if(cnt >= 6'd45) begin
			cnt <= 6'd00;
		end else begin
			cnt <= cnt + 6'd01;
		end
		end
		if (i_buzz_enz == 1'b0) begin
		cnt <= 6'd00;
		end else begin
		if(cnt >= 6'd45) begin
			cnt <= 6'd00;
		end else begin
			cnt <= cnt + 6'd01;
		end
		end
	end
end

reg	[31:0]	nco_num		;
always @ (*) begin
	case(cnt)
		6'd00: nco_num = D	;
		6'd01: nco_num = G	;
		6'd02: nco_num = A_s	;
		6'd03: nco_num = A	;
		6'd04: nco_num = G	;
		6'd05: nco_num = G	;
		6'd06: nco_num = A_s	;
		6'd07: nco_num = G	;
		6'd08: nco_num = A	;
		6'd09: nco_num = 0	;
		6'd10: nco_num = D	;
		6'd11: nco_num = G	;
		6'd12: nco_num = A_s	;
		6'd13: nco_num = A	;
		6'd14: nco_num = G	;
		6'd15: nco_num = G	;
		6'd16: nco_num = D	;
		6'd17: nco_num = A_b	;
		6'd18: nco_num = D	;
		6'd19: nco_num = D	;
		6'd20: nco_num = 0	;
		6'd21: nco_num = D	;
		6'd22: nco_num = G	;
		6'd23: nco_num = A_s	;
		6'd24: nco_num = A	;
		6'd25: nco_num = G	;
		6'd26: nco_num = G	;
		6'd27: nco_num = A_s	;
		6'd28: nco_num = G	;
		6'd29: nco_num = A	;
		6'd30: nco_num = A	;
		6'd31: nco_num = A_s	;
		6'd32: nco_num = C/2	;
		6'd33: nco_num = D/2	;
		6'd34: nco_num = D/2	;
		6'd35: nco_num = C/2	;
		6'd36: nco_num = D/2	;
		6'd37: nco_num = F/2	;
		6'd38: nco_num = D/2	;
		6'd39: nco_num = D/2	;
		6'd40: nco_num = D/2	;
		6'd41: nco_num = C/2	;
		6'd42: nco_num = A_s	;
		6'd43: nco_num = C/2	;
		6'd44: nco_num = A_s	;
		6'd45: nco_num = 0	;
	endcase
end

wire		buzz		;
nco	u_nco_buzz(	
		.o_gen_clk	( buzz		),
		.i_nco_num	( nco_num	),
		.clk		( clk		),
		.rst_n		( rst_n		));

assign		o_buzz = buzz & (i_buzz_en||i_buzz_enz) ;

endmodule

module	top(
		o_seg_enb,
		o_seg_dp,
	 	o_seg,
		o_alarm,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw5,
		i_sw6,
		clk,
		rst_n);
		
    
    
output	[5:0]	o_seg_enb	;
output	     	o_seg_dp	;
output	[6:0]	o_seg		;
output	     	o_alarm		;

input		i_sw0		;
input		i_sw1		;
input		i_sw2		;
input		i_sw3		;
input  	i_sw4		;
input		i_sw5		;
input		i_sw6		;
input		clk		;
input		rst_n		;

wire 		 max_hit_min     ;
wire		 max_hit_sec     ;
wire  	 max_hit_hou     ;
wire 		 max_hit_cnt_min     ;
wire		 max_hit_cnt_sec     ;
wire  	 max_hit_cnt_hou     ;
wire  	 hou_clk         ;
wire		 min_clk         ;
wire		 sec_clk         ;

wire  		alarm_en        ;
wire  		alarm_min       ;
wire  		alarm_sec       ;
wire  		alarm_hou       ;
wire  		timer_en        ;
wire  		timer_min       ;
wire  		timer_sec       ;
wire  		timer_hou       ;
wire  		stwat_en        ;
wire  	   stwat_min       ;
wire  		stwat_sec       ;
wire  		stwat_hou       ;


wire  		[1:0]position   ;
wire  		[2:0]mode       ;
wire    [1:0]world_position;
controller u_ctrl (
			.o_mode(mode),
			.o_position(position),
			.o_world_position(world_position),
			.o_alarm_en(alarm_en),
			.o_timer_en(timer_en),
			.o_stwat_en(stwat_en),
			.o_sec_clk(sec_clk),
			.o_min_clk(min_clk),
			.o_hou_clk(hou_clk),
			.o_alarm_sec_clk(alarm_sec),
			.o_alarm_min_clk(alarm_min),
			.o_alarm_hou_clk(alarm_hou),
			.o_timer_sec_clk(timer_sec),
			.o_timer_min_clk(timer_min),
			.o_timer_hou_clk(timer_hou),
			.o_stwat_sec_clk(stwat_sec),
			.o_stwat_min_clk(stwat_min),
			.o_stwat_hou_clk(stwat_hou),
			.i_max_hit_sec(max_hit_sec),
			.i_max_hit_min(max_hit_min),
			.i_max_hit_hou(max_hit_hou),
			.i_max_hit_cnt_sec(max_hit_cnt_sec),
			.i_max_hit_cnt_min(max_hit_cnt_min),
			.i_max_hit_cnt_hou(max_hit_cnt_hou),
			.i_sw0(i_sw0),
			.i_sw1(i_sw1),
			.i_sw2(i_sw2),
			.i_sw3(i_sw3),
			.i_sw4(i_sw4),
			.i_sw5(i_sw5),
			.i_sw6(i_sw6),
			.clk(clk),
			.rst_n(rst_n));		
			

wire    [5:0]   min            ;
wire    [5:0]   sec            ;
wire    [5:0]   hou            ;


wire    buzz                    ;
wire	  buzz_z						  ; 
houminsec u_houminsec (
			.o_sec(sec),
			.o_min(min),
			.o_hou(hou),
			.o_max_hit_sec(max_hit_sec),
			.o_max_hit_min(max_hit_min),
			.o_max_hit_hou(max_hit_hou),
			.o_max_hit_cnt_sec(max_hit_cnt_sec),
			.o_max_hit_cnt_min(max_hit_cnt_min),
			.o_max_hit_cnt_hou(max_hit_cnt_hou),
			.o_alarm(buzz),
			.o_timer(buzz_z),
			.i_mode(mode),
			.i_position(position),
			.i_world_position(world_position),
			.i_sec_clk(sec_clk),
			.i_min_clk(min_clk),
			.i_hou_clk(hou_clk),
			.i_alarm_sec_clk(alarm_sec),
			.i_alarm_min_clk(alarm_min),
			.i_alarm_hou_clk(alarm_hou),
			.i_alarm_en(alarm_en),
			.i_timer_en(timer_en),
			.i_timer_sec_clk(timer_sec),
			.i_timer_min_clk(timer_min),
			.i_timer_hou_clk(timer_hou),
			.i_stwat_en(stwat_en),
			.i_stwat_sec_clk(stwat_sec),
			.i_stwat_min_clk(stwat_min),
			.i_stwat_hou_clk(stwat_hou),
			.clk(clk),
			.rst_n(rst_n));

buzz   u_buzz(
		  .o_buzz(o_alarm),
		  .i_buzz_en(buzz),
		  .clk(clk),
		  .rst_n(rst_n),
		  .i_buzz_enz(buzz_z));

wire    [3:0]   sec_left_num   ;
wire    [3:0]   sec_right_num  ;
wire    [6:0]   sec_left       ;
wire    [6:0]   sec_right      ;

double_fig_sep u0_dfs(
			.o_left(sec_left_num),
			.o_right(sec_right_num),
			.i_double_fig(sec));
	
fnd_dec u0_fnd_dec(
			.o_seg(sec_left),
			.i_num(sec_left_num));

fnd_dec u1_fnd_dec(
			.o_seg(sec_right),
			.i_num(sec_right_num));


wire    [3:0]   min_left_num   ;
wire    [3:0]   min_right_num  ;
wire    [6:0]   min_left       ;
wire    [6:0]   min_right      ;

double_fig_sep u1_dfs(
			.o_left(min_left_num),
			.o_right(min_right_num),
			.i_double_fig(min));

fnd_dec u2_fnd_dec(
			.o_seg(min_left),
			.i_num(min_left_num));

fnd_dec u3_fnd_dec(
			.o_seg(min_right),
			.i_num(min_right_num));

wire    [3:0]   hou_left_num   ;
wire    [3:0]   hou_right_num  ;
wire    [6:0]   hou_left       ;
wire    [6:0]   hou_right      ;

double_fig_sep u2_dfs(
			.o_left(hou_left_num),
			.o_right(hou_right_num),
			.i_double_fig(hou));

fnd_dec u4_fnd_dec(
			.o_seg(hou_left),
			.i_num(hou_left_num));

fnd_dec u5_fnd_dec(
			.o_seg(hou_right),
			.i_num(hou_right_num));
			
wire [41:0] six_digit_seg	;
assign six_digit_seg = {hou_left,hou_right,min_left,min_right,sec_left,sec_right};

led_disp u_led_disp (
			.o_seg(o_seg),
			.o_seg_dp(o_seg_dp),
			.o_seg_enb(o_seg_enb),
			.i_six_digit_seg(six_digit_seg),
			.i_mode(mode),
			.i_position(position),
			.i_alarm_en(alarm_en),
			.clk(clk),
			.rst_n(rst_n));

endmodule

  







