// Usa Lexico_ClasePractica
// Solo expresiones sin ()

%{
  
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

#define ENTERO 1
#define FLOTANTE 2
#define CARAC 3

struct t_pi{
  char elemento[33];
};

FILE  *yyin;

struct t_pi pi[1000];

char a_comp[3];
char b_comp[3];
char simbolo_aux[33];
char aux_salto[5];

int pila_pos_pi[10];
int pila_type[50];

int yystopparser = 0;
int p_pi = 0;
int p_pila_pos_pi = -1;
int p_pila_type = -1;
int cont_avg = 0;
int declarados = 0;

int yyerror();
int yylex();

void generar_archivo_cod_inter();
void generar_assembler();
void insertar(char*);
void apilar();
void desapilar_insertar(int);
void actualizar_tipo(char*);
void cargar_simbolo_aux(char*, int, char*);
void revisar_declarados(char*);
void buscar_type(char*);
void evaluar_type();
void comparar_type();
void apilar_type(int);

%}

%left OP_SUM OP_RES
%left OP_MUL OP_DIV
%right OP_ASIG

/*CARACTERES*/
%token DIGITO
%token DIG_C_NUL	
%token LETRA
%token ESPACIO
%token INI_COM
%token FIN_COM
%token GUIONES
%token CHAR_COMA
%token CHAR_PUNTO
%token CHAR_PUNCO
%token CHAR_DOSPU

/*DECLARACIONES*/
%token CTE_INTEGER
%token CTE_FLOAT
%token CTE_STRING
%token ID
%token CONTENIDO
%token COMENTARIO

/*OPERADORES*/
%token OP_ASIG
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV

/*COMPARADORES*/
%token OP_MAY
%token OP_MEN
%token OP_MAIG
%token OP_MEIG
%token OP_IGU
%token OP_NEG
%token OP_DIS
%token OP_DOPU
%token OP_AND
%token OP_OR

/*OTROS CARACTERES*/
%token LLA_A
%token LLA_C
%token PAR_A
%token PAR_C
%token COR_A
%token COR_C
%token FIN_SEN

/*PALABRAS RESERVADAS*/
%token IF
%token ELSE
%token WHILE
%token INT
%token FLOAT
%token CHAR
%token FOR
%token DECVAR
%token ENDDEC
%token WRITE
%token READ
%token AVG
%token INLIST

%%

/*REGLAS*/

programa_completo:  programa {generar_archivo_cod_inter(); printf("Sintactico --> FIN PARSING\n"); generar_assembler(); printf("Sintactico --> Compilacion OK\n");}

programa: sentencia | programa sentencia; 

sentencia:  asignacion | iteracion | seleccion | declaracion | entrada_salida;

asignacion: ID {insertar((char*)$1); buscar_type((char*)$1);} OP_ASIG expresion {insertar(":="); comparar_type(); printf("Sintactico --> ASIGNACION\n");};

iteracion:  WHILE {cargar_simbolo_aux("@salto_if", INT, ""); insertar("@salto_if"); apilar(); insertar(":="); insertar("WHILE_ET"); sprintf(aux_salto,"%d",p_pi);}
              PAR_A condicion PAR_C {insertar("CMP"); insertar(a_comp); insertar("@salto_if");}
              LLA_A programa LLA_C {insertar("BI"); desapilar_insertar(2); insertar(aux_salto); printf("Sintactico --> WHILE\n");};

seleccion:      seleccion_aux {desapilar_insertar(1); printf("Sintactico --> IF\n");}
                | seleccion_aux ELSE {insertar("BI"); desapilar_insertar(1); apilar();} LLA_A programa LLA_C {desapilar_insertar(0); printf("Sintactico --> IF ELSE\n");};

seleccion_aux:  IF {cargar_simbolo_aux("@salto_if", INT, ""); insertar("@salto_if"); apilar(); insertar(":=");}
                  PAR_A condicion PAR_C {insertar("CMP"); insertar(a_comp); insertar("@salto_if");} LLA_A programa LLA_C;

condicion:      condicion {insertar("CMP"); insertar(a_comp); insertar("@salto_if");} OP_AND comparacion {printf("Sintactico --> AND\n");}
                | condicion {insertar("CMP"); insertar(b_comp); apilar();} OP_OR comparacion {desapilar_insertar(4); printf("Sintactico --> OR\n");}
                | comparacion;

comparacion:    expresion comparador expresion {comparar_type();}
                | expresion_INLIST {strcpy(a_comp,"BNE"); strcpy(b_comp,"BEQ");};

