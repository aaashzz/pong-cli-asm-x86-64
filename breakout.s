.globl _start
.type grid_func @function
.type gameover @function
.type gridfuncend @function
.type frame @function

.section .text
clearscreen:	#clear the screen after every frame
	movq $1, %rax
	movq $1, %rdi
	leaq ansiforsc, %rsi
	movq ansiforsclen, %rdx
	syscall
	xor %rcx, %rcx
	ret

grid_func:			#creates a 1d grid inside the memory
	cmpq $200, %rcx
	je ballnpadingrid
	leaq grid, %rsi
	movb $' ', (%rsi,%rcx)
	incq %rcx
	jmp grid_func
	
ballnpadingrid:			#adding ball and paddle into the grid

	movq bally, %rax
	movq $20, %rbx
	mulq %rbx
	addq ballx, %rax
	movq %rax, ballposition
	movb $'o', (%rsi, %rax)
	
	movq paddely, %rax
	movq $20, %rbx
	mulq %rbx
	addq paddelx, %rax
	movb $'_', (%rsi, %rax)
	subq $1, %rax
	movb $'_', (%rsi, %rax)
	addq $2, %rax
	movb $'_', (%rsi, %rax)
	
	

	xor %rcx, %rcx
	ret
frame:				#rendering the 1d grid in memory as 2d grid frame
	leaq grid, %rsi
	addq %rcx, %rsi
		
	movq %rcx, %r14	#moving the %rcx to %r14 because syscall clobbers the %rcx
	movq $1, %rax
	movq $1, %rdi
	movq $1, %rdx
	syscall
	movq %r14, %rcx #restoring the %rcx

	incq %rcx
	
	movq %rcx, %rax
	xor  %rdx, %rdx
	movq $20, %rbx
	divq %rbx
	cmpq $0, %rdx
	je newlinefunc	
	jne frame
	
newlinefunc: 		#prints \n if %rdx = 0
	movq %rcx, %r14 #moving the %rcx to %r14 because syscall clobbers the %rcx
	movq $1, %rax
	movq $1, %rdi
	leaq newline, %rsi
	movq newlinelen, %rdx
	syscall
	movq %r14, %rcx #restoring the %rcx
	cmpq $200, %rcx
	jne frame
	xor %rcx, %rcx
	xor %r14, %r14
	ret
	
defballmov:		#default ball movement inside the grid
	movq ballxvel, %rbx
	addq %rbx, ballx
	movq ballyvel, %rbx
	addq %rbx, bally	
	ret

bouncelogic:
	cmpq $9, bally
	je check_ballonpad
	cmpq $0, bally
	je negvely
	ret
bouncelogic2:
	cmpq $19, ballx
	je negvelx
	cmpq $0, ballx
	je negvelx
	ret

check_ballonpad:
	movq paddelx, %rax
	cmpq %rax, ballx
	je negvely
	movq paddelx , %rax
	addq $1, %rax
	cmpq %rax, ballx
	je negvely
	movq paddelx , %rax
	subq $1, %rax
	cmpq %rax, ballx
	je negvely
	jmp gameover
	
	
	
	

negvely:	#change the sign of ballyvel
	negq ballyvel	
	ret
negvelx:	#change the sign of ballyxvel
	negq ballxvel
	ret
delay:		#delay after every frame 
	movq $35, %rax
	leaq delay_sec, %rdi
	movq $0, %rsi
	syscall
	ret 
#
#paddelmovement:
#	movq $1, %rax
#	movq $1, %rdi
#	leaq teststring, %rsi
#	movq tslen, %rdx
#	syscall
#		
#	movq $0, %rax
#	movq $0, %rdi
#	leaq paddelinput, %rsi
#	movq $2, %rdx
#	syscall
#	xor %rcx, %rcx
#
#	cmpb $'z', paddelinput	
#	je paddel_minus 
#	cmpb $'m', paddelinput
#	je paddel_plus
#	ret
#paddel_minus:
#	cmpq $1, paddelx
#	je p_min_max  
#	subq $1, paddelx	
#	ret
#paddel_plus:
#	cmpq $18, paddelx
#	je p_min_max
#	addq $1, paddelx
#	ret
#p_min_max:
#	ret
paddelmovement: #func by chatgpt

    # -------------------------
    # Clear fdset
    # -------------------------
    leaq fdset, %rdi
    movq $0, (%rdi)
    movq $0, 8(%rdi)
    movq $0, 16(%rdi)
    movq $0, 24(%rdi)

    # stdin = fd 0
    # Bit 0 represents fd 0
    movq $1, (%rdi)


    # -------------------------
    # timeval = 0
    # -------------------------
    movq $0, tv_sec
    movq $0, tv_usec


    # -------------------------
    # select()
    # -------------------------
    movq $23, %rax             # sys_select
    movq $1, %rdi              # nfds = 1
    leaq fdset, %rsi          # readfds
    movq $0, %rdx              # writefds = NULL
    movq $0, %r10              # exceptfds = NULL
    leaq tv_sec, %r8           # timeout
    syscall

    # -------------------------
    # Did select find input?
    # -------------------------
    cmpq $0, %rax
    je no_input


    # -------------------------
    # Input exists → read it
    # -------------------------
    movq $0, %rax              # sys_read
    movq $0, %rdi              # stdin
    leaq paddelinput, %rsi
    movq $1, %rdx
    syscall


    # -------------------------
    # Existing paddle controls
    # -------------------------
    cmpb $'z', paddelinput
    je paddel_minus

    cmpb $'m', paddelinput
    je paddel_plus

no_input:
    ret


paddel_minus:
    cmpq $1, paddelx
    je p_min_max
    subq $1, paddelx
    ret


paddel_plus:
    cmpq $18, paddelx
    je p_min_max
    addq $1, paddelx
    ret


p_min_max:
    ret
	
terminal_init: #func by chatgpt
    # Get current terminal settings
    movq $16, %rax              # ioctl
    movq $0, %rdi               # stdin
    movq $0x5401, %rsi         # TCGETS
    leaq termios_original, %rdx
    syscall

    # Copy original settings
    leaq termios_original, %rsi
    leaq termios_raw, %rdi
    movq $60, %rcx
    rep movsb

    # Disable ICANON and ECHO
    # c_lflag is at offset 12
    movl termios_raw+12, %eax
    andl $~0x0000000A, %eax    # clear ICANON (0x2) + ECHO (0x8)
    movl %eax, termios_raw+12

    # Apply modified settings
    movq $16, %rax              # ioctl
    movq $0, %rdi               # stdin
    movq $0x5402, %rsi         # TCSETS
    leaq termios_raw, %rdx
    syscall

    ret
		
gameover:		#exits the game if ball hits the bottem wall
	movq $60, %rax
	movq $0, %rdi
	syscall

gameloop:		#executes every funtions in order
	call clearscreen
	call grid_func
	call frame
	call delay
	call bouncelogic
	call bouncelogic2
	call paddelmovement
	call defballmov
	jmp gameloop	
	#jmp gameover
	
_start:
	call terminal_init
	movq $0, %rcx
	jmp gameloop
