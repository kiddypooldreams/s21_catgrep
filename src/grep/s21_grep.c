#include <getopt.h>
#include <stdio.h>

#include "../common/flag_parser.h"
#include "grep_funcs.h"

int main(int argc, char *argv[]) {
  int return_code = 0;
  GrepFlag flags = GrepFlagsParser(argc, argv);

  if (flags.pattern_count == 0) {
    fprintf(stderr, "Error: нету паттерна\n");
    return_code = 1;
  } else {
    if (optind >= argc) {
      ProcessFile(NULL, flags, argc);
    } else {
      for (int i = optind; i < argc; i++) {
        ProcessFile(argv[i], flags, argc);
      }
    }
  }

  free(flags.patterns);

  return return_code;
}