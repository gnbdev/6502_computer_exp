.include "io_def.s"


.segment "KERNAL"
.include "io.s"


.segment "WOZMON"
.include "wozmon.s"


.segment "VECTORS"
  .org $FFFA
  .word nmi
  .word reset
  .word irq

