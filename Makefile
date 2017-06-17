parser: scanner.l parser.y
	flex --header-file=scanner.h scanner.l
	byacc  -d  parser.y
	g++  -o  codegen lex.yy.c y.tab.c
clean:
	rm -f codegen
	rm -f lex.yy.c
