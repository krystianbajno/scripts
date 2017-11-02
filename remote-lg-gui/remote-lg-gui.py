#!/usr/bin/python
import http.client
import tkinter
from tkinter import messagebox
import socket
import re
import sys
from time import sleep
import xml.etree.ElementTree

### INIT GLOBALS ###
dictionary = {} ### lgtv dictionary used to store values
banner = "\n\
Python LG Smart TV remote with GUI\n\
    _      _____   _____  ______ __  __  ____ _______ ______ \n \
  | |    / ____| |  __ \|  ____|  \/  |/ __ \__   __|  ____|\n \
  | |   | |  __  | |__) | |__  | \  / | |  | | | |  | |__   \n \
  | |   | | |_ | |  _  /|  __| | |\/| | |  | | | |  |  __|  \n \
  | |___| |__| | | | \ \| |____| |  | | |__| | | |  | |____ \n \
  |______\_____| |_|  \_\______|_|  |_|\____/  |_|  |______|\n \
  \n\
                                             By Krystian Bajno\n\
"

### Config ###

#Uncomment to set static tv address (not needed unless more than one TV on the network)
#dictionary["lgtv_ipAddress"] = '192.168.1.105'

#Change default pairing key by changing the value below.
dictionary["pairingKey"] = "123456"
### Pairing keys for LG Smart TV's are in range of 100000 to 999999.
brutenumber = 100000 ### Starting number used for bruteforce.
endnumber = 1000000
lastnumber = brutenumber
### End config
            
def connectHTTP():
    return http.client.HTTPConnection(dictionary["lgtv_ipAddress"], port=8080)

def displayPairingKey():
    httpConnection = connectHTTP()
    httpConnection.request("POST", "/roap/api/auth", "<!--?xml version=\"1.0\" encoding=\"utf-8\"?--><auth><type>AuthKeyReq</type></auth>", headers={"Content-Type": "application/atom+xml"})
    httpResponse = httpConnection.getresponse()
    if httpResponse.reason != "OK" :
        error = tkinter.Tk()
        error.withdraw()
        print("[*] Cant display key! Network error - exiting...")
        messagebox.showinfo("Error", "Cant display key! Network error - exiting...")
        sys.exit("Error")
 

def establishSessionID():
    print("[*] Pairing key to be used: " + dictionary["pairingKey"])
    print('[*] Establishing Session ID...')
    httpConnection = connectHTTP()
    httpConnection.request("POST", "/roap/api/auth", "<!--?xml version=\"1.0\" encoding=\"utf-8\"?--><auth><type>AuthReq</type><value>" \
            + dictionary["pairingKey"] + "</value></auth>", \
            headers={"Content-Type": "application/atom+xml"})
    httpResponse = httpConnection.getresponse()
    if httpResponse.reason == "OK" :
        queryselector = xml.etree.ElementTree.XML(httpResponse.read())
        session = queryselector.find('session').text
        return session
    else:
         return httpResponse.reason
    
    
