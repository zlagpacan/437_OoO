"""
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: tb_generator.py
    Instantiation Hierarchy: N/A
    Description: 
       Python script for translating a leaf SystemVerilog design .sv file into a base testbench for the
       design
    Usage:
        from 437_OoO/processors directory:
        python3 tb_generator.py <path to design .sv file>
"""

import sys

PRINTS = False

class Signal():
    def __init__(self, io, type, name):
        self.io = io
        self.type = type
        self.name = name

def parse_design(design_lines):

    # iterate through design lines looking for design name
    design_name = None
    for line in design_lines:
        if line.lstrip().startswith("module"):
            design_name = line[len("module"):].lstrip().rstrip().rstrip("(#").rstrip()
            break

    assert design_name, "could not find design name"
    print(f"design_name = {design_name}") if PRINTS else None

    # iterate through design lines looking for design signals
    design_signals = []
    inside_multiline_comment = False
    inside_io = False
    for line_index, line in enumerate(design_lines):

        # ignore comment lines
        if "/*" in line:
            print(f"entering multiline comment at line {line_index}") if PRINTS else None
            inside_multiline_comment = True
            continue
        if inside_multiline_comment:
            if "*/" in line:
                print(f"exiting multiline comment at line {line_index}") if PRINTS else None
                inside_multiline_comment = False
            continue
        if line.lstrip().rstrip().startswith("//"):
            print(f"found comment at line {line_index}") if PRINTS else None
            continue

        # ignore empty lines
        if not line.lstrip().rstrip():
            print(f"found empty line at line {line_index}") if PRINTS else None
            continue

        # try to enter io
        if line.lstrip().startswith(")") and line.rstrip().endswith("("):
            inside_io = True
            continue

        # try to exit io
        elif line.lstrip().rstrip() == ");":
            assert inside_io, "found I/O exit \");\" when not inside I/O def"
            inside_io = False
            break

        # when inside I/O signal def
        if inside_io:
            stripped_line = line.lstrip().rstrip().rstrip(",")

            # skip CLK and nRST
            if "CLK" in stripped_line or "nRST" in stripped_line:
                continue

            # cut off any comments
            if "//" in stripped_line:
                stripped_line = stripped_line[:stripped_line.index("//")].rstrip().rstrip(",")

            # split line at spaces
            tuple_line = tuple(stripped_line.split())
            print(tuple_line) if PRINTS else None
            design_signals.append(tuple_line)

    if inside_io:
        print("WARNING: did not find clean I/O section exit")

    assert design_signals, "could not find any signals in design"
    print(f"design_signals = ") if PRINTS else None
    for signal in design_signals:
        print(f"\t{signal}") if PRINTS else None

    return design_name, design_signals

def generate_tb(tb_base_lines, design_name, design_signals):
    
    output_lines = []

    # iterate through tb base lines adding in info based on design_name and design_signals as go
    num_found = 0
    for line_index, line in enumerate(tb_base_lines):

        # check for <design_name> line
        if "<design_name>" in line:
            replaced_line = line.replace("<design_name>", design_name)
            print(f"found <design_name> in line")
            print(f"old line: {line}")
            print(f"replaced line: {replaced_line}")

            output_lines.append(replaced_line)

            num_found += 1
            continue

        # check for <DUT signals>
        if line.lstrip().rstrip() == "<DUT signals>":
            print(f"found <DUT signals> at line {line_index}")

            num_found += 1
            continue

        # check for <DUT instantiation>
        if line.lstrip().rstrip() == "<DUT instantiation>":
            print(f"found <DUT instantiation> at line {line_index}")

            num_found += 1
            continue
            
        # check for <task check_outputs>
        if line.lstrip().rstrip() == "<task check_outputs>":
            print(f"found <task check_outputs> at line {line_index}")

            num_found += 1
            continue
            
        # check for <assert reset test case>
        if line.lstrip().rstrip() == "<assert reset test case>":
            print(f"found <assert reset test case> at line {line_index}")

            num_found += 1
            continue

        # check for <deassert reset test case>
        if line.lstrip().rstrip() == "<deassert reset test case>":
            print(f"found <deassert reset test case> at line {line_index}")

            num_found += 1
            continue
            
        # check for <default test case>
        if line.lstrip().rstrip() == "<default test case>":
            print(f"found <default test case> at line {line_index}")

            num_found += 1
            continue

        # otherwise, regular tb base line, add as-is
        output_lines.append(line)

    assert num_found == 9, "did not find all entries to replace in tb_base.txt\n" + \
        "(may have added more and not updated required num_found in this script)"

    return output_lines

if __name__ == "__main__":

    assert len(sys.argv) == 2, f"len(sys.argv) = {len(sys.argv)}; expect commandline input as:\n" + \
        "python3 tb_generator.py <path to design .sv file>"

    # get input design file
    try:
        with open(sys.argv[1], "r") as fp:
            design_lines = fp.readlines()
    except:
        assert False, f"could not find {sys.argv[1]}"

    # get tb base
    try:
        with open("testbench/tb_base.txt", "r") as fp:
            tb_base_lines = fp.readlines()
    except:
        assert False, "could not find testbench/tb_base.txt"
            
    # run generator algo
    design_name, design_signals = parse_design(design_lines)

    output_lines = generate_tb(tb_base_lines, design_name, design_signals)

    # write output to tb_output.txt
    with open("tb_output.txt", "w") as fp:
        fp.writelines(output_lines)