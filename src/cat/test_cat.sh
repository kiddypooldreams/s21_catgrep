#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ $# -ne 1 ]; then
    echo -e "${RED}Usage: $0 <path_to_your_cat>${NC}"
    exit 1
fi

YOUR_CAT="$1"

# Определяем оригинальный cat (GNU на macOS)
if [[ "$(uname)" == "Darwin" ]] && command -v gcat &>/dev/null; then
    ORIG_CAT="gcat"
else
    ORIG_CAT="cat"
fi

if [ ! -x "$YOUR_CAT" ]; then
    echo -e "${RED}Error: '$YOUR_CAT' is not executable.${NC}"
    exit 1
fi

TMP_ORIG="tmp_orig.txt"
TMP_YOUR="tmp_your.txt"
TEST_FILE="test_file.txt"

# Создаем тестовый файл с разными типами строк
echo -e "Macbeth
by William Shakespeare
Edited by Barbara A. Mowat and Paul Werstine
	with Michael Poston and Rebecca Niles
Folger Shakespeare Library
https://shakespeare.folger.edu/shakespeares-works/macbeth/
Created on Jul 31, 2015, from FDT version 0.9.2

Characters in the Play
======================
Three Witches, the Weird Sisters
DUNCAN, king of Scotland
MALCOLM, his elder son
DONALBAIN, Duncan's younger son
MACBETH, thane of Glamis
LADY MACBETH
SEYTON, attendant to Macbeth
Three Murderers in Macbeth's service
Both attending upon Lady Macbeth:
	A Doctor
	A Gentlewoman
A Porter
BANQUO, commander, with Macbeth, of Duncan's army
FLEANCE, his son
MACDUFF, a Scottish noble
LADY MACDUFF
Their son
Scottish Nobles:
	LENNOX
	ROSS
	ANGUS
	MENTEITH
	CAITHNESS
SIWARD, commander of the English forces
YOUNG SIWARD, Siward's son
        A Captain in Duncan's army
An Old Man
A Doctor at the English court
HECATE






Apparitions: an Armed Head, a Bloody Child, a Crowned Child, and eight nonspeaking kings
Three Messengers, Three Servants, a Lord, a Soldier
Attendants, a Sewer, Servants, Lords, Thanes, Soldiers (all nonspeaking)
" > "$TEST_FILE"

run_test() {
    local test_name="$1"
    local flags="$2"
    local file="$3"
    
    echo -e "\n=== TEST: $test_name ==="
    echo "Command: $flags $file"

    $ORIG_CAT $flags "$file" > "$TMP_ORIG" 2>&1
    $YOUR_CAT $flags "$file" > "$TMP_YOUR" 2>&1

    if cmp -s "$TMP_ORIG" "$TMP_YOUR"; then
        echo -e "${GREEN}PASSED${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        echo "--- Expected output ---"
        cat "$TMP_ORIG"
        echo "--- Your output ---"
        cat "$TMP_YOUR"
        echo "--- Differences ---"
        # Используем diff для показа различий, так как cmp только сравнивает
        diff --color "$TMP_ORIG" "$TMP_YOUR"
        exit 1
    fi
}

# Основные тесты
run_test "Basic output" "" "$TEST_FILE"
run_test "Number non-blank lines (-b)" "-b" "$TEST_FILE"
run_test "Show line ends (-e)" "-e" "$TEST_FILE"
run_test "Number all lines (-n)" "-n" "$TEST_FILE"
run_test "Squeeze blank lines (-s)" "-s" "$TEST_FILE"
run_test "Show tabs (-t)" "-t" "$TEST_FILE"

# Тест с stdin
echo -e "\n=== TEST: stdin ==="
echo "Test line" | $ORIG_CAT -n > "$TMP_ORIG"
echo "Test line" | $YOUR_CAT -n > "$TMP_YOUR"

if cmp -s "$TMP_ORIG" "$TMP_YOUR"; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
    diff --color "$TMP_ORIG" "$TMP_YOUR"
    exit 1
fi

# Удаляем временные файлы
rm -f "$TMP_ORIG" "$TMP_YOUR" "$TEST_FILE"

echo -e "\n${GREEN}All tests passed!${NC}"