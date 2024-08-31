import argparse
from PIL import Image
import numpy as np

def load_binary_data(filename):
    with open(filename, 'rb') as file:
        return file.read()

def encode_image(img, data, output_path):
    if img.mode != 'RGB':
        img = img.convert('RGB')

    img_data = np.array(img)

    data_len_bin = format(len(data), '032b')
    data_bin = data_len_bin + ''.join([format(byte, '08b') for byte in data])
    if img_data.size < len(data_bin):
        raise ValueError("Data is too large for the image")

    data_index = 0
    for i in range(img_data.shape[0]):
        for j in range(img_data.shape[1]):
            for k in range(3):
                if data_index < len(data_bin):
                    img_data[i, j, k] = img_data[i, j, k] & ~1 | int(data_bin[data_index])
                    data_index += 1
                else:
                    break
    encoded_img = Image.fromarray(img_data)
    encoded_img.save(output_path)

def decode_image(img):
    img_data = np.array(img)
    binary_data = ""
    for i in range(img_data.shape[0]):
        for j in range(img_data.shape[1]):
            for k in range(3):
                binary_data += str(img_data[i, j, k] & 1)

    data_len = int(binary_data[:32], 2)
    data_bin = binary_data[32:32 + data_len * 8]

    decoded_data = bytes(int(data_bin[i: i+8], 2) for i in range(0, len(data_bin), 8))
    return decoded_data

def main():
    parser = argparse.ArgumentParser(description="Steganography encoder/decoder")
    parser.add_argument("mode", choices=["encode", "decode"], help="Mode of operation")
    parser.add_argument("input", help="Input file path")
    parser.add_argument("output", help="Output file path")
    parser.add_argument("--payload", help="Payload file for encoding", required=False)

    args = parser.parse_args()

    if args.mode == "encode":
        if not args.payload:
            raise ValueError("Data file is required for encoding")
        image = Image.open(args.input)
        data = load_binary_data(args.payload)
        encode_image(image, data, args.output)
        print(f"Encoded image saved to {args.output}")
    
    elif args.mode == "decode":
        image = Image.open(args.input)
        decoded_data = decode_image(image)
        with open(args.output, 'wb') as file:
            file.write(decoded_data)
        print(f"Decoded data saved to {args.output}")

if __name__ == "__main__":
    main()