CC = gcc
CFLAGS = -Wall -Wextra -Werror
TARGET = s21_grep

SRC_GREP = s21_grep.c grep_funcs.c
SRC_COMMON = ../common/flag_parser.c

OBJ_GREP = $(SRC_GREP:.c=.o)
OBJ_COMMON = $(notdir $(SRC_COMMON:.c=.o))
OBJS = $(OBJ_GREP) $(OBJ_COMMON)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

%.o: ../common/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

re: clean all

.PHONY: all clean re