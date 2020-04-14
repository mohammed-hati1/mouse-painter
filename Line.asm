

bits 16
org 0x7C00
cli 
mov ah,0x02
mov al,8
mov dl,0x80
mov dh,0
mov ch,0
mov cl,2
mov bx ,DDD
int 0x13
jmp DDD

times (510 - ($ - $$)) db 0
db 0x55, 0xAA

DDD:

cli
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov edi, 0xB8000;
	
	;WRITE YOUR CODE here
	
                mov ax,0x13     ; graphical mode 320x200 pixles 256 colors
                int 0x10	       ; set video mode
                   
                
	xor eax, eax       ; aux input enable command
                call pollWrite
                mov al, 0xa8        
                out  0x64, al
	
                call pollWrite 
	mov al, 0xf6           ; set defaults: 100 packets/sec, 4 counts/mm, disable streaming
                call writeMouse

                call pollWrite
	mov al, 0xf4           ; enable streaming
                call writeMouse
	   
                ;xor ecx,ecx
                ;cmp ecx,320
                ;jge screenRowsDone
                
                ;xor edx,edx
                ;cmp edx,200
                ;jge screenColomnDone
                
                ;inc 
    screenColomnDone:
                
    screenRowsDone:
   
    ;modified segment*************************************************************************
      X: dw 0x00
    Y: dw 0x00
           mov di,word[X]
           mov si,word[Y]
               A:
                cmp di,319
                jg incy
                mov ah,0x0C	;change color for a single pixle
	mov al,0x0f	; retain color
	mov cx,di 	; x
	mov dx,si ; y
	int 0x10
                inc di
                jmp A
                incy:
                cmp si,199
                jg B
                inc si
                mov di,word[X]
                jmp A
      B:          
                xor eax, eax
                xor ecx, ecx
             ;***************************************************************   	   
    check: 
    call Drawline
                call pollRead
                in al, 0x64
                and al, 0x20
                jz check
	
cmp byte[rightButtonMouse],0x02	
je pressed
    cmp byte[leftButtonMouse],0x01
	je pressed

	mov ah,0x0C	;change color for a single pixle
	mov al,[lastPixelColor]	; retain color
	mov cx,[xMouse] 	; x
	mov dx,[yMouse] 	; y
	int 0x10
   
    pressed:
	call readMouse
                mov byte [statusMouse], al
                mov bl,al
	and al,0x01
	mov [leftButtonMouse],al
                
                and bl,0x02
                mov [rightButtonMouse],bl
	  

	xor ax,ax
	xor dx,dx
                ;call pollRead
	call readMouse
	movsx dx,al
                add [xMouse], dx
	  
	  
	cmp word[xMouse],0  ;x boundaries
	jg rightBound
	mov word[xMouse],0
	
    rightBound:
	cmp word[xMouse],319 ;x boundaries
	jl doneDeltaX
	mov word[xMouse],319

    doneDeltaX:
	  
	xor ax,ax 
	xor dx,dx
                call readMouse
	movsx dx,al
                sub [yMouse], dx  
     
	cmp word [yMouse],199  ;y boundaries
	jl up
	mov word[yMouse],199
       
    up:
	cmp word [yMouse],0   ; boundaries
	jg doneDeltaY
	mov word [yMouse],0
	
    doneDeltaY:
	call readMouse
                mov byte[zMouse], al

                
                mov ah,0x0d
                mov cx,[xMouse]         ; x
                mov dx,[yMouse]         ; y
                int 0x10
               mov [lastPixelColor],al
               
                
         ;modified segment******************************************************************
                   cmp bl,0x02
                je right
   
                mov al,[leftButtonColor]
	mov  ah,0xC 	; change pixle color
	mov  cx, [xMouse]	; x
	mov  dx, [yMouse]	; y
	int  0x10 	; call BIOS service
                jmp check
          right:
            mov al,[rightButtonColor]
	mov  ah,0xC 	; change pixle color
	mov  cx, [xMouse]	; x
	mov  dx, [yMouse]	; y
	int  0x10 	; call BIOS service
         
	jmp check
;************************************************************************************	  
        Drawline:
                 mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
	mov  cx, [xdot1]	; x
	mov  dx, [ydot1]	; y
	int  0x10 	; call BIOS service
               
                mov di,[xdot2] 
                mov si ,[ydot2]
                cmp dx,si
                je CompareX
                cmp cx ,di
                je CompareY
                   cmp di ,cx
                   jg rightSide
                      leftSide:
                  cmp si,dx
                  jl LeftupCorner
                  LeftdownCorner:
                  cmp cx,di
                    je finish
                    cmp dx,si
                    je finish
                    dec cx
                    inc dx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp LeftdownCorner
                  LeftupCorner:
                  cmp cx,di
                    je finish
                    cmp dx,si
                    je finish
                    dec cx
                    dec dx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp LeftupCorner
                
                    rightSide:
                    cmp si,dx
                    jl RightupCorner
                  RightdownCorner:
                    cmp cx,di
                    je finish
                    cmp dx,si
                    je finish
                    inc cx
                    inc dx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp RightdownCorner
                    RightupCorner:
                    cmp cx,di
                    je finish
                    cmp dx,si
                    je finish
                    inc cx
                    dec dx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp RightupCorner
                
                CompareY:
                cmp si,dx
                jl drawup
                drawdown:
                cmp dx,si
                je finish
                inc dx
                mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp drawdown
                
                drawup:
                cmp dx,si
                je finish
                dec dx
                mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp drawup
                
                CompareX:
                cmp di,cx
                jg drawright
                 drawleft:
                cmp di,cx
                je finish
                dec cx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                jmp drawleft    
                drawright:
                cmp di,cx
                je finish
                inc cx
                   mov al,[firstDotColor]
	mov  ah,0xC 	; change pixle color
                int  0x10 	; call BIOS service
                    jmp drawright
                   
                     finish:
                     ret
                                     
pollWrite:
    nextPollWrite:  
                in al, 0x64
                and al, 0x02
	jnz nextPollWrite
	ret
	  
pollRead:
    nextPollRead:  
                in al, 0x64
                and al, 0x01
	jz nextPollRead
	ret

writeMouse:
                mov bl, al
                mov al, 0xd4
                out 0x64, al
                call pollWrite
                mov al, bl
                out 0x60, al
                call pollRead
                call readMouse
                ret	  
                	
readMouse:
                in al, 0x60
                ret
	
statusMouse: dw 0
leftButtonMouse: db 0
rightButtonMouse: db 0	  	
xMouse: dw 0      
yMouse: dw 0
zMouse: dw 0
xdot1:dw 190
ydot1: dw  50
xdot2: dw  100
ydot2: dw  198
lastPixelColor: db 0
leftButtonColor: db 0x00
rightButtonColor: db 0x0f
firstDotColor: db 0x00	

times (0x400000 - 512) db 0

db   0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db  0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db  0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db  0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db  0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db  0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00





