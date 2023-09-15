; https://bitwisecmd.com/
; $D018  (c64.VMCSB see https://github.com/irmen/prog8/blob/master/compiler/res/prog8lib/c64/syslib.p8)
; https://codebase64.org/doku.php?id=base:vicii_memory_organizing
%import syslib
%import textio

; Note: VICE monitor io d000

main {

    sub start() {


        ; Screen at $3000
        c64.VMCSB = c64.VMCSB & %00001111 | %11000000
        
        ; chars =  %xxxx100x -> charmem is at $2000
        c64.VMCSB = c64.VMCSB & %11110001 | %00001000

        sys.set_irqd()
        sys.memset($2000, 8*256, 0)     ; clear charset data

        c64.SCROLX &= %11110111     ; 38 column mode

        sys.set_rasterirq(&irq.irqhandler, 245, false)

        repeat {}

    }
}


irq {

    const uword screen_base             = $3000
    const uword screen_backbuffer_base  = $3400  
    const uword char_base               = $2000      
    const ubyte start_colorcopy_line = 65;
    const ubyte map_height = 17
    const uword map_width = 512
    ubyte current_screen = 0;
    const uword map_base = $5000
    byte scroll = 7
    ubyte startline = 0
    ubyte numlines = 0
    ubyte row = 0

    sub setscreenlocation() {

        if current_screen == 0 {

            ; screen = %1100xxxx -> screenmem is at $3000
            c64.VMCSB = c64.VMCSB & %00001111 | %11000000
        
        }
        else {
            ; screen = %1100xxxx -> screenmem is at $3400
            c64.VMCSB = c64.VMCSB & %00001111 | %11010000            
        }
    }


    sub copy_and_shift() {

        &uword from_screen = screen_base
        &uword to_screen = screen_backbuffer_base

        if current_screen == 1 {
            from_screen = screen_backbuffer_base
            to_screen = screen_base
        }

        from_screen += 1 + (startline * 40)
        to_screen = (startline * 40)

        row = 0
        while row < numlines {
            sys.memcopy(from_screen, to_screen, 39)
            from_screen += 40
            to_screen += 40
            row += 1
        }
    }

    sub swap_screens() {
        ; drawcom39

    }

    sub irqhandler() {

        scroll -= 1

        if scroll<0 {
            swap_screens()
            goto irqdone
        }

        c64.SCROLX &= scroll        ; Setting 3 lsbs'
        
        if scroll == 4 {
            startline = 4
            numlines = 3
            ; copy_and_shift;
        }

        if scroll == 2 {
            startline = 12
            numlines = 9
            ; copy_and_shift;
        }

        irqdone:
           
    }

    uridium_chars: %asmbinary "UridiumChars.bin"
    uridium_map: %asmbinary "UridiumMap.bin"
   
}


