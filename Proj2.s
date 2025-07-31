@KOMAK!
.global _start
.data
	.balign 32
	arr: .word 0x1, 0x5, 0x9, 0xD, 0x9, 0x5, 0xD, 0x5
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
	RandomList: .word 0xABD234FE, 0x1234FDEF, 0xDDCC2345, 0xACDF6543, 0x0, 0x0, 0x1, 0x0 @size of sequence
	
	FIFOList2: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	LRUList2: .word 0x0, 0x0, 0x0, 0x0 @one per each line
	MRUList2: .word 0x1, 0x1, 0x1, 0x1 @one per each line
	FrequencyList2: .word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 @per each block of L1Cache 
	RandomList2: .word 0xABD234FE, 0x1234FDEF, 0xDDCC2345, 0xACDF6543, 0x0, 0x0, 0x1, 0x0 @size of sequence
	
	inp_size: .word 0x8
	
.text
_start:
	MOV R0, #0x28 @cache mode
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
		
FIFO:
	CMP R6, R1
	BEQ FIFO_first_hit
	CMP R6, R8
	BEQ FIFO_second_hit
	
	B exec2 

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
	
LRU:
	CMP R6, R1
	BEQ LRU_first_hit
	CMP R6, R8
	BEQ LRU_second_hit
	
	B exec2
	
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
	
MRU:
	CMP R6, R1
	BEQ MRU_first_hit
	CMP R6, R8
	BEQ MRU_second_hit
	
	B exec2
	
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

LFU:
	CMP R6, R1
	BEQ LFU_first_hit
	CMP R6, R8
	BEQ LFU_second_hit
	
	B exec2
	
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

MFU:
	CMP R6, R1
	BEQ MFU_first_hit
	CMP R6, R8
	BEQ MFU_second_hit
	
	B exec2
	
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

RD:
	CMP R6, R1
	BEQ RD_first_hit
	CMP R6, R8
	BEQ RD_second_hit
	
	B exec2
	
RD_first_hit:
	LDR R10, =L1Cache
	STR R6, [R7, R10]
	ADD R2, R2, #0x1
	BX LR


RD_second_hit:
	LDR R10, =L1Cache
	STR R6, [R9, R10]
	ADD R2, R2, #0x1
	BX LR
	
exec2:
	LDR R4, =L1Miss @L1 miss detected
	LDR R5, [R4]
	ADD R5, R5, #0x1
	STR R5, [R4]
	
	LDR R8, =L2Cache
	AND R4, R0, #0x38 @second 3 bits(cache mode)
	LSR R4, R4, #0x3
	LDR R1, [R7, R8] @value of first col in L2
	LDR R8, [R9, R8] @value of second col in L2
	
	CMP R4, #0x0
	BEQ FIFO2
	CMP R4, #0x1
	BEQ LRU2
	CMP R4, #0x2
	BEQ MRU2
	CMP R4, #0x3
	BEQ LFU2
	CMP R4, #0x4
	BEQ MFU2
	CMP R4, #0x5
	BEQ RD2


FIFO2:
	CMP R6, R1
	BEQ FIFO2_hit
	CMP R6, R8
	BEQ FIFO2_hit
	
	B L2_miss 
	
FIFO2_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	B L1_decision_selection
	
LRU2:
 	CMP R6, R1
 	BEQ LRU2_hit
 	CMP R6, R8
 	BEQ LRU2_hit
	
 	B L2_miss 
	
LRU2_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	B L1_decision_selection
	
MRU2:
 	CMP R6, R1
 	BEQ MRU2_hit
 	CMP R6, R8
 	BEQ MRU2_hit
	
 	B L2_miss 
	
MRU2_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	B L1_decision_selection
	
LFU2:
 	CMP R6, R1
 	BEQ LFU2_first_hit
 	CMP R6, R8
 	BEQ LFU2_second_hit
	
 	B L2_miss 
	
LFU2_first_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12
	ADD R11, R10, R11
	LDR R12, [R11]
	ADD R12, R12, #0x1
	STR R12, [R11]
	
	
	B L1_decision_selection


LFU2_second_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12
	ADD R11, R11, #0x4 @second block of a line
	ADD R11, R10, R11
	LDR R12, [R11]
	ADD R12, R12, #0x1
	STR R12, [R11]
	
	B L1_decision_selection


