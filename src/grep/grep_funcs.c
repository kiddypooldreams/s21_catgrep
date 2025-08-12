#include <getopt.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>

#include "../common/flag_parser.h"

void ProcessFile(const char *filename, GrepFlag flags, int argc) {
  FILE *file = filename ? fopen(filename, "r") : stdin;
  if (!file) {
    perror(filename ? filename : "stdin");
    return;
  }

  char line[1024];
  int line_num = 0;
  int match_count = 0;
  int multiple_files = (optind < argc - 1);
  int regex_flags = REG_EXTENDED;

  if (flags.ignore_case) {
    regex_flags |= REG_ICASE;
  }

  regex_t *compiled_regex = malloc(flags.pattern_count * sizeof(regex_t));
  for (int i = 0; i < flags.pattern_count; i++) {
    if (regcomp(&compiled_regex[i], flags.patterns[i], regex_flags) != 0) {
      fprintf(stderr, "неверный регулярный паттерн: %s\n", flags.patterns[i]);
      free(compiled_regex);
      fclose(file);
      return;
    }
  }

  while (fgets(line, sizeof(line), file)) {
    line_num++;
    int match = 0;

    for (int i = 0; i < flags.pattern_count; i++) {
      int result = regexec(&compiled_regex[i], line, 0, NULL, 0);
      if (result == 0) {
        match = !flags.invert_match;
      } else if (result == REG_NOMATCH) {
        match = flags.invert_match;
      }

      if (match) break;
    }

    if (match) {
      match_count++;
      if (flags.files_with_matches) {
        printf("%s\n", filename ? filename : "(standard input)");
        break;
      }
      if (!flags.count_lines) {
        if (flags.line_number) {
          printf("%d:", line_num);
        }
        printf("%s", line);
      }
    }
  }

  // Освобождаем скомпилированные regex
  for (int i = 0; i < flags.pattern_count; i++) {
    regfree(&compiled_regex[i]);
  }
  free(compiled_regex);

  if (flags.count_lines) {
    if (multiple_files && filename) {
      printf("%s:", filename);
    }
    printf("%d\n", match_count);
  }

  if (file != stdin) {
    fclose(file);
  }
}