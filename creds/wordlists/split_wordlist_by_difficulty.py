#!/usr/bin/python

very_hard_pass_min_length = 15
hard_pass_min_length = 12
medium_pass_min_length = 9
easy_pass_min_length = 6

file_name_in = "input.txt"
file_name_out = "output"

file_handles = {
  "trivial": open(f"{file_name_out}-trivial.txt", "a", encoding="utf-8"),
  "easy": open(f"{file_name_out}-easy.txt", "a", encoding="utf-8"),
  "medium": open(f"{file_name_out}-medium.txt", "a", encoding="utf-8"),
  "hard":  open(f"{file_name_out}-hard.txt", "a", encoding="utf-8"),
  "very-hard": open(f"{file_name_out}-very-hard.txt", "a", encoding="utf-8")
}

translate_to_ascii = {
  "ą": "a",
  "ć": "c",
  "ę": "e",
  "ł": "l",
  "ń": "n",
  "ó": "o",
  "ś": "s",
  "ź": "z",
  "ż": "z",
  "Ą": "A",
  "Ć": "C",
  "Ę": "E",
  "Ł": "L",
  "Ń": "N",
  "Ó": "O",
  "Ś": "S",
  "Ż": "Z",
  "Ź": "Z",
  "\x0d": "",
  "\x0a": "",
  " ": ""
}

print("[*] processing")
with open(file_name_in, "r", encoding="utf-8") as f:
    for result in f:
        if result in ["\n", "\r\n"]:
            continue

        outcome = result
        for old, new in translate_to_ascii.items():
            outcome = outcome.replace(old, new)

        category = "trivial"
        
        if len(outcome) >= easy_pass_min_length:
            category = "easy"
        if len(outcome) >= medium_pass_min_length:
            category = "medium"
        if len(outcome) >= hard_pass_min_length:
            category = "hard"
        if len(outcome) >= very_hard_pass_min_length:
            category = "very-hard"

        file_handles[category].write(f"{outcome}\n")
        
print("[+] success")
