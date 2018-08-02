#!/bin/bash
# Measures ICMP and DNS latency to many popular public DNS servers.
# Works concurrently or in parallel.
# Author: Kevin M. Gallagher (@ageis)
#set -x
#set -e
#set -o nounset
#set -v

export ERRFILE="./testdns_errs.txt"
export PINGS="/tmp/pings.$$"

declare -g -A nameservers=(
    [Alternate_DNS]="198.101.242.72" \
    [Alternate_DNS_2]="23.253.163.53" \
    [Cloudflare]="1.1.1.1" \
    [Cloudflare_2]="1.0.0.1" \
    [Alternate_DNS_2]="23.253.163.53" \
    [Comcast]="75.75.75.75" \
    [Comcast_2]="75.75.76.76" \
    [Comodo]="8.20.247.20" \
    [Comodo_2]="8.26.56.26" \
    [CyberGhost]="38.132.106.139" \
    [DNSReactor]="104.236.210.29" \
    [DNSReactor_2]="45.55.155.25" \
    [DNS.WATCH]="84.200.69.80" \
    [DNS.WATCH_2]="84.200.70.40" \
    [Dyn]="216.146.35.35" \
    [Dyn_2]="216.146.36.36" \
    [easyDNS]="205.210.42.205" \
    [easyDNS_2]="64.68.200.200" \
    [Freenom]="80.80.80.80" \
    [Freenom_2]="80.80.81.81" \
    [FreeDNS]="37.235.1.174" \
    [FreeDNS_2]="37.235.1.177" \
    [Google]="8.8.4.4" \
    [Google_2]="8.8.8.8" \
    [GreenTeamDNS]="209.88.198.133" \
    [GreenTeamDNS_2]="81.218.119.11" \
    [Hurricane_Electric]="74.82.42.42" \
    [Level3]="209.244.0.3" \
    [Level3_2]="209.244.0.4" \
    [Lightning_Wire]="74.113.60.185" \
    [Neustar]="156.154.70.1" \
    [Neustar_2]="156.154.71.1" \
    [Norton]="199.85.126.10" \
    [Norton_2]="199.85.127.10" \
    [Norton_SEC]="199.85.126.20" \
    [Norton_SEC]="199.85.127.20" \
    [Norton_SEC2]="199.85.126.30" \
    [Norton_SEC2]="199.85.127.30" \
    [OpenDNS]="208.67.220.220" \
    [OpenDNS_2]="208.67.220.222" \
    [OpenDNS_3]="208.67.222.220" \
    [OpenDNS_4]="208.67.222.222" \
    [OpenNIC]="104.238.153.178" \
    [OpenNIC_2]="128.52.130.209" \
    [OpenNIC_3]="162.248.241.94" \
    [OpenNIC_4]="172.98.193.42" \
    [OpenNIC_5]="192.52.166.110" \
    [OpenNIC_6]="198.199.84.126" \
    [OpenNIC_7]="198.206.14.241" \
    [OpenNIC_8]="23.94.5.133" \
    [OpenNIC_9]="23.94.60.240" \
    [OpenNIC_10]="54.236.38.98" \
    [OpenNIC_11]="63.231.92.27" \
    [OpenNIC_12]="66.70.211.246" \
    [OpenNIC_13]="69.195.152.204" \
    [OpenNIC_14]="96.47.228.108" \
    [OpenNIC_15]="96.90.175.167" \
    [puntCAT]="109.69.8.51" \
    [Quad9]="9.9.9.9" \
    [Quad9_2]="9.9.9.10" \
    [SafeDNS]="195.46.39.39" \
    [SafeDNS_2]="195.46.39.40" \
    [ScrubIT]="207.225.209.66" \
    [ScrubIT_2]="67.138.54.100" \
    [SmartViper]="208.76.50.50" \
    [SmartViper_2]="208.76.51.51" \
    [SpeakEasy]="216.254.95.2" \
    [SpeakEasy_2]="216.27.175.2" \
    [SpeakEasy_3]="64.81.127.2" \
    [SpeakEasy_4]="64.81.159.2" \
    [SpeakEasy_5]="64.81.45.2" \
    [SpeakEasy_6]="64.81.79.2" \
    [SpeakEasy_7]="66.92.159.2" \
    [SpeakEasy_8]="66.92.224.2" \
    [SpeakEasy_9]="66.93.87.2" \
    [Sprintlink]="199.2.252.10" \
    [Sprintlink_2]="204.117.214.10" \
    [Sprintlink_3]="204.97.212.10" \
    [UncensoredDNS]="89.233.43.71" \
    [UncensoredDNS_3]="91.239.100.100" \
    [Verisign]="64.6.64.6" \
    [Verisign_2]="64.6.65.6" \
    [Verizon]="4.2.2.1" \
    [Verizon_2]="4.2.2.2" \
    [Verizon_3]="4.2.2.3" \
    [Verizon_4]="4.2.2.4" \
    [Verizon_5]="4.2.2.5" \
    [Verizon_6]="4.2.2.6" \
    [Yandex_DNS]="77.88.8.1" \
    [Yandex_DNS_2]="77.88.8.8")


function measure () {
    local DNSSERV=$2
    local DNSNAME=$1
    echo "Trying $DNSSERV from $DNSNAME..." >&1
    AVGPING=$(printf '%-8.2f' "$(ping -c 10 -i 1 -W 3 "$DNSSERV" | tail -1 | awk '{ print $4 }' | cut -d '/' -f 2)")
    DIGTIME=$(dig +noall +stats +timeout=3 @"$DNSSERV" google.com | awk '/Query/{sum+=$4}END{print ""sum"ms"}')
    if (( $(echo "$AVGPING == 0" | bc -l) )); then AVGPING="ERR"; fi
    if (( $(echo "$DIGTIME == 0" | bc -l) )); then DIGTIME="ERR"; fi
    echo -e "$DNSNAME\t$DNSSERV\t$AVGPING\t$DIGTIME" > $PINGS &
}

main() {
    mkfifo $PINGS

    for i in "${!nameservers[@]}"; do
        measure "$i" "${nameservers[$i]}" 2>"$ERRFILE" &
    done

    for job in $(jobs -p); do
        wait -n "$job"
    done

    SORTED=$(sort -t$'\t' -k 3 -nr $PINGS)
    printf '%*s\n' "${COLUMNS:-$(echo "$(tput cols) / 2" | bc)}" '' | tr ' ' -
    fmt="%-20s\t%-16s\t%-10s\t%-10s\n"
    printf "$fmt" 'Provider' 'Address' 'ICMP latency' 'DNS latency'

    while read -r line; do
        PROVIDER=$(echo "$line" | awk '{ print $1 }')
        ADDRESS=$(echo "$line" | awk '{ print $2 }')
        PING=$(echo "$line" | awk '{ print $3 }')
        DNS=$(echo "$line" | awk '{ print $4 }')
        printf "$fmt" "$PROVIDER" "$ADDRESS" "$PING" "$DNS"
    done <<< "$SORTED"

    rm $PINGS
}

main
exit 0