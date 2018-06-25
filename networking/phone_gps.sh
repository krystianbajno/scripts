#!/bin/bash
if [ "$EUID" -ne 0 ];
	then echo "RUN AS ROOT"
	exit
fi
bluetoothphone="2C:54:CF:44:DA:D6"
bluetoothhost="0C:D2:92:8F:AD:A3"
while true; do
	echo Connect via USB or BT? - usb/bt/exit
	read in1
	if [[ $in1 == "usb" ]]; then
		###
		if [ -e /dev/android_adb ]; then
		echo Phone connected.
		echo Starting adb; adb start-server
		echo Forwarding adb; adb forward tcp:50000 tcp:50000 
			if [[ $? -ne 0 ]]; then
				while true; do
				read -p "Give permissions, and when you are done, press enter."
				adb forward tcp:50000 tcp:50000
				if [[ $? -eq 0 ]]; then
				echo This time ok.
				break
				else
				echo Fail. Try again.
				fi
				done;
			fi
		echo Setting up gpsd daemon.
		sleep 1
		if ! pgrep -x gpsd > /dev/null
		then
		gpsd -n tcp://localhost:50000
		echo Started gpsd successfully.
		else
		echo Already running.
		fi
		read -p "Press enter to stop and rewind."
		killall gpsd
		adb forward --remove tcp:50000
		adb kill-server
		echo Done.
		else
		echo Connect your phone to the computer with a cable.
		
		fi

	elif [[ $in1 == "exit" ]]; then
	break
	elif [[ $in1 == "bt" ]]; then
	echo Ensuring bluetooth is enabled.
	systemctl start bluetooth
	echo Bluetooth started. Powering on the device.
	echo -e 'power on\nconnect $bluetoothphone \nquit' | bluetoothctl
	sleep 2
	echo Connecting...
	channel=$(sdptool browse $bluetoothphone| grep ShareGPS -A 7 | grep Channel | cut -d ':' -f2)
	rfcomm connect $bluetoothhost $bluetoothphone $channel >/dev/null & 
	sleep 2
	echo Setting up gpsd daemon.
		if ! pgrep -x gpsd > /dev/null
		then
		gpsd -n /dev/rfcomm0
		echo Started gpsd successfully.
		else
		echo Already running.
		fi

	read -p "Press enter to stop and rewind."
	killall gpsd
	echo "Disable bluetooth? y/n"
	read in2
	if [[ $in2 == "y" ]]; then
		echo Powering off the device.
		echo -e 'power off\nquit' | bluetoothctl >/dev/null
		systemctl stop bluetooth
		kill -s 9 $(pgrep rfcomm)
	else
		echo Leaving bluetooth started.
	fi
		###
	else
		echo "Error"
	fi
done
exit
