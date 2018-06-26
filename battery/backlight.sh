#!/bin/bash
base="/sys/class/backlight/"
pat=$base$(ls $base)"/"
old=$(cat $pat"brightness")
max=$(cat $pat"max_brightness")
old_p=$(( 100 * $old / $max ))
new_p=$(($old_brightness_p $1))
new=$(( $max * $new_p / 100 ))
sudo chmod 666 $pat"brightness"
echo $new > $pat"brightness"
notify-send $new -u low
