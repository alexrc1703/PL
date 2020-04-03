mk: mkfromtemplate.l
	flex mkfromtemplate.l
	gcc -o mkfromtemplate lex.yy.c

clean:
	rm -f lex.yy.c mkfromtemplate