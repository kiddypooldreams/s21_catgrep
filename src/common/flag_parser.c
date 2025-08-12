#include "flag_parser.h"

#include <getopt.h>
#include <stdlib.h>
#include <string.h>

CatFlag CatFlagsParser(int argc, char *argv[]) {
  struct option long_flags[] = {{"number-nonblank", no_argument, NULL, 'b'},
                                {"number", no_argument, NULL, 'n'},
                                {"squeeze-blank", no_argument, NULL, 's'},
                                {0, 0, 0, 0}};

  CatFlag flag = {0};
  int opt;

  while ((opt = getopt_long(argc, argv, "bnsvEeTt", long_flags, NULL)) != -1) {
    switch (opt) {
      case 'b':
        flag.number_non_blank = 1;
        flag.number = 0;  // -b имеет приоритет над -n
        break;
      case 'e':
        flag.show_ends = 1;
        flag.show_non_printing = 1;
        break;
      case 'E':
        flag.show_ends = 1;
        break;
      case 's':
        flag.squeeze_blank = 1;
        break;
      case 'n':
        if (!flag.number_non_blank) {  // -n работает только если не установлен
                                       // -b
          flag.number = 1;
        }
        break;
      case 't':
        flag.show_tabs = 1;
        flag.show_non_printing = 1;
        break;
      case 'T':
        flag.show_tabs = 1;
        break;
      case 'v':
        flag.show_non_printing = 1;
        break;
      case '?':
        // Неизвестный флаг - обработка ошибки
        break;
    }
  }

  return flag;
}

GrepFlag GrepFlagsParser(int argc, char *argv[]) {
  GrepFlag flag = {0};
  int memory_error = 0;

  flag.patterns = malloc(sizeof(char *) * argc);
  if (flag.patterns == NULL) {
    memory_error = 1;
  } else {
    flag.pattern_count = 0;

    int opt;
    struct option long_flags[] = {
        {"line-number", no_argument, NULL, 'n'},
        {"ignore-case", no_argument, NULL, 'i'},
        {"invert-match", no_argument, NULL, 'v'},
        {"count", no_argument, NULL, 'c'},
        {"regexp", required_argument, NULL, 'e'},
        {"files-with-matches", no_argument, NULL, 'l'},
        {NULL, 0, NULL, 0}};

    while ((opt = getopt_long(argc, argv, "e:iclnv", long_flags, NULL)) != -1) {
      switch (opt) {
        case 'i':
          flag.ignore_case = 1;
          break;
        case 'e':
          flag.patterns[flag.pattern_count++] = optarg;
          break;
        case 'v':
          flag.invert_match = 1;
          break;
        case 'l':
          flag.files_with_matches = 1;
          break;
        case 'n':
          flag.line_number = 1;
          break;
        case 'c':
          flag.count_lines = 1;
          break;
        case '?':
          memory_error = 1;
          break;
      }
    }

    if (flag.pattern_count == 0 && optind < argc) {
      flag.patterns[flag.pattern_count++] = argv[optind++];
    }
  }

  if (memory_error) {
    // Очищаем флаги в случае ошибки
    if (flag.patterns != NULL) {
      free(flag.patterns);
    }
    memset(&flag, 0, sizeof(flag));
  }

  return flag;
}
