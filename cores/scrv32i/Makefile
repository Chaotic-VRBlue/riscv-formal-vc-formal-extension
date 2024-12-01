#  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
#
#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.
#
#  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
#  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
#  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Contributions by Rohith V <vrohithkattimani@gmail.com>
# LinkedIn: https://www.linkedin.com/in/v-rohith-km/
# ---------- Additional Contributions: ----------
# - Enhanced compatibility with Synopsys VC Formal
# - Implemented new targets for VCF-specific workflows
# - Automated result processing for VCF checks

# Standard targets
checks:
	python3 ../../checks/genchecks.py
	$(MAKE) -C checks

check: checks
	bash cexdata.sh
	cat cexdata/warnings.txt
	cat cexdata/status.txt

clean:
	rm -rf firmware.elf firmware.hex testbench testbench.vcd gtkwave.log
	rm -rf disasm.o disasm.s checks/ cexdata/

# New VCF-related targets
vcf_checks:
	python3 ../../checks/genchecks.py
	python3 ../../vc_formal/sby_to_tcl.py

vcf_check: vcf_checks
	bash vcf_cexdata.sh
	(cat vcf_cexdata/warnings.txt; echo)
	(cat vcf_cexdata/errors.txt; echo)
	python3 ../../vc_formal/vcf_res_process.py
	cat vcf_cexdata/results.txt

vcf_clean:
	rm -rf vcf_cexdata/ vcf/ checks/

