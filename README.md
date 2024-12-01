# RISC-V Formal Verification Framework Extension for Synopsys VC Formal

This repository is an **extension** of the official [riscv-formal](https://github.com/YosysHQ/riscv-formal) repository. It integrates the RISC-V formal verification framework with **Synopsys VC Formal tool**, enabling verification of RISC-V cores. This project focuses on providing an implementation workflow and examples for leveraging the VC Formal toolset alongside the existing framework.

## Features

### 1. **Integration with Synopsys VC Formal**
- **Property Checking and Bug Hunting**: Utilizes Synopsys VC Formal to perform property checking and identify bugs in the RISC-V core design.
- **.tcl Script Generation**: Python scripts automatically generate `.tcl` files compatible with VC Formal from `.sby` files.
- **Automated Makefile Generation**: A `Makefile` is created to organize and run multiple formal verification checks efficiently.

### 2. **Enhanced Automation**
- **(Pre-Processing) `.sby` File Conversion**: The `sby_to_tcl.py` Python script processes `.sby` files, converting them into `.tcl` files that are ready for formal verification. Additionally, it generates a `Makefile` to automatically run all checks in batch mode.
- **(Processing) Error and Warning Handling**: The `vcf_cexdata.sh` script collects and processes error and warning messages from VC Formal runs, saving them in structured files (`warnings.txt`, `errors.txt`).
- **(Post-Processing) Results Categorization and Formatting**: The `vcf_res_process.py` script parses the results of the verification, categorizes assertions (PASS/FAIL/INCONCLUSIVE), and formats them into readable summaries for further analysis.

### 3. **Easy Integration and Setup**
- **Flexible Workflow**: The entire formal verification process is managed through a single `Makefile`, allowing users to trigger different stages of the verification process with simple commands like `make vcf_check`, `make vcf_clean`, etc., eliminating the need to remember and execute multiple commands manually.

## Requirements

1. **Tools**:
   - Synopsys VC Formal
   - Python (3.x)
   - Bash (for shell scripting)
   - Yosys (optional)

## Running the Example SCRV32I Processor (For Understanding the Workflow)

1. Clone the Repository
   ```bash
   git clone https://github.com/Chaotic-VRBlue/riscv-formal-vc-formal-extension.git
   cd riscv-formal-vc-formal-extension
   ```

2. Navigate to the Core and Clean Previous Files and Results
   ```
   cd cores/scrv32i
   make vcf_clean
   ```

3. Run All Checks Automatically and View Results
   ```
   make vcf_check
   ```

   Once the process is complete, the terminal will display results in the following order:
   - Warnings
   - Errors
   - Verification results (PASS/FAIL/INCONCLUSIVE/UNKNOWN; If failed to run)

   These outputs are also saved in the `vcf_cexdata` folder for later review.

4. *(Optional)* Run a Specific Check:
   To run a specific formal verification check, use the following commands:
   ```
   cd vcf/{check_name}
   vcf -f {check_name}.tcl -batch
   ```
   This runs the selected check in **batch mode** and generates a result file named `{check_name}_results.txt`, where you can review the verification results.

   If you want to run the check directly in **GUI mode** for interactive debugging, use:
   ```
   vcf -f {check_name}.tcl -verdi
   ```
   This command launches **Verdi**, allowing you to visually analyze results and debug in an interactive environment.

5. View Waveforms in GUI Mode for Debugging:
   If you encounter a failing check or wish to analyze waveforms for a specific check:
   ```
   cd vcf/{check_name}
   vcf -restore -session {check_name}_results
   ```
   ```
   start_gui
   ```
   Since the formal verification for this check has already been run, there is no need to rerun it. Simply restore the session to view the waveforms in **GUI mode**. *Note that only one check can be analyzed in GUI mode at a time*.

6. Fix Bugs and Rerun Checks:
After debugging and making necessary fixes, you can rerun the verification. However, ensure you clean the previous results first:
   ```
   make vcf_clean
   make vcf_check
   ```
7. *(Optional)* Customize Checks to Run or Skip (do this before running):
You can configure which checks to run or skip by creating configuration files in the `vcf_checks_config` folder within the core directory (e.g., `cores/scrv32i`):

   - Case 1: Skip Specific Checks -
Create a file named `checks_to_skip.txt` and list the checks to skip, each separated by a space.
   - Case 2: Run Specific Checks Only -
Create a file named `checks_to_run.txt` and list the checks to run, separated by spaces.
   - Case 3: Default Mode (Run All Checks) -
If no configuration files are present, all checks will run by default.
   - Case 4: Conflict Between Files -
If both `checks_to_skip.txt` and `checks_to_run.txt` exist simultaneously, the program will terminate with an error message indicating that this setup is not supported.

## Configuring a New RISC-V Processor

1. First, refer to the `riscv-formal` repository and follow the steps outlined in the [riscv-formal guide](https://github.com/YosysHQ/riscv-formal?tab=readme-ov-file#configuring-a-new-risc-v-processor). Complete everything up to step 5. You don't need to run step 5, as it involves using an open-source tool. For our purpose, we will run it using the VC Formal tool, so step 5 can be skipped. If you're interested, you can explore it, but it's not required for this process.

2. Once the `RVFI` (RISC-V Formal Interface), `wrapper.sv` file, and `checks.cfg` file are implemented for your RISC-V processor as per the steps in the `riscv-formal` repository, you can proceed with running the RISC-V formal framework for your core on the Synopsys VC Formal Tool.

   *(Note: You may need to refer to the entire repository to complete this part, not just the section I linked here.)*

3. Copy the `vcf_cexdata.sh` and `Makefile` files from the `scrv32i` folder into your core folder.

4. Navigate to your core directory and run:
   ```bash
   cd cores/{core}
   make vcf_clean
   make vcf_check
   ```

   Once the process is complete, the terminal will display results in the following order:
   - Warnings
   - Errors
   - Verification results (PASS/FAIL/INCONCLUSIVE/UNKNOWN - If failed to run)

5. Then you can utilize features such as running specific checks (including in GUI mode), launching the GUI, and customizing checks to run or skip, as shown in the 'Running the Example SCRV32I Processor (For Understanding the Workflow)' section above.

## Notes
- The `checks` and `insns` folders in this repository are identical to those in the [riscv-formal](https://github.com/YosysHQ/riscv-formal) repository. That repository is the master repository for riscv-formal, and any future updates to the framework should be referred to there.
- This repository serves as an extension of the riscv-formal framework, enabling its use with the Synopsys VC Formal Tool. Any significant changes in the main riscv-formal repository in the future may cause this implementation to fail, and updates may be required to keep this extension compatible.
- Only the `vc_formal` folder in the root directory, the `vcf_cexdata.sh` file in the `scrv32i` folder, and a few additions to the `Makefile` inside the `scrv32i` directory were created by me to implement this extension.
