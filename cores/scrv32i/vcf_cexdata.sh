#!/bin/bash
#
# Copyright (C) 2024 Rohith V <vrohithkattimani@gmail.com>
# LinkedIn: https://www.linkedin.com/in/v-rohith-km/
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Enable error handling and debugging
set -e

# Store the script's name with extension
script_name=$(basename "$0")

# Define the directory containing the Makefile (relative to this script)
makefile_dir="vcf/make_folder"

# Save the current working directory (original directory)
original_dir=$(pwd)

# Create the output directory for warnings and errors in the original directory
rm -rf vcf_cexdata
mkdir -p vcf_cexdata

# Ensure the directory exists
if [[ ! -d "vcf_cexdata" ]]; then
    echo "$script_name: Failed to create directory 'vcf_cexdata'"
    exit 1
fi

# Initialize associative arrays for tracking unique warnings and errors
declare -A warnings
declare -A errors
declare -A warning_sources
declare -A error_sources

# Define output file paths in the original directory
warnings_file="$original_dir/vcf_cexdata/warnings.txt"
errors_file="$original_dir/vcf_cexdata/errors.txt"

# Ensure the files exist
touch "$warnings_file" "$errors_file"
if [[ ! -f "$warnings_file" || ! -f "$errors_file" ]]; then
    echo "$script_name: Failed to create required files"
    exit 1
fi

# Initialize a variable to track the current check
current_check=""

# Function to process a single line of output
process_line() {
    local line="$1"

    # Check if the line specifies a VCF command and extract the check name
    if [[ $line =~ vcf\ -f ]]; then
        current_check=$(echo "$line" | sed -E 's|.*vcf -f ../||; s|/.*||; s|\.tcl||')
        return
    fi

    # Process warnings
    if [[ $line =~ [Ww]arning ]]; then
        warning_msg=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        warnings["$warning_msg"]=$((warnings["$warning_msg"] + 1))
        warning_sources["$warning_msg"]+=", $current_check"
        if [[ ${warnings["$warning_msg"]} -eq 1 ]]; then
            echo "$script_name: $warning_msg (Check: $current_check)" >> "$warnings_file"
        else
            sed -i "/$warning_msg/d" "$warnings_file"
            echo "$script_name: $warning_msg (Encountered ${warnings["$warning_msg"]} times, Checks:${warning_sources["$warning_msg"]})" >> "$warnings_file"
        fi
    fi

    # Process errors
    if [[ $line =~ [Ee]rror ]]; then
        error_msg=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        errors["$error_msg"]=$((errors["$error_msg"] + 1))
        error_sources["$error_msg"]+=", $current_check"
        if [[ ${errors["$error_msg"]} -eq 1 ]]; then
            echo "$script_name: $error_msg (Check: $current_check)" >> "$errors_file"
        else
            sed -i "/$error_msg/d" "$errors_file"
            echo "$script_name: $error_msg (Encountered ${errors["$error_msg"]} times, Checks:${error_sources["$error_msg"]})" >> "$errors_file"
        fi
    fi
}

# Change to the directory containing the Makefile (make should run here)
cd "$makefile_dir"

# Run make and process output dynamically
make "$@" | while IFS= read -r line; do
    # Only print the script name for lines that are directly from the script
    if [[ "$line" =~ "error" || "$line" =~ "warning" ]]; then
        echo "$script_name: $line"  # Print the line for real-time monitoring
    else
        echo "$line"  # Let the VCF or make tool output normally without script name prefix
    fi
    process_line "$line"  # Process warnings and errors
done

# Return to the original directory
cd "$original_dir"

# Static Mode Support: If you want to run this script on an already generated log file, you can adapt the logic by reading from the file:
# cat log.txt | while IFS= read -r line; do
#     process_line "$line"
# done

# Cleanup empty files if no warnings or errors were found
[[ -f "$warnings_file" && ! -s "$warnings_file" ]] && rm -f "$warnings_file"
[[ -f "$errors_file" && ! -s "$errors_file" ]] && rm -f "$errors_file"

echo -e "$script_name: Processing complete. Warnings and errors saved in 'vcf_cexdata/' directory.\n"

