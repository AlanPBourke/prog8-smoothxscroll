; https://bitwisecmd.com/
; $D018  (c64.VMCSB see https://github.com/irmen/prog8/blob/master/compiler/res/prog8lib/c64/syslib.p8)
; https://codebase64.org/doku.php?id=base:vicii_memory_organizing
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


        sys.memset($2000, 8*256, 0)     ; clear charset data
  
        ubyte chaaa = 21
        sys.memset($3800, 1000, chaaa)     ; TEST 
        chaaa++
        sys.memset($3c00, 1000, chaaa)     ; TEST


       ; c64.SCROLX &= %11110111     ; 38 column mode

        sys.set_rasterirq(&irq.irqhandler, 255, false)

        ;fill_screen($3000, 0 as ubyte)

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
    ;uword map_ptr = &UridiumMap
    uword from_screen = 0
    uword to_screen = 0
  
    byte scroll = 7
    ubyte startline = 0
    ubyte numlines = 0
    ubyte row = 0
    ubyte i = 1

    sub setscreenlocation() {

        if current_screen == 0 {

            ; screen = %1100xxxx -> screenmem is at $3800
            c64.VMCSB = c64.VMCSB & %00001111 | %11100000
        
        }
        else {
            ; screen = %1100xxxx -> screenmem is at $3c00
            c64.VMCSB = c64.VMCSB & %00001111 | %11110000            
        }
    }


    sub copy_and_shift() {

        uword offset = 0

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
        while row < numlines {
            sys.memcopy(from_screen + 1 + offset, to_screen + offset, 39)
            offset += 40
            row++
        }

    }

    sub swap_screens() {

        if current_screen == 1 {
            to_screen = screen_backbuffer_base
        }
        else {
            to_screen = screen_base
        }

        ;map_ptr = &to_screen + (4 * 40)


    }

    sub drawcolumn39frommap () {

        if current_screen == 1 {
            from_screen = screen_backbuffer_base
            to_screen = screen_base
        }

    }

    sub irqhandler() {

        scroll -= 1
        

        if scroll<0 {
            ;swap_screens()
            return
        }

        c64.SCROLX &= scroll        ; Setting 3 lsbs'

 
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

    uridium_chars: %asmbinary "UridiumChars.bin"
    uridium_map: %asmbinary "UridiumMap.bin"
   
}


