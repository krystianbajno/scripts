time=1
declare T0=($(cat /sys/class/powercap/*/energy_uj)); sleep $time; declare T1=($(cat /sys/class/powercap/*/energy_uj))
for i in "${!T0[@]}"; do echo - | awk "{printf \"%.1f W\", $((${T1[i]}-${T0[i]})) / $time / 1e6 }" ; done
echo ""