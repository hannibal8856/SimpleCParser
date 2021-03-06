/* ===== Definition Section ===== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int linenumber = 1;
%}


%token ID
%token CONST
%token VOID    
%token INT     
%token FLOAT   
%token IF      
%token ELSE    
%token WHILE   
%token FOR
%token TYPEDEF
%token OP_ASSIGN  
%token OP_OR   
%token OP_AND  
%token OP_NOT  
%token OP_EQ   
%token OP_NE   
%token OP_GT   
%token OP_LT   
%token OP_GE   
%token OP_LE   
%token OP_PLUS 
%token OP_MINUS        
%token OP_TIMES        
%token OP_DIVIDE       
%token MK_LB 
%token MK_RB 
%token MK_LPAREN       
%token MK_RPAREN       
%token MK_LBRACE       
%token MK_RBRACE       
%token MK_COMMA        
%token MK_SEMICOLON    
%token MK_DOT  
%token ERROR
%token RETURN

%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: decl_list function_decl
		| function_decl
		;

function_decl	: type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE 

		| VOID ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE

		| type ID MK_LPAREN  MK_RPAREN MK_LBRACE block MK_RBRACE


		| VOID ID MK_LPAREN  MK_RPAREN MK_LBRACE block MK_RBRACE
		;

param_list	: param_list MK_COMMA  param
		| param	
		;

param		: type ID		
		| type ID dim_fn
		;
dim_fn		:MK_LB expr_null MK_RB dimfn1
		;
dimfn1		:MK_LB expr MK_RB dimfn1
		|
		;
expr_null	:expr
		|
		;

block           : decl_list stmt_list
                | stmt_list
                | decl_list
                |
                ;
 
decl_list	: decl_list decl
		| decl
		;

decl	: type_decl 
		| var_decl
		;

type_decl 	: TYPEDEF type id_list MK_SEMICOLON
		| TYPEDEF VOID id_list MK_SEMICOLON
		;

var_decl	: type init_id_list MK_SEMICOLON
		| ID id_list MK_SEMICOLON
		;

type	: INT
		| FLOAT
		;
	
id_list		: ID
		| id_list MK_COMMA ID
		| id_list MK_COMMA ID dim_decl
		| ID dim_decl
		;
dim_decl	: MK_LB cexpr MK_RB 
		| dim_decl MK_LB cexpr MK_RB 
		;
cexpr		: cexpr OP_PLUS mcexpr
		| cexpr OP_MINUS mcexpr
		| mcexpr
		;  
mcexpr		: mcexpr OP_TIMES cfactor 
		| mcexpr OP_DIVIDE cfactor  
		| cfactor 
		;
cfactor:	CONST
		|MK_LPAREN cexpr MK_RPAREN
		;

init_id_list	: init_id
		| init_id_list MK_COMMA init_id
		;

init_id		: ID
		| ID dim_decl
		| ID OP_ASSIGN relop_expr
		;

stmt_list	: stmt_list stmt
		| stmt
		;

stmt		: MK_LBRACE block MK_RBRACE
		| WHILE MK_LPAREN test MK_RPAREN stmt
	        | FOR MK_LPAREN assign_expr_list MK_SEMICOLON relop_expr_list MK_SEMICOLON assign_expr_list MK_RPAREN stmt 
		| var_ref OP_ASSIGN relop_expr MK_SEMICOLON
		| IF MK_LPAREN test MK_RPAREN stmt
		| IF MK_LPAREN test MK_RPAREN stmt ELSE stmt
		| ID MK_LPAREN relop_expr_list MK_RPAREN MK_SEMICOLON
		| MK_SEMICOLON
		| RETURN MK_SEMICOLON
		| RETURN relop_expr MK_SEMICOLON
		;

assign_expr_list : nonempty_assign_expr_list
                |
                ;

nonempty_assign_expr_list        : nonempty_assign_expr_list MK_COMMA assign_expr
                | assign_expr
				;

test			: assign_expr
				;

assign_expr     : ID OP_ASSIGN relop_expr
                | relop_expr


relop_expr	: relop_term
		| relop_expr OP_OR relop_term
		;

relop_term	: relop_factor
		| relop_term OP_AND relop_factor
		;

relop_factor	: expr
		| expr rel_op expr
		;

rel_op		: OP_EQ
		| OP_GE
		| OP_LE
		| OP_NE
		| OP_GT
		| OP_LT
		;

relop_expr_list	: nonempty_relop_expr_list 
		| 
		;

nonempty_relop_expr_list	: nonempty_relop_expr_list MK_COMMA relop_expr
		| relop_expr
		;

expr		: expr add_op term
		| term
		;

add_op		: OP_PLUS
		| OP_MINUS
		;

term		: term mul_op factor
		| factor 
		;

mul_op		: OP_TIMES
		| OP_DIVIDE
		;

factor		: MK_LPAREN relop_expr MK_RPAREN
		| OP_MINUS MK_LPAREN relop_expr MK_RPAREN
		| OP_NOT MK_LPAREN relop_expr MK_RPAREN
		| CONST
		| OP_MINUS CONST
		| OP_NOT CONST
		| ID MK_LPAREN relop_expr_list MK_RPAREN
		| OP_MINUS ID MK_LPAREN relop_expr_list MK_RPAREN
		| OP_NOT ID MK_LPAREN relop_expr_list MK_RPAREN
		| var_ref 
		| OP_MINUS var_ref
		| OP_NOT var_ref
		;

var_ref		: ID
		|var_ref dim
		;


dim		: MK_LB expr MK_RB
		;


%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
     yyin = fopen(argv[1],"r");
     yyparse();
	 printf("%s\n", "Parsing completed. No errors found.");
  } /* main */


int yyerror (mesg)
char *mesg;
  {
  printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  exit(1);
  }


