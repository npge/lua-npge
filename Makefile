BUSTED := $(wildcard /usr/local/lib/luarocks/rocks/busted/*/bin/busted)

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

exitless-busted:
	sed '1 s/^.*$/os.exit = function() end/g' > $@ < $(BUSTED)
