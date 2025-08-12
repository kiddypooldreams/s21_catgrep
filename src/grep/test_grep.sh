#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

MY_GREP="./s21_grep"
REAL_GREP="grep"
LOGS_DIR="test/logs"

# Создаем тестовые лог-файлы
mkdir -p "$LOGS_DIR"

# app_1.log - пример лога приложения
echo -e "2024-01-15 08:30:45 INFO: System started
2024-01-15 08:31:10 ERROR: System crash detected
2024-01-15 08:32:00 WARNING: Database server unresponsive
2024-01-15 08:33:22 SECURITY: Security breach attempt by user Alice
2024-01-15 08:35:17 INFO: System recovered
2024-01-15 09:10:34 CRITICAL: Disk failure
2024-01-15 09:15:00 ERROR: Network timeout
2024-01-15 09:20:45 INFO: Admin logged in" > "$LOGS_DIR/app_1.log"

# app_2.log - другой пример лога
echo -e "2025-02-20 12:05:01 INFO: Backup started
2025-02-20 12:10:30 ERROR: System crash detected
2025-02-20 12:15:45 WARNING: High memory usage
2025-02-20 12:20:00 SECURITY: Security breach attempt by user Bob
2025-02-20 12:25:30 CRITICAL: Database corruption
2025-02-20 12:30:00 INFO: Admin maintenance
2025-02-20 12:35:15 ERROR: 2025-02-20 12:35:15 ERROR: Service unavailable" > "$LOGS_DIR/app_2.log"

# app_3.log - третий пример лога
echo -e "2024-03-10 15:45:00 INFO: User Alice connected
2024-03-10 15:46:30 ERROR: System crash detected
2024-03-10 15:47:15 WARNING: Database server unresponsive
2024-03-10 15:48:00 SECURITY: Security breach attempt detected
2024-03-10 15:50:00 CRITICAL: Hardware failure
2024-03-10 15:55:00 INFO: System shutdown
2024-03-10 15:56:00 ERROR: 2024-03-10 15:56:00 ERROR: Backup failed" > "$LOGS_DIR/app_3.log"

run_test() {
    local test_num="$1"
    local test_name="$2"
    local pattern="$3"
    local options="$4"
    local file="$5"
    
    echo -n "Test $test_num: $test_name - "
    echo "Command: $MY_GREP $options \"$pattern\" $file"

    $MY_GREP $options "$pattern" "$file" > my_output.txt
    $REAL_GREP $options "$pattern" "$file" > real_output.txt

    if diff -q my_output.txt real_output.txt > /dev/null; then
        echo -e "${GREEN}SUCCESS${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        echo "--- Differences ---"
        diff --color my_output.txt real_output.txt
        return 1
    fi
}

# Основные тесты
run_test 1 "Basic search" "System crash detected" "" "$LOGS_DIR/app_1.log"
run_test 2 "Security search" "Security breach attempt" "" "$LOGS_DIR/app_1.log"
run_test 3 "Basic search app2" "System crash detected" "" "$LOGS_DIR/app_2.log"
run_test 4 "Security search app2" "Security breach attempt" "" "$LOGS_DIR/app_2.log"
run_test 5 "Basic search app3" "System crash detected" "" "$LOGS_DIR/app_3.log"
run_test 6 "Security search app3" "Security breach attempt" "" "$LOGS_DIR/app_3.log"
run_test 7 "Case insensitive" "SYSTEM CRASH DETECTED" "-i" "$LOGS_DIR/app_1.log"
run_test 8 "Invert match app1" "Admin" "-v" "$LOGS_DIR/app_1.log"
run_test 9 "Invert match app2" "Admin" "-v" "$LOGS_DIR/app_2.log"
run_test 10 "Invert match app3" "Admin" "-v" "$LOGS_DIR/app_3.log"
run_test 11 "Count matches app1" "Alice" "-c" "$LOGS_DIR/app_1.log"
run_test 12 "Count matches app2" "Alice" "-c" "$LOGS_DIR/app_2.log"
run_test 13 "Count matches app3" "Alice" "-c" "$LOGS_DIR/app_3.log"
run_test 14 "Files with matches" "CRITICAL" "-l" "$LOGS_DIR/*"
run_test 15 "Line numbers app1" "ERROR" "-n" "$LOGS_DIR/app_1.log"
run_test 16 "Line numbers app2" "ERROR" "-n" "$LOGS_DIR/app_2.log"
run_test 17 "Line numbers app3" "ERROR" "-n" "$LOGS_DIR/app_3.log"
run_test 18 "Extended regex app1" "Database server unresponsive" "-e" "$LOGS_DIR/app_1.log"
run_test 19 "Complex regex app1" "202[45]-.*ERROR" "-e" "$LOGS_DIR/app_1.log"
run_test 20 "Extended regex app2" "Database server unresponsive" "-e" "$LOGS_DIR/app_2.log"
run_test 21 "Complex regex app2" "202[45]-.*ERROR" "-e" "$LOGS_DIR/app_2.log"
run_test 22 "Extended regex app3" "Database server unresponsive" "-e" "$LOGS_DIR/app_3.log"
run_test 23 "Complex regex app3" "202[45]-.*ERROR" "-e" "$LOGS_DIR/app_3.log"

# Тесты с несколькими шаблонами
run_test 24 "Multiple patterns app1" "-e GTYJHB -e Database -e ERROR -e GTYJHB" "" "$LOGS_DIR/app_1.log"
run_test 25 "Complex multiple patterns app1" "202[45]-.*error -ie alice" "" "$LOGS_DIR/app_1.log"
run_test 26 "Multiple patterns app2" "-e GTYJHB -e Database -e ERROR -e GTYJHB" "" "$LOGS_DIR/app_2.log"
run_test 27 "Complex multiple patterns app2" "202[45]-.*error -ie alice" "" "$LOGS_DIR/app_2.log"
run_test 28 "Multiple patterns app3" "-e GTYJHB -e Database -e ERROR -e GTYJHB" "" "$LOGS_DIR/app_3.log"
run_test 29 "Complex multiple patterns app3" "202[45]-.*error -ie alice" "" "$LOGS_DIR/app_3.log"


# Удаляем временные файлы
rm -f "$TEST_FILE1" "$TEST_FILE2" my_output.txt real_output.txt
rm -rf "$LOGS_DIR"

echo -e "\n${GREEN}All tests completed!${NC}"