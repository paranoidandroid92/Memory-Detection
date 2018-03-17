[BITS 16]
mov ax,0x07c0
mov ds,ax

mov ax,0x5000
mov es,ax
mov di,0

mov ax,0x6000
mov ss,ax
mov sp,0






	call detect_memory
	call print_memory_map
	mov ax,bar_string;
	mov si,ax;
	call printStr;
	mov bl,[entry_count]
end:
	hlt
	jmp end

detect_memory:
	pushad
	mov ebx,0	;clear ebx
	mov edx,0x534D4150	;magic number
detect_entry:
	mov eax,0xE820
	mov ecx,24
	int 0x15
	add byte [entry_count],1
	cmp ebx,0
	je detect_end
	add di,24
	jmp detect_entry
detect_end:
	popad
	ret

print_memory_map:
	pusha
	push es
	mov ax,[entry_count]
	mov cl,24
	mul cl
	mov cx,ax
	mov ax,0x5000
	mov es,ax
	mov di,0
	mov si,0
repeat:
	cmp cx,0
	je over
	mov al,[es:di]
	call print_byte
	dec cx
	inc di
	mov ax,di
	mov dl,8
	div dl
	cmp ah,0
	je next_variable
	jmp repeat
next_variable:
	inc si
	cmp si,3
	je next_entry
	mov ax,0x4e2D
	push di
	push es
	add word [screen_index],2
	mov bx,0xb800
	mov es,bx
	mov di,[screen_index]
	mov [es:di],ax
	sub word [screen_index],4
	pop es
	pop di
	jmp repeat
next_entry:
	mov si,0
	add word [screen_index],260
	jmp repeat
over:
	pop es
	popa
	ret
	



print_byte: ;print al
	pushad
	push es
	mov bx,0xb800
	mov es,bx
	mov di,[screen_index]
	mov bl,al
	and al,0x0F
	call add_ascii_offset
	mov ch,0x4e
	mov cl,al
	shl ecx,16
	mov al,bl
	shr al,4
	call add_ascii_offset
	mov ch,0x4e
	mov cl,al
	mov eax,ecx
print:
	sub word [screen_index],4
	mov [es:di],eax
print_end:
	pop es
	popad
	ret

add_ascii_offset:
	cmp al,9
	jg letter
numeric:
	add al,48
	ret
letter:
	add al,55
	ret

;prints string in [ds:si] to screen	
printStr:
	pusha;
	push di
	push es
	cld;inc si after lodsb
loadchr:
	lodsb;
	cmp al,0x00;
	je printStrFinish;
	cmp al,0x0A;
	je newline;
	mov ah,0x4e;
	mov di,[video_memory_index];
	mov es,[video_memory_base];
	mov [es:di],ax;
	inc di;
	inc di;
	mov [video_memory_index],di;
	jmp loadchr;
newline:
	push dx;
	push bx;
	push ax;
	mov bx,0x00A0;
	add [video_memory_index],bx;
	mov dx,0;
	mov ax,[video_memory_index];
	div bx;
	sub [video_memory_index],dx;
	pop ax;
	pop bx;
	pop dx;
	jmp loadchr;
printStrFinish:
	pop es
	pop di
	popa;
	ret;

video_memory_base dw 0xb800
video_memory_index dw 0x0000
entry_count db 0x00
screen_index dw 256
bar_string db '      Type            Length            Base      ', 0x00
times 510-($-$$) db 0x00
db 0x55
db 0xAA
