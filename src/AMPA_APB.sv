module AMPA_APB_Master #(
    parameter   ADDR_WIDTH      = 16                ,
    parameter   DATA_WIDTH      = 16                , 
    localparam  PSTRB_WIDTH     = DATA_WIDTH / 8    
)(
    // System Global signals
    input                              PCLK         ,
    input                              PRESETn      , 
    // BUS Signals From AHB/ AXI    
    input                              WRITE_BUS    ,
    input       [ADDR_WIDTH-1:0]       ADDR_BUS     ,
    input       [DATA_WIDTH-1:0]       DATA_BUS     ,
    input                              TRANSFER_REQ ,
    input       [PSTRB_WIDTH-1:0]      STRB_BUS     ,
    //MASTER Signals OUT    
    output  reg                        PSEL1        ,
    output  reg                        PENABLE      , 
    output  reg                        PWRITE       ,
    output  reg     [PSTRB_WIDTH-1:0]  PSTRB        ,
    output  reg     [ADDR_WIDTH-1:0]   PADDR        ,
    output  reg     [DATA_WIDTH-1:0]   PWDATA       ,

    //SLAVE Signals INPUT   
    input                              PREADY       ,
    input       [DATA_WIDTH-1:0]       PRDATA      
);
    `ifdef SYNTH
        localparam IDLE   = 2'b00;
        localparam SETUP  = 2'b01;
        localparam ACCESS = 2'b11;
        reg [1:0] cs, ns;
    `endif
    `ifndef SYNTH 
        typedef enum logic [1:0] { IDLE = 2'b00 , SETUP = 2'b01 , ACCESS = 2'b11} state_e;
        state_e ns , cs ;
    `endif 

    // state memory 
    always_ff @(posedge PCLK) begin
        if (!PRESETn)
            cs <= IDLE ;
        else 
            cs <= ns ; 
    end
    //next state logic 
    always_comb begin
        case (cs) 
            IDLE : begin
                if(TRANSFER_REQ)
                    ns = SETUP;
                else 
                    ns = IDLE; 
            end 
            SETUP : begin
                    ns = ACCESS;
            end
            ACCESS : begin
                if (PREADY && TRANSFER_REQ)
                    ns = SETUP;
                else if (PREADY)
                    ns = IDLE;
                else 
                    ns = ACCESS;
            end

            default: begin
                    ns = IDLE ; 
            end
        endcase
    end
    //output logic 
    always_comb begin
        case (cs) 
            IDLE : begin
                PSEL1   = 0 ;
                PENABLE = 0 ; 
                PWRITE  = 0 ; 
                PADDR   = 0 ; 
                PWDATA  = 0 ;
                PSTRB   = 0 ;
            end 
            SETUP : begin
                PSEL1   = 1 ;    
                PENABLE = 0 ; 
                PWRITE  = WRITE_BUS; 
                PADDR   = ADDR_BUS ;   
                PWDATA  = DATA_BUS ;
                PSTRB   = (WRITE_BUS) ? STRB_BUS : 0;
            end
            ACCESS : begin
                PSEL1   = 1 ;    
                PENABLE = 1 ; 
                PWRITE  = WRITE_BUS; 
                PADDR   = ADDR_BUS ;   
                PWDATA  = DATA_BUS ;
                PSTRB   = (WRITE_BUS) ? STRB_BUS : 0;
            end

            default: begin
                PSEL1   = 0 ;
                PENABLE = 0 ; 
                PWRITE  = 0 ; 
                PADDR   = 0 ; 
                PWDATA  = 0 ;
                PSTRB   = 0 ;
            end
        endcase
    end
endmodule