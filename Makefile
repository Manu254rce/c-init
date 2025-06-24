# Vars

CC = gcc
CFLAGS = -Wall -Werror -Wextra -pedantic -std=c99
DEBUG_FLAGS = -g -DDEBUG

SRCDIR = src
INCDIR = include
TESTDIR = tests

.PHONY: all debug test clean betty help

test: $(TEST_TARGET)
	./$(TEST_TARGET)

betty:
	@echo "Running Betty style checker..."
	@betty $(SRCDIR)/*.c $(INCDIR)/*.h

help:
	@echo "Available targets:"
	@echo "  all       - Build the project (default)"
	@echo "  debug     - Build with debugging symbols"
	@echo "  test      - Build and run tests"
	@echo "  betty     - Run Betty style checker"
	@echo "  valgrind  - Run memory leak checks with valgrind"
	@echo "  help      - Show this help message"
