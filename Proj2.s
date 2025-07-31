@KOMAK!
.global _start
.data
	.balign 32
	arr: .word 0x1, 0x5, 0x1, 0x9
	cache: .word 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF 
	@ 4 by 2 with 4 bytes per each block
	FIFOList: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	LRUList: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	MRUList: .word 0x1, 0x1, 0x1, 0x1 @one per each line
	FrequencyList: .word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 @per each block of cache 
	
.text
_start:
	MOV R0, #0x4 @cache mode
	MOV R2, #0x0 @current index 
	MOV R3, #0x4 @input size
	MOV R4, #0x0 @hit count
	MOV R5, #0x0 @miss count
	B exec
	
exec:
	LDR R1, =arr @you can tell bih
	LDR R8, =cache
	CMP R3, R2
	BEQ _END
	LDR R6, [R1, R2, LSL #0x2] @current val
	AND R7, R6, #0x3 @find the line
	MOV R12, #0x8
	MUL R7, R7, R12 @mul won't accept immediate
	LDR R1, [R7, R8]
	ADD R9, R7, #0x4 @second col of given row
	LDR R8, [R9, R8]
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
	CMP R6, R1
	BEQ LRU_first_hit
	CMP R6, R8
	BEQ LRU_second_hit
	
	B LRU_miss
	
	
MRU:
	CMP R6, R1
	BEQ MRU_first_hit
	CMP R6, R8
	BEQ MRU_second_hit
	
	B MRU_miss
	
	
LFU:
	CMP R6, R1
	BEQ LFU_first_hit
	CMP R6, R8
	BEQ LFU_second_hit
	
	B LFU_miss
	
	
MFU:
	CMP R6, R1
	BEQ MFU_first_hit
	CMP R6, R8
	BEQ MFU_second_hit
	
	B MFU_miss
	
	
RD:
	ADD R2, R2, #0x1
	BX LR
	

FIFO_first_hit:
	ADD R4, R4, #0x1 @hit detected
	ADD R2, R2, #0x1 @increment
	BX LR
	
FIFO_second_hit:
	ADD R4, R4, #0x1 @hit detected
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
	BEQ LRU_add_first_col
	BNE LRU_add_second_col
	
FIFO_add_first_col:
	MOV R12, #0x1
	STR R12, [R11] @change First In for next round
	STR R6, [R7] @store value in right position
	ADD R2, R2, #0x1
	BX LR

FIFO_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change First In for next round
	STR R6, [R9] @store value in right position
	ADD R2, R2, #0x1
	BX LR

	
	
LRU_first_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =LRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R12, #0x0
	MOVEQ R12, #0x1
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
LRU_second_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =LRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R12, #0x1
	MOVEQ R12, #0x0
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
LRU_miss:
	ADD R5, R5, #0x1 @miss detected
	LDR R10, =LRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R12, #0x0
	BEQ LRU_add_first_col
	BNE LRU_add_second_col
	
LRU_add_first_col:
	MOV R12, #0x1
	STR R12, [R11] @change replacement index for next round
	STR R6, [R7] @store value in right position
	ADD R2, R2, #0x1
	BX LR

LRU_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change replacement index for next round
	STR R6, [R9] @store value in right position
	ADD R2, R2, #0x1
	BX LR



MRU_first_hit: 
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =MRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of MRUList
	MOV R12, #0x0
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
MRU_second_hit: 
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =MRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of MRUList
	MOV R12, #0x1
	STR R12, [R11]
	ADD R2, R2, #0x1 @increment
	BX LR
	
MRU_miss: 
	ADD R5, R5, #0x1 @miss detected
	CMP R1, #0xFFFFFFFF @-1 means cache is empty, no replacement required
	BEQ MRU_add_first_col
	CMP R8, #0xFFFFFFFF @-1 means cache is empty, no replacement required
	BEQ MRU_add_second_col
	LDR R10, =MRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of MRUList
	LDR R12, [R11]
	CMP R12, #0x0
	BEQ MRU_add_first_col
	BNE MRU_add_second_col
	
MRU_add_first_col: 
	MOV R12, #0x0
	STR R12, [R11] @change replacement index for next round
	STR R6, [R7] @store value in right position
	ADD R2, R2, #0x1
	BX LR

MRU_add_second_col: 
	MOV R12, #0x1
	STR R12, [R11] @change replacement index for next round
	STR R6, [R9] @store value in right position
	ADD R2, R2, #0x1
	BX LR
	
LFU_first_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FrequencyList
	LDR R11, [R10, R7] @index of Frequency List
	ADD R11, R11, #0x1
	STR R11, [R10, R7] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR

LFU_second_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FrequencyList
	LDR R11, [R10, R9] @index of Frequency List
	ADD R11, R11, #0x1
	STR R12, [R10, R9] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR


LFU_miss:
	ADD R5, R5, #0x1 @miss detected
	LDR R10, =FrequencyList
	LDR R8, [R9, R10] @value of second column in freq list
	LDR R1, [R7, R10] @value of first columb in freq list
	CMP R1, R8
	BLE LFU_add_first_col
	B LFU_add_second_col
	

LFU_add_first_col:
	MOV R1, #0x1
	STR R1, [R7, R10]
	LDR R8, =cache
	STR R6, [R7, R8]
	ADD R2, R2, #0x1
	BX LR

LFU_add_second_col:
	MOV R1, #0x1
	STR R1, [R9, R10]
	LDR R8, =cache
	STR R6, [R9, R8]
	ADD R2, R2, #0x1
	BX LR
	

MFU_first_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FrequencyList
	LDR R11, [R10, R7] @index of Frequency List
	ADD R11, R11, #0x1
	STR R11, [R10, R7] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR

MFU_second_hit:
	ADD R4, R4, #0x1 @hit detected
	LDR R10, =FrequencyList
	LDR R11, [R10, R9] @index of Frequency List
	ADD R11, R11, #0x1
	STR R12, [R10, R9] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR


MFU_miss:
	ADD R5, R5, #0x1 @miss detected
	LDR R10, =FrequencyList
	CMP R1, #0xFFFFFFFF @-1 means cache is empty, no repleacment reqiured
	BEQ MFU_add_first_col
 	CMP R8, #0xFFFFFFFF @-1 means cache is empty, no repleacment reqiured
	BEQ MFU_add_second_col
	LDR R8, [R9, R10] @value of second column in freq list
	LDR R1, [R7, R10] @value of first columb in freq list
	CMP R1, R8
	BLE MFU_add_second_col
	B MFU_add_first_col
	

MFU_add_first_col:
	MOV R1, #0x1
	STR R1, [R7, R10]
	LDR R8, =cache
	STR R6, [R7, R8]
	ADD R2, R2, #0x1
	BX LR

MFU_add_second_col:
	MOV R1, #0x1
	STR R1, [R9, R10]
	LDR R8, =cache
	STR R6, [R9, R8]
	ADD R2, R2, #0x1
	BX LR



_END:
	B _END
