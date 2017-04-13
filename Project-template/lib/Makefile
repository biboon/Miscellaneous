CC ?= gcc
AR ?= ar
DIRSRC := ./src
DIRBUILD := ./build

SOURCES := $(shell find $(DIRSRC) -type f -name *.c)
OBJECTS := $(patsubst $(DIRSRC)/%,$(DIRBUILD)/%,$(SOURCES:.c=.o))
STARGETS := $(patsubst $(DIRSRC)/%,%,$(SOURCES:.c=.a))
DTARGETS := $(patsubst $(DIRSRC)/%,%,$(SOURCES:.c=.so))

CFLAGS := -g -Wall -Wextra -std=gnu99
#LIB := -pthread -L $(DIRLIB)
LDFLAGS := -I ./include

.PHONY: all clean

all: $(STARGETS) $(DTARGETS)

%.a: $(DIRBUILD)/%.o
	$(AR) -q $@ $<

$(DIRBUILD)/%.o: $(DIRSRC)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $<

%.so: $(DIRSRC)/%.c
	$(CC) $(CFLAGS) -shared -fPIC $(LDFLAGS) -c -o $@ $<

clean:
	@echo "Cleaning..."
	rm -r $(DIRBUILD)