MFU2:
 	CMP R6, R1
 	BEQ MFU2_first_hit
 	CMP R6, R8
 	BEQ MFU2_second_hit
	
 	B L2_miss 
	
MFU2_first_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12
	ADD R11, R10, R11
	LDR R12, [R11]
	ADD R12, R12, #0x1
	STR R12, [R11]
	
	B L1_decision_selection


MFU2_second_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12
	ADD R11, R11, #0x4 @second block of a line
	ADD R11, R10, R11
	LDR R12, [R11]
	ADD R12, R12, #0x1
	STR R12, [R11]
	
	B L1_decision_selection


	
RD2:
 	CMP R6, R1
 	BEQ RD2_hit
 	CMP R6, R8
 	BEQ RD2_hit
	
 	B L2_miss 
	
RD2_hit:
	@L2 hit count ++
	LDR R10, =L2Hit
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	
	B L1_decision_selection

L1_decision_selection:
	AND R4, R0, #0x3
	CMP R4, #0x0
	BEQ L1_FIFO_decision
	CMP R4, #0x1
	BEQ L1_LRU_decision
	CMP R4, #0x2
	BEQ L1_MRU_decision
	CMP R4, #0x3
	BEQ L1_LFU_decision
	CMP R4, #0x4
	BEQ L1_MFU_decision
	CMP R4, #0x5
	BEQ L1_RD_decision
	
L1_FIFO_decision:
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
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
FIFO_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change First In for next round
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection
	
L1_LRU_decision:
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
	STR R12, [R11] @change index for next round
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
LRU_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change index for next round
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection

L1_MRU_decision:
	CMP R1, #0xFFFFFFFF @-1 means cache is empty, no replacment required
	BEQ MRU_add_first_col
	CMP R8, #0xFFFFFFFF @-1 means cache is empty, no replacment required
	BEQ MRU_add_second_col
	LDR R10, =MRUList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R12, #0x0
	MOVEQ R12, #0x1
	MOVNE R12, #0x0
	STR R12, [R11]
	BEQ MRU_add_first_col
	BNE MRU_add_second_col
	
MRU_add_first_col:
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
MRU_add_second_col:
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection
	
L1_LFU_decision:
	LDR R10, =FrequencyList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	ADD R5, R11, #0x4
	LDR R4, [R5]
	MOV R3, #0x1
	CMP R12, R4
	BLE LFU_add_first_col
	B LFU_add_second_col
	
LFU_add_first_col:
	STR R3, [R11]
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
LFU_add_second_col:
	STR R3, [R5]
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection
	
L1_MFU_decision:
	LDR R10, =FrequencyList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	ADD R5, R11, #0x4
	LDR R4, [R5]
	MOV R3, #0x1
	CMP R12, R4
	BLE MFU_add_second_col
	B MFU_add_first_col
	
MFU_add_first_col:
	STR R3, [R11]
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
MFU_add_second_col:
	STR R3, [R5]
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection
	

L1_RD_decision:
	LDR R10, =RandomList
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	AND R12, R12, #0x1
	CMP R12, #0x0
	BLE RD_add_first_col
	B RD_add_second_col
	
RD_add_first_col:
	LDR R10, =L1Cache
	LDR R4, [R10, R7] @read data before replace
	STR R6, [R10, R7] @store value in right position
	
	B L2_decision_selection
	
RD_add_second_col:
	LDR R10, =L1Cache
	LDR R4, [R10, R9] @store value in right position
	STR R6, [R10, R9] @store value in right position
	
	B L2_decision_selection
	
L2_miss:
	LDR R10, =L2Miss
	LDR R11, [R10]
	ADD R11, R11, #0x1
	STR R11, [R10]
	B L1_decision_selection


L2_decision_selection:
	AND R3, R0, #0x38 @second 3 bits
	LSR R3, #0x3
	CMP R3, #0x0
	BEQ L2_FIFO_decision
	CMP R3, #0x1
	BEQ L2_LRU_decision
	CMP R3, #0x2
	BEQ L2_MRU_decision
	CMP R3, #0x3
	BEQ L2_LFU_decision
	CMP R3, #0x4
	BEQ L2_MFU_decision
	CMP R3, #0x5
	BEQ L2_RD_decision
	
