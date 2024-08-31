import argparse

parser = argparse.ArgumentParser(description="XOR file encryption")
parser.add_argument("input", help="Input file")
parser.add_argument("output", help="Out file")
parser.add_argument("key", help="Key file")

args = parser.parse_args()

key_hex = ""

with open(args.key, "r") as f:
  key_hex = f.read()

key = bytes.fromhex(key_hex)

def xor(data, key):
    encrypted_data = bytearray(len(data))
    for i in range(len(data)):
        encrypted_data[i] = data[i] ^ key[i % len(key)]

    return bytes(encrypted_data)

with open(args.input, "rb") as f:
    payload = f.read()
    print()

    encrypted_payload = xor(payload, key)

with open(args.output, "wb") as f2:
    f2.write(encrypted_payload)

print(f"Key is: {key_hex[:512]}")
print(f"[ENCRYPTED_FROM]\r\n{payload[:512]}")
print(f"[ENCRYPTED TO]\r\n{encrypted_payload[:512]}")