comparador:     OP_MAIG   {strcpy(a_comp,"BLT"); strcpy(b_comp,"BGE");}
                | OP_MAY  {strcpy(a_comp,"BLE"); strcpy(b_comp,"BGT");}
                | OP_MEIG {strcpy(a_comp,"BGT"); strcpy(b_comp,"BLE");}
                | OP_MEN  {strcpy(a_comp,"BGE"); strcpy(b_comp,"BLT");}
                | OP_IGU  {strcpy(a_comp,"BNE"); strcpy(b_comp,"BEQ");}
                | OP_DIS  {strcpy(a_comp,"BEQ"); strcpy(b_comp,"BNE");};

declaracion:        DECVAR lista_declaracion ENDDEC {printf("Sintactico --> DECLARACION\n");};

lista_declaracion:  lista_declaracion lista_id CHAR_DOSPU tipo | lista_id CHAR_DOSPU tipo;

lista_id:           lista_id CHAR_COMA ID {revisar_declarados((char*)$3);}
                    | ID {revisar_declarados((char*)$1);};

tipo:               INT     {actualizar_tipo("int");}
                    | FLOAT {actualizar_tipo("float");}
                    | CHAR  {actualizar_tipo("char");};

entrada_salida: READ {insertar("READ_ETIQ");} entrada_salida_aux {printf("Sintactico --> READ ID\n");}
                | WRITE {insertar("WRITE_ETIQ");} entrada_salida_aux {printf("Sintactico --> WRITE ID\n");};

entrada_salida_aux: ID {insertar((char*)$1);}
                    | CTE_STRING {insertar((char*)$1);};

expresion_AVG:        AVG {cont_avg=0; } PAR_A COR_A lista_expresion_avg COR_C PAR_C {simbolo_aux[0] = '_'; sprintf(simbolo_aux+1,"%d",cont_avg); 
                        cargar_simbolo_aux(simbolo_aux, INT, simbolo_aux+1); apilar_type(ENTERO); insertar(simbolo_aux); insertar("/"); evaluar_type();};

lista_expresion_avg:  lista_expresion_avg CHAR_COMA expresion {insertar("+"); evaluar_type(); cont_avg++;}
                      | expresion {cont_avg++;};

expresion_INLIST: INLIST {cargar_simbolo_aux("@salto_in", INT, ""); insertar("@salto_in"); apilar(); insertar(":="); cargar_simbolo_aux("@aux_inlist", FLOAT, ""); apilar_type(FLOTANTE); 
                    insertar("@aux_inlist");} PAR_A id_aux_inlist {insertar(":="); comparar_type(); apilar_type(FLOTANTE); insertar("@aux_inlisted");} CHAR_PUNCO 
                    COR_A lista_expresion_inlist COR_C PAR_C {desapilar_insertar(1); insertar("@aux_inlist"); insertar("@aux_inlisted"); strcpy(a_comp,"BNE"); 
                    strcpy(b_comp,"BEQ"); printf("Sintactico --> INLIST\n");};

lista_expresion_inlist: lista_expresion_inlist CHAR_PUNCO {cargar_simbolo_aux("@aux_inlisted", FLOAT, ""); apilar_type(FLOTANTE); insertar("@aux_inlisted");} expresion 
                          {insertar(":="); comparar_type(); insertar("@aux_inlist"); insertar("@aux_inlisted"); insertar("CMP"); insertar("BEQ"); insertar("@salto_in"); 
                          printf("Sintactico --> AVG\n");}
                        | expresion {insertar(":="); comparar_type(); insertar("@aux_inlist"); insertar("@aux_inlisted"); insertar("CMP"); insertar("BEQ");
                          insertar("@salto_in"); printf("Sintactico --> AVG\n");};

id_aux_inlist: ID {insertar((char*)$1); buscar_type((char*)$1);};

expresion:  expresion OP_SUM termino {insertar("+"); evaluar_type(); printf("Sintactico --> SUMA\n");}
            | expresion OP_RES termino {insertar("-"); evaluar_type(); printf("Sintactico --> RESTA\n");}
            | expresion_AVG
            | termino;

termino:    termino OP_MUL factor {insertar("*"); evaluar_type(); printf("Sintactico --> MULTIPLICACION\n");}
            | termino OP_DIV factor {insertar("/"); evaluar_type(); printf("Sintactico --> DIVISION\n");}
            | factor;

factor:     PAR_A expresion PAR_C 
            | ID          {insertar((char*)$1); buscar_type((char*)$1);}
            | CTE_STRING  {insertar((char*)$1); apilar_type(CARAC);}
            | CTE_FLOAT   {insertar((char*)$1); apilar_type(FLOTANTE);}
            | CTE_INTEGER {insertar((char*)$1); apilar_type(ENTERO);};

