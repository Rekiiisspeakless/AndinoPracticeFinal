parser: scanner.l parser.y
	flex --header-file=scanner.h scanner.l
	byacc  -d  parser.y
	g++  -o  parser lex.yy.c y.tab.c
clean:
	rm -f parser
	rm -f lex.yy.c
