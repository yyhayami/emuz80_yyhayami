	page	0
	cpu	z80
;;; 
;;; Universal Monitor for Zilog Z80
;;;   Copyright (C) 2019,2020,2021 Haruo Asano
;;;

;;; 2022.10.10 It was added functions by A.honda
;;; Rev.B02

;;; 2023.2.22 Modefied by y.hayami @yyhayami 
;;;   BASIC default start

;;; Constants
CR	EQU	0DH
LF	EQU	0AH
BS	EQU	08H
DEL	EQU	7FH
BUFLEN	equ	32	
F_bitSize	equ	8
;;;
;;; Memory switch
;;;

RAM12K = 0
RAM12K84 = 0
RAM8K = 0
RAM8K43 = 1
RAM4K = 0
BACKDOOR = 0

	IF	RAM12K
;; ROM48K RAM12K for PIC18F47Q84
UARTDR	EQU	0FF00H	; UART DATA REGISTOR
UARTCR	EQU	0FF01H	; UART CONTROL REGISTOR
WORK_B	equ	0EF00H	; work area EF00-EFFF
STACKM	equ	0EF00H	; monitor stack
STACK	equ	0EEC0H	; user stack
ROM_B	equ	0000H	;EMUZ80_Q84 ROM base address
RAM_B	equ	0C000H	;EMUZ80_Q84 RAM base address
RAM_E	equ	0EFFFH	;EMUZ80_Q84 RAM END address
IO_B	equ	0F000H	;EMUZ80_Q84 I/O base address
	ENDIF

	IF	RAM8K
; ORIGINAL MEMORY MAP for PIC18F47Q84
UARTDR	EQU	0E000H	; UART DATA REGISTOR
UARTCR	EQU	0E001H	; UART CONTROL REGISTOR
WORK_B	equ	9F00H	; work area 9F00-9FFF
STACKM	equ	9F00H	; monitor stack
STACK	equ	9EC0H	; user stack
ROM_B	equ	0000H	;EMUZ80_Q84 ROM base address
RAM_B	equ	8000H	;EMUZ80_Q84 RAM base address
RAM_E	equ	9FFFH	;EMUZ80_Q84 RAM END address
IO_B	equ	0E000H	;EMUZ80_Q84 I/O base address
	ENDIF

	IF	RAM12K84
; ORIGINAL MEMORY MAP for PIC18F47Q84
UARTDR	EQU	0E000H	; UART DATA REGISTOR
UARTCR	EQU	0E001H	; UART CONTROL REGISTOR
WORK_B	equ	0AF00H	; work area 9F00-9FFF
STACKM	equ	0AF00H	; monitor stack
STACK	equ	0AEC0H	; user stack
ROM_B	equ	0000H	;EMUZ80_Q84 ROM base address
RAM_B	equ	8000H	;EMUZ80_Q84 RAM base address
RAM_E	equ	0AFFFH	;EMUZ80_Q84 RAM END address
IO_B	equ	0E000H	;EMUZ80_Q84 I/O base address
	ENDIF

	IF	RAM8K43
; MEMORY MAP for PIC18F47Q43
UARTDR	EQU	0E000H	; UART DATA REGISTOR
UARTCR	EQU	0E001H	; UART CONTROL REGISTOR
WORK_B	equ	9E00H	; work area 9E00-9EFF
STACKM	equ	9E00H	; monitor stack
STACK	equ	9DC0H	; user stack
ROM_B	equ	0000H	;EMUZ80_Q43 ROM base address
RAM_B	equ	8000H	;EMUZ80_Q43 RAM base address
RAM_E	equ	9EFFH	;EMUZ80_Q43 RAM END address
IO_B	equ	0E000H	;EMUZ80_Q43 I/O base address
	ENDIF

	IF	RAM4K
; ORIGINAL MEMORY MAP for PIC18F47Q43

UARTDR	EQU	0E000H	; UART DATA REGISTOR
UARTCR	EQU	0E001H	; UART CONTROL REGISTOR
WORK_B	equ	8F00H	; work area 8F00-8FFF
STACKM	equ	8F00H	; monitor stack
STACK	equ	8EC0H	; user stack
ROM_B	equ	0000H	;EMUZ80_Q43 ROM base address
RAM_B	equ	8000H	;EMUZ80_Q43 RAM base address
RAM_E	equ	8FFFH	;EMUZ80_Q43 RAM END address
IO_B	equ	0E000H	;EMUZ80_Q43 I/O base address
	ENDIF

BASIC_TOP	equ	2000H
BASIC_CST	equ	2000H	; basic cold start
BASIC_WST	equ	2003H	; basic warm start

	IF	RAM12K
TIM0_CTL0	equ	0F800H	; timer0 control0 register
TIM0_CTL1	equ	0F801H	; timer0 control1 register
TIMER0_CNTL	equ	0F810H	; timer0 16bit counter LSB
TIMER0_CNTH	equ	0F811H	; timer0 16bit counter MSB
TIMER0_SCTL	equ	0F820H	; timer0 seconds counter LSB
TIMER0_SCTH	equ	0F821H	; timer0 seconds counter MSB
TIMER0_INITC	equ	87e1h	; timer adjust count number
	ENDIF

ENTRY	EQU	0040H		; Entry point

;;; 
;;; ROM area
;;;
start:

	ORG	ROM_B	; (RST 00H)

E_CSTART:
	JP	CSTART
;	JP	BASIC_START	; Default to BASIC start

E_WSTART:
	JP	API01

	db	0008H - $ dup(00H)
;	ORG	0008H	; (RST 08H)
	IF	BACKDOOR
	JP	RST08H
	ELSE
	JP	CONOUT
	ENDIF

	db	0010H - $ dup(00H)
;	ORG	0010H	; (RST 10H)
	IF	BACKDOOR
	JP	RST10H
	ELSE
	JP	CONIN
	ENDIF

	db	0018H - $ dup(00H)	; nop
;	ORG	0018H	; (RST 18H)
	IF	BACKDOOR
	JP	RST18H
	ELSE
	JP	CONST
	ENDIF

	db	0020H - $ dup(00H)	; nop
;	ORG	0020H	; (RST 20H)
	IF	BACKDOOR
	JP	RST20H
	ELSE
	RET
	ENDIF

	db	0028H - $ dup(00H)	; nop
;	ORG	0028H	; (RST 28H)
	IF	BACKDOOR
	RET
	ELSE
	RET
	ENDIF

	db	0030H - $ dup(00H)	; nop
;	ORG	0030H
	IF	BACKDOOR
	JP	RST30H
	ELSE
	JP	RST30H_IN
	ENDIF

	db	0038H - $ dup(00H)	; nop
;	ORG	0038H
	IF	BACKDOOR
	JP	RST38H;
	ELSE
	JP	RST38H_IN
	ENDIF

	;;
	;; Entry point
	;;

	db	ENTRY - $ dup(00H)
	;	ORG	ENTRY

	IF	BACKDOOR
;;;
;;; RST 08H Handler
;;;
RST08H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST08)
	jr	jmp_rst

;;;
;;; RST 10H Handler
;;;
RST10H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST10)
	jr	jmp_rst

;;;
;;; RST 18H Handler
;;;
RST18H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST18)
	jr	jmp_rst

;;;
;;; RST 20H Handler
;;;
RST20H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST20)
	jr	jmp_rst

;;;
;;; RST 28H Handler
;;;
RST28H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST28)
	jr	jmp_rst

;;;
;;; RST 30H Handler
;;;
RST30H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST30)
	jr	jmp_rst

;;;
;;; RST 38H Handler
;;;
RST38H:

	ld	(save_hl), hl	; save hl
	ld	hl, (stealRST38)
jmp_rst:
	push	hl		; set jump address
	ld	hl, (save_hl)	; restore hl
RST20H_IN:
RST28H_IN:
	ret			; jump (stealRST38)
	ENDIF

;;;
;;; Universal Monitor Z80 Cold start
;;;
CSTART:
	DI
	LD	SP,STACKM	; monitor stask defines STACKM

	LD	HL,RAM_B
	LD	(DSADDR),HL
	LD	(SADDR),HL
	LD	(GADDR),HL
	LD	A,'I'
	LD	(HEXMOD),A
	
	IF	BACKDOOR
	; init back door RST XXH entory point
	ld	hl, CONOUT		; RST 08H : CONOUT
	ld	(stealRST08), hl
	ld	hl, CONIN
	ld	(stealRST10), hl	; RST 10H : CONIN
	ld	hl, CONST
	ld	(stealRST18), hl	; RST 18H : CONST
	ld	hl, RST20H_IN
	ld	(stealRST20), hl
	ld	hl, RST28H_IN
	ld	(stealRST28), hl
	ld	hl, RST30H_IN
	ld	(stealRST30), hl
	ld	hl, RST38H_IN
	ld	(stealRST38), hl
	ENDIF

	;; Initialize register value
	XOR	A
	LD	HL,REG_B
	LD	B,REG_E-REG_B
IR0:
	LD	(HL),A
	INC	HL
	DJNZ	IR0

	LD	HL,STACK		; user stack define STACK
	LD	(REGSP),HL
	ld	hl, RAM_B
	ld	(REGPC), HL		; set program counter

	ld	b, F_bitSize
	ld	a, '.'
	ld	hl, F_bit
ir00:
	ld	(hl), a
	inc	hl
	djnz	ir00		; init F_bit string
	xor	a
	ld	(hl), a		; delimiter
;
;	LD	B,100
;TL:	
;	XOR	A
;	CALL	CONOUT
;	DJNZ	TL
;
	
; init dbg work area

	LD	B, dbg_wend - dbg_wtop
	ld	hl,dbg_wtop	
	XOR	A

dbg_wini:
	ld	(hl), a
	inc	hl
	DJNZ	dbg_wini

	ld	a, 'I'
	ld	(TM_mode), a	; default call_in mode
	ld	a, 'N'
	ld	(TP_mode), a	; default display reg mode
	ld	l, 0
	ld	h, l
	ld	(TC_cnt), hl	; clear trace step counter to 0
	xor	a
	ld	(fever_t), a	; clear flag trace forever
	; init bp, tp, gstop address & opcode
	ld	hl, RAM_B
	ld	(tpt1_adr), hl
	ld	(tpt2_adr), hl
	ld	(bpt1_adr), hl
	ld	(bpt2_adr), hl
	ld	(tmpb_adr), hl
	ld	a, (hl)
	ld	(tpt1_op), a
	ld	(tpt2_op), a
	ld	(bpt1_op), a
	ld	(bpt2_op), a
	ld	(tmpb_op), a

	ld	a,(basic_f)	; BASIC default start *
	cp	'B'		; BASIC default start *
	jp	nz, BASIC_START	; BASIC default start *

;; Opening message

	LD	HL,OPNMSG
	CALL	STROUT
;	EI

WSTART:
	LD	HL,PROMPT
	CALL	STROUT
	CALL	GETLIN
	CALL	SKIPSP
;	CALL	UPPER
	OR	A
	JR	Z, WSTART

	CP	'D'
	JP	Z, DUMP
	CP	'G'
	JP	Z, GO
	CP	'S'
	JP	Z, SETM

	CP	'L'
	JP	Z, LOADH
	CP	'P'
	JP	Z, SAVEH

	CP	'R'
	JP	Z, REG

	cp	'#'
	jp	Z, Launcher

	cp	'B'
	jp	z, brk_cmd	; break point command
	
	cp	'T'
	jp	z, trace_cmd	; trace point command

	cp	'?'
	jr	z, command_hlp	; command help message

ERR:
	LD	HL,ERRMSG
	CALL	STROUT
	JR	WSTART

BASIC_START:
	ld	a, 'B'
	ld	(basic_f),a	; BASIC default start *
	JP	BASIC_CST	; BASIC Cold start		

;;
;; command help
;;
command_hlp:

	LD	HL, cmd_hlp
	CALL	STROUT
	JR	WSTART

;;
;; Launch appended program
;;
Launcher:
	INC	HL
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	OR	A
	JR	Z,ERR

	; check L or number
	
	cp	'L'
	JR	Z,LST_PRG	; list append program

	; check number

	call	GET_NUM		; return BC : number
	JR	C, ERR

	; check number
	LD	A, C
	CP	(lanch1 - ApendTBL)/2 +1	; a < 17 ?
	JP	NC, ERR
	OR	A				; check '0'
	JP	Z, ERR

	; A <- append program No.

	DEC	A	; 0 <= A <= 0FH
	RLA		; A = A * 2
	LD	D, 0
	LD	E, A
	LD	HL, ApendTBL
	ADD	HL, DE	; get lanch address point
	LD	E, (HL)
	INC	HL
	LD	D, (HL)	; DE : JUMP POINT

	; Jump to append program
	
	EX	DE, HL
	LD	E, (HL)
	INC	HL
	LD	D, (HL)	; DE : jump address
	LD	A, D
	OR	E	; address check
	JR	Z,ERR	; jump address NULL
	EX	DE, HL
	JP	(HL)	; lanch append program
	
	; List out append program
LST_PRG:
	; get address to DE
	LD	HL, ApendTBL

LST_PRG1:
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL

	PUSH	DE
	POP	IX	; IX <-DE
	LD	A, (IX+0)
	OR	(IX+1)
	JR	Z, LST_END
	INC	DE
	INC	DE	; get string address
	
	EX	DE, HL
	CALL	STROUT
	EX	DE, HL
	JR	LST_PRG1

LST_END:
	JP	WSTART
	
; Append program launch table
;
ApendTBL:
	dw	lanch1
	dw	lanch2
	dw	lanch3
	dw	lanch4
	dw	lanch5
	dw	lanch6
	dw	lanch7
	dw	lanch8
	dw	lanch9
	dw	lanch10
	dw	lanch11
	dw	lanch12
	dw	lanch13
	dw	lanch14
	dw	lanch15
	dw	lanch16
	
lanch1:
	dw	BASIC_CST
	DB	"1. BASIC4.7b Cold Start",CR,LF,00H
lanch2:
	dw	BASIC_WST
	DB	"2. BASIC4.7b Warm Start",CR,LF,00H

lanch3:
lanch4:
lanch5:
lanch6:
lanch7:
lanch8:
lanch9:
lanch10:
lanch11:
lanch12:
lanch13:
lanch14:
lanch15:
lanch16:
	dw	0

	; get number
	; input HL : string buffer
	;
	; Return
	; CF =1 : Error
	; BC: Calculation result

GET_NUM:
	XOR	A		; Initialize C
	LD	B, A
	LD	C, A		; clear BC
	
GET_NUM0:
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	OR	A
	RET	Z		; ZF=1, ok! buffer end

	CALL	GET_BI
	RET	C

	push	af
	EX	AF, AF'		;'AF <> AF: save A
	pop	af
	CALL	MUL_10		; BC = BC * 10
	RET	C		; overflow error
	EX	AF, AF'		;'AF <> AF: restor A

	ld	d, 0
	ld	e, a
	CALL	BC_PLUS_DE	; BC = BC + A
	RET	C		; overflow error
				; result: BC = BC * 10 + A
	INC	HL
	JR	GET_NUM0
;
; Make binary to A
; ERROR if CF=1
;
GET_BI:
	OR	A
	JR	Z, UP_BI
	CP	'0'
	RET	C
	
	CP	'9'+1	; ASCII':'
	JR	NC, UP_BI
	SUB	'0'	; Make binary to A
	RET

UP_BI:
	SCF		; Set CF
	RET

;
; multiply by 10
; BC = BC * 10
MUL_10:
	push	bc
	SLA	C
	RL	B		; 2BC
	SLA	C
	RL	B		; 4BC
	SLA	C
	RL	B		; 8BC
	pop	de		; de = bc
	ret	c
	CALL	BC_PLUS_DE	; 9BC
	ret	c
	CALL	BC_PLUS_DE	; 10BC
	RET			; result : BC = BC * 10
;
; BC = BC + DE
BC_PLUS_DE:
	push	hl

	push	de
	pop	hl

	add	hl, bc

	push	hl
	pop	bc

	pop	hl
	RET

;
; list break point
;
b_list:
	ld	a, (bpt1_f)
	or	a
	jr	z, b_list1

	ld	hl, (bpt1_adr)
	ld	a, '1'
	call	b_msg_out

b_list1:
	ld	a, (bpt2_f)
	or	a
	jp	z, WSTART

	ld	hl, (bpt2_adr)
	ld	a, '2'
	call	b_msg_out
	JP	WSTART


;;; 
;;; break point command
;;; 
brk_cmd:
	INC	HL
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	OR	A
	JR	Z,b_list	; only type "B"

	ld	bc, bpt1_f
	cp	'1'
	jr	z, set_bp1

	ld	bc, bpt2_f
	cp	'2'
	jr	z, set_bp1

	cp	'C'	;clear?
	jr	z, bp_clr
	jp	ERR

set_bp1:
	EX	AF, AF'

	INC	HL
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	OR	A
	JR	Z, bp_LOT 	;; No address input -> list out
	cp	','
	jp	nz, ERR

	INC	HL
	CALL	SKIPSP
	push	bc
	CALL	RDHEX		; 1st arg.
	pop	hl		; hl <- bc
	jp	c, ERR

	call	setbpadr
	jp	c, ERR
	JP	WSTART


; hl : point of bp flag( bpt1_f or bpt2_f)
; de : break point address

; check ram area, and set berak point
; 
setbpadr:
	ld	a, d
	cp	RAM_B >> 8	; a - 0C0H
	jp	c, chkERR	; ROM area
	cp	IO_B >> 8	; a - 0F0H
	jp	nc, chkERR	; I/O area
	ld	a,1
	ld	(hl), a	; set flag
	inc	hl
	ld	a, (de)		; get opcode
	ld	(hl), a		; save opcode
	inc	hl
	ld	(hl), e ; set break point low address
	inc	hl
	ld	(hl), d ; set break point high address
	or	a	; reset carry
	ret

chkERR:
	scf	;set carry
	ret

; clear break point

bp_clr:
	INC	HL
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	OR	A
	JR	Z,b_aclr	; all clear

	ld	bc, bpt1_f
	cp	'1'
	jr	z, bp_clr1

	ld	bc, bpt2_f
	cp	'2'
	jp	nz, ERR

bp_clr1:
	xor	a
	ld	(bc), a
	JP	WSTART

b_aclr:
	xor	a
	ld	bc, bpt1_f
	ld	(bc), a
	ld	bc, bpt2_f
	ld	(bc), a
	JP	WSTART

