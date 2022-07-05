:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

del ts.txt
del intermedia.txt
del assembler.asm

gcc lex.yy.c y.tab.c -o Compilador.exe

Compilador.exe prueba.txt

PATH=C:\TASM;
tasm numbers.asm
tasm assembler.asm
tlink assembler.obj numbers.obj
assembler.exe

@echo off

del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
