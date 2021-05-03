;********************************************;
;         radical - simple bootloader        ;
; file      : bootloader.asm                 ;
; desc      : main bootloader file           ;
; author    : Siddharth Mishra               ;
; time      : Mon 3 May, 2021, 17:13         ;
;********************************************;

org 0x7c00                                                          ; loaded by bios at 0x7c00
bits 16                                                             ; we are in 16 bit real mode
start: jmp loader                                                   ; jmp over oem block to entry point

; the above statements are assembler instructions and not machine instructions
; so they don't occupy any memory
; same is the case with the "times" keyword on 2nd last line

;************************************;
;       oem parameter block          ;
;************************************;
times 0x0b-$+start db 0
bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	    DB 2
bpbRootEntries: 	    DW 224
bpbTotalSectors: 	    DW 2880
bpbMedia: 	            DB 0xF0
bpbSectorsPerFAT: 	    DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors: 	    DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	            DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "

;******************************************************************************************;
;                           BIOS PARAMETER BLOCK FOR FAT32                                 ;
;                https://en.wikipedia.org/wiki/BIOS_parameter_block                        ;
;******************************************************************************************;
; Sector offset  ;	BPB offset  ;	Field length  ;	    Description                        ;
;******************************************************************************************;
; 0x00B 	     ;      0x00 	;    25 BYTEs 	  ;    DOS 3.31 BPB                        ;
; 0x024 	     ;      0x19 	;    DWORD 	      ;    Logical sectors per FAT             ;
; 0x028 	     ;      0x1D 	;    WORD 	      ;    Mirroring flags etc.                ;
; 0x02A 	     ;      0x1F 	;    WORD 	      ;    Version                             ;
; 0x02C 	     ;      0x21 	;    DWORD 	      ;    Root directory cluster              ;
; 0x030 	     ;      0x25 	;    WORD 	      ;    Location of FS Information Sector   ;
; 0x032 	     ;      0x27 	;    WORD 	      ;    Location of backup sector(s)        ;
; 0x034 	     ;      0x29 	;    12 BYTEs 	  ;    Reserved (Boot file name)           ;
; 0x040 	     ;      0x35 	;    BYTE 	      ;    Physical drive number               ;
; 0x041 	     ;      0x36 	;    BYTE 	      ;    Flags etc.                          ;
; 0x042 	     ;      0x37 	;    BYTE 	      ;    Extended boot signature (0x29)      ;
; 0x043 	     ;      0x38 	;    DWORD 	      ;    Volume serial number                ;
; 0x047 	     ;      0x3C 	;    11 BYTEs 	  ;    Volume label                        ;
; 0x052 	     ;      0x47 	;    8 BYTEs 	  ;    File-system type                    ;
;******************************************************************************************;

;************************************;
;       bootloader entry point       ;
;************************************;
loader:
    ; print welcome message
    push welcome_msg
    call print_ln

    ; print version string
    push version_msg
    call print_ln

    ; print author string
    push author_msg
    call print_ln

    cli                                                             ; clear all interrupts
    hlt                                                             ; halt the system

; data here
welcome_msg: db 'radical bootloader',0
version_msg: db 'Version : 0.0.0',0 
author_msg: db 'Author : Siddharth Mishra',0


; includes here
%include "print.asm"

times 510 - ($-$$) db 0                                             ; 1 sector is 512 bytes, so fill the remaining bytes with 0

; $            = address of current instruction
; $$           = address of start of this section 
; $-$$         = number of bytes occupied
; 510          = 512 - 2 ( 2 is for magic word 0xaa55 )
; 510 - ($-$$) = number of bytes unoccupied

dw 0xaa55                                                           ; boot signature
; the above magic word means that this is a boot sector
; a word occupies 2 bytes of 512 bytes
; the magic word must be at the end of sector and hence we have to fit our code in those 512 bytes
; to occupy a whole sector we have to fill the rest of unoccupied memory with trash

; the bios calls interrupt 0x19, which goes through every disk -> head -> track -> sector
; the interrupt then checks the last two bytes of each sector
; if 511 byte = 0xaa and 512 byte = 0x55
; then the interrupt identifies the last sector as bootsector
