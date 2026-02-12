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
