#!/bin/bash
set -euo pipefail

readonly tmp_consensus_dir="$1"
readonly tmp_errors_dir="$2"
readonly target_dir="$3"

. src/shared.sh

all_implementations() {
    find ./implementations -type d -depth 1 -print0 | xargs -0 -n1 basename | sort
}

all_query_results() {
    find "$tmp_consensus_dir" -type d -depth 1 -print0 | xargs -0 -n1 basename | sort
}

indent_2() {
    sed 's/^/  /'
}

code_block() {
    echo "\`\`\`"
    cat
    echo "\`\`\`"
}

is_failing_while_gold_standard_exists() {
    local query="$1"
    local implementation="$2"

    local consensus_dir="${tmp_consensus_dir}/${query}"

    {
        [[ -f "${tmp_errors_dir}/${implementation}___${query}" ]] \
            || [[ -f "${consensus_dir}/outliers/${implementation}" ]]
    } && [[ $(wc -l < "$consensus_dir"/matching_implementations) -gt 0 ]]

}

header() {
    echo "Results do not match other implementations

The following queries provide results that do not match those of other implementations of JSONPath
(compare https://github.com/cburgmer/json-path-comparison/tree/master/comparison):
"
}

footer() {
    local implementation="$1"

    echo
    echo "For reference, the output was generated by the program in https://github.com/cburgmer/json-path-comparison/tree/master/implementations/${implementation}."
}

failing_query() {
    local query="$1"
    local consensus_dir="${tmp_consensus_dir}/${query}"
    local selector

    selector="$(cat "./queries/${query}/selector")"

    echo "- [ ] \`${selector}\`"
    {
        echo "Input:"
        ./src/oneliner_json.py < "./queries/${query}/document.json" | code_block
        echo "Expected output:"
        ./src/oneliner_json.py < "${consensus_dir}/gold_standard.json" | code_block

        if [[ -f "${consensus_dir}/outliers/${implementation}" ]]; then
            echo "Actual output:"
            ./src/oneliner_json.py < "${consensus_dir}/outliers/${implementation}" | code_block
        else
            echo "Error:"
            code_block < "${tmp_errors_dir}/${implementation}___${query}"
        fi
    } | indent_2

    echo
}

process_implementation() {
    local implementation="$1"
    local query

    header

    while IFS= read -r query; do
        if is_failing_while_gold_standard_exists "$query" "$implementation"; then
            failing_query "$query"
        fi
    done <<< "$(all_query_results)"

    footer "$implementation"
}

main() {
    local implementation

    while IFS= read -r implementation; do
        process_implementation "$implementation" > "${target_dir}/report_for_${implementation}.md"
    done <<< "$(all_implementations)"
}

main