; when no address input. list out BP
;
; bc : break pointer buffer offset
bp_LOT:
	ld	a, (bc)		; set break point?
	or	a
	jp	z, WSTART	; no break point setting

	EX	AF, AF'
	ld	hl, (bpt1_adr)
	cp	'1'
	jr	z, l_b2
	ld	hl, (bpt2_adr)
l_b2:
	call	b_msg_out
	JP	WSTART

bp_msg1:	db	"BP(",00H
bp_msg2:	db	"):",00H

b_msg_out:
	push	hl
	push	af
	ld	hl, bp_msg1
	call	STROUT
	pop	af
	call	CONOUT
	ld	hl, bp_msg2
	call	STROUT
	pop	hl
	call	HEXOUT4
	call	CRLF	
	ret

;;; 
;;; trace command
;;; 
trace_cmd:

; T[address][,step数]
; TP[ON | OFF]
; TM[I | S]

; init steps
	push	hl
	ld	l, 0
	ld	h, 0
	ld	(TC_cnt), hl	; clear trace step counter to 0
	ld	hl,(REGPC)
	ld	(tmpT), hl	; init temp address
	xor	a
	ld	(fever_t), a	; clear flag trace forever

	pop	hl
	inc	hl
	CALL	SKIPSP
	CALL	RDHEX		; 1st arg.
	jp	nc, tadr_chk
	CALL	SKIPSP
	ld	a, (hl)
	or	a
	Jp	z, t_op1	; only 1 step trace, check opcode
	cp	','
	jp	z, stp_chk	; steps check

;	CALL	UPPER
	cp	'P'
	jr	z, tp_cmd
	cp	'M'
	jp	nz, ERR
	
	; tm_cmd
	
	inc	hl
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
dip_TM:
	ld	hl, tm_msg_i
	cp	'I'
	jr	z, set_TM
	ld	hl, tm_msg_s
	cp	'S'
	jr	z, set_TM
	or	a
	jp	nz, ERR

;display T mode
	ld	a, (TM_mode)
	jr	dip_TM

;set TM mode and display
set_TM:
	ld	(TM_mode),a
	push	hl
	ld	hl, tm_msg_0
	call	STROUT
	pop	hl
	call	STROUT
	jp	WSTART

tm_msg_0:
	db	"TM mode:<CALL ", 00h
tm_msg_i:
	db	"IN>", CR, LF, 00h
tm_msg_s:
	db	"SKIP>", CR, LF, 00h
	
	
	; tp_cmd
tp_cmd:	
	inc	hl
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER
	or	a
	jr	nz, tp_n1
	ld	a, (TP_mode)
	jr	tp_n2
	
tp_n1:
	cp	'O'
	jp	nz, ERR
	inc	hl
	CALL	SKIPSP		; A <- next char
;	CALL	UPPER

tp_n2:
	ld	hl, tp_msg_on
	cp	'N'
	jr	z, tp_md_on

	ld	hl, tp_msg_off
	cp	'F'
	jp	nz, ERR

tp_md_on:
	; set trace mode and display mode
	ld	(TP_mode), a
	push	hl
	ld	hl, tp_msg_0
	call	STROUT
	pop	hl
	call	STROUT
	jp	WSTART
	
tp_msg_0:
	db	"TP mode: ", 00h
tp_msg_on:
	db	"ON", CR, LF, 00h
tp_msg_off:
	db	"OFF", CR, LF, 00h

tadr_chk:
	ld	(tmpT), de	; set start address
	CALL	SKIPSP		; A <- next char
	or	a
	jr	z, t_op1	; 1step trace
	cp	','
	jr	z, stp_chk
	jp	ERR

stp_chk:
	inc	hl
	CALL	SKIPSP		; A <- next char
	or	a
	jp	z, ERR
	cp	'-'
	jr	z, chk_fevre

; check steps

	call	GET_NUM		; get steps to BC
	JP	C, ERR		; number error

t_op11:
	ld	(TC_cnt), bc	; set trace step counter
	jr	t_op_chk

t_op1:
	ld	bc, 1
	jr	t_op11

chk_fevre:
	inc	hl
	CALL	SKIPSP		; A <- next char
	cp	'1'
	jp	nz, ERR
	inc	hl
	CALL	SKIPSP		; A <- next char
	or	a
	jp	nz, ERR		; not "-1" then error
	ld	a, 1
	ld	(fever_t), a	; set flag trace forever

t_op_chk:
	ld	hl, (tmpT)	; get PC address
	ld	a, (hl)		; get opcode
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; branch opecode check
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2 insertion Trace code(TC) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSTC2:
	; check 1 byte machine code: branch (RET CC)

	ld	bc, RETCC_TBLE - RETCC_TBLS
	ld	hl, RETCC_TBLS
	cpir
	jr	nz, next_bc1	; not RET CC

	; RET CC
	; trace operation:
	;   1. ea = *REGSP; *ea = TC;
	;   2. ea = *REGPC; *(ea+1) = TC;

	; 1
	ld	c, 1		; first TC point
	call	insBRK_sp
	jp	c, err_trace_seq
	
	; 2
	ld	c, 2		; second TC point
	call	insBRK_1op
	jp	c, err_trace_seq

	jp	END_INS_TC

	; check 2 byte machine code: branch (JR CC, Relative Value)
next_bc1:

	ld	bc, JRCC_TBLE - JRCC_TBLS
	ld	hl, JRCC_TBLS
	cpir
	jr	nz, next_bc2	; not JR CC

	; JR CC, nn
	; trace operation:
	;   1. ea = *REGPC; *(ea + 2 + *(ea+1)) = TC;
	;   2. ea = *REGPC; *(ea+2) = TC;

	; 1
	ld	c, 1		; first TC point
	ld	hl, (tmpT)
	call	Rel_adr_c
	call	inadr_chk_and_wrt
	jp	c, err_trace_seq

	; 2
	ld	c, 2		; second TC point
	call	insBRK_2op
	jp	c, err_trace_seq

	jp	END_INS_TC

	; check 3 byte machine code: branch JP CC, nnnn 16bit literal)

next_bc2:
	ld	bc, JPCC_TBLE - JPCC_TBLS
	ld	hl, JPCC_TBLS
	cpir
	jr	nz, next_bc21		; not JP CCC

	; JP CC, nnnn
	; trace operation:
	;   1. ea = *REGPC; *((short *)(ea+1)) = TC;
	;   2. ea = *REGPC; *(ea+3) = TC;

	ld	c, 1		; first TC point
	jr	next_bc222

	; check 3 byte machine code: branch (CALL CC, nnnn 16bit literal)

next_bc21:
	ld	bc, CLCC_TBLE - CLCC_TBLS
	ld	hl, CLCC_TBLS
	cpir
	jr	nz, INSTC1		; not CALL CCC

	; CALL CC, nnnn
	; trace operation:
	; TM_mode = 'I'
	;   1. ea = *REGPC; *((short *)(ea+1)) = TC;
	;   2. ea = *REGPC; *(ea+3) = TC;
	;
	; TM_mode = 'S'
	;   2. ea = *REGPC; *(ea+3) = TC;

	ld	c, 1		; first TC point
	ld	a, (TM_mode)
	cp	'S'
	jr	z, next_bc22	; skip insertion 1.

next_bc222:
	; 1. ea = *REGPC; *((char *)(ea+1)) = TC;
	call	insBRK_brp
	jp	c, err_trace_seq
	
next_bc221:
	; 2. ea = *REGPC; *(ea+3) = TC;
	ld	c, 2		; second TC point
next_bc22:
	call	insBRK_3op
	jp	c, err_trace_seq

	jp	END_INS_TC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1 insertion Trace code(TC) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSTC1:
	; check 1 byte machine code: branch (return)
	cp	0C9H		; RET ?
	jr	nz, next_bc3	; not RET

	; RET
	; trace operation:
	;   ea = *REGSP; *ea = TC;
	ld	c, 1		; first TC point
	call	insBRK_sp
	jp	c, err_trace_seq
	jp	END_INS_TC

	; check RST p
next_bc3:
	ld	bc, RST_TBLE - RST_TBLS
	ld	hl, RST_TBLS
	cpir
	jr	nz, next_bc4		; not RST p

	; RST p
	; can't trace: skip trace
	; trace operation:
	;   ea = *REGPC; *(ea+1) = TC;
;	ld	hl, RST_DMSG
;	call	STROUT		; message out "DETECT RST OPCODE"
	ld	c, 1		; first TC point
	call	insBRK_1op
	jp	c, err_trace_seq
	
	jp	END_INS_TC

;RST_DMSG:
;	db	"(RST nn) WILL BE SKIPPED. AND TRACE NEXT OPCODE", CR, LF,00

	; check code 0EDH
next_bc4:
	cp	0EDH		; CODE 0EDH ?
	jr	nz, next_bc5	; not 0EDH

	inc	hl
	ld	a, (hl)
	cp	45H		; RETN?
	jr	z, next_bc6	; yes, RETN
	cp	4DH		; RETI?
	jr	nz, next_bc5	; not RETN

	; trace operation:
	;   ea = *REGSP; *ea = TC;
next_bc6:
	ld	c, 1		; first TC point
	call	insBRK_sp
	jr	c, err_trace_seq
	jr	END_INS_TC

	; check JP (HL)
next_bc5:
	ld	hl, (tmpT)
	ld	a, (hl)

	cp	0E9H		; JP (HL) ?
	jr	nz, next_bc7	; not JP (HL)

	; JP (HL)
	; trace operation:
	;   ea = *REGHL; *ea = TC;
	ld	hl, (REGHL)
jphl:
	ld	c, 1		; first TC point
	call	inadr_chk_and_wrt
	jr	c, err_trace_seq
	jr	END_INS_TC

	; check JP (IX)
next_bc7:
	cp	0DDH		; 1st OPOCDE 0DDH ?
	jr	nz, next_bc8	; no 0DDH
	inc	hl
	ld	a, (hl)
	cp	0E9H		; JP (IX) ?
	jr	nz, next_bc8	; not JP (IX)

	; JP (IX)
	; trace operation:
	;   ea = *REGIX; *ea = TC;
	ld	hl, (REGIX)
	jr	jphl

	; check JP (IY)
next_bc8:
	ld	hl, (tmpT)
	ld	a, (hl)

	cp	0FDH		; 1st OPOCDE 0FDH ?
	jr	nz, next_bc9	; no 0FDH
	inc	hl
	ld	a, (hl)
	cp	0E9H		; JP (IX) ?
	jr	nz, next_bc9	; not JP (IX)

	; JP (IY)
	; trace operation:
	;   ea = *REGIY; *ea = TC;
	ld	hl, (REGIY)
	jr	jphl

	; check JR relative
next_bc9:
	ld	hl, (tmpT)
	ld	a, (hl)
	cp	18H		; JR relative ?
	jr	nz, next_bc10	; not JR relative

	; JR Relative
	; trace operation:
	;   ea = *REGPC; *(ea + 2 + *(ea+1)) = TC;
	ld	c, 1		; first TC point
	call	Rel_adr_c
	call	inadr_chk_and_wrt
	jr	c, err_trace_seq
	jr	END_INS_TC

	; check JP literal
next_bc10:
	cp	0C3H		; JP literal ?
	jr	nz, next_bc11	; not JP literal

	; JP literal
	; trace operation:
	; ea = *REGPC; *((char *)(ea+1)) = TC;
	ld	c, 1		; first TC point
	call	insBRK_brp
	jr	c, err_trace_seq
	jr	END_INS_TC

	; check call literal
next_bc11:
	cp	0CDH		; CALL literal ?
	jp	nz, INS2	; no, check not branch opcode 

	; CALL literal
	; trace operation:
	; TM_mode = 'I'
	;   ea = *REGPC; *((short *)(ea+1)) = TC;
	; TM_mode = 'S'
	;   2. ea = *REGPC; *(ea+3) = TC;

	ld	c, 1		; first TC point
	ld	a, (TM_mode)
	cp	'S'
	jr	z, next_bc111	; yes, TM_mode='S'

	; TM_mode = 'I'
	; ea = *REGPC; *((char *)(ea+1)) = TC;
	call	insBRK_brp
	jr	c, err_trace_seq
	jr	END_INS_TC

	; TM_mode = 'S'
	; ea = *REGPC; *(ea+3) = TC;
next_bc111:
	call	insBRK_3op
	jr	c, err_trace_seq

END_INS_TC:
	jp	G0	; go, trace operation

err_trace_seq:
	ld	hl, terr_msg
	call	STROUT
	JP	WSTART
	rst	38h
;	
terr_msg:	db	"Adr ERR", CR, LF, 00H

;--------------------------------------
; 2 byte machine code branch
; - 2nd byte is Relative address
; - input hl : opecode address
; - output hl : target address
;--------------------------------------
Rel_adr_c:
	inc	hl
	ld	e, (hl)		; e = 2nd operand
	inc	hl		; hl = PC + 2
	ld	d, 0ffh
	bit	7, e		; test msb bit
	jr	nz, exp_msb	; 
	ld	d, 0
exp_msb:
	add	hl, de
	ret

;--------------------------------------
; 1 byte op code, insert TC
; ea = *REGPC; *(ea+1) = TC
;--------------------------------------
insBRK_1op:
;	ld	hl, (REGPC)
	ld	hl, (tmpT)
	jr	ib1
	
;--------------------------------------
; 2 byte op code, insert TC
; ea = *REGPC; *(ea+2) = TC
;--------------------------------------
insBRK_2op:
;	ld	hl, (REGPC)
	ld	hl, (tmpT)
	jr	ib2
	
;--------------------------------------
; 3 byte op code, insert TC
; ea = *REGPC; *(ea+3) = TC;
;--------------------------------------
insBRK_3op:
;	ld	hl, (REGPC)
	ld	hl, (tmpT)
ib3:
	inc	hl
ib2:
	inc	hl
ib1:
	inc	hl
	call	inadr_chk_and_wrt
	ret

;--------------------------------------
; 3 byte op code, insert TC in branch point
; ea = *REGPC; *((char *)(ea+1)) = TC;
;--------------------------------------
insBRK_brp:
;	ld	hl, (REGPC)
	ld	hl, (tmpT)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ex	de,  hl
	call	inadr_chk_and_wrt
	ret

;--------------------------------------
; insert TC at SP
; ea = *REGSP; *ea = TC;
;--------------------------------------
insBRK_sp:
	ld	de, (REGSP)
	ld	a, (de)
	ld	l, a
	inc	de
	ld	a, (de)
	ld	h, a		; hl = *sp
	call	inadr_chk_and_wrt
	ret

;--------------------------------------
; check (HL) is RAM AREA
; insert Trace code at (HL)
;--------------------------------------
inadr_chk_and_wrt:
	ld	a, h

	cp	RAM_B >> 8		; 80H
	jr	c, NO_RAM_AREA
	cp	RAM_E >> 8		; 8FH
	jr	nc, NO_RAM_AREA

	ld	a, c
	cp	1		;first save?
	jr	nz, icka1
	ld	de, tpt1_f
	ld	(de), a		; set trace ON
	ld	(tpt1_adr), hl
	ld	a, (hl)		; get opcode
	ld	(tpt1_op), a	; save opcode
	jr	icka_end
icka1:
	ld	de, tpt2_f
	ld	(de), a		; set trace ON
	ld	(tpt2_adr), hl
	ld	a, (hl)		; get opcode
	ld	(tpt2_op), a	; save opcode
icka_end:
	xor	a
	ret

NO_RAM_AREA:
	SCF
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2 insertion TC TABLE
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 1 byte machine code: branch (RET CC)
RETCC_TBLS:
	DB	0C0H	; RET	NZ
	DB	0C8H	; RET	Z
	DB	0D0H	; RET	NC
	DB	0D8H	; RET	C
	DB	0E0H	; RET	PO
	DB	0E8H	; RET	PE
	DB	0F0H	; RET	P
	DB	0F8H	; RET	M
RETCC_TBLE:

; 2 byte machine code: branch (JR CC, Relative)
JRCC_TBLS:
	DB	10H	; DJNZ	$
JRCC_TBLS1:
	DB	20H	; JR	NZ,$
	DB	28H	; JR	Z,$
	DB	30H	; JR	NC,$
	DB	38H	; JR	C,$
JRCC_TBLE:

; 3 byte machine code: branch (JP CC, 16bit literal)
JPCC_TBLS:
	DB	0C2H	; JP	NZ,1234H
	DB	0CAH	; JP	Z,1234H
	DB	0D2H	; JP	NC,1234H
	DB	0DAH	; JP	C,1234H
	DB	0E2H	; JP	PO,1234H
	DB	0EAH	; JP	PE,1234H
	DB	0F2H	; JP	P,1234H
	DB	0FAH	; JP	M,1234H
JPCC_TBLE:

; (call 16bit literal)
CLCC_TBLS:
	DB	0C4H	; CALL	NZ,1234H
	DB	0CCH	; CALL	Z,1234H
	DB	0D4H	; CALL	NC,1234H
	DB	0DCH	; CALL	C,1234H
	DB	0E4H	; CALL	PO,1234H
	DB	0ECH	; CALL	PE,1234H
	DB	0F4H	; CALL	P,1234H
	DB	0FCH	; CALL	M,1234H
CLCC_TBLE:

;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1 insertion TC TABLE
;;;;;;;;;;;;;;;;;;;;;;;;;;

; restart
RST_TBLS:
	DB	0C7H	; RST	00H
	DB	0CFH	; RST	08H
	DB	0D7H	; RST	10H
	DB	0DFH	; RST	18H
	DB	0E7H	; RST	20H
	DB	0EFH	; RST	28H
	DB	0F7H	; RST	30H
	DB	0FFH	; RST	38H
RST_TBLE:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; machine code check(except branch)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INS2:

	; 2byte machine code search
	ld	bc, TWO_OPTBL_E - TWO_OPTBL
	ld	hl, TWO_OPTBL
	cpir
	jp	z, meet_op2

	; 3byte machine code search
	ld	bc, THREE_OPTBL_E - THREE_OPTBL
	ld	hl, THREE_OPTBL
	cpir
	jp	z, meet_op3

	; check 0CBH
	
	; readjust hl
	ld	hl, (tmpT)

	cp	0CBH		; opecode 0CBH?
	jr	z, meet_op2
	
	; check 0DDH
	cp	0ddh		; opecode 0DDH?
	jr	z, meet_dd
	
	; check 0EDH
	cp	0edh		; opecode 0EDH?
	jr	z, meet_ed

	; check 0FDH
	cp	0fdh		; opecode 0FDH?
	jr	z, meet_dd

	; 1byte machine code
	jr	meet_op1

	; opecode 0DDh
