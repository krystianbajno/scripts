import subprocess

def setup_crypt_volume(password, volume, letter):
  proc = subprocess.Popen(["C:\\Program Files\\VeraCrypt\\veracrypt.exe", "/q", "/v", volume, "/p", password, "/l", letter, "/s", "/e"])
  proc.wait()

def setup_smb(name, path, permissions):
  proc = subprocess.Popen(["net", "share", f"{name}={path}", f"/GRANT:{permissions}"])
  proc.wait()

def main():
  print("$$$ PROVIDE PASSWORD TO THE TEMPLE OF GOD $$$")
  password = input("brrrrrrt: ")

  print("[*] Running subprocess, setting up volume")
  setup_crypt_volume(password, "K:\ROUNDROBIN", "R",)
  setup_crypt_volume(password, "G:\WHOOPERBITE", "W",)
  
  print("[*] Setting up SMB share")
  setup_smb("ROUNDROBIN", "R:\\", "Wszyscy,FULL")
  setup_smb("WHOOPERBITE", "W:\\", "Wszyscy,FULL")

  print("$$$ WELCOME TO THE TEMPLE OF GOD $$$")
  input("press any button to continue!")