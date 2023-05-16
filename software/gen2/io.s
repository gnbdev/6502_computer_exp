

  .org $F000

output_acia:

  pha

  and  #%01111111

  sta  ACIA6551_DATA_REGISTER
  ;sta PORTA

  cmp  #$0D
  bne  NOT_0D

  jsr delay

  lda  #$0A
  sta  ACIA6551_DATA_REGISTER

NOT_0D

  pla

  jsr delay

  rts


IDX16_L = $0
IDX16_H = $1

WAIT_RECV_COUNTER = $2

input_acia:

  ; 默认 从 $800 开始填充接收的数据,到 $6FF 为止

  lda ACIA_IN_ADDRESS_START_H
  sta IDX16_H

  lda ACIA_IN_ADDRESS_START_L
  sta IDX16_L

  ;初始化计数器
  sta WAIT_RECV_COUNTER

  ldy #$0 ; Y固定不变


wait_for_start_recv

  lda KBDCR

  bpl wait_for_start_recv

memcpy:

  ;检查计数器, 超过 255 就认为传输已经结束
  lda WAIT_RECV_COUNTER

  cmp #$FF
  beq end_input_acia

  inc WAIT_RECV_COUNTER


  lda KBDCR
  bpl memcpy


  ;重置输入状态
  lda #$0
  sta KBDCR

  ;重置计数器
  lda #$0
  sta WAIT_RECV_COUNTER

  lda ACIA_IN_BYTE

  sta (IDX16_L),Y  

  ; IDX16_L 等于 0 就跳转
  inc IDX16_L

  beq inc_IDX16_H

  jmp memcpy

inc_IDX16_H:

  lda #$6F
  cmp IDX16_H
  beq end_input_acia

  inc IDX16_H

  jmp memcpy


end_input_acia:

  jmp WOZMON


delay:

  pha

  txa
  pha

  tya
  pha

  ldx DELAY_X

continue_delay_x:

  ldy DELAY_Y

continue_delay_y:

  nop

  dey
  bne continue_delay_y

  dex
  bne continue_delay_x

  pla
  tay

  pla
  tax

  pla

  rts


init_VIA:

  lda #$FF
  sta DDRA
  sta DDRB

  sta PORTA
  sta PORTB

  rts

init_ACIA6551:


  lda #%00000000
  sta ACIA6551_STATUS_REGISTER


  lda #%00011111   ; {D3~D0=1111 Baud Rate 19200}
                   ; {D4=1       Receiver Clock Source}
                   ; {D6~D5=00   Word Length 8 bit}
                   ; {D7=0       stop bit}

  sta ACIA6551_CONTROL_REGISTER


  lda #%00001001
  sta ACIA6551_COMMAND_REGISTER


  rts


test_via:

   lda #$FF
   sta DELAY_X
   sta DELAY_Y

   lda #$3

test_via_loop:
  
  ror

  jsr delay
  
  sta PORTA
  
  jmp test_via_loop


nmi:


  pha

  lda ACIA6551_STATUS_REGISTER

  lda ACIA6551_DATA_REGISTER

  sta ACIA_IN_BYTE


  ORA  #%10000000
  sta PORTA

  sta KBD

  lda #$ff
  sta KBDCR

  pla

  rti

irq:

  ;sei
  ;cli

  rti

reset:

   lda #$FF
   sta DELAY_X
   sta DELAY_Y

   jsr delay
   jsr delay

   jsr init_VIA

   lda #$08
   sta ACIA_IN_ADDRESS_START_H

   LDA #$0
   sta ACIA_IN_ADDRESS_START_L

   jsr init_ACIA6551


   lda #$0
   sta KBDCR

   lda #$01
   sta DELAY_X
   lda #$7E
   sta DELAY_Y

   JMP WOZMON

