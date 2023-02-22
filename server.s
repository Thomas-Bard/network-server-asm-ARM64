.equ SYS_WRITE, 64
.equ SYS_READ, 63
.equ SYS_SOCKET, 198
.equ SYS_EXIT, 93
.equ SYS_BIND, 200
.equ SYS_LISTEN, 201
.equ SYS_ACCEPT, 242    // I use accept4 bc for some reason accept triggers a SIGSYS

.equ AF_INET, 2
.equ SOCK_STREAM, 1

.equ STDIN_FILENO, 0
.equ STDOUT_FILENO, 1

.equ SOCKADDR_SIZE, 16

.global _start

.section .text
_start:

mov x8, SYS_SOCKET // SYS_SOCKET
mov x0, AF_INET //AF_INET
mov x1, SOCK_STREAM //SOCK_STREAM
mov x2, 0
svc 0

cmp x0, 0
blt error

ldr w1, =server_socket
strb w0, [x1]

mov x8, SYS_BIND
// fd already in x0
ldr x1, =inaddr
mov x2, SOCKADDR_SIZE
svc 0

cmp x0, 0
blt error

mov x8, SYS_LISTEN

ldr x1, =server_socket
ldrb w0, [x1]

mov x1, 5 //Valeur random pour backlog, ça devrait etre ni trop ni pas assez

svc 0

cmp x0, 0
blt error

mov x8, SYS_ACCEPT

ldr x1, =server_socket
ldrb w0, [x1]

mov x1, 0
mov x2, 0
mov x3, 0
svc 0

cmp x0, 0
blt error

mov x8, SYS_READ
// Socket fd already in x0
ldr x1, =req_data
ldr x2, =1024
svc 0

cmp x0, 0
blt error

mov x8, SYS_WRITE
mov x2, x0
mov x0, STDOUT_FILENO
ldr x1, =req_data
svc 0

mov x8, 93
mov x0, 0
svc 0

error:
mov x8, 64
mov x0, 1
ldr x1, =erreur
mov x2, 14
svc 0

mov x8, #93
mov x0, #0
svc 0

verify_get_extract_url:
// x0 : pointer to buffer
// -> x0 1 if correct -1 else


.section .data
erreur:
.ascii "Unknown error\n"

file_buffer:
.rept 2048
.byte 0
.endr

req_data:
.rept 1024
.byte 0
.endr

server_socket: 
.byte 0
inaddr:
.2byte 2         // AF_INET
.2byte 0x901f   //8080 in host byte order
.4byte 0
.8byte 0

HTTP_HEADER:
.ascii "HTTP/1.1 200 OK\r\r\n"
HTTP_HEADER_NF:
.ascii "HTTP/1.1 404 NOT FOUND\r\r\n"
HTTP_REQUEST_FORMAT:
.ascii "GET"
URL:
.rept 255
.byte 0
.endr
