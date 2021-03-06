bits 16
org 0x7C00
                ; no click in color selection area when we are in drawMode
	cli
                cld
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov edi, 0xB8000;



           mov ax,0x13     ; graphical mode 320x200 pixles 256 colors
           int 0x10	       ; set video mode
                
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
                
                mov dl,0
again1:
                mov ax,p1
                mov es,ax
                xor bx,bx
                
                mov al,12
                mov ch,0
                mov cl,2
                mov dh,0
                inc dl
                mov ah,0x2
                int 0x13
                jc again1
                 
black: db 0
blue: db 1
green: db 2
cyan: db 3
red: db 4
magenta: db 5
brown: db 6
lightGray: db 7
gray: db 8
lightBlue: db 9
lightGreen: db 10
lightCyan: db 11
lightRed: db 12
lightMagenta: db 13
yellow: db 14
white: db 15
	
                                                
                mov al,0
                jmp p1:00
                hlt
statusMouse: dw 0
leftButtonMouse: db 0,0
rightButtonMouse: db 0,0	  	
xMouse: dw 0      
yMouse: dw 0
zMouse: dw 0
lastPixelColor: db 0x0f
currentColor: db 0x00
temporaryColor: db 0
initialCurrentColor: db 0x00
currentAuxilaryColor: db 0x03
rightButtonColor: db 0

currentShape: dw 0 ; 0 pen, 1 line, 2 rectangle, 3 circle
shapesColor: db 1
drawAvailability: db 1
	
blackX: 
orangeX: dw 303
redX:
greenX: dw 287
blueX: 
cianX: dw 271
blackY: 
redY:
blueY:
currentColorY:
penY:
lineY:
currentShapeY: dw 3
orangeY:
greenY:
cianY:
currentAuxilaryColorY: 
rectangleY:
circleY:dw 18
currentColorX: 
currentAuxilaryColorX: dw 250
lineX:
rectangleX: dw 229
circleX:
penX: dw 213
currentShapeX: dw 193


xdot: dw 0
ydot: dw 0

xRect: dw 0,0,0
yRect: dw 0,0,0
drawMode: db 0

colorSquareLength: dw 14
leftmostPixel: dw 190
lowestPixel: dw 40

