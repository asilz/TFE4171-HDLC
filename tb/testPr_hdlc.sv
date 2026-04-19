//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author: 
// Date:  
//////////////////////////////////////////////////

/* testPr_hdlc contains the simulation and immediate assertion code of the
   testbench. 

   For this exercise you will write immediate assertions for the Rx module which
   should verify correct values in some of the Rx registers for:
   - Normal behavior
   - Buffer overflow 
   - Aborts

   HINT:
   - A ReadAddress() task is provided, and addresses are documentet in the 
     HDLC Module Design Description
*/
`define Rx_SC_address 2
`define Rx_Buff_address 3

`define Tx_SC_address 0
`define Tx_Buff_address 1

program testPr_hdlc(
  in_hdlc uin_hdlc
);
  
  int TbErrorCnt;

  /****************************************************************************
   *                                                                          *
   *                               Student code                               *
   *                                                                          *
   ****************************************************************************/

  // VerifyAbortReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer is zero after abort.
  task VerifyAbortReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    logic [7:0] ReadDataBuf;

    
    // Part A: Immediate Assertions: Task 2

    ReadAddress(`Rx_Buff_address, ReadDataBuf); // Read RX data buffer
    ReadAddress(`Rx_SC_address, ReadDataSC); // Read RX status/control register
    ready_assert: assert(ReadDataSC[0] === 0) begin
	    $display("[%0t] PASS. Rx_Buff has no data", $time);
    end else begin
	    $error("[%0t] VerifyAbortReceive rx should not be ready", $time);
    end

    frame_error_assert: assert(ReadDataSC[2] === 0) begin
	    $display("[%0t] PASS. No Frame error", $time);
    end else begin
	    $error("[%0t] VerifyAbortReceive frame error", $time);
    end

    abort_signal_assert: assert(ReadDataSC[3] === 1) begin
	    $display("[%0t] PASS. No Abort signal", $time);
    end else begin
	    $error("[%0t] VerifyAbortReceive abort signal error", $time);
    end

    overflow_signal_assert: assert(ReadDataSC[4] === 0) begin
	    $display("[%0t] PASS. No Overflow signal", $time);
    end else begin
	    $error("[%0t] VerifyAbortReceive overflow error", $time);
    end

    buffer_zero_assert: assert(ReadDataBuf === 8'b00000000) begin
	    $display("[%0t] PASS. Rx_Buff is empty", $time);
    end else begin
	    $error("[%0t] VerifyAbortReceive data buffer not zero", $time);
    end
  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyNormalReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    logic [7:0] ReadDataBuf;
    wait(uin_hdlc.Rx_Ready);

    
    // Part A: Immediate Assertions: Task 1
    ReadAddress(`Rx_SC_address, ReadDataSC); // Read RX status/control register

    ready_assert: assert(ReadDataSC[0] === 1) begin
	    $display("[%0t] PASS. Rx_Buff has data to read", $time);
    end else begin
	    $error("[%0t] VerifyNormalReceive rx not ready", $time);
    end

    frame_error_assert: assert(ReadDataSC[2] === 0) begin
	    $display("[%0t] PASS. No Frame error", $time);
    end else begin
	    $error("[%0t] VerifyNormalReceive Frame error", $time);
    end

    abort_signal_assert: assert(ReadDataSC[3] === 0) begin
	    $display("[%0t] PASS. No Abort signal", $time);
    end else begin
	    $error("[%0t] VerifyNormalReceive abort signal error", $time);
    end

    overflow_assert: assert(ReadDataSC[4] === 0) begin
	    $display("[%0t] PASS. No Overflow signal", $time);
    end else begin
	    $error("[%0t] VerifyNormalReceive overflow error", $time);
    end


    for(int i = 0; i < Size; i++) begin
            ReadAddress(`Rx_Buff_address, ReadDataBuf); // Read RX data buffer
	    buf_assert: assert(ReadDataBuf === data[i]) begin
		    $display("[%0t] PASS. Rx_Buff has correct data", $time);
	    end else begin
		    $error("[%0t] VerifyNormalReceive data mismatch", $time);
	    end
    end
  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    wait(uin_hdlc.Rx_Ready);

    // Part A: Immediate Assertions: Task 3
    ReadAddress(`Rx_SC_address, ReadDataSC); // Read RX status/control register
    ready_assert: assert(ReadDataSC[0] === 1) begin
	    $display("[%0t] PASS. Rx_Buff has data to read", $time);
    end else begin
	    $error("[%0t] VerifyOverflowReceive rx not ready", $time);
    end

    frame_error_assert: assert(ReadDataSC[2] === 0) begin
	    $display("[%0t] PASS. No Frame error", $time);
    end else begin
	    $error("[%0t] VerifyOverflowReceive frame error", $time);
    end
    
    abort_signal_assert: assert(ReadDataSC[3] === 0) begin
	    $display("[%0t] PASS. No Abort signal", $time);
    end else begin
	    $error("[%0t] VerifyOverflowReceive abort signal error", $time);
    end

    overflow_assert: assert(ReadDataSC[4] === 1) begin
	    $display("[%0t] PASS. Overflow signal", $time);
    end else begin
	    $error("[%0t] VerifyOverflowReceive overflow error", $time);
    end
  endtask

  /* 9 */
  task VerifyAbortTransmit(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    logic [7:0] ReadDataBuf;
    logic [7:0] flag;
    logic [7:0] abort_pat;

    ReadAddress(`Tx_SC_address, ReadDataSC); // Read TX status/control register
    abort_transmission_early_assert: assert(ReadDataSC[3] === 0) begin
      $display("[%0t] PASS. Abort transmit signal not high too early", $time);
    end else begin
	    $error("[%0t] VerifyAbortTransmit abort frame signal error", $time);
    end

    @(negedge uin_hdlc.Tx);
    flag = 8'b0111_1110;

        // Check flag
        for (int f = 0; f < 8; f++) begin
            if (f != 0) begin
                @(posedge uin_hdlc.Clk);
            end
            assert(uin_hdlc.Tx == flag[f]) begin
              $display("PASS: Expected Tx_flag = 0b%b, Received Tx_flag = 0b%b", flag[f], uin_hdlc.Tx);
            end else begin
                $error("FAIL: Expected Tx_flag = 0b%b, Received Tx_flag = 0b%b", flag[f], uin_hdlc.Tx);
                TbErrorCnt++;
            end
        end

    repeat(10) @(posedge uin_hdlc.Clk);
    // request abort
    WriteAddress(`Tx_SC_address, 8'h04); // bit2 = Tx_AbortFrame

    repeat(2) @(posedge uin_hdlc.Clk);
    ReadAddress(`Tx_SC_address, ReadDataSC); // Read TX status/control register
    abort_pat = 8'b1111_1110;

    // Check flag
        for (int f = 0; f < 8; f++) begin
            if (f != 0) begin
                @(posedge uin_hdlc.Clk);
            end
            assert(uin_hdlc.Tx == abort_pat[f]) begin
              $display("PASS: Expected Tx_abort = 0b%b, Received Tx_abort = 0b%b", abort_pat[f], uin_hdlc.Tx);
            end else begin
                $error("FAIL: Expected Tx_abort = 0b%b, Received Tx_abort = 0b%b", abort_pat[f], uin_hdlc.Tx);
                TbErrorCnt++;
            end
        end

    abort_transmission_assert: assert(ReadDataSC[3] === 1) begin
      $display("[%0t] PASS. Abort transmit signal high", $time);
    end else begin
	    $error("[%0t] VerifyAbortTransmit abort frame signal error", $time);
    end

  endtask

  task VerifyNormalTransmit(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    logic [7:0] ReadDataBuf;
    logic [4:0] historyBuf;
    logic [7:0] flag;
    logic [7:0] end_sr;
    bit end_flag_seen;

    ReadAddress(`Tx_SC_address, ReadDataSC); // Read RX status/control register

    done_assert: assert(ReadDataSC[0] === 0) begin
	    $display("[%0t] PASS. Tx not done", $time);
    end else begin
	    $error("[%0t] VerifyNormalTransmit done asserted", $time);
      TbErrorCnt++;
    end

    abort_transmission_assert: assert(ReadDataSC[3] === 0) begin
	    $display("[%0t] PASS. Transmission not aborted", $time);
    end else begin
	    $error("[%0t] VerifyNormalTransmit abort transmission error", $time);
      TbErrorCnt++;
    end

    full_assert: assert((ReadDataSC[4] === 0)) begin
	    $display("[%0t] PASS. No full signal when buffer isn't full", $time);
    end else begin
	    $error("[%0t] VerifyNormalTransmit full error", $time);
      TbErrorCnt++;
    end

    @(negedge uin_hdlc.Tx);
    flag = 8'b0111_1110;

        // Check flag
        for (int f = 0; f < 8; f++) begin
            if (f != 0) begin
                @(posedge uin_hdlc.Clk);
            end
            assert(uin_hdlc.Tx == flag[f]) begin
              $display("PASS: Expected Tx_flag = 0b%b, Received Tx_flag = 0b%b", flag[f], uin_hdlc.Tx);
            end else begin
                $error("FAIL: Expected Tx_flag = 0b%b, Received Tx_flag = 0b%b", flag[f], uin_hdlc.Tx);
                TbErrorCnt++;
            end
        end
    
    historyBuf = 5'b00000;
    for(int i = 0; i < Size; i++) begin
      for(int j = 0; j < 8; j++) begin
        @(posedge uin_hdlc.Clk);
	      historyBuf[4] = historyBuf[3];
	      historyBuf[3] = historyBuf[2];
	      historyBuf[2] = historyBuf[1];
	      historyBuf[1] = historyBuf[0];
	      historyBuf[0] = uin_hdlc.Tx;
	      buf_assert: assert(uin_hdlc.Tx === data[i][j]) begin
		      $display("[%0t] PASS. Tx_Buff has correct data, received: 0b%b", $time, uin_hdlc.Tx);
	      end else begin
		      $error("[%0t] VerifyNormalTransmit data mismatch, expected: 0b%b, actual: 0b%b", $time, data[i][j], uin_hdlc.Tx);
          TbErrorCnt++;
	      end
	      if(historyBuf == 5'b11111) begin
		      @(posedge uin_hdlc.Clk);
		      $display("skipping inserted 0");
	              skip_assert: assert(uin_hdlc.Tx === 1'b0) begin
		        $display("[%0t] PASS. 0 inserted for skipping", $time, uin_hdlc.Tx);
	              end else begin
		        $error("[%0t] VerifyNormalTransmit 0 not inserted correctly", $time);
                        TbErrorCnt++;
		      end
                historyBuf[4] = historyBuf[3];
	              historyBuf[3] = historyBuf[2];
	              historyBuf[2] = historyBuf[1];
	              historyBuf[1] = historyBuf[0];
	              historyBuf[0] = uin_hdlc.Tx;
	      end
      end
    end
    for (int end_wait_cycles = 0; end_wait_cycles < 300; end_wait_cycles++) begin
      @(posedge uin_hdlc.Clk);
      end_sr = {uin_hdlc.Tx, end_sr[7:1]};

      if (end_sr === 8'b01111110) begin
        end_flag_seen = 1;
        $display("[%0t] PASS. End flag detected", $time);
        break;
      end
    end

    end_flag_assert: assert(end_flag_seen) begin
      $display("[%0t] PASS. End flag was found in TX", $time);
    end else begin
      $error("[%0t] VerifyNormalTransmit end flag not detected", $time);
      TbErrorCnt++;
    end
    ReadAddress(`Tx_SC_address, ReadDataSC); // Read RX status/control register
    tx_done_assert: assert(ReadDataSC[0] === 1) begin
      $display("[%0t] PASS. tx_done asserted when TX is done", $time);
    end else begin
      $error("[%0t] VerifyNormalTransmit tx_done not", $time);
      TbErrorCnt++;
    end
  endtask

  task VerifyOverflowTransmit(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadDataSC;
    ReadAddress(`Tx_SC_address, ReadDataSC); // Read RX status/control register
    overflow_assert: assert(ReadDataSC[4] === 1) begin
	    $display("[%0t] PASS. Overflow signal", $time);
    end else begin
	    $error("[%0t] VerifyOverflowReceive overflow error", $time);
      TbErrorCnt++;
    end

    @(negedge uin_hdlc.Tx);

    repeat(8) @(posedge uin_hdlc.Clk);

    repeat(Size*8) @(posedge uin_hdlc.Clk);
    
  endtask

  task VerifyIdlePatternTransmit();
    logic [7:0] historyBuf;
    historyBuf = 8'b00000000;
    for (int i = 0; i < 100; i++) begin
      @(posedge uin_hdlc.Clk);
      historyBuf = {uin_hdlc.Tx, historyBuf[7:1]};
    end
    idle_pattern_gen_assert: assert(historyBuf === 8'b11111111) begin
	    $display("[%0t] PASS. Idle Pattern Generated", $time);
    end else begin
	    $error("[%0t] VerifyIdlePatternTransmit idle pattern error", $time);
      TbErrorCnt++;
    end
  endtask

  /****************************************************************************
   *                                                                          *
   *                             Simulation code                              *
   *                                                                          *
   ****************************************************************************/

  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    Init();

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive( 10, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 40, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 45, 0, 0, 0, 0, 0, 0); //Normal
    Receive(126, 0, 0, 0, 0, 0, 0); //Normal
    Receive(122, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 25, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 47, 0, 0, 0, 0, 0, 0); //Normal

    Transmit( 10, 0, 0, 0, 0, 0, 0); //Normal
    Transmit( 40, 1, 0, 0, 0, 0, 0); //Abort
    Transmit(125, 0, 0, 0, 1, 0, 0); //Overflow
    Transmit( 45, 0, 0, 0, 0, 0, 0); //Normal
    Transmit(125, 0, 0, 0, 0, 0, 0); //Normal
    Transmit(122, 1, 0, 0, 0, 0, 0); //Abort
    //Transmit(125, 0, 0, 0, 1, 0, 0); //Overflow
    Transmit( 25, 0, 0, 0, 0, 0, 0); //Normal
    Transmit( 47, 0, 0, 0, 0, 0, 0); //Normal
    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end

  final begin

    $display("*********************************");
    $display("*                               *");
    $display("* \tAssertion Errors: %0d\t  *", TbErrorCnt + uin_hdlc.ErrCntAssertions);
    $display("*                               *");
    $display("*********************************");

  end

  task Init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Address     = 3'b000;
    uin_hdlc.WriteEnable =   1'b0;
    uin_hdlc.ReadEnable  =   1'b0;
    uin_hdlc.DataIn      =     '0;
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task InsertFlagOrAbort(int flag);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    if(flag)
      uin_hdlc.Rx = 1'b0;
    else
      uin_hdlc.Rx = 1'b1;
  endtask

  task MakeRxStimulus(logic [127:0][7:0] Data, int Size);
    logic [4:0] PrevData;
    PrevData = '0;
    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          uin_hdlc.Rx = 1'b0;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = Data[i][j];

        PrevData = PrevData >> 1;
        PrevData[4] = Data[i][j];
      end
    end
  endtask

  task MakeTxStimulus(input logic [127:0][7:0] Data, input int Size, input logic [3:0][7:0] OverflowData, input int OverflowSize);
        
        for (int i = 0; i < Size; i++) begin
            WriteAddress(`Tx_Buff_address, Data[i]);
        end         
        for (int i = 0; i < OverflowSize; i++) begin
            WriteAddress(`Tx_Buff_address, OverflowData[i]);
        end
	
  endtask

  task Receive(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] ReceiveData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    string msg;
    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";
    $display("*************************************************************");
    $display("%t - Starting task Receive %s", $time, msg);
    $display("*************************************************************");

    for (int i = 0; i < Size; i++) begin
      ReceiveData[i] = $urandom;
    end
    ReceiveData[Size]   = '0;
    ReceiveData[Size+1] = '0;

    //Calculate FCS bits;
    GenerateFCSBytes(ReceiveData, Size, FCSBytes);
    ReceiveData[Size]   = FCSBytes[7:0];
    ReceiveData[Size+1] = FCSBytes[15:8];

    //Enable FCS
    if(!Overflow && !NonByteAligned)
      WriteAddress(`Rx_SC_address, 8'h20);
    else
      WriteAddress(`Rx_SC_address, 8'h00);

    //Generate stimulus
    InsertFlagOrAbort(1);
    
    MakeRxStimulus(ReceiveData, Size + 2);
    
    if(Overflow) begin
      OverflowData[0] = 8'h44;
      OverflowData[1] = 8'hBB;
      OverflowData[2] = 8'hCC;
      MakeRxStimulus(OverflowData, 3);
    end

    if(Abort) begin
      InsertFlagOrAbort(0);
    end else begin
      InsertFlagOrAbort(1);
    end

    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    if(Abort)
      VerifyAbortReceive(ReceiveData, Size);
    else if(Overflow)
      VerifyOverflowReceive(ReceiveData, Size);
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);

    #5000ns;
  endtask

task PrintByteArrayHex(input string name, input logic [127:0][7:0] arr, input int size);
  $display("%s:", name);
  for (int i = 0; i < size; i++) begin
    $write("%02h ", arr[i]);
  end
  $write("\n");
endtask

task PrintTxBufferHex(input int size);
  $display("Tx_DataArray:");
  for (int i = 0; i < size; i++) begin
    $write("%02h ", uin_hdlc.Tx_DataArray[i]);
  end
  $write("\n");
endtask

  task Transmit(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] TransmitData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    logic TxDone;
    logic [7:0] ReadData;
    string msg;

    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";


    $display("*************************************************************");
    $display("%t - Starting task Transmit %s", $time, msg);
    $display("*************************************************************");


    for (int i = 0; i < Size; i++) begin
      TransmitData[i] = $urandom;
    end
    TransmitData[Size]   = '0;
    TransmitData[Size+1] = '0;

	  GenerateFCSBytes(TransmitData, Size, FCSBytes);
	  TransmitData[Size] = FCSBytes[7:0];
	  TransmitData[Size+1]   = FCSBytes[15:8];


    if(Overflow) begin
	        OverflowData[0] = 8'h44;
	        OverflowData[1] = 8'hBB;
	        OverflowData[2] = 8'hCC;
            MakeTxStimulus(TransmitData, Size, OverflowData, 3);
        end else begin
            MakeTxStimulus(TransmitData, Size, OverflowData, 0);
        end

    VerifyIdlePatternTransmit();
    // Start transmission
    WriteAddress(`Tx_SC_address, 8'h02);

    PrintByteArrayHex("Transmit Data", TransmitData, Size);
    PrintTxBufferHex(Size);
    if(Abort)
      VerifyAbortTransmit(TransmitData, Size);
    else if(Overflow)
      VerifyOverflowTransmit(TransmitData, Size);
    else if(!SkipRead)
      VerifyNormalTransmit(TransmitData, Size);

    #5000ns;
  endtask

  task GenerateFCSBytes(logic [127:0][7:0] data, int size, output logic[15:0] FCSBytes);
    logic [23:0] CheckReg;
    CheckReg[15:8]  = data[1];
    CheckReg[7:0]   = data[0];
    for(int i = 2; i < size+2; i++) begin
      CheckReg[23:16] = data[i];
      for(int j = 0; j < 8; j++) begin
        if(CheckReg[0]) begin
          CheckReg[0]    = CheckReg[0] ^ 1;
          CheckReg[1]    = CheckReg[1] ^ 1;
          CheckReg[13:2] = CheckReg[13:2];
          CheckReg[14]   = CheckReg[14] ^ 1;
          CheckReg[15]   = CheckReg[15];
          CheckReg[16]   = CheckReg[16] ^1;
        end
        CheckReg = CheckReg >> 1;
      end
    end
    FCSBytes = CheckReg;
  endtask

endprogram
