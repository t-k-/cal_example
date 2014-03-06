target := prefix infix postfix
t_file := $(addsuffix .test, $(addprefix test/, $(target)))

all: $(target)

test: all $(t_file)
	./$(word 1, $(target)) < $(word 2, $^)
	./$(word 2, $(target)) < $(word 3, $^)
	./$(word 3, $(target)) < $(word 4, $^)

%: %.tab.o %.yy.o common.o
	gcc $^ -lfl -lm -o $@ 

common.o: common.c common.h
	gcc -c -o $@ $<

%.tab.o: %.tab.c
	gcc -c -o $@ $^

%.yy.o: lex.yy.c %.tab.h
	gcc -c -o $@ $< -include $(word 2, $^)

lex.yy.c: cal.l 
	flex $<
	
parse = bison --verbose --report=solved -d $^
%.tab.h %.tab.c: %.y 
	$(parse) 2>&1 | grep --color conflicts || $(parse) 

clean:
	find . -mindepth 1 \( -path './.git' -o -path './test' -o -name "*.y" -o -name "*.l" -o -name "README.md" -o -name "Makefile" -o -name "*.swp" -o -name "common.[ch]" -o -name "*.test" \) -prune -o -print | xargs rm -f
