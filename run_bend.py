import subprocess
import re


def run_bend_script():
    result = subprocess.run(['bend', 'run', 'rule_array.bend'], capture_output=True, text=True)
    return result.stdout


def extract_ascii_values(output):
    pattern = r'IO/FS/STDOUT, \[(.*?)\]'
    matches = re.findall(pattern, output)
    return [list(map(int, match.split(','))) for match in matches]


def ascii_to_string(ascii_list):
    return ''.join(chr(ascii_code) for ascii_code in ascii_list)


def main():
    output = run_bend_script()
    ascii_value_lists = extract_ascii_values(output)

    for ascii_values in ascii_value_lists:
        print(ascii_to_string(ascii_values))


if __name__ == "__main__":
    main()