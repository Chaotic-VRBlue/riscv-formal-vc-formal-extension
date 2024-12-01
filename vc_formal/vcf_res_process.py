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

import os
import re


def extract_summary(file_path):
    """
    Extract the 'Summary Results' section from the given file.
    """
    summary_lines = []
    inside_summary = False

    with open(file_path, 'r') as file:
        for line in file:
            if "Summary Results" in line:
                inside_summary = True
            elif "List Results" in line:
                inside_summary = False
                break
            if inside_summary:
                summary_lines.append(line)

    return "".join(summary_lines)


def parse_subsections(summary_text):
    """
    Parse the Summary Results into subsections and extract key-value pairs.
    """
    subsection_headers = ["Assertion", "Witness", "Cover", "Constraint"]
    subsections = {}

    lines = summary_text.splitlines()
    current_section = None
    for line in lines:
        for header in subsection_headers:
            if line.strip().startswith(f"> {header}"):
                current_section = header
                subsections[current_section] = {}
                break
        if current_section and ":" in line:
            match = re.findall(r"(\w+)\s*:\s*(\d+)", line)
            if match:
                for key, value in match:
                    subsections[current_section][key] = int(value)

    return subsections


def determine_assertion_status(assertion_data):
    """
    Determine PASS/FAIL/INCONCLUSIVE status for assertions based on the conditions.
    """
    if not assertion_data:
        return "INCONCLUSIVE"

    found = assertion_data.get("found", 0)
    proven = assertion_data.get("proven", 0)
    falsified = assertion_data.get("falsified", 0)
    inconclusive = assertion_data.get("inconclusive", 0)

    if proven == found and falsified == 0 and inconclusive == 0:
        return "PASS"
    elif falsified > 0:
        return "FAIL"
    elif inconclusive > 0 and falsified == 0:
        return "INCONCLUSIVE"
    return "INCONCLUSIVE"


def format_results(check_name, parsed_results, status):
    """
    Format results in a tabular style without using any external libraries.
    """
    # Prepare the header and divider
    header = "+-------------+-----------+-------------------------------------+"
    result_lines = [f"Check: {check_name:<60} {status}"]

    # Add table header
    result_lines.append(header)
    result_lines.append("| Property    | # Found   | Sub-Results                         |")
    result_lines.append(header)

    # Add rows for each subsection
    for section, data in parsed_results.items():
        found = data.get("found", "N/A")
        sub_results = ", ".join(f"{k.capitalize()}: {v}" for k, v in data.items() if k != "found") or "N/A"
        result_lines.append(f"| {section:<11} | {str(found):<9} | {sub_results:<35} |")

    # Add footer
    result_lines.append(header)
    result_lines.append("\n")  # Blank line for spacing between checks

    return "\n".join(result_lines)


def process_all_files(vcf_folder, output_file_path):
    """
    Process all {check_name}_results.txt files in the vcf folder structure.
    """
    total_checks = 0
    pass_count = 0
    fail_count = 0
    inconclusive_count = 0
    unknown_count = 0

    with open(output_file_path, 'w') as output_file:
        for subdir in os.listdir(vcf_folder):
            subdir_path = os.path.join(vcf_folder, subdir)
            if os.path.isdir(subdir_path) and subdir != "make_folder":
                total_checks += 1
                check_name = subdir
                results_file_path = os.path.join(subdir_path, f"{check_name}_results.txt")

                if os.path.exists(results_file_path):
                    summary = extract_summary(results_file_path)
                    parsed_results = parse_subsections(summary)
                    assertion_status = determine_assertion_status(parsed_results.get("Assertion", {}))

                    if assertion_status == "PASS":
                        pass_count += 1
                    elif assertion_status == "FAIL":
                        fail_count += 1
                    elif assertion_status == "INCONCLUSIVE":
                        inconclusive_count += 1

                    formatted_results = format_results(check_name, parsed_results, assertion_status)
                    output_file.write(formatted_results)
                else:
                    unknown_count += 1
                    output_file.write(f"Check: {check_name:<60} UNKNOWN\n\n")

        # Write final summary
        output_file.write("---------------------------\n")
        output_file.write("Final Summary:\n")
        output_file.write("---------------------------\n")
        output_file.write(f"No of checks = {total_checks}\n")
        output_file.write(f"PASS         = {pass_count}\n")
        output_file.write(f"FAIL         = {fail_count}\n")
        output_file.write(f"INCONCLUSIVE = {inconclusive_count}\n")
        output_file.write(f"UNKNOWN      = {unknown_count}\n")

    print(f"All results processed and stored in {output_file_path}")


# Example usage

vcf_folder = os.path.join(os.getcwd(), "vcf")  # Dynamically set the vcf folder path
output_file_path = os.path.join(os.getcwd(), "vcf_cexdata", "results.txt")  # Adjust output path similarly

process_all_files(vcf_folder, output_file_path)

