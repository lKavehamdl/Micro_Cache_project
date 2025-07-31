@KOMAK!
.global _start
.data
	.balign 32
	arr: .word 0x1, 0x5, 0x9, 0xD, 0x5, 0x1, 0xD, 0x9
	L1Cache: .word 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
	L2Cache: .word 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF 
	
	L1Hit: .word 0x0
	L1Miss: .word 0x0
	L2Hit: .word 0x0
	L2Miss: .word 0x0
	
	FIFOList: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	LRUList: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	MRUList: .word 0x1, 0x1, 0x1, 0x1 @one per each line
	FrequencyList: .word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 @per each block of L1Cache 
	RandomList: .word 0xABD234FE, 0x1234FDEF, 0xDDCC2345, 0xACDF6543 @size of sequence
	
	FIFOList2: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	LRUList2: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	MRUList2: .word 0x1, 0x1, 0x1, 0x1 @one per each line
	FrequencyList2: .word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 @per each block of L1Cache 
	RandomList2: .word 0xABD234FE, 0x1234FDEF, 0xDDCC2345, 0xACDF6543 @size of sequence
	
	inp_size: .word 0x8
	
.text
_start:
	MOV R0, #0x0 @cache mode
	MOV R2, #0x0 @current index 
	
	B exec
	
