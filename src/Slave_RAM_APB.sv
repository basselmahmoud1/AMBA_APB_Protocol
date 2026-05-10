module RAM_APB #(
    parameter   ADDR_WIDTH      = 16                ,
    parameter   DATA_WIDTH      = 16                ,
    parameter   MEM_DEPTH       = 64                ,
    localparam  PSTRB_WIDTH     = DATA_WIDTH / 8    ,
    localparam  MEM_ADDR_WIDTH  = $clog2(MEM_DEPTH) 
) (
    // System Global signals
    input                               PCLK        ,
    input                               PRESETn     , 
    //MASTER Signals INPUT  
    input                               PSEL1       ,
    input                               PENABLE     , 
    input                               PWRITE      ,
    input           [ADDR_WIDTH-1:0]    PADDR       ,
    input           [DATA_WIDTH-1:0]    PWDATA      ,
    input           [PSTRB_WIDTH-1:0]   PSTRB       ,
    //SLAVE Signals OUTPUT  
    output  reg                         PREADY      ,
    output  reg     [DATA_WIDTH-1:0]    PRDATA      
);
    
    reg [DATA_WIDTH-1:0] mem [MEM_DEPTH];

    wire [MEM_ADDR_WIDTH-1:0] mem_addr ;
    

    localparam BYTE_PER_WORD =  DATA_WIDTH / 8;
    localparam BYTE_OFFSET_BITS = $clog2(BYTE_PER_WORD);

    assign mem_addr = PADDR[ADDR_WIDTH-1:BYTE_OFFSET_BITS];
    
    always_ff @(posedge PCLK) begin
        if (!PRESETn) begin
            PREADY <= 0 ;
            PRDATA <= 0 ;
        end
        else begin
            if (PSEL1 && PENABLE) begin
                if (PWRITE) begin
                    // write operation
                    for (int i=0; i < PSTRB_WIDTH; i++) begin
                        if (PSTRB[i]) begin
                            mem[mem_addr] <= ( mem[mem_addr] & ~( {8{1'b1}} << (i*8) ) ) | ( PWDATA & ( {8{1'b1}} << (i*8) ) );
                        end
                    end                  
                end
                else begin
                    // read operation 
                    PRDATA <= mem[mem_addr];
                end
                PREADY <= 1; 
            end
            else begin
                PREADY <= 0 ;
                PRDATA <= 0 ;
            end
        end
    end
endmodule