L2_FIFO_decision:
	LDR R10, =FIFOList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of FIFOList
	LDR R12, [R11]
	CMP R12, #0x0
	BEQ FIFO2_add_first_col
	BNE FIFO2_add_second_col
	
	
FIFO2_add_first_col:
	MOV R12, #0x1
	STR R12, [R11] @change First In for next round
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
FIFO2_add_second_col:
	MOV R12, #0x1
	STR R12, [R11] @change First In for next round
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	

L2_LRU_decision:
	LDR R10, =LRUList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R12, #0x0
	BEQ LRU2_add_first_col
	BNE LRU2_add_second_col
	
LRU2_add_first_col:
	MOV R12, #0x1
	STR R12, [R11] @change index for next round
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
LRU2_add_second_col:
	MOV R12, #0x0
	STR R12, [R11] @change index for next round
	LDR R10, =L2Cache
	STR R4, [R10, R9] @store value in right position
	
	B ChizDorostKon
	
L2_MRU_decision:
	LDR R10, =MRUList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	CMP R1, #0xFFFFFFFF @-1 means cache is empty, no replacment required
	BEQ MRU2_add_first_col
	CMP R8, #0xFFFFFFFF @-1 means cache is empty, no replacment required
	BEQ MRU2_add_second_col
	
	BEQ MRU2_add_first_col
	BNE MRU2_add_second_col
	
MRU2_add_first_col:
	MOV R12, #0x0
	STR R12, [R11]
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
MRU2_add_second_col:
	MOV R12, #0x1
	STR R12, [R11]
	LDR R10, =L2Cache
	STR R4, [R10, R9] @store value in right position
	
	B ChizDorostKon
	
L2_LFU_decision:
	CMP R4, #0xFFFFFFFF @-1 means there was no data in L1, no changes required
	BEQ ChizDorostKon
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	ADD R5, R11, #0x4
	LDR R3, [R5]
	CMP R12, R3
	BLE LFU2_add_first_col
	B LFU2_add_second_col
	
LFU2_add_first_col:
	MOV R3, #0x1
	STR R3, [R11]
	
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
LFU2_add_second_col:
	MOV R3, #0x1
	STR R3, [R5]
	
	LDR R10, =L2Cache
	STR R4, [R10, R9] @store value in right position
	
	B ChizDorostKon
	
L2_MFU_decision:
	CMP R4, #0xFFFFFFFF @-1 means there was no data in L1, no changes required
	BEQ ChizDorostKon
	
	LDR R10, =FrequencyList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x8
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	ADD R5, R11, #0x4
	LDR R3, [R5]
	
	CMP R1, #0xFFFFFFFF @-1 means there is an empty block, place it there
	BEQ MFU2_add_first_col
	CMP R8, #0xFFFFFFFF
	BEQ MFU2_add_second_col
	
	CMP R12, R3
	BLE MFU2_add_second_col
	B MFU2_add_first_col
	
MFU2_add_first_col:
	MOV R3, #0x1
	STR R3, [R11]
	
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
MFU2_add_second_col:
	MOV R3, #0x1
	STR R3, [R5]
	
	LDR R10, =L2Cache
	STR R4, [R10, R9] @store value in right position
	
	B ChizDorostKon
	

L2_RD_decision:
	CMP R1, #0xFFFFFFFF @-1 means there is an empty block, put it there
	BEQ RD2_add_first_col
	CMP R8, #0xFFFFFFFF @-1 means there is an empty block, put it there
	BEQ RD2_add_second_col
	
	LDR R10, =RandomList2
	AND R11, R6, #0x3 @find line
	MOV R12, #0x4
	MUL R11, R11, R12 @mul won't accept immediate
	ADD R11, R11, R10 @index of LRUList
	LDR R12, [R11]
	AND R12, R12, #0x1
	CMP R12, #0x0
	BLE RD2_add_first_col
	B RD2_add_second_col
	
RD2_add_first_col:
	LDR R10, =L2Cache
	STR R4, [R10, R7] @store value in right position
	
	B ChizDorostKon
	
RD2_add_second_col:
	LDR R10, =L2Cache
	STR R4, [R10, R9] @store value in right position
	
	B ChizDorostKon
	

ChizDorostKon:
	AND R4, R0, #0x7
	ADD R2, R2, #0x1
	BX LR

_END:
	B _END
