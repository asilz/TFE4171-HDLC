//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:  
// Date:    
//////////////////////////////////////////////////

/* The assertions_hdlc module is a test module containing the concurrent
   assertions. It is used by binding the signals of assertions_hdlc to the
   corresponding signals in the test_hdlc testbench. This is already done in
   bind_hdlc.sv 

   For this exercise you will write concurrent assertions for the Rx module:
   - Verify that Rx_FlagDetect is asserted two cycles after a flag is received
   - Verify that Rx_AbortSignal is asserted after receiving an abort flag
*/

module assertions_hdlc (
    output int                ErrCntAssertions,
    input  logic              Clk,
    input  logic              Rst,
    input  logic [2:0]        Address,
    input  logic              WriteEnable,
    input  logic              ReadEnable,
    input  logic [7:0]        DataIn,
    input  logic [7:0]        DataOut,
    input  logic              Rx,
    input  logic              RxEN,
    input  logic              Rx_Ready,
    input  logic              Rx_ValidFrame,
    input  logic              Rx_WrBuff,
    input  logic              Rx_EoF,
    input  logic              Rx_AbortSignal,
    input  logic              Rx_FrameError,
    input  logic              Rx_StartFCS,
    input  logic              Rx_StopFCS,
    input  logic [7:0]        Rx_Data,
    input  logic              Rx_NewByte,
    input  logic              Rx_FlagDetect,
    input  logic              Rx_AbortDetect,
    input  logic              RxD,
    input  logic              Rx_FCSerr,
    input  logic [7:0]        Rx_FrameSize,
    input  logic              Rx_Overflow,
    input  logic [7:0]        Rx_DataBuffOut,
    input  logic              Rx_FCSen,
    input  logic              Rx_RdBuff,
    input  logic              Rx_Drop,
    input  logic              Tx,
    input  logic              TxEN,
    input  logic              Tx_Done,
    input  logic              Tx_ValidFrame,
    input  logic              Tx_AbortedTrans,
    input  logic              Tx_WriteFCS,
    input  logic              Tx_InitZero,
    input  logic              Tx_StartFCS,
    input  logic              Tx_RdBuff,
    input  logic              Tx_NewByte,
    input  logic              Tx_FCSDone,
    input  logic [7:0]        Tx_Data,
    input  logic              Tx_Full,
    input  logic              Tx_DataAvail,
    input  logic [7:0]        Tx_FrameSize,
    input  logic [127:0][7:0] Tx_DataArray,
    input  logic [7:0]        Tx_DataOutBuff,
    input  logic              Tx_WrBuff,
    input  logic              Tx_Enable,
    input  logic [7:0]        Tx_DataInBuff,
    input  logic              Tx_AbortFrame
);

  initial begin
    ErrCntAssertions  =  0;
  end

  /*******************************************
   *  Verify correct Rx_FlagDetect behavior  *
   *******************************************/
  // Part A: Concurrent Assertions: Task 1
  sequence Rx_flag;
    !Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 !Rx;
  endsequence

  // Check if flag sequence is detected
  property RX_FlagDetect;
    @(posedge Clk) disable iff (!Rst) Rx_flag |-> ##2 Rx_FlagDetect;
  endproperty

  RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
    $display("PASS: Flag detect");
  end else begin 
    $error("Flag sequence did not generate FlagDetect"); 
    ErrCntAssertions++; 
  end

  /********************************************
   *  Verify correct Rx_AbortSignal behavior  *
   ********************************************/

  sequence Rx_abort;
    Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 Rx ##1 !Rx;
  endsequence

  //If abort is detected during valid frame. then abort signal should go high
  // Part A: Concurrent Assertions: Task 2
  property RX_AbortSignal;
    @(posedge Clk) disable iff (!Rst) Rx_AbortDetect and Rx_ValidFrame |-> ##2  Rx_AbortSignal;
  endproperty

  /* 10. Abort pattern detected during valid frame should generate
  * Rx_AbortSignal */
  RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
    $display("PASS: Abort signal");
  end else begin 
    $error("AbortSignal did not go high after AbortDetect during validframe"); 
    ErrCntAssertions++; 
  end

  /* 12. When a whole RX frame has been received, check if end of frame is generated */ 
  property RX_EndOfFrame;
    @(posedge Clk) disable iff (!Rst) $fell(Rx_ValidFrame) |=> $rose(Rx_EoF);
  endproperty

  RX_EndOfFrame_Assert : assert property (RX_EndOfFrame) begin
    $display("PASS: End of frame asserted");
  end else begin 
    $error("End of frame did not go high after a valid frame"); 
    ErrCntAssertions++; 
  end


endmodule
