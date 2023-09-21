; This program does a right to left x-scroll using the standard double buffered approach.
; So two 1000 byte chunks of memory starting at $3800 and $3c00 are used for screen data
; and are drawn to and switched between accordingly.
; It uses a Uridium ship map, those are 512 chars wide by 17 chars high. Therefore on a text
; screen there are 4 blank rows (or 4 non-moving starfield rows in the actual game), then 17
; rows of ship chars, then another 4 blank rows. The scroll routine only copies\shifts the
; 17 ship rows between front and back buffer screens for more speed.
;
; The charset is dumped from one of the CharPad examples. The colours are slightly wrong
; as the foreground colour for the ship should be white. 
;
; Don't have to worry about moving data in the colour RAM with this particular example.
;
; The general approach is from: http://1amstudios.com/2014/12/07/c64-smooth-scrolling
;
; In pseudocode terms described here: https://github.com/jeff-1amstudios/c64-smooth-scrolling
;

main {

    sub start() {

        c64.VMCSB = c64.VMCSB & %00001111 | %11100000   ; Screen at $3800.
        c64.VMCSB = c64.VMCSB & %11110001 | %00001000   ; %xxxx100x -> character set is at $2000.

        @($d016) = @($d016) | %00010000                 ; Multicolour text mode (bit 4 = 1).
        @($d016) = @($d016) & %11110111                 ; 38 column mode.

        sys.memset($0400, 40*25, 0)                     ; Clear text screen at default location.

        sys.memset($d800, (25*40), %00001000)           ; Set multicolour mode bit 3 for each colour RAM location.
                                                        ; with black as the BG colour.

        c64.EXTCOL = 0                                  ; Border colour = black.
        c64.BGCOL0 = 0                                  ; Screen colour = black.
        c64.BGCOL1 = 7                                  ; Multicolour 1 = yellow.
        c64.BGCOL2 = 8                                  ; Multicolour 2 - orange.


        sys.set_rasterirq(&irq.irqhandler, 245, true)   ; Raster interrupt at line 245.

        repeat {}

    }

}

irq {

    const uword screen_base = $3800
    const uword screen_backbuffer_base = $3c00 

    uword map_location = &uridium_map

    uword from_screen = 0
    uword to_screen = 0
    uword startline = 0
    uword map_offset = 0
    uword screen_offset = 0   
    uword map_col = 0
    ubyte map_char

    ubyte scroll = 7
    ubyte current_screen = 0;
    ubyte numlines = 0
    ubyte row = 0

    sub irqhandler() {

        scroll -= 1                                     ; Smooth scroll to the left, Vasily.
                                                        ; One pixel only.

        if scroll == 0 {                                ; Smooth scrolled 7 pixels?

            swap_screens()                              ; Draw a new map column at right side
                                                        ; of the back buffer screen then
                                                        ; point at the other screen and reset scroll.
            return
        }

        SetSmoothScrollPosition()
        
        if scroll == 4 {                                ; Rough scroll top half of ship.
            startline = 4
            numlines = 8
            CopyAndShift();
        }

        if scroll == 2 {                                ; Rough scroll bottom half of ship.       
            startline = 12
            numlines = 9
            CopyAndShift();
        }

    }

    ; ----------------------------------------------------------------------------------------------------------
    ; Draw a new slice of the map, reset the scroll position, point at the other screen, reset scroll.
    ; ----------------------------------------------------------------------------------------------------------
    sub swap_screens() {

        DrawNextMapColumn()
        scroll = 7
        SetSmoothScrollPosition()

        current_screen = not current_screen

        SetScreenLocation()

    }

    ; ----------------------------------------------------------------------------------------------------------
    ; Point the VIC to one of the two blocks of memory used for the front and back buffer screens.
    ; ----------------------------------------------------------------------------------------------------------
    sub SetScreenLocation() {

        if current_screen == 0 {

            c64.VMCSB = c64.VMCSB & %00001111 | %11100000       ; screen = %1100xxxx -> screenmem is at $3800
        
        }
        else {
            
            c64.VMCSB = c64.VMCSB & %00001111 | %11110000       ; screen = %1100xxxx -> screenmem is at $3c00         
        }
    }

    ; ----------------------------------------------------------------------------------------------------------
    ; Rough scroll either the top or bottom half of the ship from the current VIC text screen to the other screen.
    ; ----------------------------------------------------------------------------------------------------------
    sub CopyAndShift() {

        if current_screen == 0 {
            from_screen = screen_base
            to_screen = screen_backbuffer_base
        }
        else {
            from_screen = screen_backbuffer_base
            to_screen = screen_base
        }
              
        screen_offset = startline * 40
        row = 0

        while row <= numlines {

            sys.memcopy(from_screen + 1 + screen_offset, to_screen + screen_offset, 39)
            screen_offset += 40
            row++
        
        }

    }

    ; ----------------------------------------------------------------------------------------------------------
    ; Sets the x axis smooth scrool position via the first 3 bits of $d016
    ; ----------------------------------------------------------------------------------------------------------
    sub SetSmoothScrollPosition() {
        c64.SCROLX = c64.SCROLX & %11111000 | scroll        
    }

    ; ----------------------------------------------------------------------------------------------------------
    ; Draws the next vertical column of the ship map at column 39 of the back buffer screen, the VIC will
    ; be pointing at the 'front' screen.
    ; ----------------------------------------------------------------------------------------------------------
    sub DrawNextMapColumn () {
        
        ; Drawing on 'other' screen, i.e. what VIC is not pointing at.
        to_screen = screen_backbuffer_base
        if current_screen == 1 {
            to_screen = screen_base
        }

        screen_offset = 4 * 40                          ; Start plotting chars at line 5 of text screen.

        for row in 0 to 16 {                            ; Ship map is 17 chars high and 512 chars wide.

            map_offset = row * 512
            map_char = @(map_location + map_offset + map_col)
            @(to_screen + screen_offset + 39) = map_char

            screen_offset += 40
            
        }

        map_col++                                       ; Drawn the last ship column then back to start.
        if map_col == 512 {
            map_col = 0
        }

    }

}

; Map and character data at specified memory locations. 
uridium_chars $2000 {
    %option force_output
    %asmbinary "UridiumChars.bin"
}

uridium_map $5000 {
    %option force_output
    %asmbinary "UridiumMap.bin"
}
