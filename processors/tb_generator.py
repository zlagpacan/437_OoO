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

# PRINTS = False
PRINTS = True
BLOCK_IS_SEQ = False

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

        # try to exit io
        if line.lstrip().rstrip() == ");":
            assert inside_io, "found I/O exit \");\" when not inside I/O def"
            inside_io = False
            break

        # when inside I/O signal def
        if inside_io:
            stripped_line = line.lstrip().rstrip().rstrip(",")

            # skip seq comment
            if stripped_line.startswith("//") and "seq" in stripped_line:
                continue

            # skip CLK and nRST
            if "CLK" in stripped_line or "nRST" in stripped_line:
                global BLOCK_IS_SEQ
                BLOCK_IS_SEQ = True
                continue

            # add any empty lines as signals
            if not stripped_line:
                design_signals.append(Signal("", "empty", line))
                continue

            # add any top level comments as signals
            if stripped_line.startswith("//"):
                design_signals.append(Signal("", "comment", line))
                continue

            # cut off any mid-line comments
            if "//" in stripped_line:
                stripped_line = stripped_line[:stripped_line.index("//")].rstrip().rstrip(",")

            # split line at spaces
            tuple_line = tuple(stripped_line.split())
            print(tuple_line) if PRINTS else None
            design_signals.append(Signal(tuple_line[0], tuple_line[1], tuple_line[2]))
            continue

        # ignore empty lines
        if not line.lstrip().rstrip():
            print(f"found empty line at line {line_index}") if PRINTS else None
            continue

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

        # try to enter io
        if line.lstrip().startswith(")") and line.rstrip().endswith("("):
            inside_io = True
            continue

    if inside_io:
        print("WARNING: did not find clean I/O section exit")

    assert design_signals, "could not find any signals in design"

    return design_name, design_signals

def generate_tb(tb_base_lines, design_name, design_signals):
    
    output_lines = []

    # iterate through tb base lines adding in info based on design_name and design_signals as go
    num_found = 0
    for line_index, line in enumerate(tb_base_lines):

        # check for <design_name> line
        if "<design_name>" in line:
            replaced_line = line.replace("<design_name>", design_name)
            print(f"found <design_name> in line") if PRINTS else None
            print(f"old line: {line}") if PRINTS else None
            print(f"replaced line: {replaced_line}") if PRINTS else None

            output_lines.append(replaced_line)

            num_found += 1
            continue

        # check for <DUT signals>
        if line.lstrip().rstrip() == "<DUT signals>":
            print(f"found <DUT signals> at line {line_index}") if PRINTS else None

            # iterate through design_signals adding tb signal instantiation
            DUT_signal_lines = []
            for signal in design_signals:
                
                # input
                if signal.io == "input":
                    DUT_signal_lines.extend([
                        # f"\t// {signal.io} {signal.type} {signal.name},\n"
                        f"\t{signal.type} tb_{signal.name};\n",
                    ])

                # output
                elif signal.io == "output":
                    DUT_signal_lines.extend([
                        # f"\t// {signal.io} {signal.type} {signal.name},\n"
                        f"\t{signal.type} DUT_{signal.name}, expected_{signal.name};\n",
                    ])

                # empty
                elif signal.type == "empty":
                    DUT_signal_lines.extend([
                        f"\n"
                    ])
                    
                # comment
                elif signal.type == "comment":
                    DUT_signal_lines.extend([
                        f"{signal.name}"
                    ])

                # not input or output
                else:
                    assert False, f"invalid input vs. output for signal {signal}"

            output_lines.extend(DUT_signal_lines)

            num_found += 1
            continue

        # check for <DUT instantiation>
        if line.lstrip().rstrip() == "<DUT instantiation>":
            print(f"found <DUT instantiation> at line {line_index}") if PRINTS else None

            DUT_instantiation_lines = []

            # add beginning of DUT module instantation
            DUT_instantiation_lines.extend([
                f"\t{design_name} #(\n",
                f"fill in params\n",
                f"\t) DUT (\n",
            ])

            # add seq lines if applicable
            global BLOCK_IS_SEQ
            if BLOCK_IS_SEQ:
                DUT_instantiation_lines.extend([
                    f"\t\t// seq\n",
                    f"\t\t.CLK(CLK)\n",
                    f"\t\t.nRST(nRST)\n",
                ])

            # iterate through signals adding signal connection lines
            for signal in design_signals:
                
                # input
                if signal.io == "input":
                    DUT_instantiation_lines.extend([
                        # f"\t// {signal.io} {signal.type} {signal.name},\n"
                        f"\t\t.{signal.name}(tb_{signal.name}),\n",
                    ])

                # output
                elif signal.io == "output":
                    DUT_instantiation_lines.extend([
                        # f"\t// {signal.io} {signal.type} {signal.name},\n"
                        f"\t\t.{signal.name}(DUT_{signal.name}),\n",
                    ])

                # empty
                elif signal.type == "empty":
                    DUT_instantiation_lines.extend([
                        f"\n"
                    ])
                    
                # comment
                elif signal.type == "comment":
                    DUT_instantiation_lines.extend([
                        f"\t{signal.name}"
                    ])

                # not input or output
                else:
                    assert False, f"invalid input vs. output for signal {signal}"

            # remove comma from last non-comment
            found_last_comma = False
            for i in range(-1, -1 - len(DUT_instantiation_lines), -1):
                if DUT_instantiation_lines[i].endswith(",\n"):
                    DUT_instantiation_lines[i] = DUT_instantiation_lines[i].rstrip().rstrip(",") + "\n"

                    found_last_comma = True
                    break

            # finish DUT instantiation
            DUT_instantiation_lines.extend([
                "\t);\n"
            ])
            
            assert found_last_comma, "in DUT instantiation, did not find signal assignment ending in comma"

            output_lines.extend(DUT_instantiation_lines)

            num_found += 1
            continue
            
        # check for <task check_outputs>
        if line.lstrip().rstrip() == "<task check_outputs>":
            print(f"found <task check_outputs> at line {line_index}") if PRINTS else None

            # iterate through output design_signals adding associated check
            task_check_outputs_lines = []
            for output_signal in [signal for signal in design_signals if signal.io == "output"]:
                print(f"add check for output_signal = {output_signal.name}") if PRINTS else None
                task_check_outputs_lines.extend([
                    f"\t\tif (expected_{output_signal.name} !== DUT_{output_signal.name}) begin\n",
                    f"\t\t\t$display(\"\\tERROR: expected_{output_signal.name} (%h) != DUT_{output_signal.name} (%h)\",\n",
                    f"\t\t\t\texpected_{output_signal.name}, DUT_{output_signal.name});\n"
                    f"\t\t\tnum_errors++;\n",
                    f"\t\t\terror = 1'b1;\n",
                    f"\t\tend\n",
                    f"\n",
                ])

            output_lines.extend(task_check_outputs_lines)

            num_found += 1
            continue
            
        # check for <assert reset test case>
        if line.lstrip().rstrip() == "<assert reset test case>":
            print(f"found <assert reset test case> at line {line_index}") if PRINTS else None

            num_found += 1
            continue

        # check for <deassert reset test case>
        if line.lstrip().rstrip() == "<deassert reset test case>":
            print(f"found <deassert reset test case> at line {line_index}") if PRINTS else None

            num_found += 1
            continue
            
        # check for <default test case>
        if line.lstrip().rstrip() == "<default test case>":
            print(f"found <default test case> at line {line_index}") if PRINTS else None

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

    print("output tb base written tb_output.txt")