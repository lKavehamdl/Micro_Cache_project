@KOMAK!
.global _start
.data
	.balign 8
	arr: .word 0x1, 0x11, 0x2, 0x4, 0x13, 0x4, 0x1
	cache: .word 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF 
	@ 4 by 2 with 4 bytes per each block
	FIFOList: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	
.text
_start:
	MOV R0, #0x0 @cache mode
	MOV R2, #0x0 @current index 
	MOV R3, #0x7 @input size
	MOV R4, #0x0 @hit count
	MOV R5, #0x0 @miss count
	B exec
	
exec:
	LDR R1, =arr @you can tell bih
	LDR R8, =cache
	CMP R3, R2
	BEQ _END
	LDR R6, [R1, R2, LSL #0x2] @current val
	AND R7, R6, #3 @find the line
	MOV R12, #0x8
	MUL R7, R7, R12 @mul won't accept immediate
	ADD R7, R7, R8 @first col of given row
	LDR R1, [R7]
	ADD R9, R7, #0x4 @second col of given row
	LDR R8, [R9]
	CMP R0, #0x0
	BLEQ FIFO
	CMP R0, #0x1
	BLEQ LRU
	CMP R0, #0x2
	BLEQ MRU
	CMP R0, #0x3
	BLEQ LFU
	CMP R0, #0x4
	BLEQ MFU
	CMP R0, #0x5
	BLEQ RD
	B exec
	
FIFO:
	CMP R6, R1
	BEQ FIFO_first_hit
	CMP R6, R8
	BEQ FIFO_second_hit
	
	B FIFO_miss
	
LRU:
	ADD R2, R2, #0x1
	BX LR
	
	
MRU:
	ADD R2, R2, #0x1
	BX LR
	
	
LFU:
	ADD R2, R2, #0x1
	BX LR
	
	
MFU:
	ADD R2, R2, #0x1
	BX LR
	
	
RD:
	ADD R2, R2, #0x1
	BX LR
	
	
FIFO_first_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FIFOList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	CMP R12, #0x0
	MOVEQ R12, #0x1
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
FIFO_second_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FIFOList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	CMP R12, #0x1
	MOVEQ R12, #0x0
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
FIFO_miss:
	ADD R5, R5, #0x1 @miss detected
	LDR R10, =FIFOList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	CMP R12, #0x0
	BEQ FIFO_add_first_col
	BNE FIFO_add_second_col
	
FIFO_add_first_col:
	ADD R12, R12, #0x1
	STR R12, [R11] @change First In for next round
	STR R6, [R7] @store value in right position
	ADD R2, R2, #0x1
	BX LR

FIFO_add_second_col:
	SUB R12, R12, #0x1
	STR R12, [R11] @change First In for next round
	STR R6, [R9] @store value in right position
	ADD R2, R2, #0x1
	BX LR

_END:
	B _END