clean:
	rm -f luacov.*.out
	rm -f src/npge/*/*.gcov
	rm -f src/npge/*/*.gcda
	rm -f src/npge/*/*.gcno
	rm -f src/npge/*/*.o
	rm -f -r npge

test:
	busted -c
	gcov src/npge/*/*.c