meet_dd:
	inc	hl
	ld	a, (hl)	
	cp	0cbh		; 2nd 0CBH?
	jr	z, meet_op4
	cp	21h		; 2nd 21H?
	jr	z, meet_op4
	cp	22h		; 2nd 22H?
	jr	z, meet_op4
	cp	2ah		; 2nd 2AH?
	jr	z, meet_op4
	cp	36h		; 2nd 36H?
	jr	z, meet_op4

	; 2nd code search
	ld	bc, DD_2NDTBL_E - DD_2NDTBL
	ld	hl, DD_2NDTBL
	cpir
	jr	z, meet_op2
	jr	meet_op3

meet_ed:
	inc	hl
	ld	a, (hl)	
	cp	43h		; 2nd 43H?
	jr	z, meet_op4
	cp	4bh		; 2nd 4BH?
	jr	z, meet_op4
	cp	53h		; 2nd 53H?
	jr	z, meet_op4
	cp	5bh		; 2nd 5BH?
	jr	z, meet_op4
	cp	73h		; 2nd 73H?
	jr	z, meet_op4
	cp	7bh		; 2nd 7BH?
	jr	z, meet_op4
	jr	meet_op2

; 1 machine code
meet_op1:
	ld	c, 1
	call	insBRK_1op
	jp	c, err_trace_seq
	jp	END_INS_TC

; 2 machine code
meet_op2:
	ld	c, 1
	call	insBRK_2op
	jp	c, err_trace_seq
	jp	END_INS_TC
; 3 machine code
meet_op3:
	ld	c, 1
	call	insBRK_3op
	jp	c, err_trace_seq
	jp	END_INS_TC

; 4 machine codee
meet_op4:
	ld	c, 1
;	ld	hl, (REGPC)
	ld	hl, (tmpT)
	inc	hl
	call	ib3
	jp	c, err_trace_seq
	jp	END_INS_TC

TWO_OPTBL:	; second byte is 8bitliteral[nn]
ld_r_nn_s:
	DB	06h	; LD	B,nn
	DB	0Eh	; LD	C,nn
	DB	16h	; LD	D,nn
	DB	1Eh	; LD	E,nn
	DB	26h	; LD	H,nn
	DB	2Eh	; LD	L,nn
	DB	36h	; LD	(HL),nn
	DB	3Eh	; LD	A,nn
ld_r_nn_e:

log_op_s:
	DB	0C6h	; ADD	A,nn
	DB	0CEh	; ADC	A,nn
	DB	0DEh	; SBC	A,nn
	DB	0D6h	; SUB	nn
	DB	0E6h	; AND	nn
	DB	0EEh	; XOR	nn
	DB	0F6h	; OR	nn
	DB	0FEh	; CP	nn
	DB	0DBh	; IN	A,(nn)
	DB	0D3h	; OUT	(nn),A
log_op_e:
TWO_OPTBL_E:

THREE_OPTBL:	; 2nd, 3rd byte is 16bitliteral[nnnn]
	DB	01h	; LD	BC,nnnn
	DB	11h	; LD	DE,nnnn
	DB	21h	; LD	HL,nnnn
	DB	31h	; LD	SP,nnnn
THREE_OPTBLe
	DB	22h	; LD	(nnnn),HL
	DB	32h	; LD	(nnnn),A

	DB	2Ah	; LD	HL,(nnnn)
	DB	3Ah	; LD	A,(nnnn)
THREE_OPTBL_E:

DD_2NDTBL:
	DB	09h	; ADD	IX,BC
	DB	19h	; ADD	IX,DE
	DB	29h	; ADD	IX,IX
	DB	39h	; ADD	IX,SP
DD_2NDTBL1:
	DB	23h	; INC	IX
	DB	2Bh	; DEC	IX
	DB	0E5h	; PUSH	IX
	DB	0E1h	; POP	IX
DD_2NDTBL2:
	DB	0E3h	; EX	(SP),IX
	DB	0F9h	; LD	SP,IX
DD_2NDTBL_E:

;;; 
;;; Dump memory
;;; 

DUMP:
	INC	HL
	LD	A,(HL)
	cp	'I'
	JP	Z,disassemble
	CALL	SKIPSP
	CALL	RDHEX		; 1st arg.
	jr	c, DP0
	;; 1st arg. found
	LD	(DSADDR),DE
	jr	dp00

DP0:	;; No arg. chk

	push	hl
	LD	HL,(DSADDR)
	LD	BC,128
	ADD	HL,BC
	LD	(DEADDR),HL
	pop	hl
	LD	A,(HL)
	OR	A
	JR	z, DPM		; no arg.

dp00:
	CALL	SKIPSP
	LD	A,(HL)
	CP	','
	JR	Z,DP1
	OR	A
	JP	NZ,ERR
	;; No 2nd arg.
	LD	HL,128
	ADD	HL,DE
	LD	(DEADDR),HL
	JR	DPM
DP1:
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX
	jp	c, ERR
	CALL	SKIPSP
	OR	A
	jp	nz, ERR
	INC	DE
	LD	(DEADDR),DE
DPM:
	;; DUMP main
	LD	HL,(DSADDR)
	LD	A,0F0H
	AND	L
	LD	L,A
	XOR	A
	LD	(DSTATE),A
DPM0:
	PUSH	HL
	CALL	DPL
	POP	HL
	LD	BC,16
	ADD	HL,BC
	CALL	CONST
	JR	NZ,DPM1
	LD	A,(DSTATE)
	CP	2
	JR	C,DPM0
	LD	HL,(DEADDR)
	LD	(DSADDR),HL
	JP	WSTART
DPM1:
	LD	(DSADDR),HL
	CALL	CONIN
	JP	WSTART

DPL:
	;; DUMP line
	CALL	HEXOUT4
	PUSH	HL
	LD	HL,DSEP0
	CALL	STROUT
	POP	HL
	LD	IX,INBUF
	LD	B,16
DPL0:
	CALL	DPB
	DJNZ	DPL0

	LD	HL,DSEP1
	CALL	STROUT

	LD	HL,INBUF
	LD	B,16
DPL1:
	LD	A,(HL)
	INC	HL
	CP	' '
	JR	C,DPL2
	CP	7FH
	JR	NC,DPL2
	CALL	CONOUT
	JR	DPL3
DPL2:
	LD	A,'.'
	CALL	CONOUT
DPL3:
	DJNZ	DPL1
	JP	CRLF

DPB:	; Dump byte
	LD	A,' '
	CALL	CONOUT
	LD	A,(DSTATE)
	OR	A
	JR	NZ,DPB2
	; Dump state 0
	LD	A,(DSADDR)	; Low byte
	CP	L
	JR	NZ,DPB0
	LD	A,(DSADDR+1)	; High byte
	CP	H
	JR	Z,DPB1
DPB0:	; Still 0 or 2
	LD	A,' '
	CALL	CONOUT
	CALL	CONOUT
	LD	(IX),A
	INC	HL
	INC	IX
	RET
DPB1:	; Found start address
	LD	A,1
	LD	(DSTATE),A
DPB2:
	LD	A,(DSTATE)
	CP	1
	JR	NZ,DPB0
	; Dump state 1
	LD	A,(HL)
	LD	(IX),A
	CALL	HEXOUT2
	INC	HL
	INC	IX
	LD	A,(DEADDR)	; Low byte
	CP	L
	RET	NZ
	LD	A,(DEADDR+1)	; High byte
	CP	H
	RET	NZ
	; Found end address
	LD	A,2
	LD	(DSTATE),A
	RET

;;;
;;; Disassemble
;;; 


; DI[<address>][,s<steps>|<end address>]

disassemble:
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX		; 1st arg.
	jr	nc, get_DI1

di_nxt:
	;; No arg. chk
	CALL	SKIPSP
	LD	A,(HL)
	OR	A
	jr	NZ, chk_DI1	; ',' check

; No arg
	ld	h, 0
	ld	l, 10
	ld	a, l
	ld	(dasm_stpf), a	; set step flag
	ld	(dasm_ed), hl	; set 10 steps
	jr	DISASM_go

; 1st arg
get_DI1:
	ld	(dasm_adr), de	; save start address
;	INC	HL
	jr	di_nxt

chk_DI1:
	cp	','
	jp	nz, ERR

; check 2nd arg

	INC	HL
	CALL	SKIPSP
;	call	UPPER
	cp	'S'
	jr	nz, chk_stpDI

; step arg
	ld	a, 1
	ld	(dasm_stpf), a	; set step flag
	inc	hl
	call	GET_NUM		; get decimal number to binary
	jp	c, ERR
	ld	(dasm_ed), bc	; set steps
	jr	DISASM_go

chk_stpDI:
	CALL	RDHEX		; 2nd arg.
	jp	c, ERR
	ld	(dasm_ed), de	; set end address
	xor	a
	ld	(dasm_stpf), a	; clear step flag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; operation Disassemble
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DISASM_go:
	call	CONST
	jr	z, dis_go1
	call	CONIN		;discard key
	jp	WSTART		; exit disasm command

dis_go1:
	; get opcode
	call	dis_analysis
	call	mk_adr_str	; conout address and machine code
				; *dasm_adr is next opcode address
	ld	hl, adr_mc_buf
	call	STROUT		; conout disassemble strings

	ld	a, (dasm_stpf)
	or	a
	jr	nz, calc_dis_step
	
	; *dasm_adr > *dasm_ed ?, yes, finish
	ld	hl, (dasm_ed)
	ld	bc, (dasm_adr)
	sbc	hl, bc
	jr	nc, DISASM_go
	jp	WSTART

calc_dis_step:
	ld	hl, (dasm_ed)
	dec	hl
	ld	(dasm_ed), hl
	ld	a, h
	or	l
	jr	nz, DISASM_go
	jp	WSTART

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disassemble and maked strings to user buffer
; input de : user buffer
;       hl : disassemble address
; output de : next MC address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_disasm_st:
	ld	(dasm_adr), hl
	push	de
	call	dis_analysis
	call	mk_adr_str	; conout address and machine code
	pop	de
	ld	hl, adr_mc_buf
	ld	bc, dasm_be - dasm_bs
	ldir
	ld	de, (dasm_adr)
	ld	a, (mc_Size)
	ret

;-------------------------------------------------
; Make address and machine code at adr_mc_buf
; "XXXX XX XX XX XX " (17bytes)
;-------------------------------------------------
mk_adr_str:
	ld	hl, adr_mc_buf
	ld	de, (dasm_adr)
	call	hex4str		; address XXXX
	call	ins_spcR
	call	ins_spcR

	ld	b, 4
	ld	a, (mc_Size)
	ld	c, a
mas_1:
	ld	a, (de)
	inc	de

	push	de
	ld	e, a
	call	hex2str		; MC XX
	call	ins_spcR
	pop	de

	dec	b
	jr	z, mas_3	; end
	dec	c
	jr	nz, mas_1

mas_2:	
	call	ins_spcR
	call	ins_spcR
	call	ins_spcR
	dec	b
	jr	nz, mas_2
mas_3:
	call	ins_spcR
	ld	(dasm_adr), de	; set next analysis address
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dis assemble analysis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dis_analysis:

	; pre init string buffer

	ld	a, 1
	ld	(mc_Size), a

	ld	de, LDstr	; insert LD string
	call	mkopcstr

	ld	hl, dasm_OprStr
	call	insPostStr	; CR, LF, 00h

	ld	hl, (dasm_adr)
	ld	a, (hl)		; get opcode

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; analysys 1 byte MC
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  check no operand

	ld	bc, oth_1op_e - oth_1op_s
	ld	hl, oth_1op_s
	cpir
	jr	nz, chk_ld

;  no operand

	ld	hl, oth_1op_tbl
	call	get_strBufpoint
	jp	mkopcstr

get_r_num:
	and	38H
	rrca
	rrca
	rrca
	ld	c, a
	ld	b, 0		; bc ; register No.
	ret
;
; LD opecode
;

; check LD "A,(BC)", "A,(DE)", "(BC),A", "(DE),A", "SP,HL"

chk_ld:
	cp	0AH	; LD	A,(BC)
	jr	z, ld_a_kbck
	cp	1AH	; LD	A,(DE)
	jr	z, ld_a_kdek
	cp	02H	; LD	(BC),A
	jr	z, ld_kbck_a
	cp	12H	; LD	(DE),A
	jr	z, ld_kdek_a
	cp	0F9H	; LD	SP,HL
	jr	nz, chk_ld1

; LD SP, HL
	ld	de, RNSP
	call	mk_rcs		; "SP, "
	jp	hl_crlf
	
; LD A, (BC)
ld_a_kbck:
	ld	de, RNBC
ld_a_kxxk:
	push	de
	call	a_colon_sp	; "A, "
	pop	de
	call	mk_krk		; "(BC)", "(DE)"
	jp	insPostStr	; CR, LF, 00h

; LD A, (DE)
ld_a_kdek:
	ld	de, RNDE
	jr	ld_a_kxxk

; LD (BC), A
ld_kbck_a:
	ld	de, RNBC

ld_kxxk_a:
	call	mk_krkcs	; "(BC), ", "(DE), "
	jp	a_crlf		; "A",CR,LF

; LD (DE), A
ld_kdek_a:
	ld	de, RNDE
	jr	ld_kxxk_a

; check other 1byte LD MC

chk_ld1:
	cp	40h
	jp	c, chk_inc
	cp	80h
	jr	nc, chk_add
	cp	76h	; HALT?
	jr	nz, LD1op

	ld	de, HLTstr	; HALT string
	jp	mkopcstr	; de : next string buffer addr

; LD

LD1op:
	call	get_r_num
	call	get_rstg_off
	ld	hl, dasm_OprStr
	call	mk_rcs		; "REG, "

mk_2ndopr:
	ld	de, (dasm_adr)
	ld	a, (de)		; get opcode
	and	07h
	ld	c, a
	ld	b, 0

mk_2ndopr1:
	push	hl		; save copy buffer
	call	get_rstg_off
	pop	hl		; copy buffer
	jp	cpstr_crlf	; "REG",CR,LF

; ADD 80H - 87H
; check ADD code

chk_add:
	cp	88h
	jr	nc, chk_adc

; ADD
	call	add_opstr
	call	a_colon_sp
	jr	mk_2ndopr

; ADC 88H - 8FH
; check ADC code

chk_adc:
	cp	90h
	jr	nc, chk_sub

; ADC
	ld	de, ADCstr
	call	mkopcstr
	call	a_colon_sp
	jr	mk_2ndopr

; SUB 90H - 97H
; check SUB code

chk_sub:
	cp	98h
	jr	nc, chk_sbc

; SUB
	ld	de, SUBstr
	call	mkopcstr
	jr	mk_2ndopr

; SBC 98H - 9FH
; check SBC code

chk_sbc:
	cp	0A0h
	jr	nc, chk_and

; SBC
	ld	de, SBCstr
	call	mkopcstr
	call	a_colon_sp
	jr	mk_2ndopr

; AND 0A0H - 0A7H
; check AND code

chk_and:
	cp	0A8h
	jr	nc, chk_xor

; AND
	ld	de, ANDstr
	call	mkopcstr
	jr	mk_2ndopr

; XOR 0A8H - 0AFH
; check XOR code

chk_xor:

	cp	0B0h
	jr	nc, chk_or

; XOR
	ld	de, XORstr
	call	mkopcstr
	jr	mk_2ndopr

; OR 0B0H - 0B7H
; check OR code

chk_or:
	cp	0B8h
	jr	nc, chk_cp

; OR
	ld	de, ORstr
	call	mkopcstr
	jr	mk_2ndopr

; CP 0B8H - 0BFH
; check CP code

chk_cp:
	cp	0C0h
	jp	nc, chk_pop_rp

; CP
	ld	de, CPstr
	call	mkopcstr
	jr	mk_2ndopr

;check INC

chk_inc:
	ld	bc, INC_OPCDTBLE - INC_OPCDTBLS
	ld	hl, INC_OPCDTBLS
	cpir
	jr	nz, chk_dec

; INC
	push	af
	ld	de, INCstr
	call	mkopcstr
	pop	af

inc_dec:
	call	get_r_num
	jp	mk_2ndopr1

;check dec

chk_dec:
	ld	bc, DEC_OPCDTBLE - DEC_OPCDTBLS
	ld	hl, DEC_OPCDTBLS
	cpir
	jr	nz, chk_inc_rp

; DEC
	push	af
	ld	de, DECstr
	call	mkopcstr
	pop	af
	jr	inc_dec

; check inc rp

chk_inc_rp:
	ld	bc, inc_rp_e - inc_rp_s
	ld	hl, inc_rp_s
	cpir
	jr	nz, chk_dec_rp

; INC rp
	ld	de, INCstr
	call	mkopcstr

	ld	hl, INC_DEC_ADDrp
	call	mk_str
	jp	insPostStr	; CR, LF, 00h

; check dec rp

chk_dec_rp:
	ld	bc, dec_rp_e - dec_rp_s
	ld	hl, dec_rp_s
	cpir
	jr	nz, chk_add_rp

; dec rp
	ld	de, DECstr
	call	mkopcstr

	ld	hl, INC_DEC_ADDrp
	call	mk_str
	jp	insPostStr	; CR, LF, 00h

;check ADD HL, rp

chk_add_rp:
	ld	bc, add_rp_e - add_rp_s
	ld	hl, add_rp_s
	cpir
	jr	nz, chk_ex

; add hl, rp

	call	add_opstr

	ld	de, RNHL
	call	mk_rcs		; "HL, "

	push	hl
	ld	hl, INC_DEC_ADDrp
	call	get_strBufpoint
	pop	hl
	jp	cpstr_crlf	; CR, LF, 00h

; check POP rp

chk_pop_rp:
	ld	bc, pop_rp_e - pop_rp_s
	ld	hl, pop_rp_s
	cpir
	jr	nz, chk_push_rp

; POP RP

	ld	de, POPstr
	call	mkopcstr

	ld	hl, POP_PUSHrp
	call	mk_str
	jp	insPostStr	; CR, LF, 00h

; check PUSH rp

chk_push_rp:
	ld	bc, push_rp_e - push_rp_s
	ld	hl, push_rp_s
	cpir
	jr	nz, chk_ex

; PUSH RP

	ld	de, PUSHstr
	call	mkopcstr

	ld	hl, POP_PUSHrp
	call	mk_str
	jp	insPostStr	; CR, LF, 00h

; check EX XX, XX

