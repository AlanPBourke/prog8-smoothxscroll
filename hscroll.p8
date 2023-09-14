; https://bitwisecmd.com/
; $D018  (c64.VMCSB see https://github.com/irmen/prog8/blob/master/compiler/res/prog8lib/c64/syslib.p8)
; https://codebase64.org/doku.php?id=base:vicii_memory_organizing
%import syslib
%import textio

; Note: VICE monitor io d000

main {
    
    sub start() {

        &ubyte screen_base = $3000      ; Pointer

        ; screen = %1100xxxx -> screenmem is at $3000
        c64.VMCSB = c64.VMCSB & %00001111 | $11000000

        ; chars =  %xxxx100x -> charmem is at $2000
        c64.VMCSB = c64.VMCSB & %11110001 | $00001000

        sys.set_rasterirq(&irq.irqhandler, 245, false)

        repeat {}

    }

}

irq {

    uridium_chars: %asmbinary "UridiumChars.bin"
    uridium_map: %asmbinary "UridiumMap.bin"

    const ubyte start_colorcopy_line = 65;
    const ubyte map_height = 17
    const uword map_width = 512
    const ubyte scroll = 7
    const word map_base = $5000

    const uword screen_backbuffer_base = $3400

    sub irqhandler() {



    }
}
