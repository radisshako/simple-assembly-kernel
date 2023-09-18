.global main			#global scope main
.text				#program instructions

main:					#main program
    	addi $5, $0, 0x4d		#unmask irq2, ku=1, 0ku=1, ie=0, 0ie=1
	
	
	######## serial #############
    	la $1, serial_task_pcb		#Setup the pcb for serial task
    	la $2, parallel_task_pcb		
    	sw $2, pcb_link($1)		#Setup the link field as parallel_task
    	
    	la $2, wramp_games_task_pcb	#Setup a link to backwards pointer for the task
    	sw $2, pcb_back_link($1)
   	
    	la $2, serial_task_stack	#Setup the stack pointer
    	sw $2, pcb_sp($1)		
    	
   	la $2, serial_main		#Setup the $ear field
   	sw $2, pcb_ear($1)
    	
   	sw $5, pcb_cctrl($1)		#Setup the $cctrl field
	
   	addi $2, $0, 1
   	sw $2, pcb_time_slice($1)	#give serial task 1 interrupt per slice
   	la $2, close			#set our close label as $ra for serial_task
   	sw $2, pcb_ra($1)
   	
   	
   	
	######## Parallel #############
    	la $1, parallel_task_pcb		#Setup the pcb for parallel task
    	la $2, wramp_games_task_pcb		
    	sw $2, pcb_link($1)		#Setup the link field as wramp_games_task
   	
   	la $2, serial_task_pcb		#Setup a link to backwards pointer for the task
    	sw $2, pcb_back_link($1)
   	
   	
    	la $2, parallel_task_stack	#Setup the stack pointer
    	sw $2, pcb_sp($1)		
    	
   	la $2, parallel_main		#Setup the $ear field
   	sw $2, pcb_ear($1)
    	
   	sw $5, pcb_cctrl($1)		#Setup the $cctrl field
	
   	addi $2, $0, 1
   	sw $2, pcb_time_slice($1)	#give parallel task 1 interrupt per slice
   	la $2, close			#set our close label as $ra for parallel_task
   	sw $2, pcb_ra($1)
	
	################################
	
	
	
	
	
	##########Wramp Games################
	la $1, wramp_games_task_pcb		#Setup the pcb for wramp_games_task
    	la $2, serial_task_pcb		
    	sw $2, pcb_link($1)		#Setup the link field as serial_task
    	
    	la $2, parallel_task_pcb	#Setup a link to backwards pointer for the task
    	sw $2, pcb_back_link($1)
   	
   	
    	la $2, wramp_games_task_stack	#Setup the stack pointer
    	sw $2, pcb_sp($1)		
    	
   	la $2, breakout_main		#Setup the $ear field
   	sw $2, pcb_ear($1)
    	
   	sw $5, pcb_cctrl($1)		#Setup the $cctrl field
	
   	addi $2, $0, 4
   	sw $2, pcb_time_slice($1)	#give our wramp games 4 interrupts per slice
   	la $2, close			#set our close label as $ra for game
   	sw $2, pcb_ra($1)
	
	########################################
	
	
	##########Idle Screen Task################
	la $1, idle_screen_task_pcb		#Setup the pcb for idling screen task
    	la $2, idle_screen_task_pcb		
    	sw $2, pcb_link($1)		#Setup the link field as idle_screen task
   	
    	la $2, idle_screen_task_stack		#Setup the stack pointer
    	sw $2, pcb_sp($1)		
    	
   	la $2, idle_screen_task_loop		#Setup the $ear field
   	sw $2, pcb_ear($1)
    	
   	sw $5, pcb_cctrl($1)		#Setup the $cctrl field
	
   	addi $2, $0, 1
   	sw $2, pcb_time_slice($1)	#give idle_screen task 1 interrupts per slice
   	
	########################################
	
	

    	la $1, serial_task_pcb		#Setup our serial task as the current task
    	sw $1, current_task($0)
	
    	
    	movsg $2, $evec		#backup the older evec address to old_vector variable
   	sw $2, old_vector($0)
    	la $2, handler			#setup handler as the new evec
    	movgs $evec, $2
    
    
    	sw $0, 0x72003($0)		#make sure we acknowledge any timer interrupts
	addi $4, $0, 24		#add 2400 / 100 = 24 to $4
	sw $4, 0x72001($0)		#save this as the load value
	addi $4, $0, 0x3		#store 0x3 in $4
	sw $4, 0x72000($0)		#turn on autorestart and timer enable with '11'
	
	jal load_context		#jump and link to load_context


    	
handler:
    	movsg $13, $estat		#load in the estat register
    	andi $13, $13, 0xffb0		#if its 0 only timer was responsible
    	beqz $13, handle_timer		#branch to handle_timer

    	lw $13, old_vector($0)		#otherwise load in the old exception handler for other excpetions
    	jr $13				#jump to $13

