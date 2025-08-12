#include "flag_func.h"

#include <ctype.h>
#include <string.h>

#include "../common/flag_parser.h"

void ProcessFile(const char *filename, CatFlag flags) {
  FILE *fp = filename ? fopen(filename, "rb") : stdin;
  if (!fp) {
    perror(filename ? filename : "stdin");
    return;
  }

  int c, prev = '\n';
  int line_num = 1;
  int empty_lines = 0;

  while ((c = fgetc(fp)) != EOF) {
    if (flags.squeeze_blank && c == '\n' && prev == '\n') {
      if (++empty_lines > 1) continue;
    } else {
      empty_lines = 0;
    }

    if (prev == '\n') {
      if (flags.number_non_blank) {
        if (c != '\n') printf("%6d\t", line_num++);
      } else if (flags.number) {
        printf("%6d\t", line_num++);
      }
    }

    if (c == '\n') {
      if (flags.show_ends) {
        putchar('$');
      }
      putchar('\n');
    } else if (c == '\t' && flags.show_tabs) {
      printf("^I");
    } else if (flags.show_non_printing) {
      if (c < 32 && c != '\t') {
        printf("^%c", c + 64);
      } else if (c == 127) {
        printf("^?");
      } else if (c >= 128) {
        if (c < 160) {
          printf("M-^%c", c - 64);
        } else if (c < 255) {
          printf("M-%c", c - 128);
        } else {
          printf("M-^?");
        }
      } else {
        putchar(c);
      }
    } else {
      putchar(c);
    }

    prev = c;
  }

  if (filename) fclose(fp);
}