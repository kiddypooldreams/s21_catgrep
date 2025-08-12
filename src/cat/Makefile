CC = gcc
CFLAGS = -Wall -Wextra -Werror
TARGET = s21_cat

SRC_CAT = s21_cat.c flag_func.c
SRC_COMMON = ../common/flag_parser.c

OBJ_CAT = $(SRC_CAT:.c=.o)
OBJ_COMMON = $(notdir $(SRC_COMMON:.c=.o))
OBJS = $(OBJ_CAT) $(OBJ_COMMON)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS)  $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS)  -c $< -o $@

%.o: ../common/%.c
	$(CC) $(CFLAGS)  -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

re: clean all

.PHONY: all clean re