chk_ex:
	cp	08H		; EX	AF,AF'
	jr	z, ex_af_af
	cp	0E3H		; EX	(SP),HL
	jr	z, ex_sp_hl
	cp	0EBH		; EX	DE,HL
	jr	nz, chk_1mc_bnh

; EX DE, HL
	ld	de, RNDE
	call	mk_rcs

ins_hl_opr:
	call	hl_crlf

ins_ex_opc:
	ld	de, EXstr
	jp	mkopcstr

; EX AF,AF'
ex_af_af:
	ld	de, RNAF
	call	mk_rcs
	ld	de, RNAFX
	call	cpstr_crlf
	jr ins_ex_opc

; EX (SP),HL
ex_sp_hl:
	ld	de, RNSP
	call	mk_krkcs
	jr	ins_hl_opr

; check other one MC code

chk_1mc_bnh:

; check JP (HL)

	cp	0E9H		; JP (HL) ?
	jr	nz, chk_ret

; JP (HL)
	ld	de, JPstr
	call	mkopcstr	; "JP "

	ld	de, RNHL
	call	mk_krk_1
	jp	insPostStr

; check RET CC
chk_ret:
	ld	bc, RETCC_TBLE - RETCC_TBLS
	ld	hl, RETCC_TBLS
	cpir
	jr	nz, chk_rst

; RET CC
; BC : 7 >= BC >= 0

	; make opcode string
	ld	de, RETstr
	call	mkopcstr

	; make operand string

	ld	hl, CC_opr	; string base
	call	mk_str
	jp	insPostStr	; CR, LF, 00h

; check RST p

chk_rst:
	ld	bc, RST_TBLE - RST_TBLS
	ld	hl, RST_TBLS
	cpir
	jr	nz, chk_2MC		; 2bytes MC

; RST p

	ld	de, RSTstr
	call	mkopcstr	; de : next string buffer addr

; 0 <= BC <= 7
; 7: 00H  (0000 0 111 : 00 000 000)
; 6: 08H  (0000 0 110 : 00 001 000)
; 5: 10H  (0000 0 101 : 00 010 000)
; 4: 18H  (0000 0 100 : 00 011 000)
; 3: 20H  (0000 0 011 : 00 100 000)
; 2: 28H  (0000 0 010 : 00 101 000)
; 1: 30H  (0000 0 001 : 00 110 000)
; 0: 38H  (0000 0 000 : 00 111 000)
;
	ld	a, c
	cpl		; not a
	sla	a
	sla	a
	sla	a
	and	38H	; a = RST No.

	ld	e, a
	ld	hl, dasm_OprStr
	jp	mk_n2crlf	; "nnH", CR, LF

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; analysys 2 byte MC
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_2MC:

	push	af
	ld	a, 2
	ld	(mc_Size), a
	pop	af

; check LD r, nn

	ld	bc, ld_r_nn_e - ld_r_nn_s
	ld	hl, ld_r_nn_s
	cpir
	jr	nz, chk_logop2

; LD r, nn

	call	get_r_num
	call	get_rstg_off
	call	mk_rcs		; "REG, "

	ld	de, (dasm_adr)
	inc	de
	ld	a, (de)		; get nn
	ld	e, a
	call	hex2str_asm	; "nnH"
	jp	insPostStr	; CR, LF, 00h

; check logical operation with 8 bit literal

chk_logop2:

	ld	bc, log_op_e - log_op_s
	ld	hl, log_op_s
	cpir
	jp	nz, chk_djnz

; logical operation with 8 bit literal


	push	bc
	ld	hl, logop2str
	call	get_strBufpoint
	call	mkopcstr		; make op code string
	pop	bc
	ld	a, c

	cp	1
	jr	z, acs_kn2k	; insert "A, (nn)"
	or	a
	jr	z, ins_kn2k	; insert "(nn), A"
	cp	7
	jr	c, ins_n2crlf	; insert  "nnH"

; insert "A, "

	call	a_colon_sp

; "nn"
ins_n2crlf:
	ld	de, (dasm_adr)
	inc	de
	ld	a, (de)
	ld	e, a		; get nn
	jp	mk_n2crlf	; "nnH", CR, LF

acs_kn2k:
	call	a_colon_sp	; "A, "
	call	kn2k		; "(nnH)"
	jp	insPostStr	; CR, LF, 00h

; "(nn), A"
ins_kn2k:
	ld	hl, dasm_OprStr	;operand str buffer
	call	kn2k		; "(nnH)"
	call	ins_kmR		; " ,"
	jp	a_crlf		; "A", CR, LF, 00h

; "(nnH)"
kn2k:
	call	ins_kakkoL	; "("
	ld	de, (dasm_adr)
	inc	de
	ld	a, (de)		; get nn
	ld	e, a		; e: nn
	call	hex2str_asm	; hex strings
	jp	ins_kakkoR	; ")"


; check DJNZ nn
chk_djnz:
	cp	10H
	jr	nz, chk_jrnn

; check DJNZ nn
	ld	de, DJNZstr
	jr	jr_n4crlf

; check jr nn
chk_jrnn:
	cp	18H
	jr	nz, chk_jrcc	; not JR relative

; JR Relative
	ld	de, JRstr
jr_n4crlf:
	call	mkopcstr	; de : next string buffer addr
	ld	hl, dasm_OprStr
	jp	mkRel_str	; "nnnnH",cr,lf : nnnn : branch address

; JR CC, nn

chk_jrcc:
	ld	bc, JRCC_TBLE - JRCC_TBLS1
	ld	hl, JRCC_TBLS1
	cpir
	jr	nz, chk_3MC	; no, check 3 bnytes MC

; JR CC, nn(Relative Value)

	ld	de, JRstr
	call	mkopcstr
	ld	hl, JRCC_opr1	; string base
	call	mk_str		; "NZ", "Z", "NC", "C"
	call	ins_kmR		; ", "
	jp	mkRel_str	; "nnnnH", cr, lf

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; analysys 3 byte MC
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_3MC:
	push	af
	ld	a, 3
	ld	(mc_Size), a
	pop	af

	ld	bc, THREE_OPTBLe - THREE_OPTBL
	ld	hl, THREE_OPTBL
	cpir
	jp	nz, chk_ld16

; LD rp, nnnn

	ld	hl, logop3str
	call	get_strBufpoint
	call	mk_rcs		; "Reg, "

get_n4crlf:
	call	get_n4
	jp	mk_n4crlf	; "nnnnH", CR, LF, 00h

; LD 16bit literal
chk_ld16:
	cp	22h
	jr	z, ins_kkhl	; "(nnnnH), HL"
	cp	32h
	jr	z, ins_kka	; "(nnnnH), A"
	cp	2ah
	jr	z, ins_hlkk	; "HL, (nnnnH)"
	cp	3ah
	jp	nz, chk_jpn4	; check jp n4

; "A, (nnnnH)"
	call	a_colon_sp	; "A, "
	jr	kn4kcrlf

; "(nnnnH), HL"
ins_kkhl:
	call	kn4hk
	jp	hl_crlf		; "HL",cr,lf

; "(nnnnH), A"
ins_kka:
	call	kn4hk
	jp	a_crlf		; "A",cr,lf

kn4hk:
	call	get_n4
	jp	ins_kn4kcs	; "(nnnnH), "

get_n4:
	push	hl
	ld	hl, (dasm_adr)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	pop	hl
	ret

; "HL, (nnnnH)"
ins_hlkk:
	ld	de, RNHL
	call	mk_rcs		; "HL ,"

kn4kcrlf:
	call	get_n4
	call	mk_kn4k		; "(nnnnH)"
	jp	insPostStr	; cr, lf

; check JP literal

chk_jpn4:
	cp	0C3H		; JP literal ?
	jr	nz, chk_calln4	; not JP literal

; "JP nnnnH"

	ld	de, JPstr
	call	mkopcstr	; de : next string buffer addr
	jr	get_n4crlf

; check call literal

chk_calln4:
	cp	0CDH		; CALL literal ?
	jr	nz, chk_jpcc

; "CALL nnnnH",cr,lf

	ld	de, CALLstr
	call	mkopcstr	; de : next string buffer addr
	jr	get_n4crlf


; check 3 byte machine code: branch JP CC, nnnn

chk_jpcc:
	ld	bc, JPCC_TBLE - JPCC_TBLS
	ld	hl, JPCC_TBLS
	cpir
	jr	nz, chk_calcc

; JP CC, nnnn
; BC : 7 >= BC >= 0

	ld	de, JPstr

CC_NNNN:
	call	mkopcstr	; de : next string buffer addr

	ld	hl, CC_opr	; string base
	call	mk_str		; de: point (string end) + 1
	call	ins_kmR		; " ,"
	jr	get_n4crlf	; "nnnnh", cr,lf


; check 3 byte machine code: branch (CALL CC, nnnn 16bit literal)

chk_calcc:
	ld	bc, CLCC_TBLE - CLCC_TBLS
	ld	hl, CLCC_TBLS
	cpir
	jr	nz, chk_0CBH

; CALL CC, nnnn
; BC : 7 >= BC >= 0 CALLstr

	ld	de, CALLstr
	jr	CC_NNNN

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OPECODE 0CBH check
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_0CBH:
	ld	hl, (dasm_adr)
	inc	hl		; 2nd opecode address

	push	af
	ld	a, 2
	ld	(mc_Size), a	; set 2bytes MC
	pop	af

	cp	0cbh
	jp	nz, chk_0DDH

	ld	a, (hl)		; a : 2nd opecode
	ld	hl, dasm_OprStr ; set operand string buffer

	cp	08h
	jp	c, mk_rlcr
	cp	10h
	jp	c, mk_rrcr
	cp	18h
	jp	c, mk_rlr
	cp	20h
	jp	c, mk_rrr
	cp	28h
	jp	c, mk_slar
	cp	30h
	jp	c, mk_srar
	cp	38h
	jp	c, op_err
	cp	40h
	jp	c, mk_srlr
	cp	80h
	jp	c, mk_bitr
	cp	0c0h
	jp	c, mk_resr

; make SET n, r, SET n, (HL)

	call	mk_bitr_str
	ld	de, SETstr
	jp	mkopcstr


; make RLC r, RLC (HL)
mk_rlcr:
	call	ins_rstg
	ld	de, RLCstr
	jp	mkopcstr

; make RRC r, RRC (HL)
mk_rrcr:
	call	ins_rstg
	ld	de, RRCstr
	jp	mkopcstr

; make RL r, RL (HL)
mk_rlr:
	call	ins_rstg
	ld	de, RLstr
	jp	mkopcstr

; make RR r, RR (HL)
mk_rrr:
	call	ins_rstg
	ld	de, RRstr
	jp	mkopcstr

; make SLA r, SLA (HL)
mk_slar:
	call	ins_rstg
	ld	de, SLAstr
	jp	mkopcstr

; make SRA r, SRA (HL)
mk_srar:
	call	ins_rstg
	ld	de, SRAstr
	jp	mkopcstr

; make SRL r, SRL (HL)
mk_srlr:
	call	ins_rstg
	ld	de, SRLstr
	jp	mkopcstr

; make BIT n, r, BIT n, (HL)
mk_bitr:
	call	mk_bitr_str
	ld	de, BITstr
	jp	mkopcstr

; make RES n, r, RES n, (HL)
mk_resr:
	call	mk_bitr_str
	ld	de, RESstr
	jp	mkopcstr

op_err:
	ld	de, ER_OPMSG
	jp	mkopcstr

;-------------------------------------------
; input a : 2nd opecode
;	hl : make string buffer
; make "bit No, r" string to *hl
; (ex) *hl = "1, B"
;-------------------------------------------
mk_bitr_str:
	push	af
	call	set_bitno
	pop	af

ins_rstg:
	and	07h
	ld	c, a	; table offset
	ld	b, 0		; bc : string offset
	push	hl
	call	get_rstg_off	; get string address to de
	pop	hl
	jp	cpstr_crlf	; "REG", CR, LF, 00h
;
; input hl : make string buffer
;
set_bitno:
	and	38h
	rrca
	rrca
	rrca
	ld	b, a	; bit number

	ld	a, 30h
	or	b		; a : bit string "0" - "7"
	ld	(hl), a
	inc	hl
	jp	ins_kmR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OPECODE 0DDH check
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_0DDH:
	cp	0ddh
	jp	nz, chk_0EDH

	ld	de, RNIX
	ld	(reg_xy), de	; save index reg string
	ld	de, addixrp_tbl
	ld	(xy_srtp), de

chk_0DDH_1:

	ld	a, (hl)		; get 2nd opcode

	cp	0E3h	; EX (SP),IX
	jp	z, ins_kspkix
	cp	0E9h	; JP (IX)
	jp	z, ins_jpix
	cp	0F9h	; LD SP, IX
	jp	z, ins_spix

	ld	bc, DD_2NDTBL1 - DD_2NDTBL
	ld	hl, DD_2NDTBL
	cpir
	jp	z, ins_ixrp

	ld	bc, DD_2NDTBL2 - DD_2NDTBL1
	ld	hl, DD_2NDTBL1
	cpir
	jp	nz, chk_0DD3op

; INC	IX
; DEC	IX
; PUSH	IX
; POP	IX
	ld	hl, dd_2opt
	call	get_strBufpoint
	call	mkopcstr		; inseert OPCODE strings to dasm_OpcStr

	ld	hl, dasm_OprStr
	jp	ix_crlf			; "IX", CR, LF, 00h

; JP	(IX)
ins_jpix:
	ld	de, (reg_xy)
ins_jpix1:
	push	de
	ld	de, JPstr
	call	mkopcstr	; de : next string buffer addr

	pop	de
	call	mk_krk_1
	jp	insPostStr	; CR, LF, 00h

; EX	(SP),IX
ins_kspkix:
	ld	de, EXstr
	call	mkopcstr	; de : next string buffer addr
	ld	de, RNSP
	call	mk_krkcs	; "(SP), "
	jp	ix_crlf		; "IX",cr,lf

; LD	SP,IX
ins_spix:
	ld	de, RNSP
	call	mk_rcs		; "SP, "
	jp	ix_crlf		; "IX",cr,lf

; ADD	IX,BC
; ADD	IX,DE
; ADD	IX,IX
; ADD	IX,SP
ins_ixrp:
	call	add_opstr	; de : next string buffer addr

	ld	de, (reg_xy)
	call	mk_rcs		; "IX, "

	push	hl
	ld	hl, (xy_srtp)
	call	get_strBufpoint
	pop	hl
	jp	cpstr_crlf	; "REG",cr,lf

;
; check 0DD 3bytes MC
;
chk_0DD3op:
	push	af
	ld	a, 3
	ld	(mc_Size), a	; 2byte machine code
	pop	af

	ld	bc, dd_ld_tble - dd_ld_tbl
	ld	hl, dd_ld_tbl
	cpir
	jp	z, dd_ld

	cp	86h
	jp	z, dd_mix
	cp	8eh
	jp	z, dd_mix1
	cp	9eh
	jp	z, dd_mix2

	ld	bc, dd_log_tble - dd_log_tbl
	ld	hl, dd_log_tbl
	cpir
	jp	nz, chk_0DD4op

;
; make "SUB (IX+nn)", "AND (IX+nn)", "XOR (IX+nn)"
;       "OR (IX+nn)",  "CP (IX+nn)"
;      "INC (IX+nn)", "DEC (IX+nn)"
;
	ld	hl, ddlogtbl
	call	get_strBufpoint
	call	mkopcstr

mk_kixpnk:
	ld	de, (reg_xy)

mk_kiypnk:
	ld	hl, dasm_OprStr
	jp	kixypnk_crlf		; "(IX+nnH)",cr,lf

;
; make "LD (IX+nn), r" or "LD r, (IX+nn)"
;
dd_ld:
	ld	a, c
	cp	7
	jp	nc, dd_ld1
	
; LD (IX+nn), r
	ld	de, (reg_xy)
	call	kixypnk_cs	; make "(IX+nn), "

	push	hl
	ld	hl, dd_ldtbl
	call	get_strBufpoint
	pop	hl
	jp	cpstr_crlf	; "A", "L", "H", "E", D", "C", "B"
				; CR, LF, 00h
	
; LD r, (IX+nn)
dd_ld1:
	sub	7
	ld	c, a
	ld	hl, dd_ldtbl
	call	get_strBufpoint

	call	mk_rcs		; "REG, "
dd_mix4:
	ld	de, (reg_xy)
	jp	kixypnk_crlf	; "(IX+nn)", CR, LF, 00h


; "ADD A,(IX+nn)"
dd_mix:
	ld	de, ADDstr
dd_mix3:
	call	mkopcstr	; "ADD"
	call	a_colon_sp	; "A, "
	jr	dd_mix4		; "(IX+nn)",cr,lf

;"ADC A,(IX+nn)"
dd_mix1:
	ld	de, ADCstr
	jr	dd_mix3

;"SBC A,(IX+nn)"
dd_mix2:
	ld	de, SBCstr
	jr	dd_mix3

;
; check 0DD 4bytes MC
;
chk_0DD4op:
	push	af
	ld	a, 4
	ld	(mc_Size), a	; 2byte machine code
	pop	af

	cp	21h
	jp	z, DD_21
	cp	22h
	jp	z, DD_22
	cp	2ah
	jp	z, DD_2a
	cp	36h
	jp	nz, chk_DD_CB
; DD 36
; "LD (IX+xx), yy"

	ld	de, (reg_xy)
	call	kixypnk_cs	; "(IX+xx), "
	ld	e, d		; e: yy
	jp	mk_n2crlf	; "0yyH",cr,lf


; "LD IX, nnnn"
DD_21:
	ld	de, (reg_xy)
	call	mk_rcs		; "IX, "
	call	get_nnnn
	jp	mk_n4crlf	; "nnnnH",cr,lf

; "LD (nnnn), IX"
DD_22:
	call	get_nnnn
	call	ins_kn4kcs	; "(nnnnH), "
	jp	ix_crlf		; "IX",cr,lf

; "LD IX, (nnnn)"
DD_2a:
	ld	de, (reg_xy)
DD_2a1:
	call	mk_rcs		; "IX, "
	call	get_nnnn
	call	mk_kn4k		; "(nnnnH)"
	jp	insPostStr	; cr,lf

chk_DD_CB
	cp	0CBH
	jp	nz, op_err

	call	get_nnnn	; d: 3rd OP, e:nn
	ld	a, d

	ld	bc, dd_rt_tble - dd_rt_tbles
	ld	hl, dd_rt_tbles
	cpir
	jp	nz, DD_CB_nn_XX

	ld	hl, dd_rt_str
	call	get_strBufpoint
	call	mkopcstr	; RLC, RRC, RL, RR, SLA, SRA, SRL
	jp	mk_kixpnk	; "(IX+nnH)",cr,lf

