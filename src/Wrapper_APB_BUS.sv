module APB_System #(
    parameter   ADDR_WIDTH  = 16 ,
    parameter   DATA_WIDTH  = 16 ,
    parameter   MEM_DEPTH   = 64 ,
    localparam  PSTRB_WIDTH = DATA_WIDTH / 8    
)(
    // Global Signals
    input                           PCLK         ,
    input                           PRESETn      ,
    // Upstream Bus Interface (from AHB/AXI)
    input                           TRANSFER_REQ ,
    input                           WRITE_BUS    ,
    input       [ADDR_WIDTH-1:0]    ADDR_BUS     ,
    input       [DATA_WIDTH-1:0]    DATA_BUS     ,
    input       [PSTRB_WIDTH-1:0]   STRB_BUS     ,
    // Read data back to upstream
    output      [DATA_WIDTH-1:0]    PRDATA_OUT
);

    // --------------------------------------------------------
    // Internal APB Bus Signals (Master → Slave)
    // --------------------------------------------------------
    wire                            PSEL1   ;
    wire                            PENABLE ;
    wire                            PWRITE  ;
    wire    [ADDR_WIDTH-1:0]        PADDR   ;
    wire    [DATA_WIDTH-1:0]        PWDATA  ;
    wire    [PSTRB_WIDTH-1:0]       PSTRB   ;

    // --------------------------------------------------------
    // Internal APB Bus Signals (Slave → Master)
    // --------------------------------------------------------
    wire                            PREADY  ;
    wire    [DATA_WIDTH-1:0]        PRDATA  ;

    // --------------------------------------------------------
    // APB Master Instance
    // --------------------------------------------------------
    AMPA_APB_Master #(
        .ADDR_WIDTH  ( ADDR_WIDTH ) ,
        .DATA_WIDTH  ( DATA_WIDTH )
    ) u_master (
        // Global
        .PCLK         ( PCLK         ) ,
        .PRESETn      ( PRESETn      ) ,
        // Upstream bus inputs
        .TRANSFER_REQ ( TRANSFER_REQ ) ,
        .WRITE_BUS    ( WRITE_BUS    ) ,
        .ADDR_BUS     ( ADDR_BUS     ) ,
        .DATA_BUS     ( DATA_BUS     ) ,
        .STRB_BUS     ( STRB_BUS     ) ,
        // APB Master outputs -> Slave inputs
        .PSEL1        ( PSEL1        ) ,
        .PENABLE      ( PENABLE      ) ,
        .PWRITE       ( PWRITE       ) ,
        .PADDR        ( PADDR        ) ,
        .PWDATA       ( PWDATA       ) ,
        .PSTRB        ( PSTRB        ) ,
        // APB Slave outputs -> Master inputs
        .PREADY       ( PREADY       ) ,
        .PRDATA       ( PRDATA       )
    );

    // --------------------------------------------------------
    // APB Slave RAM Instance
    // --------------------------------------------------------
    RAM_APB #(
        .ADDR_WIDTH  ( ADDR_WIDTH ) ,
        .DATA_WIDTH  ( DATA_WIDTH ) ,
        .MEM_DEPTH   ( MEM_DEPTH  )
    ) u_slave (
        // Global
        .PCLK    ( PCLK    ) ,
        .PRESETn ( PRESETn ) ,
        // APB Master outputs -> Slave inputs
        .PSEL1   ( PSEL1   ) ,
        .PENABLE ( PENABLE ) ,
        .PWRITE  ( PWRITE  ) ,
        .PADDR   ( PADDR   ) ,
        .PWDATA  ( PWDATA  ) ,
        .PSTRB   ( PSTRB   ) ,
        // APB Slave outputs -> Master inputs
        .PREADY  ( PREADY  ) ,
        .PRDATA  ( PRDATA  )
    );

    // --------------------------------------------------------
    // Read data back to upstream bus
    // --------------------------------------------------------
    assign PRDATA_OUT = PRDATA;
endmodule