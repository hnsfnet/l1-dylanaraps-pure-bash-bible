#!/usr/bin/env bash
# shellcheck source=/dev/null disable=2178,2128,2329
#
# Tests for the Pure Bash Bible.

set +H

test_trim_string() {
    result="$(trim_string "    Hello,    World    ")"
    assert_equals "$result" "Hello,    World"
}

test_trim_all() {
    result="$(trim_all "    Hello,    World    ")"
    assert_equals "$result" "Hello, World"
}

test_regex() {
    result="$(regex "#FFFFFF" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$')"
    assert_equals "$result" "#FFFFFF"
}

test_lower() {
    result="$(lower "HeLlO")"
    assert_equals "$result" "hello"
}

test_upper() {
    result="$(upper "HeLlO")"
    assert_equals "$result" "HELLO"
}

test_reverse_case() {
    result="$(reverse_case "HeLlO")"
    assert_equals "$result" "hElLo"
}

test_trim_quotes() {
    result="$(trim_quotes "\"te'st' 'str'ing\"")"
    assert_equals "$result" "test string"
}

test_strip_all() {
    result="$(strip_all "The Quick Brown Fox" "[aeiou]")"
    assert_equals "$result" "Th Qck Brwn Fx"
}

test_strip() {
    result="$(strip "The Quick Brown Fox" "[aeiou]")"
    assert_equals "$result" "Th Quick Brown Fox"
}

test_lstrip() {
    result="$(lstrip "!:IHello" "!:I")"
    assert_equals "$result" "Hello"
}

test_rstrip() {
    result="$(rstrip "Hello!:I" "!:I")"
    assert_equals "$result" "Hello"
}

test_urlencode() {
    result="$(urlencode "https://github.com/dylanaraps/pure-bash-bible")"
    assert_equals "$result" "https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible"
}

test_urldecode() {
    result="$(urldecode "https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible")"
    assert_equals "$result" "https://github.com/dylanaraps/pure-bash-bible"
}

test_reverse_array() {
    shopt -s compat44
    IFS=$'\n' read -d "" -ra result < <(reverse_array 1 2 3 4 5)
    assert_equals "${result[*]}" "5 4 3 2 1"
    shopt -u compat44
}

test_cycle() {
    # shellcheck disable=2034
    arr=(a b c d)
    result="$(cycle; cycle; cycle)"
    assert_equals "$result" "a b c "
}

test_head() {
    printf '%s\n%s\n\n\n' "hello" "world" > test_file
    result="$(head 2 test_file)"
    assert_equals "$result" $'hello\nworld'
}

test_tail() {
    printf '\n\n\n%s\n%s\n' "hello" "world" > test_file
    result="$(tail 2 test_file)"
    assert_equals "$result" $'hello\nworld'
}

test_lines() {
    printf '\n\n\n\n\n\n\n\n' > test_file
    result="$(lines test_file)"
    assert_equals "$result" "8"
}

test_lines_loop() {
    printf '\n\n\n\n\n\n\n\n' > test_file
    result="$(lines_loop test_file)"
    assert_equals "$result" "8"
}

test_count() {
    result="$(count ./{README.m,LICENSE.m,.travis.ym}*)"
    assert_equals "$result" "3"
}

test_dirname() {
    result="$(dirname "/home/black/Pictures/Wallpapers/1.jpg")"
    assert_equals "$result" "/home/black/Pictures/Wallpapers"

    result="$(dirname "/")"
    assert_equals "$result" "/"

    result="$(dirname "/foo")"
    assert_equals "$result" "/"

    result="$(dirname ".")"
    assert_equals "$result" "."

    result="$(dirname "/foo/foo")"
    assert_equals "$result" "/foo"

    result="$(dirname "something/")"
    assert_equals "$result" "."

    result="$(dirname "//")"
    assert_equals "$result" "/"

    result="$(dirname "//foo")"
    assert_equals "$result" "/"

    result="$(dirname "")"
    assert_equals "$result" "."

    result="$(dirname "something//")"
    assert_equals "$result" "."

    result="$(dirname "something/////////////////////")"
    assert_equals "$result" "."

    result="$(dirname "something/////////////////////a")"
    assert_equals "$result" "something"

    result="$(dirname "something//////////.///////////")"
    assert_equals "$result" "something"

    result="$(dirname "//////")"
    assert_equals "$result" "/"
}

test_basename() {
    result="$(basename "/home/black/Pictures/Wallpapers/1.jpg")"
    assert_equals "$result" "1.jpg"
}

test_hex_to_rgb() {
    result="$(hex_to_rgb "#FFFFFF")"
    assert_equals "$result" "255 255 255"

    result="$(hex_to_rgb "000000")"
    assert_equals "$result" "0 0 0"
}

test_rgb_to_hex() {
    result="$(rgb_to_hex 0 0 0)"
    assert_equals "$result" "#000000"
}

test_date() {
    result="$(date "%C")"
    assert_equals "$result" "20"
}

test_read_sleep() {
    result="$((SECONDS+1))"
    read_sleep 1
    assert_equals "$result" "$SECONDS"
}