; check BIT, RES, SET
DD_CB_nn_XX:

	; check undefine MC
	ld	bc, dd_bit_opTble - dd_bit_opTbl
	ld	hl, dd_bit_opTbl
	cpir
	jp	nz, op_err

	cp	80h
	jp	c, dd_bit
	cp	0c0h
	jp	c, dd_res

; DD_SET
; "SET i, (IX+nn)"

	ld	de, SETstr
	call	mkopcstr

DD_BSR:

	ld	hl, dasm_OprStr ; set operand string buffer
	call	set_bitno	; "i, "
	jp	dd_mix4		; "(IX+nn)", cr,lf

; DD_BIT
; "BIT i, (IX+nn)"
dd_bit:
	ld	de, BITstr
	call	mkopcstr
	jr	DD_BSR

; DD_RES
; "RES i, (IX+nn)"
dd_res:
	ld	de, RESstr
	call	mkopcstr
	jr	DD_BSR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OPECODE 0EDH check
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_0EDH:
	cp	0edh
	jp	nz, chk_0FDH

	ld	a, (hl)		; get 2nd opcode

	; check undefine MC
	ld	bc, ed_op_tble - ed_op_tbl
	ld	hl, ed_op_tbl
	cpir
	jp	nz, op_err

	ld	a, c
	cp	6
	jp	c, ed_4mc
	cp	27
	jp	c, ed_no_opr
	cp	30
	jp	c, ed_im
	jp	z, ed_ld_ar
	cp	31
	jp	z, ed_ld_ai
	cp	32
	jp	z, ed_ld_ra
	cp	33
	jp	z, ed_ld_ia
	cp	38
	jp	c, ed_adc
	cp	42
	jp	c, ed_sbc
	cp	49
	jp	c, ed_out

; c: 49 - 55 : IN r,(C) (r:B,C,D,E,H,L,A)

	ld	de, INstr
	call	mkopcstr

	ld	a, c
	sub	49
	ld	c, a
	ld	hl, dd_ldtbl
	call	get_strBufpoint	; get strung buffer
	call	mk_rcs		; "REG, "
	ld	de, KCKstr
	jp	cpstr_crlf	; "(C)",cr,lf

; c: 42 - 48 : OUT (C),r(r:B,C,D,E,H,L,A)
ed_out:
	ld	de, OUTstr
	call	mkopcstr

	ld	de, KCKstr
	call	mk_rcs		; "(C), "

	ld	a, c
	sub	42
	ld	c, a
	push	hl
	ld	hl, dd_ldtbl

ed_out1:
	call	get_strBufpoint	; get strung buffer
	pop	hl
	jp	cpstr_crlf	; "REG",cr,lf

; c: 38 - 41 : SBC HL,rr(rr:BC,DE,HL,SP)
ed_sbc:
	ld	de, SBCstr
	call	mkopcstr

	ld	de, RNHL
	call	mk_rcs		; "HL, "

	ld	a, c
	sub	38
ed_sbc1:
	ld	c, a
	push	hl
	ld	hl, INC_DEC_ADDrp
	jr	ed_out1

; c: 34 - 37 : ADC HL,rr(rr:BC,DE,HL,SP)
ed_adc:
	ld	de, ADCstr
	call	mkopcstr

	ld	de, RNHL
	call	mk_rcs		; "HL, "

	ld	a, c
	sub	34
	jr	ed_sbc1

; c: 30, 31 : LD A,R ; LD A,I
ed_ld_ar:
	call	a_colon_sp	; "A, "
	ld	de, RNR
	jp	cpstr_crlf	; "R",cr,lf
	
ed_ld_ai:
	call	a_colon_sp	; "A, "
	ld	de, RNI
	jp	cpstr_crlf	; "I",cr,lf
	
; c: 32, 33 : LD R,A ; LD I,A
ed_ld_ra:
	ld	de, RNR
ed_ld_ra1:
	call	mk_rcs		; "R, "
	jp	a_crlf		; "A",cr,lf

ed_ld_ia:
	ld	de, RNI
	jr	ed_ld_ra1
	
; c: 27, 28, 29 : IM 2, IM 1, IM 0
ed_im:
	ld	de, IMstr
	call	mkopcstr

	ld	a, 29
	sub	c
	add	a, '0'		; '0', '1', '2'
	ld	hl, dasm_OprStr
	ld	(hl), a
	inc	hl
	jp	insPostStr

; c: 6 - 26 ed_noopr
ed_no_opr:
	sub	6
	ld	c, a
	ld	b, 0
	ld	hl, ed_noopr
	call	get_strBufpoint		; de : string buffer
	jp	mkopcstr
;
; check ED 4 byte MC
;
ed_4mc:
	ld	a, 4
	ld	(mc_Size), a	; 4byte machine code

	push	bc
	ld	a, c
	ld	hl, ed_rp_str
	call	get_strBufpoint		; de : string buffer
	pop	bc
	ld	a, c
	cp	3
	jp	c, DD_2a1		; "rr, (nnnnH)",cr,lf
					; rr: BC, DE, SP
; "(nnnnH), rr" rr: BC, DE, SP

	push	de
	call	get_nnnn
	call	ins_kn4kcs	; "(nnnnH), "
	pop	de
	jp	cpstr_crlf	; "REG",cr,lf

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OPECODE 0FDH check
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

chk_0FDH:

	ld	de, RNIY
	ld	(reg_xy), de	; save index reg string
	ld	de, addiyrp_tbl
	ld	(xy_srtp), de

	jp	chk_0DDH_1

;-----------------------------------
; make "(REG+nn), " at dasm_OprStr
;	REG : IX or IY
; input de: RNIX, or RNIY
;-----------------------------------
kixypnk_cs:
	ld	hl, dasm_OprStr
	call	mk_kixypnk
	jp	ins_kmR

;-----------------------------------
; make "(REG+nn)",cr,lf 
;	REG : IX or IY
; input de: RNIX, or RNIY
;       hl: string buffer
;-----------------------------------
kixypnk_crlf:
	call	mk_kixypnk
	jp	insPostStr	; CR, LF, 00h

;-----------------------------------
; make "(IX+nn)", "(IY+nn)" string
; input de: RNIX, or RNIY
;       hl: string buffer
;-----------------------------------
mk_kixypnk:
	call	ins_kakkoL	; "("
	call	st_copy	; IX
	call	get_nnnn
	ld	a, e		;get number
	cp	80h
	jr	c, numPlus	; number plus
	neg			; a = not a + 1
	ld	e, a
	call	ins_misR	; -
sv_nnkr:
	call	hex2str_asm	; nnh
	jp	ins_kakkoR	; ")"
	
numPlus:
	call	ins_plsR	; +
	jr	sv_nnkr

; de : nnnn , or d:yy, e:xx
get_nnnn:
	push	hl
	ld	hl, (dasm_adr)
	inc	hl		; 2nd opecode address
	inc	hl		; operand address
	ld	e, (hl)		; get nn
	inc	hl
	ld	d, (hl)		; d:yy use for "LD (IX+xx), yy"
				; d:OP use for 4bytes MC like "DD CB xx OP"
				; de : YYXX : ED OP XX YY
	pop	hl
	ret

;-------------------------------------------------
; hl: massage table
; bc: found operand point
;
; output: copy strings to dasm_OprStr buffer
;         hl = end point of copied string buffer
;-------------------------------------------------
mk_str:
	call	get_strBufpoint
	ld	hl, dasm_OprStr
	jp	st_copy

;------------------------------------------------
; get register strings address
; input bc: string buffer offset
; output de: register strings address
;------------------------------------------------
get_rstg_off:
	ld	hl, disRegTbl

;-------------------------------------------------
; input
;	bc: found operand point
;	hl: massage table
; output: 
;	DE : string point
;-------------------------------------------------
get_strBufpoint:
	sla	c
	rl	b		; bc *=2
	add	hl, bc		; get operand string point
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ret

;------------------------------------------------
; insert "nnH", CR, LF to buffer
;input e: value
;      hl: string buffer
;------------------------------------------------
mk_n2crlf:
	call	hex2str_asm
	jp	insPostStr

;------------------------------------------------
; insert "nnnnH", CR, LF to buffer
;input de: value
;      hl: string buffer
;------------------------------------------------
mk_n4crlf:
	call	hex4str_asm
	jp	insPostStr

;------------------------------------------------
; insert "(nnnnH), " to buffer dasm_OprStr
;input de: value
;
; make "(nnnnH), " to dasm_OprStr buffer
; output hl: end point of string buffer
;------------------------------------------------
ins_kn4kcs:
	ld	hl, dasm_OprStr	;operand str buffer
	call	ins_kakkoL	; "("
	call	hex4str_asm
	call	ins_kakkoR	; ")"
	jp	ins_kmR		; ", "

;------------------------------------------------
; insert "(nnnnH)" to buffer
;input de: value
;      hl: string buffer
;------------------------------------------------
mk_kn4k:
	call	ins_kakkoL	; "("
	call	hex4str_asm
	jp	ins_kakkoR	; ")"

;------------------------------------------------
; Make address string from branch relative value
; input hl: string buffer pointer
; output *hl= "nnnnH",cr,lf,0
;------------------------------------------------
mkRel_str:
	push	hl
	ld	hl, (dasm_adr)
	call	Rel_adr_c	; return hl : target addr
	ex	de, hl		; hl: buffer, de: addr value
	pop	hl
	call	hex4str_asm
	jr	insPostStr
	
;------------------------------------------------
;input de: value, hl: save baffer.
;output 4hex chars(asm format)
;	(ex). "0FFFFH"
;             "1234H"
;       hl : hl = hl + 5(or 6); *hl=0
;------------------------------------------------
hex4str_asm:
	ld	a, d
	cp	0a0h
	jr	c, h4sa_1
	ld	a, '0'
	ld	(hl), a
	inc	hl

h4sa_1:
	call	hex4str
h4sa_2:
	ld	a, 'H'
	jp	ikk_1

;------------------------------------------------
;input e: value, hl: save baffer.
;output: 2 hex chars(asm format)
;	(ex). "0FFH"
;             "12H"
;       hl : hl = hl + 3(or 4); *hl=0
;------------------------------------------------
hex2str_asm:
	ld	a, e
	cp	0a0h
	jr	c, h2sa_1
	ld	a, '0'
	ld	(hl), a
	inc	hl

h2sa_1:
	call	hex2str
	jr	h4sa_2

;------------------------------------------------
;input de: value, hl: save baffer.
;output: 4 hex chras in save buffer
;	 hl = hl + 4
;------------------------------------------------
hex4str:
	ld	a, d
	call	h2s_n1
	ld	a, d
	call	h2s_n2

;------------------------------------------------
;input e: value, hl: save baffer.
;output: 2 hex chras in save buffer
;	 hl = hl + 2
;------------------------------------------------
hex2str:
	ld	a, e
	call	h2s_n1
	ld	a, e
	call	h2s_n2
	ret

h2s_n1:
	rrca
	rrca
	rrca
	rrca
h2s_n2:
	and	0fh
	or	30h
	cp	3aH
	jr	c, ikk_1	; '0' to '9'
	add	a, 07h		; 'A' to 'F'
	jr	ikk_1

add_opstr:
	ld	de, ADDstr
;-----------------------------------
; make opecode strings
; input de : opecode strings
;-----------------------------------
mkopcstr:
	push	af
	push	bc
	ld	b, 8	;tab size
	ld	hl, dasm_OpcStr
dmkstr0:
	ld	a, (de)
	or	a
	jr	z, dmkst1
	ld	(hl), a
	inc	hl
	inc	de
	dec	b
	jr	dmkstr0
dmkst1:
	ld	a, ' '
dmkst2:
	ld	(hl), a
	inc	hl
	dec	b
	jr	nz, dmkst2
	pop	bc
	pop	af
	ret

;
; "REG",CR,LF
;
a_crlf:
	ld	de, RNA
	jr	cpstr_crlf	; "A",CR,LF
;bc_crlf:
;	ld	de, RNBC
;	jr	cpstr_crlf
;de_crlf:
;	ld	de, RNDE
;	jr	cpstr_crlf
ix_crlf:
	ld	de, (reg_xy)
	jr	cpstr_crlf
;sp_crlf:
;	ld	de, RNSP
;	jr	cpstr_crlf
hl_crlf:
	ld	de, RNHL
cpstr_crlf:
	call	st_copy		; "REG"
	
;-----------------------------------
; insert CR, LF, 00H(end delimiter)
; input hl : insert buffer
;-----------------------------------
insPostStr:
	ld	a, CR
	ld	(hl), a		; CR code
	inc	hl
	ld	a, LF
	ld	(hl), a		; LF code
	inc	hl
	xor	a
	ld	(hl), a		; end delimiter
	ret

mk_krk_1:
	ld	hl, dasm_OprStr
;----------------------------
; insert "(Reg)" to buffer
;
; input de: register string
;	hl: save buffer
;----------------------------
mk_krk:
	call	ins_kakkoL	; "("
	call	st_copy		; "REG"
	jr	ins_kakkoR	; ")"

;----------------------------
; insert "(Reg), " to dasm_OprStr
;
; input de: register string
;----------------------------
mk_krkcs:
	ld	hl, dasm_OprStr
	call	ins_kakkoL	; "("
	call	st_copy		; "REG"
	call	ins_kakkoR	; ")"
	jr	ins_kmR		; ", "

;----------------------------
; insert "A, " to dasm_OprStr
;----------------------------
a_colon_sp:
	ld	de, RNA
;----------------------------
; insert "Reg, " to dasm_OprStr
;
; input de: register string
;----------------------------
mk_rcs:
	ld	hl, dasm_OprStr
	call	st_copy		; "REG"
	jr	ins_kmR		; ", "

;-------------------------------------------------
; copy string to output buffer
; input:
;	de : string point
;	hl : output buffer
;-------------------------------------------------
st_copy:
	ld	a, (de)
	ld	(hl), a
	or	a
	ret	z	; return after coping delimiter
			; hl : delimiter position
	inc	hl
	inc	de
	jr	st_copy

;--------------
; insert "("
;--------------
ins_kakkoL:
	ld	a, '('
	jr	ikk_1
	
;--------------
; insert ")"
;--------------
ins_kakkoR:
	ld	a, ')'
ikk_1:
	ld	(hl), a
	inc	hl
	ret

;--------------
; insert " "
;--------------
ins_spcR:
	ld	a, ' '
	jr	ikk_1

;--------------
; insert "+"
;--------------
ins_plsR:
	ld	a, '+'
	jr	ikk_1

;--------------
; insert "-"
;--------------
ins_misR:
	ld	a, '-'
	jr	ikk_1

;--------------
; insert ", "
;--------------
ins_kmR:
	ld	a, ','
	call	ikk_1
	jr	ins_spcR

;------------------------------------------
; Dis assemble tables
;------------------------------------------
oth_1op_s:
	DB	00H	; NOP
	DB	07H	; RLCA
	DB	0FH	; RRCA
	DB	17H	; RLA
	DB	1FH	; RRA
	DB	27H	; DAA
	DB	2FH	; CPL
	DB	37H	; SCF
	DB	3FH	; CCF
	DB	0C9H	; RET
	DB	0D9H	; EXX
	DB	0F3H	; DI
	DB	0FBH	; EI
oth_1op_e:

INC_OPCDTBLS:
	DB	04H	; INC	B
	DB	0CH	; INC	C
	DB	14H	; INC	D
	DB	1CH	; INC	E
	DB	24H	; INC	H
	DB	2CH	; INC	L
	DB	34H	; INC	(HL)
	DB	3CH	; INC	A
INC_OPCDTBLE:

DEC_OPCDTBLS:
	DB	05H	; DEC	B
	DB	0DH	; DEC	C
	DB	15H	; DEC	D
	DB	1DH	; DEC	E
	DB	25H	; DEC	H
	DB	2DH	; DEC	L
	DB	35H	; DEC	(HL)
	DB	3DH	; DEC	A
DEC_OPCDTBLE:

inc_rp_s:
	DB	03H	; INC	BC
	DB	13H	; INC	DE
	DB	23H	; INC	HL
	DB	33H	; INC	SP
inc_rp_e:

dec_rp_s:
	DB	0BH	; DEC	BC
	DB	1BH	; DEC	DE
	DB	2BH	; DEC	HL
	DB	3BH	; DEC	SP
dec_rp_e:

add_rp_s:
	DB	09H	; ADD	HL,BC
	DB	19H	; ADD	HL,DE
	DB	29H	; ADD	HL,HL
	DB	39H	; ADD	HL,SP
add_rp_e:

pop_rp_s:
	DB	0C1H	; POP	BC
	DB	0D1H	; POP	DE
	DB	0E1H	; POP	HL
	DB	0F1H	; POP	AF
pop_rp_e:

push_rp_s:
	DB	0C5H	; PUSH	BC
	DB	0D5H	; PUSH	DE
	DB	0E5H	; PUSH	HL
	DB	0F5H	; PUSH	AF
push_rp_e:

dd_ld_tbl:
	DB	46h	; nn: LD B,(IX+nn)
	DB	4Eh	; nn: LD C,(IX+nn)
	DB	56h	; nn: LD D,(IX+nn)
	DB	5Eh	; nn: LD E,(IX+nn)
	DB	66h	; nn: LD H,(IX+nn)
	DB	6Eh	; nn: LD L,(IX+nn)
	DB	7Eh	; nn: LD A,(IX+nn)

	DB	70h	; nn: LD (IX+nn),B
	DB	71h	; nn: LD (IX+nn),C
	DB	72h	; nn: LD (IX+nn),D
	DB	73h	; nn: LD (IX+nn),E
	DB	74h	; nn: LD (IX+nn),H
	DB	75h	; nn: LD (IX+nn),L
	DB	77h	; nn: LD (IX+nn),A
dd_ld_tble:

dd_log_tbl:
	DB	96h	; nn: SUB (IX+nn)
	DB	0A6h	; nn: AND (IX+nn)
	DB	0AEh	; nn: XOR (IX+nn)
	DB	0B6h	; nn: OR  (IX+nn)
	DB	0BEh	; nn: CP  (IX+nn)
	DB	34h	; nn: INC (IX+nn)
	DB	35h	; nn: DEC (IX+nn)
dd_log_tble:

dd_rt_tbles:
	DB	06h	; RLC (IX+nn)
	DB	0Eh	; RRC (IX+nn)
	DB	16h	; RL  (IX+nn)
	DB	1Eh	; RR  (IX+nn)
	DB	26h	; SLA (IX+nn)
	DB	2Eh	; SRA (IX+nn)
	DB	3Eh	; SRL (IX+nn)
dd_rt_tble:

; use checking undefine MC ( DD CB nn XX )
dd_bit_opTbl:
	DB	46h	; BIT 0,(IX+12H)
	DB	4Eh	; BIT 1,(IX+12H)
	DB	56h	; BIT 2,(IX+12H)
	DB	5Eh	; BIT 3,(IX+12H)
	DB	66h	; BIT 4,(IX+12H)
	DB	6Eh	; BIT 5,(IX+12H)
	DB	76h	; BIT 6,(IX+12H)
	DB	7Eh	; BIT 7,(IX+12H)
	DB	86h	; RES 0,(IX+12H)
	DB	8Eh	; RES 1,(IX+12H)
	DB	96h	; RES 2,(IX+12H)
	DB	9Eh	; RES 3,(IX+12H)
	DB	0A6h	; RES 4,(IX+12H)
	DB	0AEh	; RES 5,(IX+12H)
	DB	0B6h	; RES 6,(IX+12H)
	DB	0BEh	; RES 7,(IX+12H)
	DB	0C6h	; SET 0,(IX+12H)
	DB	0CEh	; SET 1,(IX+12H)
	DB	0D6h	; SET 2,(IX+12H)
	DB	0DEh	; SET 3,(IX+12H)
	DB	0E6h	; SET 4,(IX+12H)
	DB	0EEh	; SET 5,(IX+12H)
	DB	0F6h	; SET 6,(IX+12H)
	DB	0FEh	; SET 7,(IX+12H)
dd_bit_opTble:

; use checking undefine MC ( ED XX ....)
ed_op_tbl:
	DB	40h	; 55:IN  B,(C)
 	DB	48h	; 54:IN  C,(C)
	DB	50h	; 53:IN  D,(C)
	DB	58h	; 52:IN  E,(C)
	DB	60h	; 51:IN  H,(C)
	DB	68h	; 50:IN  L,(C)
	DB	78h	; 49:IN  A,(C)

	DB	41h	; 48:OUT (C),B
	DB	49h	; 47:OUT (C),C
	DB	51h	; 46:OUT (C),D
	DB	59h	; 45:OUT (C),E
	DB	61h	; 44:OUT (C),H
	DB	69h	; 43:OUT (C),L
	DB	79h	; 42:OUT (C),A

	DB	42h	; 41:SBC HL,BC
	DB	52h	; 40:SBC HL,DE
	DB	62h	; 39:SBC HL,HL
	DB	72h	; 38:SBC HL,SP

	DB	4Ah	; 37:ADC HL,BC
	DB	5Ah	; 36:ADC HL,DE
	DB	6Ah	; 35:ADC HL,HL
	DB	7Ah	; 34:ADC HL,SP

	DB	47h	; 33:LD I,A
	DB	4Fh	; 32:LD R,A
	DB	57h	; 31:LD A,I
	DB	5Fh	; 30:LD A,R

	DB	46h	; 29:IM  0
	DB	56h	; 28:IM  1
	DB	5Eh	; 27:IM  2

	DB	44h	; 26:NEG
	DB	45h	; 25:RETN
	DB	4Dh	; 24:RETI
	DB	67h	; 23:RRD
	DB	6Fh	; 22:RLD
	DB	0A0h	; 21:LDI
	DB	0A1h	; 20:CPI
	DB	0A2h	; 19:INI
	DB	0A3h	; 18:OUTI
	DB	0A8h	; 17:LDD
	DB	0A9h	; 16:CPD
	DB	0AAh	; 15:IND
	DB	0ABh	; 14:OUTD
	DB	0B0h	; 13:LDIR
	DB	0B1h	; 12:CPIR
	DB	0B2h	; 11:INIR
	DB	0B3h	; 10:OTIR
	DB	0B8h	; 09:LDDR
	DB	0B9h	; 08:CPDR
	DB	0BAh	; 07:INDR
	DB	0BBh	; 06:OTDR

	DB	43h	; 05:LD (nnnn),BC
	DB	53h	; 04:LD (nnnn),DE
	DB	73h	; 03:LD (nnnn),SP

	DB	4Bh	; 02:LD BC,(nnnn)
	DB	5Bh	; 01:LD DE,(nnnn)
	DB	7Bh	; 00:LD SP,(nnnn)
ed_op_tble:

RNAF:		DB	"AF",00H
RNAFX:		DB	"AF'",00H

RETstr:		db	"RET", 00h
JPstr:		db	"JP", 00h
JRstr:		db	"JR", 00h
DJNZstr:	db	"DJNZ", 00h
CALLstr:	db	"CALL", 00h
RSTstr:		db	"RST", 00h
LDstr:		db	"LD", 00h
HLTstr:		db	"HALT", 00h
ADDstr:		db	"ADD", 00h
ADCstr:		db	"ADC", 00h
SUBstr:		db	"SUB", 00h
SBCstr:		db	"SBC", 00h
ANDstr:		db	"AND", 00h
XORstr:		db	"XOR", 00h
ORstr:		db	"OR", 00h
CPstr:		db	"CP", 00h
INCstr:		db	"INC", 00h
DECstr:		db	"DEC", 00h
POPstr:		db	"POP", 00h
PUSHstr:	db	"PUSH",00h
EXstr:		db	"EX", 00h

EXXstr:		db	"EXX", 00h
NOPstr:		db	"NOP", 00h
RLCAstr:	db	"RLCA", 00h
RRCAstr:	db	"RRCA", 00h
RLAstr:		db	"RLA", 00h
RRAstr:		db	"RRA", 00h
DAAstr:		db	"DAA", 00h
CPLstr:		db	"CPL", 00h
SCFstr:		db	"SCF", 00h
CCFstr:		db	"CCF", 00h
DIstr:		db	"DI", 00h
EIstr:		db	"EI", 00h

OUTstr:		db	"OUT", 00h
INstr:		db	"IN", 00h

RLCstr		db	"RLC", 00h
RRCstr		db	"RRC", 00h
RLstr		db	"RL", 00h
RRstr		db	"RR", 00h
SLAstr		db	"SLA", 00h
SRAstr		db	"SRA", 00h
SRLstr		db	"SRL", 00h
BITstr		db	"BIT", 00h
RESstr		db	"RES", 00h
NEGstr		db	"NEG", 00h
IMstr		db	"IM", 00h
RRDstr		db	"RRD", 00h
RLDstr		db	"RLD", 00h
LDIstr		db	"LDI", 00h
CPIstr		db	"CPI", 00h
INIstr		db	"INI", 00h
OUTIstr		db	"OUTI", 00h
LDDstr		db	"LDD", 00h
CPDstr		db	"CPD", 00h
INDstr		db	"IND", 00h
OUTDstr		db	"OUTD", 00h
LDIRstr		db	"LDIR", 00h
CPIRstr		db	"CPIR", 00h
INIRstr		db	"INIR", 00h
OTIRstr		db	"OTIR", 00h
LDDRstr		db	"LDDR", 00h
CPDRstr		db	"CPDR", 00h
INDRstr		db	"INDR", 00h
OTDRstr		db	"OTDR", 00h
RETIstr		db	"RETI", 00h
RETNstr		db	"RETN", 00h
;BITstr		db	"BIT", 00h
;RESstr		db	"RES", 00h
SETstr		db	"SET", 00h
ER_OPMSG:	db	"???", 00h
KCKstr		db	"(C)", 00h

kRNHL:	db	"(HL)", 00h
cc0:	db	"NZ", 00h
cc1:	db	"Z", 00h
cc2:	db	"NC", 00h
cc3:	db	"C", 00h
cc4:	db	"PO", 00h
cc5:	db	"PE", 00h
cc6:	db	"P", 00h
cc7:	db	"M", 00h

disRegTbl:	dw	RNB, RNC, RND, RNE, RNH, RNL, kRNHL, RNA
CC_opr:		dw	cc7, cc6, cc5, cc4, cc3, cc2, cc1, cc0
JRCC_opr1:	dw	cc3, cc2, cc1, cc0
INC_DEC_ADDrp:	dw	RNSP, RNHL, RNDE, RNBC
POP_PUSHrp:	dw	RNAF, RNHL, RNDE, RNBC

oth_1op_tbl:	dw	EIstr, DIstr, EXXstr, RETstr, CCFstr
		dw	SCFstr, CPLstr, DAAstr, RRAstr
		dw	RLAstr, RRCAstr, RLCAstr, NOPstr

logop2str:	dw	OUTstr, INstr, CPstr, ORstr, XORstr
		dw	ANDstr, SUBstr, SBCstr, ADCstr, ADDstr

logop3str	dw	RNSP, RNHL, RNDE, RNBC
ed_rp_str	dw	RNSP, RNDE, RNBC, RNSP, RNDE, RNBC

dd_2opt:	dw	POPstr, PUSHstr, DECstr, INCstr
addixrp_tbl:	dw	RNSP, RNIX, RNDE, RNBC
addiyrp_tbl:	dw	RNSP, RNIY, RNDE, RNBC

ddlogtbl:	dw	DECstr, INCstr, CPstr, ORstr, XORstr, ANDstr, SUBstr
dd_ldtbl:	dw	RNA, RNL, RNH, RNE, RND, RNC, RNB

ed_noopr:	dw	OTDRstr, INDRstr, CPDRstr, LDDRstr
		dw	OTIRstr, INIRstr, CPIRstr, LDIRstr
		dw	OUTDstr, INDstr, CPDstr, LDDstr
		dw	OUTIstr, INIstr, CPIstr, LDIstr
		dw	RLDstr, RRDstr, RETIstr, RETNstr
		dw	NEGstr

dd_rt_str:	dw	SRLstr, SRAstr, SLAstr, RRstr
		dw	RLstr, RRCstr, RLCstr
	
;;;
;;; GO address
;;; 

GO:
	ld	de, (REGPC)
	ld	(goTmp), de	; save go tmp go address
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX
	jr	nc, gostmp
	OR	A
	JR	Z, g_stpadr
gostmp:
	ld	a, d
	cp	IO_B >> 8	; a - 0F0H
	jp	nc, ERR		; detect I/O area
	LD	(goTmp),DE	; save going address
g_stpadr:
	CALL	SKIPSP
	LD	A,(HL)
	or	a
	jr	z, GO1
	cp	','
	jp	nz, ERR

; set break point with go command

	INC	HL
	CALL	SKIPSP
	CALL	RDHEX		; 1st arg.
	jp	c, ERR

	ld	hl, tmpb_f	; hl: temp break point buffer
	call	setbpadr
	jp	c, ERR		; address is incorrect

GO1:
	LD	hl, (goTmp)
	ld	(REGPC), hl	; set go address

G0:
; check Trace mode

	ld	a, (tpt1_f)
	or	a
	jr	z, donot_trace
	
	ld	hl,(tmpT)
	ld	(REGPC), hl	; set trace address

	ld	hl, tpt1_f
	ld	de, tpt1_adr
	call	set_bp
	ld	hl, tpt2_f
	ld	de, tpt2_adr
	call	set_bp
	jr	skp_tbp		; skip set tmp bp and bp, if tracing

; set break point
donot_trace:
	ld	hl, bpt1_f
	ld	de, bpt1_adr
	call	set_bp
	ld	hl, bpt2_f
	ld	de, bpt2_adr
	call	set_bp


; check go, break pointer

	ld	hl, tmpb_f
	ld	de, tmpb_adr
	call	set_bp

	;; R register adjustment

skp_tbp:
	LD	HL,(REGSP)
	LD	SP,HL
	LD	HL,(REGPC)
	PUSH	HL
	LD	IX,(REGIX)
	LD	IY,(REGIY)
	LD	HL,(REGAFX)
	PUSH	HL
	LD	BC,(REGBCX)
	LD	DE,(REGDEX)
	LD	HL,(REGHLX)
	EXX
	POP	AF
	EX	AF,AF'
	LD	HL,(REGAF)
	PUSH	HL
	LD	BC,(REGBC)
	LD	DE,(REGDE)
	LD	HL,(REGHL)
	LD	A,(REGI)
	LD	I,A
	LD	A,(REGR)
	LD	R,A
	POP	AF
	RET			; POP PC

set_bp:
	ld	a, (hl)
	or	a
	ret	z

	ld	a, (de)
	ld	c, a
	inc	de
	ld	a, (de)
	ld	b, a	; bc = break point address

	ld	a, 0FFH
	ld	(bc), a	; insert RST 38H code
	ret
	
;;;
;;; SET memory
;;; 

SETM:
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX

	jp	c, ERR

	CALL	SKIPSP
	LD	A,(HL)
	OR	A
	JP	NZ,ERR
	LD	A,C
	OR	A
	JR	NZ,SM0
	LD	DE,(SADDR)


SM0:
	EX	DE,HL
SM1:
	CALL	HEXOUT4
	PUSH	HL
	LD	HL,DSEP1
	CALL	STROUT
	POP	HL
	LD	A,(HL)
	PUSH	HL
	CALL	HEXOUT2
	LD	A,' '
	CALL	CONOUT
	CALL	GETLIN
	CALL	SKIPSP
	LD	A,(HL)
	OR	A
	JR	NZ,SM2
	;; Empty  (Increment address)
	POP	HL
	INC	HL
	LD	(SADDR),HL
	JR	SM1
SM2:
	CP	'-'
	JR	NZ,SM3
	;; '-'  (Decrement address)
	POP	HL
	DEC	HL
	LD	(SADDR),HL
	JR	SM1
SM3:
	CP	'.'
	JR	NZ,SM4
	POP	HL
	LD	(SADDR),HL
	JP	WSTART
SM4:
	CALL	RDHEX
	OR	A
	POP	HL
	JP	Z,ERR
	LD	(HL),E
	INC	HL
	LD	(SADDR),HL	; set value

	; resave opcode for BP command
	ld	de, (bpt1_adr)
	ld	a, (de)
	ld	(bpt1_op), a
	ld	de, (bpt2_adr)
	ld	a, (de)
	ld	(bpt2_op), a

	JR	SM1

;;;
;;; LOAD HEX file
;;;

LOADH:
	; clear brk point
	xor	a
	ld	(bpt1_f), a
	ld	(bpt2_f), a
	
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX
	CALL	SKIPSP
	LD	A,(HL)
	OR	A
	JP	NZ,ERR

	LD	A,C
	OR	A
	JR	NZ,LH0

	LD	DE,0		;Offset
LH0:
	CALL	CONIN
;	CALL	UPPER
	CP	'S'
	JR	Z,LHS0
LH1:
	CP	':'
	JR	Z,LHI0
LH2:
	;; Skip to EOL
	CP	CR
	JR	Z,LH0
	CP	LF
	JR	Z,LH0
LH3:
	CALL	CONIN
	JR	LH2

LHI0:
	ld	a, '.'
	call	CONOUT

	CALL	HEXIN
	LD	C,A		; Checksum
	LD	B,A		; Length

	CALL	HEXIN
	LD	H,A		; Address H
	ADD	A,C
	LD	C,A

	CALL	HEXIN
	LD	L,A		; Address L
	ADD	A,C
	LD	C,A

	;; Add offset
	ADD	HL,DE

	CALL	HEXIN
	LD	(RECTYP),A
	ADD	A,C
	LD	C,A		; Checksum

	LD	A,B
	OR	A
	JR	Z,LHI3
LHI1:
	CALL	HEXIN
	PUSH	AF
	ADD	A,C
	LD	C,A		; Checksum

	LD	A,(RECTYP)
	OR	A
	JR	NZ,LHI20

	POP	AF
	LD	(HL),A
	INC	HL
	JR	LHI2
LHI20:
	POP	AF
LHI2:
	DJNZ	LHI1
LHI3:
	CALL	HEXIN
	ADD	A,C
	JR	NZ,LHIE		; Checksum error
	LD	A,(RECTYP)
	OR	A
	JP	Z,LH3
	JP	WSTART
LHIE:
	LD	HL,IHEMSG
	CALL	STROUT
	JP	WSTART
	
LHS0:
	CALL	CONIN
	LD	(RECTYP),A

	CALL	HEXIN
	LD	B,A		; Length+3
	LD	C,A		; Checksum

	CALL	HEXIN
	LD	H,A
	ADD	A,C
	LD	C,A
	
	CALL	HEXIN
	LD	L,A
	ADD	A,C
	LD	C,A

	ADD	HL,DE

	DEC	B
	DEC	B
	DEC	B
	JR	Z,LHS3
LHS1:
	CALL	HEXIN
	PUSH	AF
	ADD	A,C
	LD	C,A		; Checksum

	LD	A,(RECTYP)
	CP	'1'
	JR	NZ,LHS2

	POP	AF
	LD	(HL),A
	INC	HL
	JR	LHS20
LHS2:
	POP	AF
LHS20:
	DJNZ	LHS1
LHS3:
	CALL	HEXIN
	ADD	A,C
	CP	0FFH
	JR	NZ,LHSE

	LD	A,(RECTYP)
	CP	'7'
	JR	Z,LHSR
	CP	'8'
	JR	Z,LHSR
	CP	'9'
	JR	Z,LHSR
	JP	LH3
LHSE:
	LD	HL,SHEMSG
	CALL	STROUT
LHSR:
	JP	WSTART
	
;;;
;;; SAVE HEX file
;;;

SAVEH:
	INC	HL
	LD	A,(HL)
;	CALL	UPPER
	CP	'I'
	JR	Z,SH0
	CP	'S'
	JR	NZ,SH1
SH0:
	INC	HL
	LD	(HEXMOD),A
SH1:
	CALL	SKIPSP
	CALL	RDHEX
	OR	A
	JR	Z,SHE
	PUSH	DE
	POP	IX		; IX = Start address
	CALL	SKIPSP
	LD	A,(HL)
	CP	','
	JR	NZ,SHE
	INC	HL
	CALL	SKIPSP
	CALL	RDHEX		; DE = End address
	OR	A
	JR	Z,SHE
	CALL	SKIPSP
	LD	A,(HL)
	OR	A
	JR	Z,SH2
SHE:
	JP	ERR

SH2:
	PUSH	IX
	POP	HL
	EX	DE,HL
	INC	HL
	OR	A
	SBC	HL,DE		; HL = Length
SH3:
	CALL	SHL00
	LD	A,H
	OR	L
	JR	NZ,SH3

	LD	A,(HEXMOD)
	CP	'I'
	JR	NZ,SH4
	;; End record for Intel HEX
	LD	HL,IHEXER
	CALL	STROUT
	JP	WSTART