def setPairingKey():
    pairingKeyBox = tkinter.Tk()
    pairingKeyBox.title("Set your pairing key!")
    pairingKeyBox.geometry("200x280")
    pairingKeyBox.configure(bg='#111111')
    _keyLabel = tkinter.Label(pairingKeyBox, bg='#111111'  ,fg='#FFFFFF',text = 'Set correct pairing key')
    _keyLabel.pack(pady = 5)
    pairingKey_toSet = tkinter.Entry(pairingKeyBox, bg='#111111'  ,fg='#FFFFFF',bd=1)
    pairingKey_toSet.pack(pady = 5)
   
    def setKey():
        dictionary["pairingKey"] = pairingKey_toSet.get()
        pairingKeyBox.destroy()
    def setBrute():
            global lastnumber, endnumber
            lastnumber = int(brutenumber_toSet.get())
            endnumber = int(endnumber_toSet.get())
            print("[*] Bruteforce config refreshed...")
    def justexit():
        pairingKeyBox.destroy()
        sys.exit("[*] Program has been closed correctly on user request. Goodbye!")
    ### Bruteforce :D :D :D

    def bruteforce():
        global lastnumber, endnumber
        if lastnumber > brutenumber:
                print("-------------------------------------")
                print("[*] Continuing from the breakpoint...")
        if lastnumber >= endnumber:
                print("[*] Fix your config - do not exceed " + str(endnumber) + ", or bruteforce won't even start.")
        for i in range(lastnumber, endnumber):
            try:
                dictionary["pairingKey"] = str(i)
                sessionID = establishSessionID()
                if sessionID == "Unauthorized":
                    print("[*] Invalid key, continuing...")
                    lastnumber = lastnumber+1
                    brutenumber_toSet.delete(0, tkinter.END)
                    brutenumber_toSet.insert(0, lastnumber)
                    sleep(0.01)
                else:
                    print("-----------------------------------------------")
                    print("[*] Pairing key acquired: " + dictionary["pairingKey"])
                    pairingKeyBox.destroy()
                    break
                if len(sessionID) < 8 :
                    sys.exit("[*] Can't get proper Session ID: " + sessionID)
                if lastnumber == endnumber:
                     print("\n[*] Error! Key not found.")
                     print("[*] Zeroing the counter...")
                     lastnumber = brutenumber
                     break

            except KeyboardInterrupt:
                print("[*] Received keyboard interrupt, stopping bruteforce...")
                break
    
    _enterButton = tkinter.Button(pairingKeyBox,bg='#111111'  ,fg='#FFFFFF', text="Enter key", command=setKey)
    _exitButton = tkinter.Button(pairingKeyBox,bg='#111111'  ,fg='#FFFFFF', text="Exit", command=justexit)
    _bruteforceButton = tkinter.Button(pairingKeyBox,bg='#111111'  ,fg='#FFFFFF', text="BRUTEFORCE!", command=bruteforce)
    _enterButton.pack(pady = 5)
    _bruteforceButton.pack(pady = 5)
    brutenumber_toSet = tkinter.Entry(pairingKeyBox, bg='#111111'  ,fg='#FFFFFF',bd=1)
    brutenumber_toSet.pack(pady = 5)
    brutenumber_toSet.delete(0, tkinter.END)
    brutenumber_toSet.insert(0, lastnumber)
    endnumber_toSet = tkinter.Entry(pairingKeyBox, bg='#111111'  ,fg='#FFFFFF',bd=1)
    endnumber_toSet.pack(pady = 5)
    endnumber_toSet.delete(0, tkinter.END)
    endnumber_toSet.insert(0, endnumber)
    _bruteforceSet = tkinter.Button(pairingKeyBox,bg='#111111'  ,fg='#FFFFFF', text="BRUTEFORCE SET", command=setBrute)
    _bruteforceSet.pack(pady = 5)
    _exitButton.pack(pady = 5)
    pairingKeyBox.mainloop()

####################################

def scanNetwork():
    print('[*] Searching for LG Smart TV on the network...')
    ssdpDiscover =   'M-SEARCH * HTTP/1.1' + '\r\n' + \
                    'HOST: 239.255.255.250:1900'  + '\r\n' + \
                    'MAN: "ssdp:discover"'  + '\r\n' + \
                    'MX: 2'  + '\r\n' + \
                    'ST: urn:schemas-upnp-org:device:MediaRenderer:1'  + '\r\n' +  '\r\n'
    bytesToSend = ssdpDiscover.encode()
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(2)
    s.sendto(bytesToSend,('239.255.255.250',1900))
    flag = False
    decodedBytes = '' 
    counter = 0 
    while not flag and decodedBytes == '' and counter < 5:
        try:
            receivedBytes, addressport = s.recvfrom(512)
            decodedBytes = receivedBytes.decode()
        except:
            counter += 1
            s.sendto(bytesToSend, ('239.255.255.250', 1900))
        if re.search('LG', decodedBytes):
            lgtv_ipAddress, _ = addressport
            flag = True
            print('[*] LG Smart TV found!')
        else:
            decodedBytes = ''
        counter += 1
    s.close()
    if not flag:
        error = tkinter.Tk()
        error.withdraw()
        messagebox.showinfo("LG TV not found", "LG TV was not found, check your firewall settings and TV connection presence.")
        sys.exit("[*] LG TV was not found, check your firewall settings and TV connection presence. Exiting...")
    return lgtv_ipAddress

