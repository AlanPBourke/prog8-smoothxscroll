%import syslib

main {

   sub start() {

        ;https://pastebin.com/tjPEr8Bq
        ; chars =  %xxxx100x -> charmem is at $2000
        c64.VMCSB = c64.VMCSB & %11110001 | %00001000

        @($d016) = @($d016) | %00010000         ; Multicolour text mode (bit 4 = 1)

        sys.memset($0400, 40*25, 0)             ; Clear text screen at default location

        sys.memset($d800, (25*40), %00001000)   ; Set multicolour mode bit 3 for each colour RAM location
                                                ; with black as the BG colour

        c64.EXTCOL = 0  ; Border
        c64.BGCOL0 = 0  ; Screen
        c64.BGCOL1 = 7  ; Multicolour 1
        c64.BGCOL2 = 8  ; Multicolour 2
        

;%breakpoint
        uword map_ptr = &uridium_map

        ;ubyte col = 0
        ubyte row = 0
        uword map_col = 4
        uword screen_offset = 0
        uword map_offset = 0
        ubyte cha = 0

        screen_offset = 4 * 40
;%breakpoint
        for row in 0 to 16 {

            ; Draw screenful
            ;for col in 0 to 39 {
            ;    
            ;    cha = @(map_ptr + map_offset + col)
            ;    @($400 + offset + col) = cha
            ;}

            map_offset = row * 512
            cha = @(map_ptr + map_offset + map_col)
            @($400 + screen_offset + 39) = cha

            screen_offset += 40
            
        }

        

        repeat {}

    }

}

uridium_chars $2000 {
    %option force_output
    %asmbinary "UridiumChars.bin"
}

uridium_map $5000 {
    %option force_output
    %asmbinary "UridiumMap.bin"
}