SH4:
	;; End record for Motorola S record
	LD	HL,SRECER
	CALL	STROUT
	JP	WSTART

SHL00:
	LD	C,16
	LD	A,H
	OR	A
	JR	NZ,SHL0
	LD	A,L
	CP	C
	JR	NC,SHL0
	LD	C,A
SHL0:
	LD	B,0
	OR	A
	SBC	HL,BC
	LD	B,C

	LD	A,(HEXMOD)
	CP	'I'
	JR	NZ,SHLS

	;; Intel HEX
	LD	A,':'
	CALL	CONOUT

	LD	A,B
	CALL	HEXOUT2		; Length
	LD	C,B		; Checksum

	LD	A,D
	CALL	HEXOUT2
	LD	A,D
	ADD	A,C
	LD	C,A
	
	LD	A,E
	CALL	HEXOUT2
	LD	A,E
	ADD	A,C
	LD	C,A
	
	XOR	A
	CALL	HEXOUT2
SHLI0:
	LD	A,(DE)
	PUSH	AF
	CALL	HEXOUT2
	POP	AF
	ADD	A,C
	LD	C,A

	INC	DE
	DJNZ	SHLI0

	LD	A,C
	NEG
	CALL	HEXOUT2
	JP	CRLF

SHLS:
	;; Motorola S record
	LD	A,'S'
	CALL	CONOUT
	LD	A,'1'
	CALL	CONOUT

	LD	A,B
	ADD	A,2+1		; DataLength + 2(Addr) + 1(Sum)
	LD	C,A
	CALL	HEXOUT2

	LD	A,D
	CALL	HEXOUT2
	LD	A,D
	ADD	A,C
	LD	C,A
	
	LD	A,E
	CALL	HEXOUT2
	LD	A,E
	ADD	A,C
	LD	C,A
SHLS0:
	LD	A,(DE)
	PUSH	AF
	CALL	HEXOUT2		; Data
	POP	AF
	ADD	A,C
	LD	C,A

	INC	DE
	DJNZ	SHLS0

	LD	A,C
	CPL
	CALL	HEXOUT2
	JP	CRLF

;;;
;;; Register
;;;

REG:
	INC	HL
	CALL	SKIPSP
;	CALL	UPPER
	OR	A
	JR	NZ,RG0
	CALL	RDUMP
	JP	WSTART
RG0:
	EX	DE,HL
	LD	HL,RNTAB
RG1:
	CP	(HL)
	JR	Z,RG2		; Character match
	LD	C,A
	INC	HL
	LD	A,(HL)
	OR	A
	JR	Z,RGE		; Found end mark
	LD	A,C
	LD	BC,5
	ADD	HL,BC		; Next entry
	JR	RG1
RG2:
	INC	HL
	LD	A,(HL)
	CP	0FH		; Link code
	JR	NZ,RG3
	;; Next table
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,C
	INC	DE
	LD	A,(DE)
;	CALL	UPPER
	JR	RG1
RG3:
	OR	A
	JR	Z,RGE		; Found end mark

	LD	C,(HL)		; LD C,A???
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE		; Reg storage address
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A		; HL: Reg name
	CALL	STROUT
	LD	A,'='
	CALL	CONOUT

	LD	A,C
	AND	07H
	CP	1
	JR	NZ,RG4
	;; 8 bit register
	POP	HL
	LD	A,(HL)
	PUSH	HL
	CALL	HEXOUT2
	JR	RG5
RG4:
	;; 16 bit register
	POP	HL
	PUSH	HL
	INC	HL
	LD	A,(HL)
	CALL	HEXOUT2
	DEC	HL
	LD	A,(HL)
	CALL	HEXOUT2
RG5:
	LD	A,' '
	CALL	CONOUT
	PUSH	BC		; C: reg size
	CALL	GETLIN
	CALL	SKIPSP
	CALL	RDHEX
	OR	A
	JR	Z,RGR
	POP	BC
	POP	HL
	LD	A,C
	CP	1
	JR	NZ,RG6
	;; 8 bit register
	LD	(HL),E
	JR	RG7
RG6:
	;; 16 bit register
	LD	(HL),E
	INC	HL
	LD	(HL),D
RG7:
RGR:
	JP	WSTART
RGE:
	JP	ERR

RDUMP:
	LD	HL,RDTAB
RD0:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,D
	OR	E
	JP	Z,CRLF		; End
	push	de
	EX	DE,HL
	CALL	STROUT	; print name of register
	EX	DE,HL
	pop	de

; flag check
	ld	a, RDSF_H
	cp	d
	jr	nz, rd101
	ld	a, RDSF_L
	cp	e
	jr	nz, rd101
	jr	rd20

rd101:
	ld	a, RDSFX_H
	cp	d
	jr	nz, rd10
	ld	a, RDSFX_L
	cp	e
	jr	z, rd20

rd10:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	EX	DE,HL
	CP	1
	JR	NZ,RD1
	;; 1 byte
	LD	A,(HL)
	CALL	HEXOUT2
	EX	DE,HL
	JR	RD0
RD1:
	;; 2 byte
	INC	HL
	LD	A,(HL)
	CALL	HEXOUT2		; High byte
	DEC	HL
	LD	A,(HL)
	CALL	HEXOUT2		; Low byte
	EX	DE,HL
	JR	RD0

; make flag image string
rd20:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	ld	a, (de)		; get flag values

	push	de
	push	hl

; make flag image

	ld	hl, F_bit
	ld	bc, F_bit_on
	ld	de, F_bit_off
	push	af		; adjustment SP. DO NOT DELETE THIS LINE!

flg_loop:
	pop	af		; "push af" before loop back
	sla	a
	jr	nc, flg_off
	push	af
	ld	a, (bc)
	ld	(hl), a
	pop	af
	jr	flg_nxt
flg_off:
	push	af
	ld	a, (de)
	ld	(hl), a
	pop	af

flg_nxt:
	inc	bc
	inc	de
	inc	hl

	push	af
	ld	a, (hl)
	or	a		;check delimiter
	jr	nz, flg_loop

	pop	af		; restore stack position
	ld	hl, F_bit
	call	STROUT		; print flag register for bit imaze

	pop	hl
	pop	de

	inc	hl
	JR	RD0

F_bit_on:	db	"SZ.H.PNC"
F_bit_off:	db	"........"


;;;
;;; Other support routines
;;;

STROUT:
	LD	A,(HL)
	AND	A
	RET	Z
	CALL	CONOUT
	INC	HL
	JR	STROUT

; input:  HL
; output: 4 hex_char output console

HEXOUT4:
	LD	A,H
	CALL	HEXOUT2
	LD	A,L

; input:  A
; output: 2 hex_char output console
HEXOUT2:
	PUSH	AF
	RRA
	RRA
	RRA
	RRA
	CALL	HEXOUT1
	POP	AF

; input:  A
; output: 1 hex_char output console
HEXOUT1:
	AND	0FH
	ADD	A,'0'
	CP	'9'+1
	JP	C,CONOUT
	ADD	A,'A'-'9'-1
	JP	CONOUT

HEXIN:
	XOR	A
	CALL	HI0
	RLCA
	RLCA
	RLCA
	RLCA
HI0:
	PUSH	BC
	LD	C,A
	CALL	CONIN
;	CALL	UPPER
	CP	'0'
	JR	C,HIR
	CP	'9'+1
	JR	C,HI1
	CP	'A'
	JR	C,HIR
	CP	'F'+1
	JR	NC,HIR
	SUB	'A'-'9'-1
HI1:
	SUB	'0'
	OR	C
HIR:
	POP	BC
	RET
	
CRLF:
	LD	A,CR
	CALL	CONOUT
	LD	A,LF
	JP	CONOUT

CLR_CRT:
	PUSH	HL
	LD	HL, ESC_CRT_CLR
	CALL	STROUT
	POP	HL
	RET
	
ESC_CRT_CLR:
	db	01BH
	db	"[2"
	db	0

GETLIN:
	LD	HL,INBUF

GL0:	; input hl

	PUSH	BC
	push	hl
	LD	B,0

GL00:
	CALL	CONIN
	CP	CR
	JR	Z,GLE
	CP	LF
	JR	Z,GLE
	CP	BS
	JR	Z,GLB
	CP	DEL
	JR	Z,GLB
	CP	' '
	JR	C,GL00
	CP	80H
	JR	NC,GL00
	LD	C,A
	LD	A,B
	CP	BUFLEN-1
	JR	NC,GL00	; Too long
	INC	B
	LD	A,C
	CALL	CONOUT
	cp	'a'
	jr	c, GL1
	cp	'z'+1
	jr	nc, GL1
	and	0DFH	; make upper code
GL1:
	LD	(HL),A
	INC	HL
	JR	GL00
GLB:
	LD	A,B
	AND	A
	JR	Z,GL00
	DEC	B
	DEC	HL
	LD	A,08H
	CALL	CONOUT
	LD	A,' '
	CALL	CONOUT
	LD	A,08H
	CALL	CONOUT
	JR	GL00
GLE:
	CALL	CRLF
	LD	(HL),00H
	pop	hl
	POP	BC
	RET

SKIPSP:
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	SKIPSP

UPPER:
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	ADD	A,'A'-'a'
	RET

RDHEX:
	LD	C,0
	LD	DE,0
RH0:
	LD	A,(HL)
;	CALL	UPPER
	CP	'0'
	JR	C,RHE
	CP	'9'+1
	JR	C,RH1
	CP	'A'
	JR	C,RHE
	CP	'F'+1
	JR	NC,RHE
	SUB	'A'-'9'-1
RH1:
	SUB	'0'
	RLA
	RLA
	RLA
	RLA
	RLA
	RL	E
	RL	D
	RLA
	RL	E
	RL	D
	RLA
	RL	E
	RL	D
	RLA
	RL	E
	RL	D
	INC	HL
	INC	C
	JR	RH0
RHE:
	ld	a, c
	or	a
	jr	z, rhe1
	cp	5
	jr	nc, rhe1
	or	a	; clear carry
	ret
	
rhe1:
	scf	; set carry
	RET

;;;
;;; API Handler
;;:   C : API entory NO.
;;;

RST30H_IN:

	PUSH	HL
	PUSH	BC
	LD	HL,APITBL
	LD	B,0
	ADD	HL,BC
	ADD	HL,BC

	ld	bc, APITBL_E
	or	a
	push	hl
	sbc	hl, bc
	pop	hl
	jr	nc, no_api	; request No. is not exist

	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B

	POP	BC
	EX	(SP),HL		; Restore HL, jump address on stack top
no_operate:
	RET

no_api:
	pop	bc
	pop	hl
	ret

APITBL:
	DW	API00		; 00: CSTART
	DW	API01		; 01: WSTART
	DW	CONOUT		; 02: CONOUT
	DW	STROUT		; 03: STROUT
	DW	CONIN		; 04: CONIN
	DW	CONST		; 05: CONST
	DW	API06		; 06: PSPEC
	DW	HEXOUT4		; 07: CONOUT HEX4bytes: input HL
	DW	HEXOUT2		; 08: CONOUT HEX2bytes: input A
	DW	HEXOUT1		; 09: CONOUT HEX1byte : input A
	DW	CLR_CRT		; 10: Clear screen (ESC+[2)
	DW	GL0		; 11: GET a line (input HL : input buffer address)
	DW	SKIPSP		; 12: SKIP Spase
	DW	CRLF		; 13: CONOUT CRLF
	DW	UPPER		; 14: Lower to UPPER
	DW	RDHEX		; 15: get hex number from chr buffer
				;     input  HL : hex string buffer
				;     output DE : hex number
				;            CF=1 : error, C, A = hex counts(1-4)
	DW	DEC_STR		; 16: get decimal srtings
				; input hl : return storings buffer addr.
				;       de : 16bit binary
	DW	DIV16_8		; 17; division 16bit / 8bit
	DW	MUL_8		; 18: multiply 8bit * 8bit
	IF RAM12K
	DW	STOPW		; 19: stopwatch
	ELSE
	DW	no_operate	; 19: no operation : if RAM12K=0
	ENDIF
	dw	get_disasm_st	; 20: dis assemble string
				;     input: HL buffer. need 42bytes
				;     output : DE : next MC address
				;              A  : disassembled MC size
APITBL_E:

	;; CSTART
API00:
	JP	CSTART

	;; WSTART from API
API01:
	LD	SP,STACKM	; reset SP for monitor

; check stop by bp and trace operation

	ld	a, (tmpb_f)
	or	a
	jr	z, ws_chk1
	ld	hl, tmpb_op
	call	rstr_tpt
ws_chk1:
	ld	a, (tpt1_f)
	or	a
	jr	z, ws_chk2
	ld	hl, tpt1_op
	call	rstr_tpt

ws_chk2:
	ld	a, (tpt2_f)
	or	a
	jr	z, ws_chk3
	ld	hl, tpt2_op
	call	rstr_tpt
ws_chk3:
	ld	a, (bpt2_f)
	or	a
	jr	z, ws_chk4
	ld	hl, bpt2_op
	call	rstr_bpt
ws_chk4:
	ld	a, (bpt1_f)
	or	a
	jr	z, ws_chk5
	ld	hl, bpt1_op
	call	rstr_bpt
ws_chk5:
	JP	backTomon

	;; PSPEC
API06:
	XOR	A
	RET

;;;
;;; Break Point
;;; trace Point
;;; go, stop point
;;; operation handler
;;
RST38H_IN:
	PUSH	AF
	LD	A,R
	LD	(REGR),A
	LD	A,I
	LD	(REGI),A
	LD	(REGHL),HL
	LD	(REGDE),DE
	LD	(REGBC),BC
	POP	HL
	LD	(REGAF),HL
	EX	AF,AF'
	PUSH	AF
	EXX
	LD	(REGHLX),HL
	LD	(REGDEX),DE
	LD	(REGBCX),BC
	POP	HL
	LD	(REGAFX),HL
	LD	(REGIX),IX
	LD	(REGIY),IY
	POP	HL
	DEC	HL
	LD	(REGPC),HL
	LD	(REGSP),SP

; check bp and trace operation

	LD	SP,STACKM	; reset SP for monitor
	xor	a
	ld	d, a
	ld	e, a		;clear msg pointer


; check go, end operation
	ld	a, (tmpb_f)
	or	a
	jr	z, chk_bp
	ld	de, stpBrk_msg
	ld	hl, tmpb_op
	call	rstr_tpt

; check set break point

chk_bp:
	ld	a, (bpt2_f)
	or	a
	jr	z, bp_chk1
	ld	de, stpBrk_msg
	ld	hl, bpt2_op
	call	rstr_bpt

bp_chk1:
	ld	a, (bpt1_f)
	or	a
	jr	z, tp_chk1
	ld	de, stpBrk_msg
	ld	hl, bpt1_op
	call	rstr_bpt

; check trace operation
tp_chk1:
	ld	a, (tpt1_f)
	or	a
	jr	z, tp_chk2
	ld	de, trace_msg
	ld	hl, tpt1_op
	call	rstr_tpt

tp_chk2:
	ld	a, (tpt2_f)
	or	a
	jr	z, bp_chk_end

	ld	de, trace_msg
	ld	hl, tpt2_op
	call	rstr_tpt

bp_chk_end:
	ld	a, d
	or	e
	jr	nz, no_rst38_msg

	; set RST 38H message
	LD	de,RST38MSG

no_rst38_msg:
	ld	a, (de)		; get first char of message
	cp	'T'		; trace ?
	jr	z, chk_ntrace
	
	ex	de, hl
	CALL	STROUT

	;; R register adjustment

	CALL	RDUMP
	call	dis_call	; list disassemble
	jr	backTomon	; goto WBOOT

;
; check continue trace operation
;
chk_ntrace:
	ld	a, (TP_mode)
	cp	'F'		; chk
	jr	z, skp_rmsg

;no_trace:
	ex	de, hl
	CALL	STROUT

	;; R register adjustment

	CALL	RDUMP
	call	dis_call	; list disassemble

skp_rmsg:
	call	CONST
	jr	z, t_no_ky		; no key in
	call	CONIN
	cp	03h	; chk CTL+C
	jr	nz, t_no_ky

	; stop_trace
backTomon:
	xor	a
	ld	(fever_t), a	; clear forever flag
	ld	h, a
	ld	l, a
	ld	(TC_cnt), hl
	JP	WSTART
	
	; check trace forever
t_no_ky:
	ld	a, (fever_t)
	or	a
	jp	nz, repeat_trace

	ld	hl, (TC_cnt)
	dec	hl
	ld	(TC_cnt), hl
	ld	a, l
	or	h
	jr	nz, repeat_trace
	JP	WSTART

repeat_trace:
	ld	hl, (REGPC)
	ld	(tmpT), hl
	jp	t_op_chk

rstr_tpt:	; HL=buffer point
	push	hl
	ld	a, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)

	ld	(bc), a		; restor OP CODE
	pop	hl
	xor	a
	dec	hl
	ld	(hl), a		; clear trace flag
	ret

rstr_bpt:	; HL=buffer point
	ld	a, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)

	ld	(bc), a		; restor OP CODE
	ret

dis_call:
	ld	hl, (REGPC)
	ld	(dasm_adr), hl	; set disasm address
	call	dis_analysis
	call	mk_adr_str	; conout address and machine code
	ld	hl, adr_mc_buf
	call	STROUT		; conout disassemble strings
	ld	hl, (REGPC)
	ld	(dasm_adr), hl	; restrore disasm address
	ret

RST38MSG:
	DB	"RST 38H",CR,LF,00H
stpBrk_msg:	
	db	"Break!",CR,LF,00H
trace_msg:	
	db	"Trace!",CR,LF,00H

	IF RAM12K
STOPW:
	; (input) A = 0 : start timer, (output) none
	; (input) A = 1 : stop timer,  (output) BC : msec time, DE : Sec time
	; (input) A = 2 : lap timer,   (output) BC : msec time, DE : Sec time
	; (input) A = 3 : clear timer counter,  (output) none

	push	af
	push	hl
	cp	0
	jr	z, start_tim
	cp	1
	jr	z, stop_tim
	cp	2
	jr	z, lap_tim
	cp	3
	jr	z, clr_tim
	pop	hl
	pop	af
	ret

start_tim:
	ld	hl, TIM0_CTL0
	ld	a, 90h
	ld	(hl),a		; enable timer 0
	pop	hl
	pop	af
	ret
	