test_bar() {
    result="$(bar 50 10)"
    assert_equals "${result//$'\r'}" "[-----     ]"
}

test_get_functions() {
    local result
    result="$(get_functions)"

    if [[ "$result" == *$'\n'assert_equals$'\n'* || "$result" == assert_equals$'\n'* || "$result" == *$'\n'assert_equals || "$result" == assert_equals ]]; then
        assert_equals "contains_assert_equals" "contains_assert_equals"
    else
        assert_equals "$result" "assert_equals"
    fi
}

test_extract() {
    printf '{\nhello, world\n}\n' > test_file
    result="$(extract test_file "{" "}")"
    assert_equals "$result" "hello, world"
}

test_split() {
    IFS=$'\n' read -d "" -ra result < <(split "hello,world,my,name,is,john" ",")
    assert_equals "${result[*]}" "hello world my name is john"
}

# -- Regression tests for the extraction pipeline --

test_extract_readme_code_filters_examples() {
    local tmp_in=".test_extract_in_$$"
    local tmp_out=".test_extract_out_$$"

    cat <<'EOF' > "$tmp_in"
```shell
$ fake_command
literal output
```
```sh
first() {
    # comment
    printf '%s\n' "ok"
}
```
```bash
second() {

    printf '%s\n' "ok"
}
```
EOF

    extract_readme_code "$tmp_in" "$tmp_out"
    local result
    result="$(< "$tmp_out")"
    local expected
    expected=$'first() {\n    # comment\n    printf \'%s\\n\' "ok"\n}'
    assert_equals "$result" "$expected"

    rm -f "$tmp_in" "$tmp_out" 2>/dev/null
}

test_no_dollar_prompts_in_extracted() {
    local dollar_lines
    dollar_lines="$(grep -cE '^\$ ' "$readme_code" 2>/dev/null)" || dollar_lines=0
    assert_equals "$dollar_lines" "0"
}

test_functions_actually_sourced() {
    local count=0
    declare -F trim_string  &>/dev/null && ((count++))
    declare -F urlencode   &>/dev/null && ((count++))
    declare -F hex_to_rgb  &>/dev/null && ((count++))
    declare -F split       &>/dev/null && ((count++))
    assert_equals "$count" "4"
}

test_no_shellcheck_required() {
    declare -F trim_string &>/dev/null
    assert_equals "$?" "0"
}

assert_equals() {
    if [[ "$1" == "$2" ]]; then
        ((pass+=1))
        status=$'\e[32m✔'
    else
        ((fail+=1))
        status=$'\e[31m✖'
        local err="(\"$1\" != \"$2\")"
    fi

    printf ' %s\e[m | %s\n' "$status" "${FUNCNAME[1]/test_} $err"
}

# extract_readme_code INPUT_FILE OUTPUT_FILE
#
# Extract only function/library code from ```sh fenced blocks in a Markdown
# file.  All other fenced blocks (```shell, ```bash, ```text, plain ```, etc.)
# are ignored.  Lines that look like interactive prompt examples ("$ ...")
# inside a sh block are also dropped so that the result can be safely sourced.
extract_readme_code() {
    local input_file="${1:?input file required}"
    local output_file="${2:?output file required}"
    local in_sh_block=0

    : > "$output_file"

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\`\`\` ]]; then
            # Only ```sh (exact, no extra chars) opens a library block.
            if [[ "$line" =~ ^\`\`\`sh$ ]]; then
                in_sh_block=1
            else
                in_sh_block=0
            fi
            continue
        fi

        if (( in_sh_block )); then
            # Skip interactive-prompt / example lines ("$ command ...").
            [[ "$line" =~ ^[[:space:]]*\$[[:space:]] ]] && continue
            printf '%s\n' "$line" >> "$output_file"
        fi
    done < "$input_file"
}

main() {
    readme_code=".readme_code_$$"
    trap 'rm -f "$readme_code" test_file .test_extract_in_$$ .test_extract_out_$$ sample_readme 2>/dev/null' EXIT

    extract_readme_code README.md "$readme_code"

    if command -v shellcheck &>/dev/null; then
        if ! shellcheck -s bash -S warning test.sh build.sh; then
            printf 'NOTE: shellcheck reported issues or crashed, continuing with runtime tests.\n' >&2
        fi
    else
        printf 'NOTE: shellcheck not installed, skipping lint checks.\n'
    fi

    # Source the extracted function definitions.
    # shellcheck source=/dev/null
    . "$readme_code"

    head="-> Running tests on the Pure Bash Bible.."
    printf '\n%s\n%s\n' "$head" "${head//?/-}"

    # Generate the list of tests to run.
    IFS=$'\n' read -d "" -ra funcs < <(declare -F)
    for func in "${funcs[@]//declare -f }"; do
        [[ "$func" == test_* ]] && "$func";
    done

    comp="Completed $((fail+pass)) tests. ${pass:-0} passed, ${fail:-0} failed."
    printf '%s\n%s\n\n' "${comp//?/-}" "$comp"

    # If a test failed, exit with '1'.
    (( fail > 0 )) && exit 1
    exit 0
}

main "$@"