drawHorizontalRectangleCounter: dw 0
times 510 - ($ - $$) db 0
dw 0xAA55
bits 16
p1:            cli        
                call initializeMouse
                call initializeColorSelectionArea    
                mov byte[drawAvailability],0
    check:
                call pollRead
                in al, 0x64
                and al, 0x20
                jz check
                
                cmp byte[drawMode],0
                jnz notPen
                call isMouseInsideColorSelectionArea
                cmp al,0
                je normalMouseOperation
                call restoreLastPixelColor
                cmp byte[leftButtonMouse],0x00
                jnz leftButtonPressedInsideColorSelectionArea
                jmp leftButtonPressed
    leftButtonPressedInsideColorSelectionArea:
                mov cx,[blackX]
                mov bx,[colorSquareLength]
                mov dx,[blackY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz cianSquareTest
                mov word[currentColor],0x00
                call drawCurrentColorSquare
                jmp leftButtonPressed
                
    cianSquareTest:
                mov cx,[cianX]
                mov bx,[colorSquareLength]
                mov dx,[cianY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz redSquareTest
                mov word[currentColor],0x03
                call drawCurrentColorSquare
                jmp leftButtonPressed
                
    redSquareTest:
                mov cx,[redX]
                mov bx,[colorSquareLength]
                mov dx,[redY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz blueSquareTest
                mov word[currentColor],0x04
                call drawCurrentColorSquare
                jmp leftButtonPressed
                
    blueSquareTest:
                mov cx,[blueX]
                mov bx,[colorSquareLength]
                mov dx,[blueY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz orangeSquareTest
                mov word[currentColor],0x01
                call drawCurrentColorSquare
                jmp leftButtonPressed
               
    orangeSquareTest:
                mov cx,[orangeX]
                mov bx,[colorSquareLength]
                mov dx,[orangeY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz greenSquareTest
                mov word[currentColor],0x06
                call drawCurrentColorSquare
                jmp leftButtonPressed
                 
    greenSquareTest:
                mov cx,[greenX]
                mov bx,[colorSquareLength]
                mov dx,[greenY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz lineTest
                mov word[currentColor],0x0A
                call drawCurrentColorSquare
                jmp leftButtonPressed
                
    lineTest:
                mov cx,[lineX]
                mov bx,[colorSquareLength]
                mov dx,[lineY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz circleTest
                mov word[currentShape],0x01
                call drawCurrentShapeSquare
                jmp leftButtonPressed
                
    circleTest:
                mov cx,[circleX]
                mov bx,[colorSquareLength]
                mov dx,[circleY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz rectangleTest
                mov word[currentShape],0x03
                call drawCurrentShapeSquare
                jmp leftButtonPressed
                
    rectangleTest:
                mov cx,[rectangleX]
                mov bx,[colorSquareLength]
                mov dx,[rectangleY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz penTest
                mov word[currentShape],0x02
                call drawCurrentShapeSquare
                jmp leftButtonPressed
                
    penTest:
                mov cx,[penX]
                mov bx,[colorSquareLength]
                mov dx,[penY]
                mov ax,bx
                call isMouseInsideHorizontalRectangle
                cmp al,0
                jz leftButtonPressed
                mov word[currentShape],0x00
                call drawCurrentShapeSquare
                jmp leftButtonPressed
                  
    normalMouseOperation:
                cmp byte[currentShape],0
                jnz notPen
                
                cmp byte[leftButtonMouse],0x00
	jne leftButtonPressed
                
                call restoreLastPixelColor
    leftButtonPressed:
                call update
                call storeLastPixelColor
                call showPointer
                jmp check
               
    notPen:            ; you are outside color selection area with a shape other than pen
                cmp byte[leftButtonMouse],0x00
	jne leftButtonPressedN
                cmp byte[drawMode],0
                jz notInDrawMode
                
                call drawStoredCircle
                call update
                call isMouseInsideColorSelectionArea
                cmp al,0
                jne finishDrawingInsideColorSelectionArea
                mov al,[currentColor]
                mov [lastPixelColor],al
                jmp finishDrawing
    finishDrawingInsideColorSelectionArea:
                call storeLastPixelColor
    finishDrawing:
                call drawCircleAndStore
                jmp doneOtherShapes
    notInDrawMode:
                call restoreLastPixelColor
                call update
                call storeLastPixelColor
                call showPointer
                jmp check
    leftButtonPressedN:
                cmp byte[drawMode],0
                jz notInDrawModeAndPressed

                call drawStoredCircle
                call update
                call drawCircleAndStore
                jmp check
    notInDrawModeAndPressed:
                ;call restoreLastPixelColor
                call storeInitialCircleValues
                call update
                call drawCircleAndStore
    doneOtherShapes:
                xor byte[drawMode],1
                
                jmp check
                hlt
 
update:
                call setMouseStatus
                call setXMouse
                call setYMouse
                ;call setZMouse
                ret

drawCircleAndStore:
                call calRadius	
                call circleAndStore
                ret
                
storeInitialCircleValues:
                mov ax , [xMouse]
                mov [xc] , ax
                mov ax , [yMouse]
                mov [yc], ax
                ret
                  
drawStoredCircle:
                call calRadius
                call circleAndRestore
                ret
                
                
drawLineAndStore:
                ret
                
drawStoredLine:
                ret
                
storeInitialLineValues:
                ret
                
drawRectangleAndStore:
                ret
                
drawStoredRectangle:
                ret
                
storeInitialRectangleValues:
                ret
                
                
                
                
                
         
                                    
    calRadius:                
        mov ax , [xc]
        movsx eax , ax
        mov [xcd] , eax
        mov ax , [yc]
        movsx eax , ax
        mov [ycd] , eax
        	
        mov ax , [yMouse]
        movsx eax , ax
        mov [ymd] , eax	
        
        
        mov ax, [xMouse]
        movsx eax , ax
        mov [xmd] , eax	
        
        finit
        fild dword[xcd]
        fisub dword[xmd]
        fmul st0
        fild dword[ycd]
        fisub dword[ymd]
        fmul st0
        faddp
        fsqrt
        fistp dword[rd]
        mov eax , [rd]
        mov [r] , ax
                
        ret
        
        
        
         circleAndStore:
        mov esi , restoreCounter
        mov ax , [r]
        cmp ax , 0
        JE Send
        mov [x] , ax 
        mov ax , [x]
        add ax , [xc]
        
        mov [xn], ax
        mov ax , 0 
        mov [y], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print it
        
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        
       
        mov ax , [xn]
        sub ax, [r]
        mov [xn] , ax 
        mov ax, [yn]
        add ax , [r]
        mov [yn], ax 
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [x]
        neg ax
        add ax , [xc]
        mov [xn], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [xn]
        add ax , [r]
        mov [xn] ,ax
        mov ax, [yn]
        sub ax , [r]
        mov [yn] ,ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw  
        
        ;Drawing The Circle
        mov ax,  1
        mov [p] , ax
        mov ax , [p]
        sub ax , [r]
        mov [p], ax
        
        Sl1:
        mov ax, [x]
        cmp ax, [y]
        JLE Sdone1
        mov ax , [y]
        inc ax
        mov [y] , ax
        
        mov ax, [p]
        cmp ax , 0
        JG Sl2
        mov dx , [y]
        shl dx ,1
        add ax , dx
        add ax, 1
        mov [p] , ax
        jmp Sdone2
        Sl2:
        mov dx , [x]
        dec dx
        mov [x] ,dx
        sub dx , [y]
        neg dx
        shl dx , 1
        add ax , dx
        add ax , 1
        mov [p], ax
        Sdone2:
        mov ax , [x]
        cmp ax ,  [y]
        JL Sdone1
        
        mov ax , [x]
        add ax , [xc]
        mov [xn], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [x]
        neg ax
        add ax , [xc]
        mov [xn] , ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        
        mov ax , [y]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [x]
        add ax , [xc]
        mov [xn] , ax
        mov ax , [y]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax, [x]
        cmp ax, [y]
        JE Sdone1
        
        mov ax , [y]
        add ax , [xc]
        mov [xn], ax
        mov ax , [x]
        add ax , [yc]
        mov [yn],ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [y]
        neg ax
        add ax , [xc]
        mov [xn], ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [x]
        neg ax
        add ax , [yc]
        mov [yn], ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        mov ax , [y]
        add ax , [xc]
        mov [xn] , ax
        mov ax , [x]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw
        
        jmp Sl1
        Sdone1:
        jmp Send1
        Send:
        mov al , 0x00
        mov ah , 0x0c
        mov cx , [xc]
        mov dx , [yc]
        int 10h
        Send1:
        
        ret
        
        
        
        circleAndRestore:
        mov esi , restoreCounter
        mov ax , [r]
        cmp ax , 0
        JE end
        mov [x] , ax 
        mov ax , [x]
        add ax , [xc]
        
        mov [xn], ax
        mov ax , 0 
        mov [y], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print it
        
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
       
        mov ax , [xn]
        sub ax, [r]
        mov [xn] , ax 
        mov ax, [yn]
        add ax , [r]
        mov [yn], ax 
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [x]
        neg ax
        add ax , [xc]
        mov [xn], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [xn]
        add ax , [r]
        mov [xn] ,ax
        mov ax, [yn]
        sub ax , [r]
        mov [yn] ,ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1 
        
        ;Drawing The Circle
        mov ax,  1
        mov [p] , ax
        mov ax , [p]
        sub ax , [r]
        mov [p], ax
        
        l1:
        mov ax, [x]
        cmp ax, [y]
        JLE done1
        mov ax , [y]
        inc ax
        mov [y] , ax
        
        mov ax, [p]
        cmp ax , 0
        JG l2
        mov dx , [y]
        shl dx ,1
        add ax , dx
        add ax, 1
        mov [p] , ax
        jmp done2
        l2:
        mov dx , [x]
        dec dx
        mov [x] ,dx
        sub dx , [y]
        neg dx
        shl dx , 1
        add ax , dx
        add ax , 1
        mov [p], ax
        done2:
        mov ax , [x]
        cmp ax ,  [y]
        JL done1
        
        mov ax , [x]
        add ax , [xc]
        mov [xn], ax
        mov ax , [y]
        add ax , [yc]
        mov [yn],ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [x]
        neg ax
        add ax , [xc]
        mov [xn] , ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        
        mov ax , [y]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [x]
        add ax , [xc]
        mov [xn] , ax
        mov ax , [y]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax, [x]
        cmp ax, [y]
        JE done1
        
        mov ax , [y]
        add ax , [xc]
        mov [xn], ax
        mov ax , [x]
        add ax , [yc]
        mov [yn],ax
        ;print it
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [y]
        neg ax
        add ax , [xc]
        mov [xn], ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [x]
        neg ax
        add ax , [yc]
        mov [yn], ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        mov ax , [y]
        add ax , [xc]
        mov [xn] , ax
        mov ax , [x]
        neg ax
        add ax , [yc]
        mov [yn] , ax
        ;print
        mov cx, [xn]
        mov dx, [yn]
        call draw1
        
        jmp l1
        done1:
        jmp end1
        end:
        mov al , 0x00
        mov ah , 0x0c
        mov cx , [xc]
        mov dx , [yc]
        int 10h
        end1:
        
        ret
        
draw:
    cmp cx, 0
    jl Sdont
    cmp cx, 319
    jg Sdont
    cmp dx, 0
    jl Sdont
    cmp dx, 199
    jg Sdont 
    cmp byte[drawAvailability],0
    jnz Scontinue
    cmp cx,[leftmostPixel]
    jl Scontinue
    cmp dx,[lowestPixel]
    jg Scontinue
    jmp Sdont
Scontinue:
    mov ah , 0xd
    int 10h
    mov [esi] , al
    inc esi
    mov al ,[currentColor]
    mov ah , 0xc
    int 10h
    ret
    Sdont:
    
    ret
    
    
    
        draw1:
    cmp cx, 0
    jl dont
    cmp cx, 319
    jg dont
    cmp dx, 0
    jl dont
    cmp dx, 199
    jg dont 
    cmp byte[drawAvailability],0
    jnz continue
    cmp cx,[leftmostPixel]
    jl continue
    cmp dx,[lowestPixel]
    jg continue
    jmp dont
continue:
    mov al ,[esi]
    inc esi
    mov ah , 0xc
    int 10h
    ret
    dont:
    ret
    
    
 drawCircleShape:
mov ax  , [colorSquareLength]
mov bx , 2
xor dx ,  dx
div bx
;===Calculate Xc ===;
mov bx , [circleX]
add bx, ax
mov [xc] , bx

;===Calculate Yc===;
 mov bx , [circleY]
 add bx , ax
 mov [yc] , bx 

;===Calculate R ===;
sub ax ,  2
mov [r] , ax

call circleAndStore

ret


drawRectangleShape:
drawLineShape:
drawPenShape:
            ret
                                                
initializeColorSelectionArea:
                mov al,[lightGray]
                mov cx,[leftmostPixel]
                mov dx,0
                mov bx,[lowestPixel]
                mov [drawHorizontalRectangleCounter],bx
                mov bx,319
                call drawHorizontalRectangle
                
                mov al,[shapesColor]
                mov [currentColor],al
                
                mov al,[gray]
                mov cx,[penX]
                mov dx,[penY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                call drawPenShape
                
                mov al,[gray]
                mov cx,[lineX]
                mov dx,[lineY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                call drawLineShape
                
                mov al,[gray]
                mov cx,[rectangleX]
                mov dx,[rectangleY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                call drawRectangleShape
                
                
                mov al,[gray]
                mov cx,[circleX]
                mov dx,[circleY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                call drawCircleShape
                
                
                mov al,[initialCurrentColor]
                mov [currentColor],al
                
                mov al,0x00
                mov cx,[blackX]
                mov dx,[blackY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                mov al,0x03
                mov cx,[cianX]
                mov dx,[cianY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                mov al,0x0a
                mov cx,[greenX]
                mov dx,[greenY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                mov al,0x01
                mov cx,[blueX]
                mov dx,[blueY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                mov al,0x04
                mov cx,[redX]
                mov dx,[redY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                mov al,0x06
                mov cx,[orangeX]
                mov dx,[orangeY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                call drawCurrentColorSquare
                call drawCurrentShapeSquare
                call drawCurrentAuxilaryColorSquare
                ret
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawCurrentColorSquare:                
                mov al,[currentColor]
                mov cx,[currentColorX]
                mov dx,[currentColorY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                ret
            
drawCurrentShapeSquare:                
                mov al,[currentShape]
                mov cx,[currentShapeX]
                mov dx,[currentShapeY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                ret
                                    
drawCurrentAuxilaryColorSquare:                   
                mov al,[currentAuxilaryColor]
                mov cx,[currentAuxilaryColorX]
                mov dx,[currentAuxilaryColorY]
                mov bx,[colorSquareLength]
                mov [drawHorizontalRectangleCounter],bx
                add bx,cx
                call drawHorizontalRectangle
                
                ret
                
initializeMouse:
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
                 hlt 
                
drawHorizontalLine:       ; al color, cx left point , dx hight, bx right point       
                cmp cx,bx
                jb continueDrawingHorizontalLine  
                xchg cx,bx    
    continueDrawingHorizontalLine:     
                mov ah,0x0C	;change color for a single pixle
	int 0x10
                inc cx
                cmp cx,bx
                jbe continueDrawingHorizontalLine
                ret
                
                
drawHorizontalRectangle:        ; al color, cx left point , dx top point, bx right point
    nextdrawHorizontalRectangle:
                cmp word[drawHorizontalRectangleCounter],0
                jbe donedrawHorizontalRectangle
                push cx
                push bx
                call drawHorizontalLine
                pop bx
                pop cx
                inc dx
                dec word[drawHorizontalRectangleCounter]
                jmp nextdrawHorizontalRectangle
    donedrawHorizontalRectangle:
                ret
               
      ; left & right
setMouseStatus:
	call readMouse
                mov byte [statusMouse], al
                mov bl,al
	and al,0x01
	mov [leftButtonMouse],al
                
                and bl,0x02
                mov [rightButtonMouse],bl 
                ret
                
setXMouse:
                ; x displacement
	xor ax,ax
	xor dx,dx
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
                ret
                
setYMouse:
                ; y displacement
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
                ret
                
setZMouse:
                call readMouse
                mov byte [zMouse], al
                ret
                
storeLastPixelColor:
                mov ah,0x0d
                mov cx,[xMouse]         ; x
                mov dx,[yMouse]         ; y
                int 0x10
                mov [lastPixelColor],al 
                ret
                
restoreLastPixelColor:
                mov ah,0x0C	;change color for a single pixle
	mov al,[lastPixelColor]	; retain color
	mov cx,[xMouse] 	; x
	mov dx,[yMouse] 	; y
	int 0x10
                ret
                
                
generalRestoreLastPixelColor:
                mov al,[currentColor]
                mov [temporaryColor],al
	mov al,[lastPixelColor]	; retain color
	mov cx,[xMouse] 	; x
	mov dx,[yMouse] 	; y
                mov [currentColor],al
                mov esi,restoreCounter
                call draw
                mov al,[temporaryColor]
                mov [currentColor],al
	
                ret

                
showPointer:
                mov al,[currentColor]
	mov  ah,0xC 	; change pixle color
	mov  cx, [xMouse]	; x
	mov  dx, [yMouse]	; y
	int  0x10
                ret
              
isMouseInsideColorSelectionArea:
                mov cx,[leftmostPixel]
                mov bx,319
                sub bx,cx
                mov dx,0
                mov ax,[lowestPixel]
                call isMouseInsideHorizontalRectangle
                ret
                
isMouseInsideHorizontalRectangle:
                cmp [xMouse],cx
                jb mouseNotInsideHorizontalRectangle
                add cx,bx
                cmp [xMouse],cx
                ja mouseNotInsideHorizontalRectangle
                cmp [yMouse],dx
                jb mouseNotInsideHorizontalRectangle
                add dx,ax
                cmp [yMouse],dx
                ja mouseNotInsideHorizontalRectangle
                mov al,1
                ret
    mouseNotInsideHorizontalRectangle:
                xor al,al
                ret

                hlt

xc: dw 50,0
yc: dw 50,0
x: dw 0,0
y: dw 0,0
r: dw 40,0
xn: dw 70,0
yn: dw 50,0
p: dw 1, 0
ycd: dd 0,0
xcd: dd 0,0
xmd: dd 0,0
ymd: dd 0	,0
rd: dd 0,0
restoreCounter: times (2000) db 0
times (0x400000 - ($-$$)) db 0

db 	0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db	0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db	0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db	0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db	0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db	0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00