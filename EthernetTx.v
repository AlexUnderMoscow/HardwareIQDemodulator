`timescale 1ns / 1ps
module IEEE802TX(	 
	input Reset,
	input Clk,
	input clk_en,
	
	output [7:0]  gmii_txd,              // Transmit data from client MAC.
   output        gmii_tx_en,            // Transmit control signal from client MAC.
   output        gmii_tx_er,            // Transmit control signal from client MAC.
	output reg		  complete,
	  
   // parameter for Fifo
	input iEmpty,                        // fifo is empty
	input [15:0] i8Data,                  // data from fifo
	output oRead,                    // read request for data from fifo
	output [2:0] diagnostic,
	output [8:0] Addres
	// parameter for MTU
	);
	
	parameter[3:0] /* состояния модуля */       
	StateIdle           =4'd00,
	StatePreamble       =4'd01,
	StateSFD            =4'd02,
	StateHeader         =4'd03,
	StateData           =4'd04,
	StateFCS            =4'd05,
	StateIFG            =4'd06;	
	
	reg [3:0] state, next_state;
	reg [3:0] r4CntrPreamble = 4'd0;									//счетчик числа байт преамбулы 0
	reg [10:0] r11DataCounter;							//счетчик данных из фифо
	reg [2:0] diag;
	reg [8:0] addrCnt;
	reg [1:0] clkDiv = 2'd0;
	
	assign Addres = r11DataCounter[9:1];				//состояние адресной шину меняем через такт
	
	assign diagnostic = diag;
	
	assign oRead = ~clkDiv[0];
	
	wire      wFinishPreamble;
	assign    wFinishPreamble = (r4CntrPreamble == 4'd6);		//семь байт преамбулы
	
	always @(negedge Clk)
	if (Reset)
		clkDiv <= 2'd0;
	else
		clkDiv <= clkDiv + 1'b1;


	//////////////////////////////////////////////счетчик байт преамбулы///////////////////////////////
	always @(posedge Clk)
	
		if (Reset)
			begin
				r4CntrPreamble <= 4'd0;									//счетчик байт преамбулы при сбросе в ноль
			end		
		else if (clk_en)
			begin		
				if ((state == StatePreamble) & wFinishPreamble)
					begin						
						r4CntrPreamble <= 4'd0;								//всю преамбулу передали = 0
					end
				else if (state == StatePreamble)
					begin
			        	r4CntrPreamble <= r4CntrPreamble + 1'b1; 		//не до конца преамбула - продолжаем
					end	 
			end
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////сброс и заполнение регистра преамбулы числом 0х55///////////////////////////////////
    reg [7:0] r8PreambleData = 8'd0;
	always @(posedge Clk)
		if (Reset)
			r8PreambleData <= 8'd0;
		else if (clk_en)
			begin							
				r8PreambleData <= 8'h00;
				if (state == StatePreamble)
					r8PreambleData <= 8'h55;								//заполнение меандром
				end
   ///////////////////////////////////////////////////////////////////////////////////////////////////// 
	// block for control header state
	reg [3:0] r4CntrHeader = 4'd0;	  
	wire wFinishHeader;
	assign wFinishHeader = (r4CntrHeader == 4'd11);	 				//двенадцать байт мас адресов
	wire wFinishHeaderFifo;
	assign wFinishHeaderFifo = (r4CntrHeader == 4'd10);	 			//?
	always @(posedge Clk)
		if (Reset)		 
			begin
				r4CntrHeader <= 4'd0;
			end
		else if (clk_en)
			begin 						
				if  ((state == StateHeader) & wFinishHeader)
					begin			  
						r4CntrHeader <= 1'b0;
					end
				else if  (state == StateHeader) 
					begin
						r4CntrHeader <= r4CntrHeader + 1'b1;
					end
			end
	
			reg [7:0] r8HeaderData = 8'd0;
			always @(posedge Clk)
			if (Reset)
				r8HeaderData <= 8'd0;
			else if (clk_en)
				begin 
					r8HeaderData <= 8'h00;
					if(state == StateHeader)
					case (r4CntrHeader)
						4'd0:			  
							r8HeaderData <= 8'h12;
						4'd1:
							r8HeaderData <= 8'h34;
						4'd2:					  
							r8HeaderData <= 8'h56;
						4'd3:					  
							r8HeaderData <= 8'h78;
						4'd4:
							r8HeaderData <= 8'h9A;
						4'd5:					  
							r8HeaderData <= 8'hBC;
						4'd6:					  
							r8HeaderData <= 8'hC8;
						4'd7:					  
							r8HeaderData <= 8'h60;
						4'd8:					  
							r8HeaderData <= 8'h00;
						4'd9:					  
							r8HeaderData <= 8'h98;
						4'd10:					  
							r8HeaderData <= 8'hCC;
						4'd11:					  
							r8HeaderData <= 8'hBE;
					endcase
				end
				
	
	// block SFD
	reg [7:0] r8SFD = 8'd0;
	always @(posedge Clk)
		if (Reset)
			r8SFD <= 8'd0;
		else if (clk_en) 
			begin	
				r8SFD <= 8'd0;
				if (state == StateSFD)
					r8SFD <= 8'hd5;				///?
			end
		
	// block data transfer
	reg [15:0] rFIFOData;  								//данные из фифо

	reg rReadFifo = 1'b0;
	
	wire wFinishData;
	assign wFinishData = iEmpty | (r11DataCounter == 11'd1023);		//сколько данных можно считать 1100 ?байт
	wire wFinishDataFifo;
	assign wFinishDataFifo = iEmpty | (r11DataCounter == 11'd1023); //на предпоследнем уже 
	
	always @(posedge Clk)
		if (Reset)
			rReadFifo <= 1'b0;
		else if (clk_en)
			begin
				rReadFifo <= ~iEmpty & wFinishHeaderFifo;  //когда предпоследний байт мак адресов отсылается
																			//и фифо не пусто, то пора читать фифо
				if (wFinishData)
					rReadFifo <= 1'b0; 				//данные кончились, больше не читать фифо
				else
					if (wFinishDataFifo)
					rReadFifo <= 1'b0;
				else
				if (~iEmpty & (state == StateHeader) & wFinishHeader)
					rReadFifo <= ~iEmpty;
				else if (state == StateData)
					rReadFifo <= ~iEmpty;			//будем читать из фифо если закончили писать заголовок
															// и фифо не пусто
			end
	
	wire wReadFifo; 
	assign wReadFifo = rReadFifo & ~iEmpty;  //..и фифо не пустое
			
///////////////////////////////счетчик количества данных из фифо (адрес)/////////			
	always @(posedge Clk)
		if (Reset)	
			begin
				r11DataCounter <= 11'd0;				//почему то уже байт 12 видимо мак адреса
			end
		else if (clk_en)
			begin  	 
				r11DataCounter <= 11'd0;
				if  (wFinishData)
					begin				  
						r11DataCounter <= 11'd0;
					end
				else if (state == StateData)
					begin				
						r11DataCounter <= r11DataCounter + 1'b1;				///сколько данных прочитано
					end
			end
/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////тут считывание байта со входа////////////////////////////////////////////	
	always @(posedge Clk)
		if (Reset)
			rFIFOData <= 16'd0;
		else if (clk_en)
			begin				 
				rFIFOData <= 8'd0;
				if (state == StateData)// (rReadFifo)
					rFIFOData <= i8Data;										/////перезапись данных со входа
			end																	//нужно сделать с 16 битного входа
//////////////////////////////////////////////////////////////////////////////////////////////	
	// block FCS	
	reg tx_en;
	reg FCS_init;
	reg [7:0] FCS_data;
	reg FCS_data_en;
	reg FCS_read;
	wire FCS_end;
	wire[7:0] FCS_out;
	/////////////////////присоединяем блок вычисления контрольной суммы///////////////
	CRC_gen CRC_gen_inst(.Reset(Reset), .Clk(Clk), .Ce(clk_en), .Init(FCS_init), 
	.Frame_data(FCS_data), .Data_en(FCS_data_en),
	.CRC_rd(FCS_read), .CRC_end(FCS_end), .CRC_out (FCS_out));
	
	// задержка на такт
	reg [3:0] /* synopsys enum eth_state */ dstate;
	always @(posedge Clk)
		if (Reset)
			dstate <= StateIdle;
		else if (clk_en)
			dstate <= state;
	
	// form FCS_data
	always @(posedge Clk)
		if (Reset)
			begin 
				FCS_data_en <= 1'b0;
				FCS_data <= 8'd0;	 
				FCS_init <= 1'b0; 
				FCS_read <= 1'b0;
				tx_en <= 1'b0;
			end
		else if (clk_en)
			begin				 
				FCS_data_en <= 1'b0;
				FCS_data <= 8'd0;		 
				FCS_init <= 1'b0;	
				tx_en <= 1'b0;
				FCS_read <= 1'b0;
				if (state == StatePreamble)
					begin  
						FCS_data <= 8'h55;
						tx_en <= 1'b1;
					end	
				else if (state == StateSFD)
					begin		  
						FCS_init <= 1'b1;
						FCS_data <= 8'hd5;	
						tx_en <= 1'b1;
					end
				else if (state == StateHeader)
					begin
						FCS_data_en <= 1'b1;
						tx_en <= 1'b1;
							case (r4CntrHeader)
							4'd6:			  
								FCS_data <= 8'h12;
							4'd7:
								FCS_data <= 8'h34;
							4'd8:					  
								FCS_data <= 8'h56;
							4'd9:					  
								FCS_data <= 8'h78;
							4'd10:
								FCS_data <= 8'h9A;
							4'd11:					  
								FCS_data <= 8'hBC;
							4'd0:					  
								FCS_data <= 8'hC8;
							4'd1:					  
								FCS_data <= 8'h60;
							4'd2:					  
								FCS_data <= 8'h00;
							4'd3:					  
								FCS_data <= 8'h98;
							4'd4:					  
								FCS_data <= 8'hCC;
							4'd5:					  
								FCS_data <= 8'hBE;
						endcase
					end
				else if (state == StateData)// (rReadFifo)
					begin
						FCS_data_en <= 1'b1;
						
						
						FCS_data <= (r11DataCounter[0]==1'b1) ? i8Data[7:0] : i8Data[15:8];			/////// занасение данных со входа 16 бит
																
				
						tx_en <= 1'b1;
					end	
				else if (state == StateFCS)
					begin
						FCS_read <= 1'b1; 			//чтение контрольной суммы с блока рассчета
					end
			end
	
	reg delayed_tx_en;
	reg [7:0] delayed_FCS_data;

   assign  gmii_txd = delayed_FCS_data;              // Transmit data from client MAC.
   assign  gmii_tx_en = delayed_tx_en;               // Transmit control signal from client MAC.
   assign  gmii_tx_er = 1'b0;                        // Transmit control signal from client MAC.

	////////////////////////////отправка данных к Marvell//////////////////////
	always @(posedge Clk)
		if (Reset)		
			begin
				delayed_FCS_data <= 8'd0;
				delayed_tx_en <= 1'b0;					//при сбросе очистка регистров
			end
		else if (clk_en)
			begin
					delayed_FCS_data <= FCS_data;
					delayed_tx_en <= tx_en;
				if ((dstate == StateFCS) & (state == StateFCS))
					begin		
						delayed_FCS_data <= FCS_out;
						delayed_tx_en <= 1'b1;
					end
			end
	// IFG 
	reg [5:0]       r6IFG_counter;
	///////////////счетчик пустого времени для пауз между пакетами////////////////////
	always @ (posedge Clk)
    if (Reset)
        r6IFG_counter     <= 6'd0;
    else if (state != StateIFG)
        r6IFG_counter     <= 6'd0;
    else if (clk_en)
        r6IFG_counter     <= r6IFG_counter + 1'b1;
	///////////////////////////////////////////////посчитали/////////////////////////
	////////////////////////////с каждым новым тактом пытаемся менять состояние////////
	always @(posedge Clk)
		if (Reset)
			state <= StateIdle;
		else if (clk_en)
			state <= next_state;  
	////////////////////////////////////////////////////////////////////////////////////	
	////////////////////главная машина состояний
	always @(*)
		case (state)  
			StateIdle:	 
			begin
				next_state <= state; //остаемся на месте
				diag=3'd0;
				complete = 1'b1;
			
			    if (~iEmpty)
					next_state <= StatePreamble; //////если фифо не пусто, то переход в состояние передачи преамбулы
			end
			StatePreamble: 
			begin	
				diag=3'd1;
				complete = 1'b0;			
				next_state <= state; //остаемся на месте
				if (wFinishPreamble)
					next_state <= StateSFD; //если закочили передавать преамбулу, то SOF
			end
			StateSFD: 
			begin
				diag=3'd2;
				complete = 1'b0;
				next_state <= StateHeader; //сразу переход в передачу заголовков
			end
			StateHeader:  
			begin
					diag=3'd3;
					complete = 1'b0;
					next_state <= state; //остаемся на месте
					if (wFinishHeader)
						next_state <= StateData; //закончили передавать заголовок - передаем данные
			end
			StateData:
			begin
					diag=3'd4;
					complete = 1'b0;
			    next_state <= state; //остаемся на месте
				if (~wReadFifo | wFinishData)
					next_state <= StateFCS;  //данные кончились или предел длины пакета - к контрольной сумме
			end
			StateFCS:	
			begin
				diag=3'd5;
				complete = 1'b0;
				next_state <= state; //остаемся на месте
				if (FCS_end)
			    	next_state <= StateIFG; // конец контрольной суммы - пауза
			end
			StateIFG:											  
			begin
				diag=3'd6;
				complete = 1'b0;
				next_state <= state;
				if (r6IFG_counter==6'd12)				//пропуск 12 тактов между пакетами
					next_state <= StateIdle;			// в режим ожидания
			end
		endcase
		//////////////////конец главной машины состояний////////////////////////
endmodule