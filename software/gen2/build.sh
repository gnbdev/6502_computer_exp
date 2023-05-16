#!/bin/sh

rm -f *.o *.bin *.lst *.map

ca65 -g -l boot.lst --feature labels_without_colons boot.s
ld65 -C boot.cfg -vm -m boot.map -o boot.bin boot.o


ca65 -g -l a1basic.lst --feature labels_without_colons a1basic.s
ld65 -C a1basic.cfg -vm -m a1basic.map -o a1basic.bin a1basic.o

srec_cat boot.bin -binary -offset 0x1000  a1basic.bin -binary -offset 0x0000  -o 6502_exp.bin -binary


