import re
import csv
from collections import defaultdict

def parse_prolog_output(file_path):
    with open(file_path, "r") as file:
        content = file.read()
    test_cases = re.split(r"Running algorithms on list:", content)[1:]
    results = []
    for case in test_cases:
        lines = case.strip().split("\n")
        input_list = eval(lines[0])
        case_results = defaultdict(float)
        case_results["input_list"] = input_list
        for i in range(1, len(lines), 2):
            cpu_time = float(re.search(r"CPU time: ([\d.e-]+)", lines[i]).group(1))
            algo_type = re.search(r"Algotype: (.+)", lines[i+1]).group(1)
            case_results[algo_type] = cpu_time
        results.append(case_results)
    return results

def save_to_csv(results, output_file):
    if not results:
        print("No results to save.")
        return
    fieldnames = ["input_list"] + sorted(set(key for result in results for key in result.keys() if key != "input_list"))
    with open(output_file, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for result in results:
            writer.writerow(result)
input_file = "prolog_output.txt"
output_file = "sorting_results.csv"
results = parse_prolog_output(input_file)
save_to_csv(results, output_file)
print(f"Results have been saved to {output_file}")

