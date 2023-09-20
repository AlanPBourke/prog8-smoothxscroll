%import syslib

main {

   sub start() {

        ;https://pastebin.com/tjPEr8Bq
        ; chars =  %xxxx100x -> charmem is at $2000
        c64.VMCSB = c64.VMCSB & %11110001 | %00001000

        @($d016) = @($d016) | %00010000         ; Multicolour text mode

        sys.memset($0400, 40*25, 0)             ; Clear text screen at default location

        sys.memset($d800, (25*40), %00001000)   ; Set multicolour mode bit for each colour RAM location
                                                ; with black as the BG colour

        c64.EXTCOL = 0  ; Border
        c64.BGCOL0 = 0  ; Screen
        c64.BGCOL1 = 7
        c64.BGCOL2 = 8
        

;%breakpoint
        uword map_ptr = &uridium_map

        ubyte col = 0
        ubyte row = 4
        uword map_offset = 0
        uword offset = 0
        ubyte cha = 0

        offset = 4 * 40

        for row in 0 to 16 {

            for col in 0 to 39 {
                
                cha = @(map_ptr + map_offset + col)
                @($400 + offset + col) = cha
            }

            offset += 40
            map_offset += 512
            
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

