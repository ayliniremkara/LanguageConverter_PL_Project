%{
	#include <stdio.h>
	#include <iostream>
	#include <string.h>
	#include <map>
	#include <unordered_set>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	
	extern int linenumber, tabcount;

	std::map<std::string, std::string> mySet;
	std::map<std::string, std::string> myIntSet;
	std::map<std::string, std::string> myStrSet;
	std::map<std::string, std::string> myFltSet;
	

    
%}

%union
{
	int number;
	char * str;
}

%token <str> TAB QUOTE VARIABLE MATHOP NUMBER FLOAT STRING CONDOP IF ELSE ELIF OPENPAR CLOSEPAR  ASSIGNOP COMMA SEMICOLON COLON INT
%type <str>  tab if elif else value expression assignment statement program conditional comparison

%%

start:
	program
	{	
		cout<<"void main()"<<endl<<"{"<<endl;
		if(!myIntSet.empty()){
			cout<<"\t";
			cout<<"int ";
			for (auto it = myIntSet.begin(); it != myIntSet.end(); ++it) {
				if (it != myIntSet.begin()) {
				std::cout << ",";
				}
				
				cout<< it->second;
			}
			cout<<";"<<endl;
		}

		if(!myFltSet.empty()){
			cout<<"\t";
			cout<<"float ";
			for (auto it = myFltSet.begin(); it != myFltSet.end(); ++it) {
				if (it != myFltSet.begin()) {
				std::cout << ",";
				}
				cout<< it->second;
			}
			cout<<";"<<endl;
		}

		if(!myStrSet.empty()) {
			cout<<"\t";
			cout<<"string ";
			for (auto it = myStrSet.begin(); it != myStrSet.end(); ++it) {
				if (it != myStrSet.begin()) {
				std::cout << ",";
				}
				cout<< it->second;
			}
			cout<<";"<<endl;

		}
		cout<<"\n";
		cout<<$1;
		cout<<"}"<<endl;
	}
	
program:
	statement
	{	
		string combined;
		for (int i = 0; i < tabcount;i++){
			combined = combined+ "\t";
		}
		combined = combined + string($1);
		$$=strdup(combined.c_str());
		
	}
	|
	statement program
	{
		string combined;
		for (int i = 0; i < tabcount;i++){
			combined = combined+ "\t";
		}
		combined = combined + string($1)+string($2);
		$$=strdup(combined.c_str());
	}
    ;

statement:
	assignment
	{
		string combined=string($1)+"\n";
		$$=strdup(combined.c_str());
	}
    |
    conditional
    {
		string combined=string($1)+"\n";
		$$=strdup(combined.c_str());
    }
	;

conditional:
	if
	{
		$$ = strdup($1);
	}
    |
    if elif 
    {
		
		string combined=string($1)+string($2);
		$$=strdup(combined.c_str());
	}
    |
    if else conditional
    {
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
    |
    if elif else
    {
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
	|
	if else 
    {
		string combined=string($1)+string($2);
		$$=strdup(combined.c_str());
	}
    ;

tab:
	TAB
	{
		string combined="\t"+string($1);
		$$=strdup(combined.c_str());
	}
	|
	TAB tab
	{
		string combined="\t"+string($1)+string($2);
		$$=strdup(combined.c_str());
	}
	;

if:
    IF comparison COLON tab program
    {
		string tabs;
		for (int i = 0; i < tabcount;i++){
			tabs = tabs + "\t";
		}
		string combined=string($1)+"( "+string($2)+" )"+"\n\t"+"{\n"+tabs+string($5)+tabs+"}";
		$$=strdup(combined.c_str());
    }
	|
	IF comparison COLON tab if
    {
		string tabs;
		for (int i = 0; i < tabcount;i++){
			tabs = tabs + "\t";
		}
		string combined=string($1)+"( "+string($2)+" )"+"\n\t"+"{\n"+tabs+string($5)+tabs+"}";
		$$=strdup(combined.c_str());
    }
    ;


elif:
	ELIF comparison COLON tab program
	{
		string tabs;
		for (int i = 0; i < tabcount;i++){
			tabs = tabs + "\t";
		}
		string combined="else if ( "+string($2)+" )\n\t"+"{\n"+tabs+string($5)+tabs+"}";
		$$=strdup(combined.c_str());
	}
	|
	ELIF comparison COLON tab conditional
	{
		string tabs;
		for (int i = 0; i < tabcount;i++){
			tabs = tabs + "\t";
		}
		string combined="else if ( "+string($2)+" )"+"\n\t"+"{\n"+tabs+string($5)+tabs+"}";
		$$=strdup(combined.c_str());
	}
	;

else:
	ELSE COLON tab program
	{
		string tabs;
		for (int i = 0; i < tabcount;i++){
			tabs = tabs + "\t";
		}
		string combined=string($1)+"\n\t"+"{"+"\n"+tabs+string($4)+tabs+"}";
		$$=strdup(combined.c_str());
	}
	;

comparison:
	VARIABLE CONDOP VARIABLE
	{
		string valWithType1 = mySet[string($1)];
		string valWithType2 = mySet[string($3)];
		string combined=valWithType1+" "+string($2)+" "+valWithType2;
		

		for (auto& it : myStrSet) {
				if ((it.second == valWithType1) || (it.second == valWithType2)) {
						cout<<"comparison type inconsistency in line"<<linenumber<<endl;
						exit(1);
				}
		}
		$$=strdup(combined.c_str());
	}
	;


assignment:
	VARIABLE ASSIGNOP expression
	{

		string val;
		val = string($1)+"_flt"; 
		mySet.insert(std::make_pair(string($1), val));
		myFltSet.insert(std::make_pair(string($1), val));
		string combined=val+" = "+string($3)+";";
		$$=strdup(combined.c_str());
	}
	|
	VARIABLE ASSIGNOP FLOAT
	{
		string val = string($1)+"_flt"; 
		mySet.insert(std::make_pair(string($1), val));
		myFltSet.insert(std::make_pair(string($1), val));
		string combined = val+" = "+string($3)+";";
		$$=strdup(combined.c_str());
	}
	|
	
	VARIABLE ASSIGNOP STRING
	{
		string val = string($1)+"_str"; 
		mySet.insert(std::make_pair(string($1), val));
		myStrSet.insert(std::make_pair(string($1), val));
		string combined = val+" = "+string($3)+";";
		$$=strdup(combined.c_str());
	}
	|
	VARIABLE ASSIGNOP NUMBER
	{
		string val = string($1)+"_int"; 
		mySet.insert(std::make_pair(string($1), val));
		myIntSet.insert(std::make_pair(string($1), val));
		string combined= val+" = "+string($3)+";";
		$$=strdup(combined.c_str());
	}
    ;

expression:
	value {
		$$=strdup($1);	
	}
    |
	value MATHOP expression    
	{
		string combined=string($1)+" "+string($2)+" "+string($3);
		$$=strdup(combined.c_str());
	}
    ;

value:
	NUMBER	{
		 $$=strdup($1);	 
	}
	|
	VARIABLE   {
		string val;
		if(mySet.count($1) > 0){
			val = mySet[$1];
		}else {
			val = string($1)+"_flt"; 
			mySet.insert(std::make_pair(string($1), val));
			myFltSet.insert(std::make_pair(string($1), val));
		}
		$$=strdup(val.c_str());
	}
	|
	OPENPAR expression CLOSEPAR      {
		string combined="("+string($2)+")";
		$$=strdup(combined.c_str());
	}
	;

%%

void yyerror(string s){
	cout<<"error at line"<<linenumber<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
