#ifndef GREP_FUNCS_H_
#define GREP_FUNCS_H_

#include "../common/flag_parser.h"

void ProcessFile(const char *filename, GrepFlag flags, int argc);

#endif