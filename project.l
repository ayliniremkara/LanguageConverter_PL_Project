letter	[A-Za-z]
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int linenumber=1;
int tabcount = 1;
%}
%%
int return INT;

(([-]?[0-9]+)|([0-9]+))	{yylval.str = strdup(yytext); return NUMBER;}
if                   {yylval.str = strdup(yytext);return IF;}
else  {yylval.str = strdup(yytext);return ELSE;}
elif  {yylval.str = strdup(yytext);return ELIF;}
\+|\-|\*|\/	{yylval.str = strdup(yytext); return MATHOP;}
\( {yylval.str = strdup(yytext);return OPENPAR;}
\) {yylval.str = strdup(yytext);return CLOSEPAR;}
">"|"!="|"=="|"<"|"<="|">=" {yylval.str = strdup(yytext); return CONDOP;}
\=   {yylval.str = strdup(yytext);return ASSIGNOP; }
\,   {yylval.str = strdup(yytext);return COMMA; }
\;   {yylval.str = strdup(yytext);return SEMICOLON; }
\:   {yylval.str = strdup(yytext);return COLON; }
\n	linenumber++;
\"  {yylval.str = strdup(yytext);return QUOTE; }
\t {yylval.str = strdup(yytext);return TAB; tabcount++; }
[a-zA-Z][0-9a-zA-Z]*	{yylval.str = strdup(yytext); return VARIABLE;}
([0-9]+\.[0-9]+)	{yylval.str = strdup(yytext); return FLOAT;}
\"(\\.|[^"\\])*\"  {yylval.str = strdup(yytext);return STRING;}

%%

/*use the line below to show what will happen if strdup is not used
[a-z]([a-z]|[0-9])*	{yylval.str =yytext; return VARIABLE;}

*/
