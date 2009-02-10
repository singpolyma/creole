%{
#include <stdio.h>
#include <string.h>
#define START(tag)  {printf("<%s>", #tag); tag = 1;}
#define END(tag)    {printf("</%s>", #tag); tag = 0;}
#define MESCP(code) {if(escaped) {ECHO; escaped = 0;} else {if(nowiki) {ECHO;} else {code}}}
int strong = 0;
int em = 0;
int escaped = 0;
int nowiki = 0;
int heading = 0;
int ul = 0;
int ult = 0;
int ol = 0;
int olt = 0;
char * t = NULL;
char c;
int i;
/* ECHO should be made to escape <>& */
%}

%%

~                             {if(escaped) {printf("~"); escaped = 0;} else {escaped = 1;}}
^\{\{\{                       {nowiki = 2;}
\{\{\{                        {nowiki = 1;}
^\}\}\}$                      {nowiki = 0;}
\}\}\}                        {if(nowiki == 2) {ECHO;} else {nowiki = 0;}}
\[\[[^\]]+\]\]                {MESCP((*strchr(yytext,']'))='\0'; if((t=strchr(yytext,'|'))) {*t = '\0'; t++;} else {t = yytext+2;} printf("<a href=\"%s\">%s</a>",yytext+2,t););}
(https|http|ftp):\/\/[^ \r\n\t<>\(\)]+  {MESCP(c = yytext[strlen(yytext)-1]; if(c == '.' || c == ',' || c == ':' || c == ';' || c == '"' || c == '\'' || c == '!' || c == '?') {yytext[strlen(yytext)-1] = '\0';} else {c = 0;} printf("<a href=\"%s\">%s</a>",yytext,yytext); if(c) {printf("%c",c);});}
^[ \t]*----[ \t]*$            {MESCP(printf("<hr />"););}
^[ \t]*[\*]+                  {MESCP(yytext += strspn(yytext," \t"); ult = strlen(yytext); if(ult == 2 && !ul && !ol) {START(strong);}
                               if(ul || ol) {for(i = 0; i < ul; i++) {printf("\t");} printf("</li>\n");}
                               if(ul < ult && (ul||ol)) {for(i = 0; i < ult-1; i++) {printf("\t");} printf("<li>\n");}
                               if(ul > ult) {for(i = 0; i < ul-1; i++) {printf("\t");} printf("</ul>\n"); for(i = 0; i < ul-1; i++) {printf("\t");} printf("</li>\n");}
                               if(ul < ult) {for(i = 0; i < ult-1; i++) {printf("\t");} printf("<ul>\n");}
                               for(i = 0; i < ult; i++) {printf("\t");} printf("<li>");
                               ul = ult;);}
^[ \t]*[#]+                    {MESCP(yytext += strspn(yytext," \t"); olt = strlen(yytext);
                               if(ol || ul) {for(i = 0; i < ol; i++) {printf("\t");} printf("</li>\n");}
                               if(ol < olt && (ol||ul)) {for(i = 0; i < olt-1; i++) {printf("\t");} printf("<li>\n");}
                               if(ol > olt) {for(i = 0; i < ol-1; i++) {printf("\t");} printf("</ol>\n"); for(i = 0; i < ol-1; i++) {printf("\t");} printf("</li>\n");}
                               if(ol < olt) {for(i = 0; i < olt-1; i++) {printf("\t");} printf("<ol>\n");}
                               for(i = 0; i < olt; i++) {printf("\t");} printf("<li>");
                               ol = olt;);}
\*\*                          {MESCP(if(strong) {END(strong);} else {START(strong);});}
\/\/                          {MESCP(if(em) {END(em);} else {START(em);});}
\\\\                          {MESCP(printf("<br />"););}
\|=                           {ECHO;} /* TODO */
[=]+                          {MESCP(if(heading) {printf("</h%d>", heading); heading = 0;} else {heading = strlen(yytext); printf("<h%d>", heading);});}
\n                            {if(heading) {printf("</h%d>", heading); heading = 0;} ECHO;}
\n\n                          {if(strong) {END(strong);} if(em) {END(em);} if(heading) {printf("</h%d>", heading); heading = 0;} 
                               if(ul) {for(i = 0; i < ul; i++) {printf("\t");} printf("</li>\n");}
                               while(ul > 0) {for(i = 0; i < ul-1; i++) {printf("\t");} printf("</ul>\n"); if(ul > 1) {for(i = 0; i < ul-1; i++) {printf("\t");} printf("</li>\n");} ul--;}
                               if(ol) {for(i = 0; i < ol; i++) {printf("\t");} printf("</li>\n");}
                               while(ol > 0) {for(i = 0; i < ol-1; i++) {printf("\t");} printf("</ol>\n"); if(ol > 1) {for(i = 0; i < ol-1; i++) {printf("\t");} printf("</li>\n");} ol--;}
                               ECHO;} /* Eventually add <p> support */
<<EOF>>                       {if(strong) {END(strong);} if(em) {END(em);} if(heading) {printf("</h%d>", heading); heading = 0;}
                               if(ul) {for(i = 0; i < ul; i++) {printf("\t");} printf("</li>\n");}
                               while(ul > 0) {for(i = 0; i < ul-1; i++) {printf("\t");} printf("</ul>\n"); if(ul > 1) {for(i = 0; i < ul-1; i++) {printf("\t");} printf("</li>\n");} ul--;}
                               if(ol) {for(i = 0; i < ol; i++) {printf("\t");} printf("</li>\n");}
                               while(ol > 0) {for(i = 0; i < ol-1; i++) {printf("\t");} printf("</ol>\n"); if(ol > 1) {for(i = 0; i < ol-1; i++) {printf("\t");} printf("</li>\n");} ol--;}
                               printf("\n"); exit(0);} /* Eventually add <p> support */
.                             {ECHO; escaped = 0;}

%%

int yywrap() {return 1;}
int yyerror(char * err) {fprintf(stderr, "%s\n", err);}

int main() {
	return yylex();
}
