[BITS 16]
mov ax,0x07c0
mov ds,ax

end:
	jmp end
				
times 510-($-$$) db 0x00
db 0x55
db 0xAA
