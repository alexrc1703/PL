TP2.exe : y.tab.o lex.yy.o 
	gcc -o TP2.exe y.tab.o lex.yy.o -ll  

y.tab.o : y.tab.c
	gcc -c y.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.c y.tab.h : TP2.y
	yacc -d TP2.y

lex.yy.c : TP2.l y.tab.h
	flex TP2.l

	