%%

int main(int argc, char *argv[]){
  if((yyin = fopen(argv[1], "rt"))==NULL)
  {
    printf("Sintactico --> No se puede abrir el archivo de prueba: %s\n", argv[1]);
  }
  else
  { 
    yyparse();

    printf("Sintactico --> BISON finalizo la lectura del archivo %s \n", argv[1]);
  }

	fclose(yyin);

  return 0;
}

void generar_archivo_cod_inter(){
  FILE *pf;
  int i = 0;
	
  pf = fopen("intermedia.txt", "wt");

  while(strlen(pi[i].elemento) != 0){
    fputs(pi[i++].elemento,pf);
    fputs("\n",pf);
  }

  fclose(pf);
}

//Genera el codigo assembler
void generar_assembler(){
  struct t_pi assem[1000];
  int p_assem = 0, p_pi_aux = 0, free = 1, elem_type, i, fetch;
  char strline[100], ts_line[100], elemento[33], name[33], val[33], type[10];
  FILE *pf, *pf_ts;

  printf("Inicio generacion de Codigo Assembler\n");

  pf = fopen("assembler.asm", "wt");
  pf_ts = fopen("ts.txt", "rt");

  //Agregando Headers y include de funciones macro
  fputs("include macros2.asm\n",pf);
  fputs("include number.asm\n",pf);

  fputs("\n.MODEL LARGE\n",pf);
  fputs(".386\n",pf);
  fputs(".STACK 200h\n\n",pf);

  //Carga de tabla de simbolos
  fgets(ts_line, 99, pf_ts); //Salteo cabecera

  while(fgets(ts_line, 99, pf_ts) != NULL){
    strncpy(name,ts_line,33);
		name[32] = '\0';

    if(name[0] != '_'){
      strncpy(type,&ts_line[34],10);
      type[10] = '\0';

      strncpy(val,&ts_line[45],33);
      val[32] = '\0';

      if(strstr(type,"char"))
        sprintf(strline,"%s %s %s\n",name,"db",val);
      else
        sprintf(strline,"%s %s %s\n",name,"dd",val);

      fputs(strline,pf);
    }
  }

  fputs("\n.CODE\n",pf);
  fputs("mov AX,@DATA\n",pf);
  fputs("mov DS,AX\n",pf);
  fputs("mov ES,AX\n\n",pf);

  for(i = 0; i < p_pi; i++){
    fetch = 0;

    //Recupera el elemento actual de la PI
    strcpy(elemento,pi[p_pi_aux++].elemento);

    //Copia el elemento recuperado en la pila de assembler
    fseek(pf_ts, 0, SEEK_SET);

    while(fgets(ts_line, 99, pf_ts) != NULL && !fetch){
      strncpy(name,ts_line,33);
	    name[32] = '\0';

      if(strstr(name, elemento))
      {
        //Si es una constante, cargar su valor desde ts
        if(elemento[0] == '_'){
          strncpy(val,&ts_line[45],33);
          val[31] = '\0'; //Resivar si hay otra solucion para esto

          sprintf(assem[p_assem++].elemento,"%s\n",val);
        }
        else{ //Si no es constante, recupero su tipo
          sprintf(assem[p_assem++].elemento,"%s\n",elemento);

          strncpy(type,&ts_line[34],10);
          type[10] = '\0';

          if(strstr(type,"char")){
            elem_type = CARAC;
          }
          else if(strstr(type,"int")){
            elem_type = ENTERO;
          }
          else{
            elem_type = FLOAT;
          }
        }

        fetch = 1;
      }
    }

    //printf("elemento: %s\n",elemento);

    //Asignacion
    if(strcmp(elemento,":=") == 0){
      if(free){
        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        p_assem--;
      }

      sprintf(strline,"FSTP %s",&assem[p_assem-1]);
      fputs(strline,pf);

      sprintf(strline,"FFREE\n\n");
      fputs(strline,pf);
      free = 1;

      p_assem--;
    }

    //Suma
    if(strcmp(elemento,"+") == 0){
      if(free){
        sprintf(strline,"FLD %s",&assem[p_assem-2]);
        fputs(strline,pf);

        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        p_assem -= 2;
        free = 0;
      }
      else
      {
        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        sprintf(strline,"FXCH\n");//intercambia registro 1 y 0
        fputs(strline,pf);

        p_assem--;
      }
      
      sprintf(strline,"FADD\n");//registro 1 = 1 + 0
      fputs(strline,pf);
    }

    //Resta
    if(strcmp(elemento,"-") == 0){
      if(free){
        sprintf(strline,"FLD %s",&assem[p_assem-2]);
        fputs(strline,pf);

        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        p_assem -= 2;
        free = 0;
      }
      else
      {
        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        sprintf(strline,"FXCH\n");//intercambia registro 1 y 0
        fputs(strline,pf);

        p_assem--;
      }
      
      sprintf(strline,"FSUB\n");//registro 1 = 1 + 0
      fputs(strline,pf);
    }

    //Multiplicacion
    if(strcmp(elemento,"*") == 0){
      if(free){
        sprintf(strline,"FLD %s",&assem[p_assem-2]);
        fputs(strline,pf);

        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        p_assem -= 2;
        free = 0;
      }
      else
      {
        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        sprintf(strline,"FXCH\n");//intercambia registro 1 y 0
        fputs(strline,pf);

        p_assem--;
      }
      
      sprintf(strline,"FMUL\n");//registro 1 = 1 + 0
      fputs(strline,pf);
    }

    //Division (revisar dividido 0)
    if(strcmp(elemento,"/") == 0){
      if(free){
        sprintf(strline,"FLD %s",&assem[p_assem-2]);
        fputs(strline,pf);

        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        p_assem -= 2;
        free = 0;
      }
      else
      {
        sprintf(strline,"FLD %s",&assem[p_assem-1]);
        fputs(strline,pf);

        sprintf(strline,"FXCH\n");//intercambia registro 1 y 0
        fputs(strline,pf);

        p_assem--;
      }
      
      sprintf(strline,"FDIV\n");//registro 1 = 1 + 0
      fputs(strline,pf);
    }

    //Comparacion
    if(strcmp(elemento,"CMP") == 0){
      //
    }

    //Write
    if(strcmp(elemento,"WRITE_ETIQ") == 0){
      
      switch(elem_type){
        case ENTERO:
          sprintf(strline,"DisplayInteger %s",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
        case FLOTANTE:
          sprintf(strline,"DisplayFloat %s.2",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
        case CARAC:
          sprintf(strline,"DisplayString %s",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
      }
    }

    //Read
    if(strcmp(elemento,"READ_ETIQ") == 0){

      switch(elem_type){
        case ENTERO:
          sprintf(strline,"GetInteger %s",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
        case FLOTANTE:
          sprintf(strline,"GetFloat %s.2",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
        case CARAC:
          sprintf(strline,"GetString %s",&assem[p_assem-1]);
          fputs(strline,pf);

          sprintf(strline,"FFREE\n\n");
          fputs(strline,pf);

          break;
      }
    }
  }

  //Hardcode fin de programa assembler
  fputs("mov ax,4c00h\n",pf);
  fputs("int 21h\n",pf);
  fputs("End\n",pf);

  printf("Generacion de Codigo Assembler terminada -> OK\n");

  fclose(pf);
  fclose(pf_ts);
}

//Inserta un elemento en la PI
void insertar(char* elemento){
  sprintf(pi[p_pi++].elemento,"%s",elemento);
}

//Apila un numero de posicion de la PI y avanza 1 posicion
void apilar(){
  pila_pos_pi[++p_pila_pos_pi] = p_pi++;
}

//Desapila e inserta en la posicion recibida de PI
void desapilar_insertar(int offset){
  int pos;
  char aux[5];

  pos = pila_pos_pi[p_pila_pos_pi];
  p_pila_pos_pi--;

  sprintf(aux,"%d",p_pi+offset);
  sprintf(pi[pos].elemento,"%s",aux);
}

//Inserta el type del ultimo ID registrado
void actualizar_tipo(char* type){
	FILE *pf;
	char strline[100];
  
  pf = fopen("ts.txt", "r+");

  while(declarados != 0){
    fseek(pf, -80*declarados, SEEK_END);
    fgets(strline, 99, pf);

    if(strline[34] != ' '){
      printf("Sintactico --> Variable ya declarada\n", strline);
	    exit (1);
    }

    sprintf((strline+34),"%-10s|%-32s|",type,"");

    fseek(pf, -80*declarados, SEEK_END);
    fputs(strline,pf);

    declarados--;
  }

  fclose(pf);
}

//Almacenar datos en tabla de simbolos
void cargar_simbolo_aux(char* name, int type, char* val){
  FILE *pf, *pf_aux;
	char strline[100], straux[100], valaux[33], subline[33], subaux[33];

	if (fopen("ts.txt","r") == NULL){
		pf = fopen("ts.txt", "wt");

    fputs("NOMBRE                           |TIPO      |VALOR                           |LONGITUD\n",pf);
	}
	else
    pf = fopen("ts.txt", "at");

	switch (type){
		case INT:
			sprintf(straux, "%-33s|%-10s|%-32s|\n", name, "int", val);
			break;
		case FLOAT:
			sprintf(straux, "%-33s|%-10s|%-32s|\n", name, "float", val);
			break;
		case CHAR:
			strcpy(valaux,val+1);
      valaux[strlen(valaux)-1] = '\0';
			sprintf(straux, "%-33s|%-10s|%-32s|%-10d\n", name, "char", valaux, strlen(valaux));
			break;
	}

  pf_aux = fopen("ts.txt", "rt");

	//Leo toda la linea en busca de duplicados
  while(fgets(strline, 99, pf_aux) != NULL){
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

//Revisa que el elemento declarado no este declarado antes, y aumenta los declarados si no lo encuentra
void revisar_declarados(char* name){
  FILE *pf;
	char strline[100], subline[33];

  pf = fopen("ts.txt", "rt");

  while(fgets(strline, 99, pf) != NULL){
    strncpy(subline,strline,33);
    subline[strlen(name)] = '\0';

    if(strcmp(subline, name) == 0 && strline[34] != ' '){
      printf("Sintactico --> Variable ya declarada: %s\n", name);

      fclose(pf);
      exit(1);
    }
  }
    
  declarados++;
  fclose(pf);
}

//Busca el tipo del ID correspondiente a la operacion y lo apila
void buscar_type(char* name){
  FILE *pf;
	char strline[100], subline[33];

  pf = fopen("ts.txt", "rt");

  while(fgets(strline, 99, pf) != NULL){
    strncpy(subline,strline,33);
    subline[strlen(name)] = '\0';

    if(strcmp(subline, name) == 0){
      strncpy(subline,strline+34,7);
      subline[6] = '\0';
      
      if(strstr(subline,"int")){
        apilar_type(ENTERO);

        fclose(pf);
        return;
      }
      
      if(strstr(subline,"float")){
        apilar_type(FLOTANTE);

        fclose(pf);
        return;
      }

      if(strstr(subline,"char")){
        apilar_type(CARAC);

        fclose(pf);
        return;
      }
    }
  }

  fclose(pf);
  yyerror();
}

//Remplaza dos tipos apilados con el tipo resultado de operar sobre ellos, siempre que sea valido
void evaluar_type(){
  int a_type, b_type;

  b_type = pila_type[p_pila_type--];
  a_type = pila_type[p_pila_type--];

  switch(a_type){
    case ENTERO:
    switch(b_type){
      case ENTERO:
        apilar_type(ENTERO);
        return;
      break;
      case FLOTANTE:
        apilar_type(FLOTANTE);
        return;
      break;
      case CARAC:
        printf("Sintactico --> Tipos de dato no compatibles\n");
        exit(1);
      break;
    }
    break;
    case FLOTANTE:
    switch(b_type){
      case ENTERO:
        apilar_type(FLOTANTE);
        return;
      break;
      case FLOTANTE:
        apilar_type(FLOTANTE);
        return;
      break;
      case CARAC:
        printf("Sintactico --> Tipos de dato no compatibles\n");
        exit(1);
      break;
    }
    break;
    case CARAC:
    switch(b_type){
      case ENTERO:
        printf("Sintactico --> Tipos de dato no compatibles\n");
        exit(1);
      break;
      case FLOTANTE:
        printf("Sintactico --> Tipos de dato no compatibles\n");
        exit(1);
      break;
      case CARAC:
        apilar_type(CARAC);
        return;
      break;
    }
    break;
  }
}

//Compara los dos ultimos tipos apilados y reinicia la pila de tipos
void comparar_type(){
  int a_type, b_type;

  b_type = pila_type[p_pila_type--];
  a_type = pila_type[p_pila_type--];

  if(a_type == CARAC && b_type != CARAC){
    printf("Sintactico --> Tipos de dato no compatibles\n");
    exit(1);
  }

  if(a_type == ENTERO && b_type != ENTERO){
    printf("Sintactico --> Tipos de dato no compatibles\n");
    exit(1);
  }

  if(a_type == FLOTANTE && b_type == CARAC){
    printf("Sintactico --> Tipos de dato no compatibles\n");
    exit(1);
  }
}

//Apila el tipo recibido
void apilar_type(int type){
  pila_type[++p_pila_type] = type;
}

int yyerror(void){
  printf("Sintactico --> Error Sintactico\n");
	exit (1);
}
