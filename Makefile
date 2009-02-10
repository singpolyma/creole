.PHONY: all run clean

all: creole

creole: lex.yy.c
	gcc -o creole lex.yy.c
lex.yy.c: creole.l
	lex creole.l

clean:
	rm -f creole lex.yy.c

test:
	echo "**Hello**" | ./creole
