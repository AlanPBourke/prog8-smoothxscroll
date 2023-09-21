# prog8-hscroll
Commodore 64 smooth horizontal scroller using the Prog8 language (https://prog8.readthedocs.io/en/latest/)

This program does a right to left x-scroll using the standard double buffered approach.
So two 1000 byte chunks of memory starting at $3800 and $3c00 are used for screen data and are drawn to and switched between accordingly.
It uses a Uridium ship map, those are 512 chars wide by 17 chars high. Therefore on a text screen there are 4 blank rows (or 4 non-moving starfield rows in the actual game), then 17 rows of ship chars, then another 4 blank rows. The scroll routine only copies\shifts the 17 ship rows between front and back buffer screens for more speed.

The charset is dumped from one of the CharPad examples. The colours are slightly wrong as the foreground colour for the ship should be white. 

Don't have to worry about moving data in the colour RAM with this particular example.

The general approach is from: http://1amstudios.com/2014/12/07/c64-smooth-scrolling
In pseudocode terms described here: https://github.com/jeff-1amstudios/c64-smooth-scrolling
