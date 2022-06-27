%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <math.h>

#include "y.tab.h"

#define ID_TYPE 0
#define ENTERO 1
#define FLOTANTE 2
#define CARAC 3

#define MAX 1000
#define LIMIT_ID 32
#define LIMIT_STR 30
#define LIMIT_INT_INF -32768
#define LIMIT_INT_SUP 32767
#define LIMIT_FLOAT_INF pow(-1.17549,-38)
#define LIMIT_FLOAT_SUP pow(3.40282,38)

void cargar_simbolo(char*, int, char*);

FILE* yyin;

int yyerror(void);
int lineno = 1;

char yytext_aux[33];

%}

/*OPCIONES*/
%option noyywrap  
%option yylineno 

/*CARACTERES*/
DIGITO			[1-9]
DIG_C_NUL		[0-9]		
LETRA			[a-zA-Z]
ESPACIO			[" "]
INI_COM			"-/"
FIN_COM			"/-"
GUIONES			[-_]
COMILLAS		["]
CHAR_COMA		[","]
CHAR_PUNTO		["."]
CHAR_PUNCO		[";"]
CHAR_DOSPU		[":"]
CARACTER        [a-z,A-Z,0-9,=,>,<,!,:,+,\-,*,/,@,?]

/*OPERADORES*/
OP_ASIG		":="
OP_SUM		"+"
OP_MUL		"*"
OP_RES		"-"
OP_DIV		"/"
OP_MAY		">"
OP_MEN		"<"
OP_MAIG		">="
OP_MEIG		"<="
OP_IGU		"=="
OP_NEG		"!"
OP_DIS		"!="
OP_DOPU		":"
OP_AND 		"&&"
OP_OR		"||"

/*OTROS CARACTERES*/
LLA_A		"{"
LLA_C		"}"
PAR_A		"("
PAR_C		")"
COR_A		"["
COR_C		"]"

/*DECLARACIONES*/
CTE_INTEGER		{DIG_C_NUL}+
CTE_FLOAT		{DIG_C_NUL}*"."{DIG_C_NUL}*|0  
CTE_STRING      {COMILLAS}({CARACTER}+|{ESPACIO})*{COMILLAS}
ID				{LETRA}({LETRA}|{DIGITO}|{GUIONES})*
CONTENIDO		({CARACTER}+|{ESPACIO})*
COMENTARIO 		{INI_COM}{CONTENIDO}{FIN_COM}

/*PALABRAS RESERVADAS*/
IF			"if"|"IF"|"If"
ELSE		"else"|"ELSE"|"Else"
WHILE		"while"|"WHILE"|"While"
INT			"int"|"INT"|"Int"
FLOAT		"float"|"FLOAT"|"Float"
CHAR		"char"|"CHAR"|"Char"
FOR			"for"|"FOR"|"For"
WRITE		"write"|"WRITE"|"Write"
READ		"read"|"READ"|"Read"
DECVAR		"decvar"|"DECVAR"|"Decvar"
ENDDEC		"enddec"|"ENDDEC"|"Enddec"
AVG			"avg"|"AVG"|"Avg"
INLIST		"inlist"|"INLIST"|"Inlist"

%%

{CHAR_COMA}		{printf("Lexico --> Coma: %s\n", yytext); return CHAR_COMA;}
{CHAR_PUNTO}	{printf("Lexico --> Punto: %s\n", yytext); return CHAR_PUNTO;}
{CHAR_PUNCO}	{printf("Lexico --> Punto y coma: %s\n", yytext); return CHAR_PUNCO;}
{CHAR_DOSPU}	{printf("Lexico --> Dos puntos: %s\n", yytext); return CHAR_DOSPU;}

{COMENTARIO}    {printf("Lexico --> Comentario \n");}

{OP_SUM}		{printf("Lexico --> Suma: %s\n", yytext); return OP_SUM;}
{OP_ASIG}		{printf("Lexico --> Asignacion: %s\n", yytext); return OP_ASIG;}
{OP_MUL}		{printf("Lexico --> Multiplicacion: %s\n", yytext); return OP_MUL;}
{OP_RES}		{printf("Lexico --> Resta: %s\n", yytext); return OP_RES;}
{OP_DIV}		{printf("Lexico --> Division: %s\n", yytext); return OP_DIV;}
{OP_MAY}		{printf("Lexico --> Mayor: %s\n", yytext); return OP_MAY;}
{OP_MEN}		{printf("Lexico --> Menor: %s\n", yytext); return OP_MEN;}
{OP_MAIG}		{printf("Lexico --> Mayor igual: %s\n", yytext); return OP_MAIG;}
{OP_MEIG}		{printf("Lexico --> Menor igual: %s\n", yytext); return OP_MEIG;}
{OP_IGU}		{printf("Lexico --> Iguales: %s\n", yytext); return OP_IGU;}
{OP_NEG}		{printf("Lexico --> Negacion: %s\n", yytext); return OP_NEG;}
{OP_DIS}		{printf("Lexico --> Distinto: %s\n", yytext); return OP_DIS;}
{OP_DOPU}		{printf("Lexico --> Dos puntos: %s\n", yytext); return OP_DOPU;} // Consultar sobre este operador
{OP_AND}		{printf("Lexico --> And: %s\n", yytext); return OP_AND;}
{OP_OR}			{printf("Lexico --> Or: %s\n", yytext); return OP_OR;}

{PAR_A}			{printf("Lexico --> Parentesis abre: %s\n", yytext); return PAR_A;}
{PAR_C}			{printf("Lexico --> Parentesis cierra: %s\n", yytext); return PAR_C;}
{LLA_A}			{printf("Lexico --> Llave abre: %s\n", yytext); return LLA_A;}
{LLA_C}			{printf("Lexico --> Llave cierra: %s\n", yytext); return LLA_C;}
{COR_A}			{printf("Lexico --> Corchete abre: %s\n", yytext); return COR_A;}
{COR_C}			{printf("Lexico --> Corchete cierra: %s\n", yytext); return COR_C;}

{IF}			{printf("Lexico --> Palabra reservada IF: %s\n", yytext); return IF;}
{ELSE}			{printf("Lexico --> Palabra reservada ELSE: %s\n", yytext); return ELSE;}
{WHILE}			{printf("Lexico --> Palabra reservada WHILE: %s\n", yytext); return WHILE;}
{INT}			{printf("Lexico --> Palabra reservada INT: %s\n", yytext); return INT;}
{FLOAT}			{printf("Lexico --> Palabra reservada FLOAT: %s\n", yytext); return FLOAT;}
{CHAR}			{printf("Lexico --> Palabra reservada CHAR: %s\n", yytext); return CHAR;}
{FOR}			{printf("Lexico --> Palabra reservada FOR: %s\n", yytext); return FOR;}
{DECVAR}		{printf("Lexico --> Palabra reservada DECVAR: %s\n", yytext); return DECVAR;}
{ENDDEC}		{printf("Lexico --> Palabra reservada ENDDEC: %s\n", yytext); return ENDDEC;}

{WRITE}			{printf("Lexico --> Palabra reservada WRITE: %s\n", yytext); return WRITE;}
{READ}			{printf("Lexico --> Palabra reservada READ: %s\n", yytext); return READ;}

{AVG}			{printf("Lexico --> Palabra reservada AVG: %s\n", yytext); return AVG;}
{INLIST}		{printf("Lexico --> Palabra reservada INLIST: %s\n", yytext); return INLIST;}

{ID}			{if (strlen(yytext) > LIMIT_ID){
                        printf( "Lexico --> El nombre del identificador supera la cantidad maxima de caracters permitidos. Cantidad: %d\n", LIMIT_ID);
                       	exit(1);
                    }
				yylval = (int)strdup(yytext);
				cargar_simbolo(yytext, 0, 0);
				printf("Lexico --> Identificador: %s\n", yytext); return ID;}

{CTE_INTEGER}		{if (atof(yytext) > LIMIT_INT_SUP || atof(yytext) < LIMIT_INT_INF){
                        printf( "Lexico --> El entero supera los limites permitidos.\n");
                        exit(1);
					}
				strcpy(yytext_aux,"_");
				strcpy(yytext_aux+1,yytext);
				yylval = (int)strdup(yytext_aux);
				cargar_simbolo(yytext, 1, yytext);
				printf("Lexico --> Constante entera: %s\n", yytext); return CTE_INTEGER;}

{CTE_FLOAT}		{if (atof(yytext) > LIMIT_FLOAT_SUP || atof(yytext) < LIMIT_FLOAT_INF){
                        printf( "Lexico --> El real supera los limites permitidos. \n");
                        exit(1);
					}
				strcpy(yytext_aux,"_");
				strcpy(yytext_aux+1,yytext);
				yylval = (int)strdup(yytext_aux);
				cargar_simbolo(yytext, 2, yytext);
				printf("Lexico --> Constante flotante: %s\n", yytext); return CTE_FLOAT;}

{CTE_STRING}		{if (strlen(yytext) > LIMIT_STR){
                        printf( "Lexico --> El string ingresado supera la cantidad maxima permitida. Cantidad: %d\n", LIMIT_STR);
                       	exit(1); 
					}
				strcpy(yytext_aux,"_");
				strcpy(yytext_aux+1,yytext);
				yylval = (int)strdup(yytext_aux);
				cargar_simbolo(yytext, 3, yytext);
				printf("Lexico --> Constante char: %s\n", yytext); return CTE_STRING;}

"\n"      	{lineno++;}	
"\t"
"\n\t"		{lineno++;}
" "             		
"\r\n"		{lineno++;}
.			{printf( "Lexico --> ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}
"ñ"			{printf( "Lexico --> ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}
"Ñ"			{printf( "Lexico --> ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%

int main1 (int argc, char *argv[]){
	if((yyin = fopen(argv[1], "rt")) == NULL){
		printf("Lexico --> No se puede abrir el archivo: %s\n", argv[1]);
		exit(0);
	}

	printf("Lexico --> El archivo %s se abrio correctamente\n", argv[1]);
	yylex();

	printf("Lexico --> FLEX finalizo la lectura del archivo %s \n", argv[1]);

	fclose(yyin);

	return 0;
}

//Almacenar datos en tabla de simbolos
void cargar_simbolo(char* name, int type, char* val){
  	FILE *pf, *pf_aux;
	char strline[100], straux[100], valaux[33], subline[33], subaux[33];
	
	if (fopen("ts.txt","r") == NULL){
		pf = fopen("ts.txt", "wt");
        fputs("NOMBRE                           |TIPO      |VALOR                           |LONGITUD\n",pf);
	}
	else
        pf = fopen("ts.txt", "at");
	
	switch (type){
		case ID_TYPE:
			sprintf(straux, "%-33s|%-10s|%-32s|\n", name, "", "");
			break;
		case ENTERO:
			sprintf(straux, "_%-32s|%-10s|%-32s|\n", name, "int", val);
			break;
		case FLOTANTE:
			sprintf(straux, "_%-32s|%-10s|%-32s|\n", name, "float", val);
			break;
		case CARAC:
			strcpy(valaux,val+1);
      		valaux[strlen(valaux)-1] = '\0';
			sprintf(straux, "_%-32s|%-10s|%-32s|%-10d\n", name, "char", valaux, strlen(valaux));
			break;
	}

    pf_aux = fopen("ts.txt", "rt");

	//Lee toda la linea en busca de duplicados
    while(fgets(strline, 99, pf_aux) != NULL)
    {
		strncpy(subline,strline,33);
		subline[32] = '\0';

		strncpy(subaux,straux,33);
		subaux[32] = '\0';

        if(strcmp(subline, subaux) == 0)
        {
			fclose(pf);
            fclose(pf_aux);
            return;
        }
    }
    
    fputs(straux,pf);

    fclose(pf_aux);
    fclose(pf);
}