def checkStatic_IP():
    print('[*] Searching for ' + dictionary['lgtv_ipAddress'] + ' LG Smart TV on the network...')
    httpConnection = connectHTTP()
    authKeyRequest = "<!--?xml version=\"1.0\" encoding=\"utf-8\"?--><auth><type>AuthKeyReq</type></auth>"
    try: 
        httpResponse = httpConnection.request("POST", "/roap/api/auth", "<!--?xml version=\"1.0\" encoding=\"utf-8\"?--><auth><type>AuthKeyReq</type></auth>", headers={"Content-Type": "application/atom+xml"})
        print('[*] LG Smart TV found!')
    except:
        
        error = tkinter.Tk()
        error.withdraw()
        messagebox.showinfo("LG TV not found", "LG TV was not found, check your firewall settings and TV connection presence.")
        sys.exit("[*] LG TV was not found, check your firewall settings and TV connection presence. Exiting...")

 ### Command handling ###
def sendPayload(_lgCmdcode):
    print('[*] Sending command ' + _lgCmdcode + '...')
    httpConnection = connectHTTP()
    command = "<!--?xml version=\"1.0\" encoding=\"utf-8\"?--><command>" \
                + "<name>HandleKeyInput</name><value>" \
                + _lgCmdcode \
                + "</value></command>"
    httpConnection.request("POST", "/roap/api/command", command, headers={"Content-Type": "application/atom+xml"})
    httpResponse = httpConnection.getresponse()

