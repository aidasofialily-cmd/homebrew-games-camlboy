# Makefile for games/old_games/
CC = gcc
ASM = nasm
ASMFLAGS = -f elf64
LDFLAGS = -lSDL2 -no-pie

SRC = tobutobugirl.asm
OBJ = tobutobugirl.o
TARGET = tobutobugirl

all: $(TARGET)

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)

run: all
	./$(TARGET)
