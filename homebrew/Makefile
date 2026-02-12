ASM = rgbasm
LNK = rgblink
FIX = rgbfix

# Compile all .asm files in src/ to .gb in bin/
all: bin/sync_test.gb

bin/%.gb: src/%.asm
	@mkdir -p bin
	$(ASM) -o bin/$*.o $<
	$(LNK) -o $@ bin/$*.o
	$(FIX) -v -p 0 $@

# Add this to your root Makefile
cpp-test:
	g++ -c src/cpp_game/StressTest.cpp -I./include -o StressTest.o
	dune build bin/main.exe
	g++ StressTest.o _build/default/bin/main.exe.o -o camlboy-stress-test -lpthread -ldl
