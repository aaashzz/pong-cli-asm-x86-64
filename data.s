.globl grid, ballx, ballxvel, bally, ballyvel, ansiforsc, ansiforsclen, newline, newlinelen, delay_sec, delay_nsec, paddelx, paddely, paddelmov, paddelinput, ballposition, teststring, tslen, termios_original, termios_raw, fdset, tv_Set, tv_usec, tv_sec
.type grid @object
.type ballx @object
.type ballxvel @object
.type bally @object
.type ballyvel @object  
.type ansiforsc @object 
.type ansiforsclen @object 
.section .bss
#forinput
termios_original:
    .zero 60

termios_raw:
    .zero 60

fdset:
    .zero 128

tv_sec:
    .quad 0

tv_usec:
    .quad 0
#

grid:
	 .zero 200
paddelinput:
	.zero 2

.section .data

ballx:
	.quad 1
ballxvel:
	.quad 1
bally:
	.quad 1
ballyvel:
	.quad 1
ansiforsc:
	.ascii "\033[2J\033[H"
ansiforsclen:
	.quad . - ansiforsc
newline:
	.ascii "\n"
newlinelen:
	.quad . - newline
delay_sec:  
	.quad 0 
delay_nsec: 
	.quad 200000000
paddelx:
	.quad 9
paddely:
	.quad 9
paddelmov:
	.quad 1
ballposition:
	.quad 0
teststring:
	.ascii "wasup: "
tslen:
	.quad . - teststring
