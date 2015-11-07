# asm_roller
Assembly-based Dice Roller

## About
I have been meaning to learn more assembly code.  This project is the ideal early project for that.  My plan is to create a dice-rolling program in C, then x86 Assembly.

I would consider making a microcontroller version, and making a user interface for that, but I have determined that I'd rather use this as a starter project for a larger concept of mine.  I might make a microcontroller version if I have time in the future though.

## License
Public domain, go wild.	

## Disclaimer
It should not be my problem if something goes wrong.  I disclaim all liability.  This software comes with no guarentee of its fittness for any purpose whatsoever.  Also, neither myself nor this software has any affiliation with D&D or Wizards of the coast, and therefore should not be construed as being in any manner an official tool.

## Planning
This software should be pretty trivial, so the plan is to:
<ol>
<li>Create a version in C</li>
<li>Make the associated x86 version(s).</li>
<li>Go play D&D with it.</li>
</ol>

## Testing
- I'll probably make scripts to test the versions, so I can play around with bash a little more.

## Building
**step 1:** cd FLAVOR_OF_CHOICE/<br/>
**step 2:** make<br/>

- the C version will require gcc, make
- the x86 assembly will require nasm

## Running
./dice_roller <number of dice> <number of sides per die>

## Why no fancy, modern tools?
I wanted to play around with these older technologies a little bit to refresh my feel for the underlying low-level stuff.  The low-level concepts are necessary in order to make full-use of higher-level technologies correctly.  I have different plans for more modern projects.