handle_timer:
   	sw $0, 0x72003($0)		#acknowledge the interrupt by adding 0
    	lw $13, counter($0)		#load in the counter variable
    	addi $13, $13, 1		#add one to it
    	sw $13, counter($0)		#store it back in the variable
    
    	lw $13, time_slice($0)		#load in the timeslice variable
    	subi $13, $13, 1		#subtract 1 from it
    	beqz $13, save_context		#if its zero beanch to save context
    	sw $13, time_slice($0)		#store it back at time_slice
	rfe				


    
dispatcher:
save_context:
    	lw $13, current_task($0)		#get the base address of current pcb

	sw $1, pcb_reg1($13)			#save the registers to the pcb 
	sw $2, pcb_reg2($13)
    	sw $3, pcb_reg3($13)
    	sw $4, pcb_reg4($13)
    	sw $5, pcb_reg5($13)
    	sw $6, pcb_reg6($13)
    	sw $7, pcb_reg7($13)
    	sw $8, pcb_reg8($13)
    	sw $9, pcb_reg9($13)
    	sw $10, pcb_reg10($13)
    	sw $11, pcb_reg11($13)
    	sw $12, pcb_reg12($13)
    	sw $sp, pcb_sp($13)
    	sw $ra, pcb_ra($13)

    	movsg $1, $ers				#get the old $13 value to $1
    	sw $1, pcb_reg13($13)			#save it to pcb

    	movsg $1, $ear				#save $ear to pcb
   	sw $1, pcb_ear($13)		
	
   	movsg $1, $cctrl			#save $cctrl in pcb
    	sw $1, pcb_cctrl($13)

schedule:
	lw $13, current_task($0)		#Get current task
	lw $13, pcb_link($13)			#get next task from pcb_link field
    	sw $13, current_task($0)		#set next task as teh current task
    	lw $13, pcb_time_slice($13)		#store time slice as new time slice
    	sw $13, time_slice($0)			

load_context:
    	lw $13, current_task($0)		#get pcb of current task
    	lw $1, pcb_reg13($13)			#get the pcb value $13 back to ers
    	movgs $ers, $1			

    	lw $1, pcb_ear($13)			#restore ear
    	movgs $ear, $1

    	lw $1, pcb_cctrl($13)			#restore cctrl
    	movgs $cctrl, $1

    	lw $1, pcb_reg1($13)			#restore all other registers
    	lw $2, pcb_reg2($13)
    	lw $3, pcb_reg3($13)
    	lw $4, pcb_reg4($13)
    	lw $5, pcb_reg5($13)
    	lw $6, pcb_reg6($13)
    	lw $7, pcb_reg7($13)
    	lw $8, pcb_reg8($13)
    	lw $9, pcb_reg9($13)
    	lw $10, pcb_reg10($13)
    	lw $11, pcb_reg11($13)
    	lw $12, pcb_reg12($13)
    	lw $sp, pcb_sp($13)
    	lw $ra, pcb_ra($13)

    	rfe					#return to the new task
close:
    	lw $1, current_task($0)		#load in current task
    	lw $2, pcb_link($1)			#load in pcb_link
    	lw $4, pcb_back_link($1)		#load in pcb_back_link
    	seq $7, $1, $2				#if the same set $7 to 1
    	bnez $7, idle_screen_task_loading	#if true branch to idle_screen_task_loading 
   	sw $2, pcb_link($4)			#take out current task
   	sw $4, pcb_back_link($2)

wait:					#wait here untill for time to run down

	j wait


idle_screen_task_loading:
    	la $2, idle_screen_task_pcb		#Make idle screen task the current one
    	sw $2, current_task($0)
   	j load_context				#jump to load_context

idle_screen_task_loop:
    	addi $2, $0, 0		
    	sw $2, 0x73004($0)		#turn off hex on ssd
   	addi $2, $0, 64
    	sw $2, 0x73008($0)		#display idle sign to lower left and lower right ssd
    	sw $2, 0x73009($0)
    	
    	j idle_screen_task_loop	#loop back up

.equ pcb_link, 0
.equ pcb_reg1, 1
.equ pcb_reg2, 2
.equ pcb_reg3, 3
.equ pcb_reg4, 4
.equ pcb_reg5, 5
.equ pcb_reg6, 6
.equ pcb_reg7, 7
.equ pcb_reg8, 8
.equ pcb_reg9, 9
.equ pcb_reg10, 10
.equ pcb_reg11, 11
.equ pcb_reg12, 12
.equ pcb_reg13, 13
.equ pcb_sp, 14
.equ pcb_ra, 15
.equ pcb_ear, 16
.equ pcb_cctrl, 17
.equ pcb_time_slice, 18
.equ pcb_back_link, 19

.data
old_vector:
    	.word 0

time_slice:
    	.word 2

.bss
serial_task_pcb:
    	.space 20

parallel_task_pcb:
    	.space 20
    	
wramp_games_task_pcb:
	.space 20
	
idle_screen_task_pcb:
    	.space 20
    
    	.space 200
serial_task_stack:

    	.space 200
parallel_task_stack:

	.space 200
wramp_games_task_stack:

	.space 200
idle_screen_task_stack:
    
current_task:
    	.word
