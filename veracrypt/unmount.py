import subprocess

def unmount_crypt_volume(letter):
  proc = subprocess.Popen(["C:\\Program Files\\VeraCrypt\\veracrypt.exe", "/dismount", f"{letter}", "/quit", "/silent", "/force"])
  proc.wait()

def unmount_smb(name):
  proc = subprocess.Popen(["net", "share", f"{name}", "/delete"])
  proc.wait()

def main():
  print("[*] Disbanding SMB share")
  unmount_smb("R:\\")
  unmount_smb("W:\\")

  print("[*] Disconnecting encrypted volume")
  unmount_crypt_volume("R")
  unmount_crypt_volume("W")

  print("$$$ COME BACK TO THE TEMPLE OF GOD $$$")
  input("press any button to continue!")
  
if __name__ == "__main__":
  main()