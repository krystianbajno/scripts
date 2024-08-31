#!/usr/bin/python

import os
import random

directory = './images'

key = ""
for filename in os.listdir(directory):
   image = os.path.join(directory, filename)
   if os.path.isfile(image):
     with open(image, 'rb') as f:
       key += bytes.hex(f.read())

key = list(key)
random.shuffle(key)
key = ''.join(key)

print(f"Key: {key[:2048]}...\nKey length: {len(key)/2} bytes")
print(f"Saving to stego/key.bin")

with open("key.bin", 'w') as f:
   f.write(key)