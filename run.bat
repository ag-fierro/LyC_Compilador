:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

del ts.txt
del intermedia.txt

gcc lex.yy.c y.tab.c -o Segunda.exe

Segunda.exe prueba.txt

@echo off

del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