def _initGui():
    ############## GUI FUNCTIONS #########
    def EXIT():
        sys.exit("[*] Program has been closed correctly on user request. Goodbye!")
    def POWER():
        _commandCode = 1
        sendPayload(str(_commandCode))
    def OK():
        _commandCode = 20
        sendPayload(str(_commandCode))
    def VolUp():
        _commandCode = 24
        sendPayload(str(_commandCode))
    def VolDown():
        _commandCode = 25
        sendPayload(str(_commandCode))
    def ChannelUp():
        _commandCode = 27
        sendPayload(str(_commandCode))
    def ChannelDown():
        _commandCode = 28
        sendPayload(str(_commandCode))
    def UP():
        _commandCode = 12
        sendPayload(str(_commandCode))
    def DOWN():
        _commandCode = 13
        sendPayload(str(_commandCode))
    def LEFT():
        _commandCode = 14
        sendPayload(str(_commandCode))
    def RIGHT():
        _commandCode = 15
        sendPayload(str(_commandCode))
    def ZERO():
        _commandCode = 2
        sendPayload(str(_commandCode))
    def ONE():
        _commandCode = 3
        sendPayload(str(_commandCode))
    def TWO():
        _commandCode = 4
        sendPayload(str(_commandCode))
    def THREE():
        _commandCode = 5
        sendPayload(str(_commandCode))
    def FOUR():
        _commandCode = 6
        sendPayload(str(_commandCode))
    def FIVE():
        _commandCode = 7
        sendPayload(str(_commandCode))
    def SIX():
        _commandCode = 8
        sendPayload(str(_commandCode))
    def SEVEN():
        _commandCode = 9
        sendPayload(str(_commandCode))
    def EIGHT():
        _commandCode = 10
        sendPayload(str(_commandCode))
    def NINE():
        _commandCode = 11
        sendPayload(str(_commandCode))
    def HOME():
        _commandCode = 21
        sendPayload(str(_commandCode))
    def EXTERNAL_INPUT():
        _commandCode = 47
        sendPayload(str(_commandCode))
    def PROGRAM_LIST():
        _commandCode = 44
        sendPayload(str(_commandCode))
    def MUTE():
        _commandCode = 26
        sendPayload(str(_commandCode))
    def BACK():
        _commandCode = 23
        sendPayload(str(_commandCode))
    def TELEGAZETA():
        _commandCode = 51
        sendPayload(str(_commandCode))
    def RED():
        _commandCode = 31
        sendPayload(str(_commandCode))
    def GREEN():
        _commandCode = 30
        sendPayload(str(_commandCode))
    def YELLOW():
        _commandCode = 32
        sendPayload(str(_commandCode))
    def BLUE():
        _commandCode = 29
        sendPayload(str(_commandCode))
    def INFO():
        _commandCode = 45
        sendPayload(str(_commandCode))
    def SETTINGS():
        _commandCode = 46
        sendPayload(str(_commandCode))
    ############## END FUNCTIONS #########
    top = tkinter.Tk()
    top.title("LG REMOTE")
    top.configure(background='#121212')
    top.geometry("300x650")
    OK = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "OK", command = OK)
    POWER = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="OFF", command = POWER)
    EXIT = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "EXIT", command = EXIT)
    VOLUP = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="Vol+", command = VolUp)
    VOLDOWN = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="Vol-", command = VolDown)
    CHANNELUP = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="P+", command = ChannelUp)
    CHANNELDOWN = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="P-", command = ChannelDown)
    UP = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="/\\", command = UP)
    DOWN = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="\\/", command = DOWN)
    LEFT = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="<-", command = LEFT)
    RIGHT = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="->", command = RIGHT)
    ZERO = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="0", command = ZERO)
    ONE = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="1", command = ONE)
    TWO = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="2", command = TWO)
    THREE = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="3", command = THREE)
    FOUR = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="4", command = FOUR)
    FIVE = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="5", command = FIVE)
    SIX = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="6", command = SIX)
    SEVEN = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="7", command = SEVEN)
    EIGHT = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="8", command = EIGHT)
    NINE = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text ="9", command = NINE)
    ZERO = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text="0", command = ZERO)
    HOME = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text="HOME", command = HOME)
    EXTERNAL_INPUT = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text="EXTERNAL INPUT", command = EXTERNAL_INPUT)
    PROGRAM_LIST = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "PROGRAM LIST", command = PROGRAM_LIST)
    BACK = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "BACK", command = BACK)
    MUTE = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "MUTE", command = MUTE)
    TELEGAZETA = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "TELEGAZETA", command = TELEGAZETA)
    R = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "R", command = RED)
    G = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "G", command = GREEN)
    B = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "B", command = BLUE)
    Y = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "Y", command = YELLOW)
    INFO = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "INFO", command = INFO)
    credits = tkinter.Label(top, bg='#111111'  ,fg='#FFFFFF', text = 'REMOTE BY KRYSTIAN BAJNO')
    info = tkinter.Label(top, bg='#111111'  ,fg='#FFFFFF', text = 'TV IP: ' + dictionary["lgtv_ipAddress"] + ' Key: ' + dictionary["pairingKey"])
    info2 = tkinter.Label(top, bg='#111111'  ,fg='#FFFFFF', text = 'Session: ' + dictionary["session"])
    SETTINGS = tkinter.Button(top, bg='#111111'  ,fg='#FFFFFF', text = "settings", command = SETTINGS)
    #### GUI PLACE
    POWER.place(x = 30, y = 10)
    EXIT.place(x = 220, y = 10)
    VOLUP.place(x = 30, y = 100)
    VOLDOWN.place(x = 30, y = 150)
    CHANNELUP.place(x = 220, y = 100)
    CHANNELDOWN.place(x = 220, y = 150)
    OK.place(x = 125, y = 160)
    UP.place(x=130, y = 130)
    DOWN.place(x=130, y = 190)
    LEFT.place(x=85, y =160)
    RIGHT.place(x=170, y = 160)
    MUTE.place(x=210, y = 210)
    ONE.place(x = 30, y = 250)
    TWO.place(x = 130, y = 250)
    THREE.place(x = 230, y = 250)
    FOUR.place(x = 30, y = 300)
    FIVE.place(x = 130, y = 300)
    SIX.place(x = 230, y = 300)
    SEVEN.place(x = 30, y = 350)
    INFO.place(x = 30, y = 400)
    EIGHT.place(x = 130, y = 350)
    NINE.place(x = 230, y = 350)
    ZERO.place(x = 130, y = 400)
    HOME.place(x = 115, y = 60)
    BACK.place(x = 30, y = 210)
    SETTINGS.place(x = 200, y = 400)
    PROGRAM_LIST.place(x = 100, y = 500)
    EXTERNAL_INPUT.place(x = 90, y = 10)
    TELEGAZETA.place(x = 15, y = 550)
    R.place(x = 125, y = 550)
    G.place(x = 165, y = 550)
    B.place(x = 245, y = 550)
    Y.place(x = 205, y = 550)
    credits.place(x = 70, y = 460)
    info2.pack(side=tkinter.BOTTOM, pady = 10)
    info.pack(side=tkinter.BOTTOM, pady = 1)
    top.mainloop()

