%import syslib

main {

   sub start() {

        sys.memset($0400, 40*25, 0)
        ;sys.memset($d800, 40*25, 0)

        ; chars =  %xxxx100x -> charmem is at $2000
        c64.VMCSB = c64.VMCSB & %11110001 | %00001000
        
        c64.SCROLX = %00010000
        c64.EXTCOL = $f0  ; Border
        c64.BGCOL0 = $f0  ; Screen
        c64.BGCOL1 = $f7
        c64.BGCOL2 = $f8
        c64.BGCOL4 = $f3

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

