import os
import getpass
import shutil
import py7zr
import hashlib
import argparse
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.exceptions import InvalidTag

EXCLUDE_FILES = ['aes.py', '.gitignore']
EXCLUDE_DIRS = ['.git']

def derive_key(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)

def encrypt_file(file_path: str, password: str):
    salt, nonce = os.urandom(16), os.urandom(12)
    key = derive_key(password, salt)
    aesgcm = AESGCM(key)
    try:
        with open(file_path, 'rb') as f, open(file_path + '.enc', 'wb') as out:
            out.write(salt + nonce + aesgcm.encrypt(nonce, f.read(), None))
        os.remove(file_path)
        return file_path + '.enc'
    except Exception as e:
        print(f"Error encrypting file {file_path}: {e}")
        return None

def decrypt_file(file_path: str, password: str):
    try:
        with open(file_path, 'rb') as f:
            salt, nonce, enc_data = f.read(16), f.read(12), f.read()
        key = derive_key(password, salt)
        aesgcm = AESGCM(key)
        with open(file_path[:-4], 'wb') as out:
            out.write(aesgcm.decrypt(nonce, enc_data, None))
        os.remove(file_path)
        return file_path[:-4]
    except InvalidTag:
        print(f"Error: Invalid password or corrupted file: {file_path}")
    except Exception as e:
        print(f"Error decrypting file {file_path}: {e}")
    return None

def compress_directory(directory_path: str):
    if os.path.basename(directory_path) in EXCLUDE_DIRS:
        return None
    archive_path = directory_path + '.arc'
    with py7zr.SevenZipFile(archive_path, 'w') as archive:
        for root, dirs, files in os.walk(directory_path):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for file in files:
                file_path = os.path.join(root, file)
                archive.write(file_path, os.path.relpath(file_path, directory_path))
    shutil.rmtree(directory_path)
    return archive_path

def decompress_directory(archive_path: str):
    try:
        extract_path = os.path.splitext(archive_path)[0]
        with py7zr.SevenZipFile(archive_path, 'r') as archive:
            archive.extractall(path=extract_path)
        os.remove(archive_path)
        return extract_path
    except Exception as e:
        print(f"Error decompressing archive {archive_path}: {e}")
        return None

def process_path(path: str, password: str, encrypt: bool):
    if os.path.basename(path) in EXCLUDE_FILES or any(ex_dir in path for ex_dir in EXCLUDE_DIRS):
        return

    if encrypt and not path.endswith('.enc'):
        if os.path.isdir(path):
            archive_path = compress_directory(path)
            if archive_path:
                encrypt_file(archive_path, password)
        else:
            encrypt_file(path, password)
        
    elif not encrypt and path.endswith('.enc'):
        archive_path = decrypt_file(path, password)
        if archive_path:
            if os.path.isfile(archive_path) and archive_path.endswith('.arc'):
                decompress_directory(archive_path)

def process_directory(password: str, encrypt: bool):
    current_directory = os.getcwd()
    for root, dirs, files in os.walk(current_directory):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for name in dirs + files:
            process_path(os.path.join(root, name), password, encrypt)

def main():
    parser = argparse.ArgumentParser(description="aes.py")
    parser.add_argument("action", choices=['e', 'd'], help="e - encrypt, d - decrypt")
    args = parser.parse_args()

    password = getpass.getpass("Enter the password: ")

    process_directory(password, encrypt=(args.action == 'e'))

if __name__ == "__main__":
    main()