def printhelp():
    print("\nUsage:\n\tUse without arguments to run GUI, adding keycodes to command will run the program manually.")
    print("\tFor example: ./remote-lg-gui.py - will run GUI.")
    print("\tE.g ./remote-lg-gui.py 24 24 24 24 24 will turn the volume up five times.")
    print("\tI.e ./remote-lg.gui.py --help, -h, /h, help will run this manual again")
    print("LG COMMAND CODES:")
    print('1 - POWER')
    print('2 - Number 0')
    print('3 - Number 1')
    print('4 - Number 2')
    print('5 - Number 3')
    print('6 - Number 4')
    print('7 - Number 5')
    print('8 - Number 6')
    print('9 - Number 7')
    print('10 - Number 8')
    print('11 - Number 9')
    print('12 - UP key')
    print('13 - DOWN key')
    print('14 - LEFT key')
    print('15 - RIGHT key')
    print('20 - OK')
    print('21 - Home menu')
    print('22 - Menu key')
    print('23 - Back')
    print('24 - Volume up')
    print('25 - Volume down')
    print('26 - Mute (toggle)')
    print('27 - Channel UP (+)')
    print('28 - Channel DOWN (-)')
    print('29 - Blue key')
    print('30 - Green key')
    print('31 - Red key')
    print('32 - Yellow')
    print('33 - Play')
    print('34 - Pause')
    print('35 - Stop')
    print('36 - Fast forward')
    print('37 - Rewind')
    print('38 - Skip Forward')
    print('39 - Skip Backward')
    print('40 - Record')
    print('41 - Recordings list')
    print('42 - Repeat')
    print('43 - Live TV')
    print('44 - EPG')
    print('45 - Current program information')
    print('46 - Aspect ratio')
    print('47 - External input')
    print('48 - PIP secondary video')
    print('49 - Show / Change subtitle')
    print('50 - Program list')
    print('51 - Tele Text')
    print('52 - Mark')
    print('400 - 3D Video')
    print('401 - 3D L/R')
    print('402 - Dash (-)')
    print('403 - Previous channel')
    print('404 - Favorite channel')
    print('405 - Quick menu')
    print('406 - Text Option')
    print('407 - Audio Description')
    print('408 - NetCast key')
    print('409 - Energy saving')
    print('410 - A/V mode')
    print('411 - SIMPLINK')
    print('412 - Exit')
    print('413 - Reservation programs list')
    print('414 - PIP channel up')
    print('415 - PIP channel down')
    print('416 - Primary/secondary video')
    print('417 - My Apps')
        
def main(): ## Main loop
    if len(sys.argv) > 1:
        for i in range(1, len(sys.argv)):
            if sys.argv[i] == "help" or sys.argv[i] == "--help"  or sys.argv[i] == "-h" or sys.argv[i] == "/h":
                printhelp()
                sys.exit(1)

    if "lgtv_ipAddress" not in dictionary: dictionary["lgtv_ipAddress"] = scanNetwork()
    else: 
        print("[*] Using preconfigured IP - " + dictionary['lgtv_ipAddress'])
        checkStatic_IP()

    sessionID = establishSessionID()
    while sessionID == "Unauthorized":
        print("[*] Session can not be established due to invalid authentication. Enter the proper pairing key.")
        print("[*] You can also try to bruteforce.\n[*] Click on the button and press Ctrl+C to stop in case it takes too long.")
        displayPairingKey()
        setPairingKey()
        sleep(0.5)
        sessionID = establishSessionID()
    if len(sessionID) < 8 : sys.exit("[*] Can't get proper Session ID: " + sessionID)
    dictionary["session"] = sessionID
    print(dictionary)
    print(len(sys.argv))
    if len(sys.argv) > 1:
        for i in range(1, len(sys.argv)):
            print(sys.argv[i])
            _commandCode = str(sys.argv[i])
            sendPayload(_commandCode)
            sleep(0.1)
        exit()
    _initGui()

if __name__ == "__main__":
        print(banner)
        main()
