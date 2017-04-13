CC ?= gcc
TARGET := ./bin/runner
DIRSRC := ./src
DIRLIB := ./lib
DIRBUILD := ./build

SOURCES := $(shell find $(DIRSRC) -type f -name *.c)
OBJECTS := $(patsubst $(DIRSRC)/%,$(DIRBUILD)/%,$(SOURCES:.c=.o))

CFLAGS := -g -Wall -Wextra -std=gnu99
LIB := -pthread -L $(DIRLIB)
LDFLAGS := -I ./include -I $(DIRLIB)/include

$(TARGET): $(OBJECTS)
	@echo "Linking..."
	@mkdir -p $(dir $@)
	$(CC) $^ -o $@ $(LIB)

$(DIRBUILD)/%.o: $(DIRSRC)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $<

.PHONY: clean

clean:
	@echo "Cleaning..."
	rm -r $(DIRBUILD)
