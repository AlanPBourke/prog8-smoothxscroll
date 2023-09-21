; https://bitwisecmd.com/
; $D018  (c64.VMCSB see https://github.com/irmen/prog8/blob/master/compiler/res/prog8lib/c64/syslib.p8)
; https://codebase64.org/doku.php?id=base:vicii_memory_organizing
;https://www.pagetable.com/c64ref/c64mem/
;https://codebase64.org/doku.php?id=base:built_in_screen_modes
;%import syslib
;%import textio

; Note: VICE monitor io d000

main {

    sub start() {

        ;sys.set_irqd()

        ; Screen at $3800
        c64.VMCSB = c64.VMCSB & %00001111 | %11100000
        
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

        sys.set_rasterirq(&irq.irqhandler, 245, true)

        repeat {}

    }

}


irq {

    const uword screen_base             = $3800
    const uword screen_backbuffer_base  = $3c00 
    const uword char_base               = $2000      
    const ubyte start_colorcopy_line = 65;
    const ubyte map_height = 17
    const uword map_width = 512
    ubyte current_screen = 0;
    uword from_screen = 0
    uword to_screen = 0
  
    ubyte scroll = 7
    uword startline = 0
    ubyte numlines = 0
    ubyte row = 0
    ubyte i = 1
    uword map_offset = 0
    uword offset = 0   
    uword screen_offset = 0   
    uword map_ptr = &uridium_map
    uword map_col = 0
    ubyte map_char

    sub setscreenlocation() {

        if current_screen == 0 {

            ; screen = %1100xxxx -> screenmem is at $3800
            ; screen_base
            c64.VMCSB = c64.VMCSB & %00001111 | %11100000
        
        }
        else {
            ; screen = %1100xxxx -> screenmem is at $3c00
            ; screen_backbuffer_base
            c64.VMCSB = c64.VMCSB & %00001111 | %11110000            
        }
    }


    sub copy_and_shift() {

        if current_screen == 0 {
            from_screen = screen_base
            to_screen = screen_backbuffer_base
        }
        else {
            from_screen = screen_backbuffer_base
            to_screen = screen_base
        }
              
        offset = startline * 40

        row = 0
        while row <= numlines {
            sys.memcopy(from_screen + 1 + offset, to_screen + offset, 39)
            offset += 40
            row++
        }

    }

    sub set_smoothscroll_position() {
        c64.SCROLX = c64.SCROLX & %11111000 | scroll        ; Setting 3 lsbs'        
    }

    sub swap_screens() {

        drawcolumn39frommap()
        scroll = 7
        set_smoothscroll_position()

        ;current_screen = (current_screen + 1) & 1
        current_screen = not current_screen

        setscreenlocation()

    }

    sub drawcolumn39frommap () {

        
        to_screen = screen_backbuffer_base

        ; Drawing on 'other' screen, i.e. what VIC is not pointing at.
        if current_screen == 1 {
            to_screen = screen_base
        }

        screen_offset = 4 * 40

        for row in 0 to 16 {

            map_offset = row * 512
            map_char = @(map_ptr + map_offset + map_col)
            @(to_screen + screen_offset + 39) = map_char

            screen_offset += 40
            
        }

        map_col++
        if map_col == 512 {
            map_col = 0
        }

    }

    sub irqhandler() {

        scroll -= 1

        if scroll == 0 {
            swap_screens()
            return
        }

        set_smoothscroll_position()
        
        if scroll == 4 {
            startline = 4
            numlines = 8
            copy_and_shift();
        }

        if scroll == 2 {
            startline = 12
            numlines = 9
            copy_and_shift();
        }

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
