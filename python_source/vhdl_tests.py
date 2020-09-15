import os
import random

import subterranean_bit

def print_state_to_VHDL(s, file):
    output = ""
    for i in range(257):
        output = ("{0:01b}").format(s[i]) + output
    file.write(output)
    file.write('\n')

def print_subterranean_permutation(number_of_tests, VHDL_file_name="subterranean_permutation.dat"):
    tests_folder = "../data_tests/"
    if(not os.path.isdir(tests_folder)):
        os.makedirs(tests_folder)
    with open(tests_folder+VHDL_file_name, 'w') as VHDL_memory_file:
        VHDL_memory_file.write((("{0:0d}").format(number_of_tests)))
        VHDL_memory_file.write('\n')
        s = [0 for i in range(257)]
        for i in range(number_of_tests):
            print_state_to_VHDL(s, VHDL_memory_file)
            s = subterranean_bit.subterranean_round(s)
            print_state_to_VHDL(s, VHDL_memory_file)
            s = [random.randint(0, 1) for i in range(257)]

if __name__ == "__main__":
    print_subterranean_permutation(100)