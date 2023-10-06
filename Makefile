basic:
	yacc -o basic.tab.c basic.y
	gcc basic.tab.c -o basic
	./basic

assign:
	yacc -o assign.tab.c assign.y
	gcc assign.tab.c -o assign
	./assign

assembly:
	yacc -o to_assembly.tab.c to_assembly.y
	gcc to_assembly.tab.c -o assembly
	./assembly

postfix:
	yacc -o to_postfix.tab.c to_postfix.y
	gcc to_postfix.tab.c -o postfix
	./postfix

clean:
	rm -rf *.tab.c *.tab.h basic assign assembly postfix