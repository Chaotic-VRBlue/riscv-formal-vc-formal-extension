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

def process_sby_files():
    current_dir = os.getcwd()  # Get the directory from where the script is called
    directory_name = os.path.basename(current_dir)
    source_folder = os.path.join(current_dir, "checks")
    destination_folder = os.path.join(current_dir, "vcf")
    os.makedirs(destination_folder, exist_ok=True)

    # Create make_folder inside the vcf folder
    make_folder = os.path.join(destination_folder, "make_folder")
    os.makedirs(make_folder, exist_ok=True)

    if not os.path.exists(source_folder):
        print(f"Error: Source folder '{source_folder}' does not exist.")
        return

    # Check for the configuration folder and its .txt files
    config_folder = os.path.join(current_dir, "vcf_checks_config")
    checks_to_run_file = os.path.join(config_folder, "checks_to_run.txt")
    checks_to_skip_file = os.path.join(config_folder, "checks_to_skip.txt")

    # Validate the configuration folder and files
    checks_to_run = []
    checks_to_skip = []
    all_checks = [file[:-4] for file in os.listdir(source_folder) if file.endswith(".sby")]
    log_message = ""  # Log message for "checks_processing_log.txt"
    checks_ran = []
    checks_skipped = []

    if os.path.exists(config_folder):
        if os.path.exists(checks_to_run_file) and os.path.exists(checks_to_skip_file):
            # Delete 'make_folder' it's empty
            if os.path.exists(make_folder):
                os.rmdir(make_folder)
            # Delete 'vcf' folder it's empty
            if os.path.exists(destination_folder):
                os.rmdir(destination_folder)
            print("Error: Both 'checks_to_run.txt' and 'checks_to_skip.txt' exist. This is not supported.")
            return
        elif os.path.exists(checks_to_run_file):
            with open(checks_to_run_file, "r") as f:
                checks_to_run = f.read().split()
            if checks_to_run:
                checks_ran = [check for check in checks_to_run if check in all_checks]
                checks_skipped = [check for check in all_checks if check not in checks_ran]
                log_message = f"Checks ran based on 'checks_to_run.txt':\n" + "\n".join(checks_ran)
                log_message += f"\n\nChecks skipped:\n" + "\n".join(checks_skipped)
            else:
                # When checks_to_run.txt is empty, log all checks
                checks_ran = all_checks
                log_message = f"`core/vcf_checks_config/checks_to_run.txt` configuration file is empty\n"
                log_message += f"All checks ran by default:\n" + "\n".join(checks_ran)
        elif os.path.exists(checks_to_skip_file):
            with open(checks_to_skip_file, "r") as f:
                checks_to_skip = f.read().split()
            if checks_to_skip:
                checks_skipped = [check for check in checks_to_skip if check in all_checks]
                checks_ran = [check for check in all_checks if check not in checks_skipped]
                log_message = f"Checks skipped based on 'checks_to_skip.txt':\n" + "\n".join(checks_skipped)
                log_message += f"\n\nChecks ran:\n" + "\n".join(checks_ran)
            else:
                # When checks_to_skip.txt is empty, log all checks
                checks_ran = all_checks
                log_message = f"`core/vcf_checks_config/checks_to_skip.txt` configuration file is empty\n"
                log_message += f"All checks ran by default:\n" + "\n".join(checks_ran)
        else:
            # When neither checks_to_run.txt nor checks_to_skip.txt exists, log all checks
            checks_ran = all_checks
            log_message = f"No configuration files found at `core/vcf_checks_config/checks_to_run.txt` or `core/vcf_checks_config/checks_to_skip.txt`\n"
            log_message += f"All checks ran by default:\n" + "\n".join(checks_ran)
    else:
        # When vcf_checks_config folder does not exists, log all checks
        checks_ran = all_checks
        log_message = f"No configuration files found at `core/vcf_checks_config/checks_to_run.txt` or `core/vcf_checks_config/checks_to_skip.txt`\n"
        log_message += f"All checks ran by default:\n" + "\n".join(checks_ran)

    total_sby_files = 0
    defines_created = 0
    defines_failed = 0
    tcl_created = 0
    tcl_failed = 0
    instruction_names = []

    for file_name in os.listdir(source_folder):
        if file_name.endswith(".sby"):
            check_name = file_name[:-4]  # Get the check name without extension

            # Skip or process based on checks_to_run or checks_to_skip
            if checks_to_run and check_name not in checks_to_run:
                continue
            if checks_to_skip and check_name in checks_to_skip:
                continue

            total_sby_files += 1
            sby_path = os.path.join(source_folder, file_name)
            folder_name = check_name
            target_folder = os.path.join(destination_folder, folder_name)
            defines_path = os.path.join(target_folder, "defines.sv")

            try:
                os.makedirs(target_folder, exist_ok=True)
                defines_content = extract_defines_content(sby_path)
                common_files = [
                    "../../../../checks/rvfi_macros.vh",
                    "defines.sv",
                    "../../../../checks/rvfi_channel.sv",
                    "../../../../checks/rvfi_testbench.sv",
                ]
                files = extract_files_list(sby_path, common_files)
                write_file(defines_path, defines_content)
                defines_created += 1

                create_tcl_file(target_folder, folder_name, files, directory_name, sby_path)
                tcl_created += 1

                # Add instruction name to instruction list
                instruction_names.append(folder_name)

            except Exception as e:
                print(f"Error processing '{file_name}': {e}")
                if defines_created == total_sby_files - tcl_created - 1:  # Fails in define stage
                    defines_failed += 1
                else:
                    tcl_failed += 1

    # Create Makefile in make_folder
    try:
        makefile_path = os.path.join(make_folder, "makefile")
        create_makefile(makefile_path, instruction_names)
        print("Makefile created")
    except Exception as e:
        print(f"Error creating Makefile: {e}")
        print("Makefile creation failed")

    # Printing stats
    print("\n--- Defines File Creation Stats ---")
    print(f"Total .sby files:       {total_sby_files}")
    print(f"Defines created:        {defines_created}")
    print(f"Defines creation failed: {defines_failed}")

    print("\n--- TCL File Creation Stats ---")
    print(f"TCL files created:      {tcl_created}")
    print(f"TCL creation failed:     {tcl_failed}")

    print("-------------------------------")
    print("Processing completed successfully.\n")

    # Write log message to checks_processing_log.txt
    log_path = os.path.join(destination_folder, "checks_processing_log.txt")
    with open(log_path, "w") as log_file:
        log_file.write(log_message)

    # Print log summary to terminal in single lines
    if checks_ran:
        print("Checks ran:", " ".join(checks_ran))
    if checks_skipped:
        print("\nChecks skipped:", " ".join(checks_skipped))

