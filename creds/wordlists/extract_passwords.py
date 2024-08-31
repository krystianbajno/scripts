import re

input_file = 'CHANGEME_IN'
output_file = 'CHANGEME_OUT'

pattern = re.compile(r':([^:\n\r]*)$')

def extract_passwords(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
        with open(output_file, 'w', encoding='utf-8') as outfile:
            for line in infile:
                match = pattern.search(line)
                if match:
                    password = match.group(1)
                    outfile.write(password + '\n')

extract_passwords(input_file, output_file)