stop_tim:
	ld	hl, TIM0_CTL0
	ld	a, 10h
	ld	(hl), a		; disable timer 0

	; save timer counter

lap_tim:
	ld	a, (TIMER0_CNTL)
	ld	(c16b), a
	ld	a, (TIMER0_CNTH)
	ld	(c16b+1), a

; adjust 16bit counter

	ld	bc, TIMER0_INITC
	ld	hl, (c16b)
	ld	a, h
	or	l	; HL = 0?
	jr	nz, adj_tim1
	ld	(c16b), bc
	jr	rd_sec

adj_tim1:
	sbc	hl, bc
	ld	(c16b), hl

; read seconds counter

rd_sec:
	ld	a, (TIMER0_SCTL)
	ld	(secb), a
	ld	a, (TIMER0_SCTH)
	ld	(secb+1), a

	; convert msec from 16bit counter

	ld	hl,(c16b)
	call	chg_msec	; result BC
	ld	(msecb),bc	; save result
	ld	de,(secb)	; get sec counter
	pop	hl
	pop	af
	ret

clr_tim:
	xor	a
	ld	h, a
	ld	l, a
	ld	(msecb), hl
	ld	(secb), hl
	ld	(c16b), hl
	
	ld	(TIMER0_SCTL), a
	ld	(TIMER0_SCTH), a
	ld	a, 0e8h
	ld	(TIMER0_CNTL), a
	ld	a, 86H
	ld	(TIMER0_CNTH), a
	pop	hl
	pop	af
	ret

chg_msec:
	xor	a
	ld	b, a
	ld	c ,a		;cear BC
	ld	hl, (c16b)	; get 16bit counter
	ld	a, l
u_00:
	cp	31
	jr	c, u_1
	sub	31
u_0:
	ld	l, a
	inc	bc
	jr	u_00

u_1:
	ld	a, h
	or	a
	ret	z	; can't sub

	ld	a, l
	sub	31
	neg
	dec	h
	jr	u_0

	ENDIF

;
; make decimal string
;
; input HL : output string buffer
;       DE : 16bit binary
;
; output (HL) : decimal strings

DEC_STR:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	push	hl
	push	ix

	push	hl
	pop	ix		; ix: save buffer top address

	ex	de, hl		; hl: 16bit binary, de: buffer
	push	hl		; save 16bit binary
	ld	hl, 5
	add	hl, de		; hl = buffer + 5
	xor	a
	ld	(hl), A
	ex	de, hl		; de: buffer + 5, hl : buffer
	pop	hl		; hl : 16bit binary
	LD	BC, 1

LOOP_DEC:
	LD	A, 10
	CALL	DIV16_8
	OR	30H
	DEC	DE
	LD	(DE), A
	INC	C
	LD	A, H
	OR	L
	JR	NZ, LOOP_DEC

	LD	A, C
	CP	6
	JR	Z, END_DEC

	push	ix
	pop	hl		; hl : buffer top address
	EX	DE, HL
	LDIR

END_DEC:
	pop	ix
	pop	hl
	POP	DE
	POP	BC
	POP	AF
	RET


; DIV 16bit / 8 bit
; input
;	HL, A
; output
;	result = HL, mod = A

DIV16_8:
	PUSH	BC
	PUSH	DE

	LD	C, A
	LD	B, 15
	XOR	A
	ADD	HL, HL
	RLA
	SUB	C
	JR	C, D16_MINUS_BEFORE
	ADD	HL, HL
	INC	L

D16_PLUS:
	RLA
	SUB	C
	JR	C, D16_MINUS_AFTER

D16_PLUS_AFTER:
	ADD	HL, HL
	INC	L
	DJNZ	D16_PLUS
	JP	D16_END

D16_MINUS_BEFORE:
	ADD	HL, HL

D16_MINUS:
	RLA
	ADD	A, C
	JR	C, D16_PLUS_AFTER

D16_MINUS_AFTER:
	ADD	HL, HL
	DJNZ	D16_MINUS
	ADD	A,C
D16_END:
	POP	DE
	POP	BC
	RET

;
; input : HL / DE
; output : quotient HL
;	   remainder DE

DIV16:
	LD	(DIV16_NA), HL
	LD	(DIV16_NB), DE

	XOR	A
	LD	(DIV16_NC), A
	LD	(DIV16_NC+1), A
	LD	(DIV16_ND), A
	LD	(DIV16_ND+1), A
	LD	B, 16

DIV16_X2:
	LD	HL, DIV16_NC
	SLA	(HL)
	INC	HL
	RL	(HL)

	LD	HL, DIV16_NA
	SLA	(HL)
	INC	HL
	RL	(HL)
	LD	HL, DIV16_ND
	RL	(HL)
	INC	HL
	RL	(HL)

	LD	HL, (DIV16_NB)
	LD	E, L
	LD	D, H
	LD	HL, (DIV16_ND)
	XOR	A
	SBC	HL, DE
	JR	NC, DIV16_X0
	JR	DIV16_X1

DIV16_X0:
	LD	(DIV16_ND), HL

	LD	A, (DIV16_NC)
	OR	1
	LD	(DIV16_NC), A

DIV16_X1:
	DJNZ	DIV16_X2

	LD	HL,(DIV16_NC)
	LD	DE,(DIV16_ND)
	RET

; 8bit * 8bit : ans = 16bit
; input A , BC
; output HL

MUL_8:
	PUSH	AF
	PUSH	BC
	OR	A	; clear carry
	JR	ST_MUL8

LOOP_M8:
	SLA	C
	RL	B

ST_MUL8:
	RRA
	JR	NC, LOOP_M8
	ADD	HL, BC
	JR	NZ, LOOP_M8
	POP	BC
	POP	AF
	RET
;;;
;;; Messages
;;;

cmd_hlp:	db	"? :Command Help", CR, LF
		db	"D[<adr>] :Dump Memory", CR, LF
		db	"S[<adr>] :Set Memory", CR, LF
		db	"R[<reg>] :Set or Dump register", CR, LF
		db	"G[<adr>][,<stop adr>] :Go and Stop", CR, LF
		db	"L :Load HexFile", CR, LF
		db	"P[I|S] :Save HexFile(I:Intel,S:Motorola)", CR, LF
		db	"#L|<num> :Launch program", CR, LF
		db	"B[1|2[,<adr>]] :Set or List Break Point", CR, LF
		db	"BC[1|2] :Clear Break Point", CR, LF
		db	"T[<adr>][,<steps>|-1] : Trace command", CR, LF
		db	"TP[ON|OFF] :Trace Print Mode", CR, LF
		db	"TM[I|S] :Trace Option for CALL", CR, LF
		db	"DI[<adr>][,s<steps>|<adr>] :Disassemble", CR, LF, 00h

OPNMSG:
	DB	CR,LF
	db	"EMUZ80 MONITOR Rev.B02.3",CR,LF
	db	"This monitor is based on unimon.",CR,LF,00H

PROMPT:
	DB	"] ",00H

IHEMSG:
	DB	"Error ihex",CR,LF,00H
SHEMSG:
	DB	"Error srec",CR,LF,00H
ERRMSG:
	DB	"Error",CR,LF,00H

DSEP0:
	DB	" :",00H
DSEP1:
	DB	" : ",00H
IHEXER:
        DB	":00000001FF",CR,LF,00H
SRECER:
        DB	"S9030000FC",CR,LF,00H

	;; Register dump table
RDTAB:	DW	RDSA,   REGAF+1
	DB	1
	DW	RDSBC,  REGBC
	DB	2
	DW	RDSDE,  REGDE
	DB	2
	DW	RDSHL,  REGHL
	DB	2
	DW	RDSF,   REGAF
	DB	1

	DW	RDSIX,  REGIX
	DB	2
	DW	RDSIY,  REGIY
	DB	2

	DW	RDSAX,  REGAFX+1
	DB	1
	DW	RDSBCX, REGBCX
	DB	2
	DW	RDSDEX, REGDEX
	DB	2
	DW	RDSHLX, REGHLX
	DB	2
	DW	RDSFX,  REGAFX
	DB	1

	DW	RDSSP,  REGSP
	DB	2
	DW	RDSPC,  REGPC
	DB	2
	DW	RDSI,   REGI
	DB	1
	DW	RDSR,   REGR
	DB	1

	DW	0000H,  0000H
	DB	0

RDSA:	DB	"A =",00H
RDSBC:	DB	" BC =",00H
RDSDE:	DB	" DE =",00H
RDSHL:	DB	" HL =",00H

RDSF:	DB	" F =",00H

RDSF_H	equ	RDSF >> 8
RDSF_L	equ	RDSF & 0FFh


RDSIX:	DB	" IX=",00H
RDSIY:	DB	" IY=",00H
RDSAX:	DB	CR,LF,"A'=",00H
RDSBCX:	DB	" BC'=",00H
RDSDEX:	DB	" DE'=",00H
RDSHLX:	DB	" HL'=",00H

RDSFX:	DB	" F'=",00H

RDSFX_H	equ	RDSFX >> 8
RDSFX_L	equ	RDSFX & 0FFh

RDSSP:	DB	" SP=",00H
RDSPC:	DB	" PC=",00H
RDSI:	DB	" I=",00H
RDSR:	DB	" R=",00H

RNTAB:
	DB	'A',0FH		; "A?"
	DW	RNTABA,0
	DB	'B',0FH		; "B?"
	DW	RNTABB,0
	DB	'C',0FH		; "C?"
	DW	RNTABC,0
	DB	'D',0FH		; "D?"
	DW	RNTABD,0
	DB	'E',0FH		; "E?"
	DW	RNTABE,0
	DB	'F',0FH		; "F?"
	DW	RNTABF,0
	DB	'H',0FH		; "H?"
	DW	RNTABH,0
	DB	'I',0FH		; "I?"
	DW	RNTABI,0
	DB	'L',0FH		; "L?"
	DW	RNTABL,0
	DB	'P',0FH		; "P?"
	DW	RNTABP,0
	DB	'R',1		; "R"
	DW	REGR,RNR
	DB	'S',0FH		; "S?"
	DW	RNTABS,0

	DB	00H,0		; End mark

RNTABA:
	DB	00H,1		; "A"
	DW	REGAF+1,RNA
	DB	27H,1		; "A'"
;;	DB	'\'',1		; "A'"
	DW	REGAFX+1,RNAX

	DB	00H,0
	
RNTABB:
	DB	00H,1		; "B"
	DW	REGBC+1,RNB
	DB	27H,1		; "B'"
;;	DB	'\'',1		; "B'"
	DW	REGBCX+1,RNBX
	DB	'C',0FH		; "BC?"
	DW	RNTABBC,0

	DB	00H,0		; End mark

RNTABBC:
	DB	00H,2		; "BC"
	DW	REGBC,RNBC
	DB	27H,2		; "BC'"
;;	DB	'\'',2		; "BC'"
	DW	REGBCX,RNBCX

	DB	00H,0
	
RNTABC:
	DB	00H,1		; "C"
	DW	REGBC,RNC
	DB	27H,1		; "C'"
;;	DB	'\'',1		; "C'"
	DW	REGBCX,RNCX

	DB	00H,0
	
RNTABD:
	DB	00H,1		; "D"
	DW	REGDE+1,RND
	DB	27H,1		; "D'"
;;	DB	'\'',1		; "D'"
	DW	REGDEX+1,RNDX
	DB	'E',0FH		; "DE?"
	DW	RNTABDE,0

	DB	00H,0

RNTABDE:
	DB	00H,2		; "DE"
	DW	REGDE,RNDE
	DB	27H,2		; "DE'"
;;	DB	'\'',2		; "DE'"
	DW	REGDEX,RNDEX

	DB	00H,0
	
RNTABE:
	DB	00H,1		; "E"
	DW	REGDE,RNE
	DB	27H,1		; "E'"
;;	DB	'\'',1		; "E'"
	DW	REGDEX,RNEX

	DB	00H,0
	
RNTABF:
	DB	00H,1		; "F"
	DW	REGAF,RNF
	DB	27H,1		; "F'"
;;	DB	'\'',1		; "F'"
	DW	REGAFX,RNFX

	DB	00H,0
	
RNTABH:
	DB	00H,1		; "H"
	DW	REGHL+1,RNH
	DB	27H,1		; "H'"
;;	DB	'\'',1		; "H'"
	DW	REGHLX+1,RNHX
	DB	'L',0FH		; "HL?"
	DW	RNTABHL,0

	DB	00H,0

RNTABHL:
	DB	00H,2		; "HL"
	DW	REGHL,RNHL
	DB	27H,2		; "HL'"
;;	DB	'\'',2		; "HL'"
	DW	REGHLX,RNHLX

	DB	00H,0
	
RNTABL:
	DB	00H,1		; "L"
	DW	REGHL,RNL
	DB	27H,1		; "L'"
;;	DB	'\'',1		; "L'"
	DW	REGHLX,RNLX

	DB	00H,0
	
RNTABI:
	DB	00H,1		; "I"
	DW	REGI,RNI
	DB	'X',2		; "IX"
	DW	REGIX,RNIX
	DB	'Y',2		; "IY"
	DW	REGIY,RNIY
	
	DB	00H,0

RNTABP:
	DB	'C',2		; "PC"
	DW	REGPC,RNPC

	DB	00H,0

RNTABS:
	DB	'P',2		; "SP"
	DW	REGSP,RNSP

	DB	00H,0

RNA:	DB	"A",00H
RNBC:	DB	"BC",00H
RNB:	DB	"B",00H
RNC:	DB	"C",00H
RNDE:	DB	"DE",00H
RND:	DB	"D",00H
RNE:	DB	"E",00H
RNHL:	DB	"HL",00H
RNH:	DB	"H",00H
RNL:	DB	"L",00H
RNF:	DB	"F",00H
RNAX:	DB	"A'",00H
RNBCX:	DB	"BC'",00H
RNBX:	DB	"B'",00H
RNCX:	DB	"C'",00H
RNDEX:	DB	"DE'",00H
RNDX:	DB	"D'",00H
RNEX:	DB	"E'",00H
RNHLX:	DB	"HL'",00H
RNHX:	DB	"H'",00H
RNLX:	DB	"L'",00H
RNFX:	DB	"F'",00H
RNIX:	DB	"IX",00H
RNIY:	DB	"IY",00H
RNSP:	DB	"SP",00H
RNPC:	DB	"PC",00H
RNI:	DB	"I",00H
RNR:	DB	"R",00H

;;;
;;; Cold start for device dependent
;;;
INIT:
	RET

;;;
;;; Console drivers
;;;

CONIN:
	LD	A,(UARTCR)
	BIT	0,A
	JR	Z,CONIN
	LD	A,(UARTDR)
	RET

CONST:
	LD	A,(UARTCR)
	BIT	0,A
	RET

CONOUT:
	PUSH	AF
PCST1:	LD	A,(UARTCR)
	BIT	1,A
	JR	Z,PCST1
	POP	AF
	LD	(UARTDR),A
	RET

	db	BASIC_TOP - $ dup(0ffH)
;	ORG	BASIC_TOP

;;;
;;; RAM area
;;;

	;;
	;; Work Area
	;;
	
	ORG	WORK_B

	IF	BACKDOOR
stealRST08:	ds	2	; hacking RST 08H, set jump address
stealRST10:	ds	2	; hacking RST 10H, set jump address
stealRST18:	ds	2	; hacking RST 18H, set jump address
stealRST20:	ds	2	; hacking RST 20H, set jump address
stealRST28:	ds	2	; hacking RST 28H, set jump address
stealRST30:	ds	2	; hacking RST 30H, set jump address
stealRST38:	ds	2	; hacking RST 38H, set jump address
save_hl:	ds	2
	ENDIF
	
INBUF:	DS	BUFLEN	; Line input buffer
DSADDR:	DS	2	; Dump start address
DEADDR:	DS	2	; Dump end address
DSTATE:	DS	1	; Dump state
GADDR:	DS	2	; Go address
SADDR:	DS	2	; Set address
HEXMOD:	DS	1	; HEX file mode
RECTYP:	DS	1	; Record type
SIZE:	DS	1	; I/O Size 00H,'W','S'

REG_B:	
REGAF:	DS	2
REGBC:	DS	2
REGDE:	DS	2
REGHL:	DS	2
REGAFX:	DS	2		; Register AF'
REGBCX:	DS	2
REGDEX:	DS	2
REGHLX:	DS	2		; Register HL'
REGIX:	DS	2
REGIY:	DS	2
REGSP:	DS	2
REGPC:	DS	2
REGI:	DS	1
REGR:	DS	1
REG_E:


	IF RAM12K
; stop watch timer

c16b:	ds	2	; copy of TIMER0_CNT
secb:	ds	2	; copy of TIMER0_SCTT
msecb:	ds	2
	ENDIF
; BASIC Default start

basic_f:	ds	1	; BASIC default start flag *

; DIV 16 /16 buffer
DIV16_NA:	ds	2
DIV16_NB:	ds	2
DIV16_NC:	DS	2
DIV16_ND:	DS	2

; go command temp start address
goTmp:		ds	2

; trace mode switch
TP_mode:	ds	1	; N: display on, F: display off
TM_mode:	ds	1	; 'S':skip call, 'I':trace CALL IN
TC_cnt:		ds	2	; numbers of step
tmpT:		ds	2	; save temp buffer
fever_t:	ds	1	; flag trace forever

; break, trace point work area
dbg_wtop	equ	$
tpt1_f:		ds	1
tpt1_op:	ds	1	; save trace point1 opcode
tpt1_adr:	ds	2
tpt2_f:		ds	1
tpt2_op:	ds	1	; save trace point2 opcode (for branch)
tpt2_adr:	ds	2

; break point work area
bpt1_f:		ds	1
bpt1_op:	ds	1
bpt1_adr:	ds	2
bpt2_f:		ds	1
bpt2_op:	ds	1
bpt2_adr:	ds	2

tmpb_f:		ds	1
tmpb_op:	ds	1
tmpb_adr:	ds	2
dbg_wend	equ	$

F_bit:		ds	F_bitSize+1

;::::::::::::::::::::::::::
; DISASEM work area
;;;;;;;;;;;;;;;;;;;;;;;;;;;
dasm_ed:	ds	2
dasm_stpf:	ds	1
dasm_adr:	ds	2
reg_xy:		ds	2	; RNIX or RNIY
xy_srtp		ds	2	; strings pointer

mc_Size:	ds	1

;  DidAsm string buffer
; total 42 bytes
dasm_bs:
adr_mc_buf:	ds	19
dasm_OpcStr:	ds	8
dasm_OprStr:	ds	15
dasm_be:

	END