def extract_defines_content(sby_path):
    """Extract [file defines.sv] section from the .sby file, ensuring no duplicate lines."""
    defines_content = []
    seen_lines = set()  # Track lines to ensure uniqueness
    current_section = None

    with open(sby_path, "r") as sby_file:
        for line in sby_file:
            line = line.strip()
            if line.startswith("["):
                if "[file defines.sv]" in line:
                    current_section = "defines"
                else:
                    current_section = None
                continue

            if current_section == "defines" and line not in seen_lines:
                defines_content.append(line)
                seen_lines.add(line)  # Mark the line as seen

    if not defines_content:
        raise ValueError("No content found in [file defines.sv] section.")
    return "\n".join(defines_content)

def extract_files_list(sby_path, common_files):
    """Extract [files] section from the .sby file, ensuring no duplicates based on the file name."""
    files = []
    current_section = None

    # Extract the file names from common_files (without paths)
    common_file_names = [os.path.basename(file) for file in common_files]

    with open(sby_path, "r") as sby_file:
        for line in sby_file:
            line = line.strip()
            
            # Skip empty lines
            if not line:
                continue

            if line.startswith("["):
                if "[files]" in line:
                    current_section = "files"
                else:
                    current_section = None
                continue

            if current_section == "files":
                # Extract the file name without the path
                file_name = os.path.basename(line)
                
                # Only add the file if it is not in the common_files list
                if file_name not in common_file_names:
                    # Ensure that we keep the "checks" and "insns" parts of the path intact
                    if "checks" in line:
                        # Find the relative path from 'checks' onwards and add it
                        line = os.path.join("checks", os.path.relpath(line, start=os.path.dirname(line)).lstrip(os.sep))
                    elif "insns" in line:
                        # Find the relative path from 'insns' onwards and add it
                        line = os.path.join("insns", os.path.relpath(line, start=os.path.dirname(line)).lstrip(os.sep))

                    files.append(line)

    if not files:
        raise ValueError("No files found in [files] section.")
    
    return files

def create_tcl_file(target_folder, folder_name, files, directory_name, sby_path):
    """Generate the .tcl file for the respective folder."""
    tcl_file_path = os.path.join(target_folder, f"{folder_name}.tcl")

    common_files = [
        "../../../../checks/rvfi_macros.vh",
        "defines.sv",
        "../../../../checks/rvfi_channel.sv",
        "../../../../checks/rvfi_testbench.sv",
    ]

    # Extract files without duplicates
    files = extract_files_list(sby_path, common_files)  # Pass common_files for duplication check

    wrapper_file = "../../wrapper.sv"
    core_file = f"../../{directory_name}.sv"

    analyze_files = "\n    ".join(
        common_files + [f"../../../../{file}" for file in files] + [wrapper_file, core_file]
    )

    tcl_content = f"""# Simple TCL script for VC Formal

# Set reset behavior without permanent constraint
set reset_without_constraint 1

# Configure VC Formal environment and application variables
setenv VERDI_COLOR_THEME brightPlus
set_fml_appmode FPV
set_app_var apply_bind_in_all_units true
set_app_var analyze_skip_translate_body false
set_app_var fml_auto_save default
set_app_var fml_composite_trace true
set_fml_var fml_witness_on true
set_fml_var fml_vacuity_on true

# Set paths to libraries and design files
cd [file dirname [info script]]

# Analyze design files
analyze -format sverilog -vcs -verbose {{
    {analyze_files}
}}

# Set the correct top module
set top rvfi_testbench

# Elaborate the top module
set elaborateOption -verbose 
elaborate $top -verbose -sva

create_clock clock -period 200
if {{$reset_without_constraint}} {{
    sim_force reset -apply 1'b1
}} else {{
    create_reset reset -sense high
}}

# For Batch
check_fv -block
report_fv -list > {folder_name}_results.txt
save_session -session {folder_name}_results

"""

    write_file(tcl_file_path, tcl_content)

def create_makefile(makefile_path, instruction_names):
    """Create the Makefile for all instructions."""
    all_target = "all: " + " ".join(instruction_names)
    makefile_content = all_target + "\n"

    for instruction in instruction_names:
        makefile_content += f"{instruction}: ../{instruction}/{instruction}_results.txt\n"
        makefile_content += f"../{instruction}/{instruction}_results.txt:\n"
        makefile_content += f"\tvcf -f ../{instruction}/{instruction}.tcl -batch\n"
        makefile_content += f".PHONY: {instruction}\n"

    write_file(makefile_path, makefile_content)

def write_file(file_path, content):
    """Write the content to the specified file."""
    try:
        with open(file_path, "w") as file:
            file.write(content)
    except Exception as e:
        raise IOError(f"Failed to write to {file_path}: {e}")

if __name__ == "__main__":
    process_sby_files()