exec:
	LDR R1, =arr @you can tell bih
	LDR R8, =L1Cache
	LDR R3, =inp_size
	LDR R3, [R3]
	CMP R3, R2
	BEQ _END
	AND R4, R0, #0x7
	LDR R6, [R1, R2, LSL #0x2] @current val
	AND R7, R6, #0x3 @find the line
	MOV R12, #0x8
	MUL R7, R7, R12 @mul won't accept immediate
	LDR R1, [R7, R8]
	ADD R9, R7, #0x4 @second col of given row
	LDR R8, [R9, R8]
	
	CMP R4, #0x0
	BLEQ FIFO
	CMP R4, #0x1
	BLEQ LRU
	CMP R4, #0x2
	BLEQ MRU
	CMP R4, #0x3
	BLEQ LFU
	CMP R4, #0x4
	BLEQ MFU
	CMP R4, #0x5
	BLEQ RD
	B exec
	
exec2:
	LDR R4, =L1Miss @L1 miss detected
	LDR R5, [R4]
	ADD R5, R5, #0x1
	STR R5, [R4]
	
	LDR R8, =L2Cache
	AND R4, R0, #0x38 @second 3 bits(cache mode)
	LDR R1, [R7, R8] @value of first col in L2
	LDR R8, [R9, R8] @value of second col in L2
	
	CMP R4, #0x0
	BEQ FIFO2
	//CMP R4, #0x1
	//BEQ LRU2
	//CMP R4, #0x2
	//BEQ MRU2
	//CMP R4, #0x3
	//BEQ LFU2
	//CMP R4, #0x4
	//BEQ MFU2
	//CMP R4, #0x5
	//BEQ RD2
	
FIFO:
	CMP R6, R1
	BEQ FIFO_first_hit
	CMP R6, R8
	BEQ FIFO_second_hit
	
	B exec2 
	
LRU:
	CMP R6, R1
	BEQ LRU_first_hit
	CMP R6, R8
	BEQ LRU_second_hit
	
	B exec2
	
	
MRU:
	CMP R6, R1
	BEQ MRU_first_hit
	CMP R6, R8
	BEQ MRU_second_hit
	
	B exec2
	
	
LFU:
	CMP R6, R1
	BEQ LFU_first_hit
	CMP R6, R8
	BEQ LFU_second_hit
	
	B exec2
	
	
MFU:
	CMP R6, R1
	BEQ MFU_first_hit
	CMP R6, R8
	BEQ MFU_second_hit
	
	B exec2
	
	
RD:
	CMP R6, R1
	BEQ RD_first_hit
	CMP R6, R8
	BEQ RD_second_hit
	
	B exec2
	

FIFO2:
	CMP R6, R1
	BEQ FIFO2_hit
	CMP R6, R8
	BEQ FIFO2_hit
	
	B FIFO_miss 
	
// LRU2:
// 	CMP R6, R1
// 	BEQ LRU2_first_hit
// 	CMP R6, R8
// 	BEQ LRU2_second_hit
	
// 	B LRU_miss 
	
	
// MRU2:
// 	CMP R6, R1
// 	BEQ MRU2_first_hit
// 	CMP R6, R8
// 	BEQ MRU2_second_hit
	
// 	B MRU_miss 
	
	
// LFU2:
// 	CMP R6, R1
// 	BEQ LFU2_first_hit
// 	CMP R6, R8
// 	BEQ LFU2_second_hit
	
// 	B LFU_miss 
	
	
// MFU2:
// 	CMP R6, R1
// 	BEQ MFU2_first_hit
// 	CMP R6, R8
// 	BEQ MFU2_second_hit
	
// 	B MFU_miss 
	
	
// RD2:
// 	CMP R6, R1
// 	BEQ RD2_first_hit
// 	CMP R6, R8
// 	BEQ RD2_second_hit
	
// 	B RD_miss 
	


FIFO_first_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	
	ADD R2, R2, #0x1 @increment
	BX LR
	
FIFO_second_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	
	ADD R2, R2, #0x1 @increment
	BX LR
	
FIFO2_hit:
	LDR R4, =L2Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	
	LDR R10, =FIFOList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	
	@L2 --> L1
	LDR R4, =L1Cache
	AND R3, R6, #0x3 @find line
	MOV R10, #0x8
	MUL R3, R3, R10
	ADD R4, R3, R4
	LDR R5, [R4, R12, LSL #0x2]
	STR R6, [R4, R12, LSL #0x2]
	
	@FIFO List update
	CMP R12, #0x0
	MOVEQ R12, #0x1
	MOVNE R12, #0x0
	STR R12, [R11]
	
	LDR R10, =FIFOList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	
	@L1 --> L2
	LDR R4, =L2Cache
	ADD R4, R3, R4
	STR R5, [R4, R12, LSL #0x2]
	
	@FIFO list 2 update
	CMP R12, #0x0
	MOVEQ R12, #0x1
	MOVNE R12, #0x0
	STR R12, [R11]
	
	
	ADD R2, R2, #0x1 @increment
	BX LR
	

//FIFO2_second_hit:
	//LDR R4, =L2Hit
	//LDR R5, [R4]
	//ADD R5, R5, #0x1 @hit detected
	//STR R5, [R4]
	
	@TODO: SWAP
	
	//ADD R2, R2, #0x1 @increment
	//BX LR
	

	
FIFO_miss:
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
	
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
	MOV R12, #0x1
	STR R12, [R11] @change First In for next round
	LDR R8, =L1Cache
	LDR R4, [R8, R7] @read data before replace
	STR R6, [R8, R7] @store value in right position
	
	B L2_FIFO_decision
	
FIFO_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change First In for next round
	LDR R8, =L1Cache
	LDR R4, [R8, R9] @store value in right position
	STR R6, [R8, R9] @store value in right position
	
	
	B L2_FIFO_decision
	
	
L2_FIFO_decision:
	LDR R10, =FIFOList2
	AND R11, R6, #0x3 @find line
	MOV R6, R4 @store R4 in R6 for later checks
	AND R4, R0, #0x7 @keep policy
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	
	CMP R12, #0x0
	BEQ Transfer_to_first_col_L2
	BNE Transfer_to_second_col_L2
	

Transfer_to_first_col_L2:
	MOV R12, #0x1
	STR R12, [R11] @change First In for next round
	LDR R8, =L2Cache
	STR R6, [R8, R7]
	
	ADD R2, R2, #0x1
	BX LR
	

Transfer_to_second_col_L2:
	MOV R12, #0x0
	STR R12, [R11] @change First In for next round
	LDR R8, =L2Cache
	STR R6, [R8, R9]
	
	ADD R2, R2, #0x1
	BX LR
	
	
	
LRU_first_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
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
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
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
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
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
	LDR R8, =L1Cache
	STR R6, [R7, R8] @store value in right position
	ADD R2, R2, #0x1
	BX LR

LRU_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change replacement index for next round
	LDR R8, =L1Cache
	STR R6, [R9, R8] @store value in right position
	ADD R2, R2, #0x1
	BX LR



MRU_first_hit: 
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
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
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
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
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
	CMP R1, #0xFFFFFFFF @-1 means L1Cache is empty, no replacement required
	BEQ MRU_add_first_col
	CMP R8, #0xFFFFFFFF @-1 means L1Cache is empty, no replacement required
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
	LDR R8, =L1Cache
	STR R6, [R7, R8] @store value in right position
	ADD R2, R2, #0x1
	BX LR

MRU_add_second_col: 
	MOV R12, #0x1
	STR R12, [R11] @change replacement index for next round
	LDR R8, =L1Cache
	STR R6, [R9, R8] @store value in right position
	ADD R2, R2, #0x1
	BX LR
	
LFU_first_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	LDR R11, [R10, R7] @index of Frequency List
	ADD R11, R11, #0x1
	STR R11, [R10, R7] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR

LFU_second_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	LDR R11, [R10, R9] @index of Frequency List
	ADD R11, R11, #0x1
	STR R12, [R10, R9] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR


LFU_miss:
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	LDR R8, [R9, R10] @value of second column in freq list
	LDR R1, [R7, R10] @value of first columb in freq list
	CMP R1, R8
	BLE LFU_add_first_col
	B LFU_add_second_col
	

LFU_add_first_col:
	MOV R1, #0x1
	STR R1, [R7, R10]
	LDR R8, =L1Cache
	STR R6, [R7, R8]
	
	ADD R2, R2, #0x1
	BX LR

LFU_add_second_col:
	MOV R1, #0x1
	STR R1, [R9, R10]
	LDR R8, =L1Cache
	STR R6, [R9, R8]
	
	ADD R2, R2, #0x1
	BX LR
	

MFU_first_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	LDR R11, [R10, R7] @index of Frequency List
	ADD R11, R11, #0x1
	STR R11, [R10, R7] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR

MFU_second_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	LDR R11, [R10, R9] @index of Frequency List
	ADD R11, R11, #0x1
	STR R12, [R10, R9] @store new value of frequency for this
	ADD R2, R2, #0x1
	BX LR


MFU_miss:
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
	LDR R10, =FrequencyList
	CMP R1, #0xFFFFFFFF @-1 means L1Cache is empty, no repleacment reqiured
	BEQ MFU_add_first_col
 	CMP R8, #0xFFFFFFFF @-1 means L1Cache is empty, no repleacment reqiured
	BEQ MFU_add_second_col
	LDR R8, [R9, R10] @value of second column in freq list
	LDR R1, [R7, R10] @value of first columb in freq list
	CMP R1, R8
	BLE MFU_add_second_col
	B MFU_add_first_col
	

MFU_add_first_col:
	MOV R1, #0x1
	STR R1, [R7, R10]
	LDR R8, =L1Cache
	STR R6, [R7, R8]
	ADD R2, R2, #0x1
	BX LR

MFU_add_second_col:
	MOV R1, #0x1
	STR R1, [R9, R10]
	LDR R8, =L1Cache
	STR R6, [R9, R8]
	ADD R2, R2, #0x1
	BX LR
	
RD_first_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	ADD R2, R2, #0x1
	BX LR

RD_second_hit:
	LDR R4, =L1Hit
	LDR R5, [R4]
	ADD R5, R5, #0x1 @hit detected
	STR R5, [R4]
	ADD R2, R2, #0x1
	BX LR

RD_miss:
	LDR R4, =L2Miss
	LDR R5, [R4]
	ADD R5, R5, #0x1 @miss detected
	STR R5, [R4]
	LDR R10, =RandomList
	CMP R1, #0xFFFFFFFF @-1 means L1Cache is empty, no repleacment reqiured
	BEQ RD_add_first_col
 	CMP R8, #0xFFFFFFFF @-1 means L1Cache is empty, no repleacment reqiured
	BEQ RD_add_second_col
	LDR R11, [R10, R2, LSL #0x2]
	AND R11, R11, #0x1
	CMP R11, #0x0
	BEQ RD_add_first_col
	B RD_add_second_col
	
RD_add_first_col:
	LDR R8, =L1Cache
	STR R6, [R7, R8]
	ADD R2, R2, #0x1
	BX LR


RD_add_second_col:
	LDR R8, =L1Cache
	STR R6, [R9, R8]
	ADD R2, R2, #0x1
	BX LR


_END:
	B _END