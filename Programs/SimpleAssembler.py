
def nzp_to_bin(nzp):
    """Converts the NZP condition codes to a 3-bit binary representation."""
    n, z, p = 0, 0, 0
    if 'n' in nzp:
        n = 1
    if 'z' in nzp:
        z = 1
    if 'p' in nzp:
        p = 1
    return f"{n}{z}{p}"

def assemble_br_instruction(instruction):
    """Assembles a BR instruction to machine code."""
    parts = instruction.split()
    print(parts) 
    opcode = "0000"  # Opcode for BR
    nzp = nzp_to_bin(parts[1])  # NZP condition codes
    pcoffset9 = pcoffset9_to_bin(int(parts[2]))  # PCoffset9
    
    machine_code = opcode + nzp + pcoffset9
    return machine_code

def pcoffset9_to_bin(value):
    """Converts a PCoffset9 value to its 9-bit signed binary representation."""
    if -256 <= value <= 255:
        return format(value & 0x1FF, '09b')  # Masking with 0x1FF to handle negatives
    else:
        raise ValueError("PCoffset9 value out of range (-256 to 255)")

def assemble_ld_instruction(instruction):
    """Assembles an LD instruction to machine code."""
    parts = instruction.split()
    print(parts) 
    opcode = "0010"  # Opcode for LD
    dr = register_to_bin(parts[1])  # Destination Register
    pcoffset9 = pcoffset9_to_bin(int(parts[2]))  # PCoffset9
    
    machine_code = opcode + dr + pcoffset9
    return machine_code

def assemble_st_instruction(instruction):
    """Assembles an ST instruction to machine code."""
    parts = instruction.split()
    print(parts) 
    opcode = "0011"  # Opcode for ST
    sr = register_to_bin(parts[1])  # Source Register
    pcoffset9 = pcoffset9_to_bin(int(parts[2]))  # PCoffset9
    
    machine_code = opcode + sr + pcoffset9
    return machine_code


def register_to_bin(register):
    """Converts a register like R0 to its binary representation."""
    return format(int(register[1]), '03b')

def imm5_to_bin(value):
    """Converts an immediate value to its 5-bit signed binary representation."""
    if -16 <= value <= 15:
        return format(value & 0x1F, '05b')  # Masking with 0x1F to handle negatives
    else:
        raise ValueError("Immediate value out of range (-16 to 15)")

def assemble_add_instruction(instruction):
    """Assembles an ADD instruction to machine code."""
    parts = instruction.split()
    print(parts) 
    opcode = "0001"  # Opcode for ADD
    
    # Parse the destination and source registers
    dr = register_to_bin(parts[1])
    sr1 = register_to_bin(parts[2])
    
    # Check if the 4th part is a 1 (immediate mode) or 000 (register mode)
    if parts[3] == "1":
        imm_flag = "1"
        imm5 = imm5_to_bin(int(parts[4]))
        machine_code = opcode + dr + sr1 + imm_flag + imm5
    elif parts[3] == "000":
        imm_flag = "0"
        sr2 = register_to_bin(parts[4])
        machine_code = opcode + dr + sr1 + imm_flag + "00" + sr2
    else:
        raise ValueError("Invalid ADD instruction format.")
    
    return machine_code

def assemble_instructions_from_file(input_file, output_file):
    """Reads assembly instructions from a file, assembles them, and writes the machine code to an output file."""
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            line = line.strip()
            if not line or line.startswith(';'):  # Skip empty lines and comments
                continue
            
            if line.startswith("ADD"):
                machine_code = assemble_add_instruction(line)
                outfile.write(machine_code + '\n')
            elif line.startswith("LD"):
                machine_code = assemble_ld_instruction(line)
                outfile.write(machine_code + '\n')
            elif line.startswith("ST"):
                machine_code = assemble_st_instruction(line)
                outfile.write(machine_code + '\n')
            elif line.startswith("BR"):
                machine_code = assemble_br_instruction(line)
                outfile.write(machine_code + '\n')
            else:
                # Handle other instructions or raise an error if unsupported
                raise ValueError(f"Unsupported instruction: {line}")

# Example usage
input_file = 'input.txt'  # Input file containing assembly instructions
output_file = 'output.txt'  # Output file to write the binary machine code

assemble_instructions_from_file(input_file, output_file)

