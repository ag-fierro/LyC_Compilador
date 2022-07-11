:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

del ts.txt
del intermedia.txt
del final.asm

pause

gcc lex.yy.c y.tab.c -o Compilador.exe

Compilador.exe prueba.txt

@echo off

del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
