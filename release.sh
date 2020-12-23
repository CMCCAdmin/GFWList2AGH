#!/bin/bash

# Current Version: 1.5.0

## How to get and use?
# git clone "https://github.com/hezhijie0327/GFWList2AGH.git" && bash ./GFWList2AGH/release.sh

## Function
# Get Data
function GetData() {
    cnacc_domain=(
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt"
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf"
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf"
    )
    dead_domain=(
        "https://raw.githubusercontent.com/hezhijie0327/DHDb/master/dhdb_dead.txt"
    )
    gfwlist_base64=(
        "https://raw.githubusercontent.com/Loukky/gfwlist-by-loukky/master/gfwlist.txt"
        "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
        "https://raw.githubusercontent.com/poctopus/gfwlist-plus/master/gfwlist-plus.txt"
    )
    gfwlist_domain=(
        "https://raw.githubusercontent.com/Loyalsoldier/cn-blocked-domain/release/domains.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt"
        "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt"
        "https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/gh-pages/gfwlist_domain.txt"
        "https://raw.githubusercontent.com/pexcn/gfwlist-extras/master/gfwlist-extras.txt"
    )
    rm -rf ./gfwlist2agh_* ./Temp && mkdir ./Temp && cd ./Temp
    for cnacc_domain_task in "${!cnacc_domain[@]}"; do
        curl -s --connect-timeout 15 "${cnacc_domain[$cnacc_domain_task]}" >> ./cnacc_domain.tmp
    done
    for dead_domain_task in "${!dead_domain[@]}"; do
        curl -s --connect-timeout 15 "${dead_domain[$dead_domain_task]}" >> ./dead_domain.tmp
    done
    for gfwlist_base64_task in "${!gfwlist_base64[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist_base64[$gfwlist_base64_task]}" | base64 -d >> ./gfwlist_base64.tmp
    done
    for gfwlist_domain_task in "${!gfwlist_domain[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist_domain[$gfwlist_domain_task]}" >> ./gfwlist_domain.tmp
    done
}
# Analyse Data
function AnalyseData() {
    cnacc_data=($(cat ./cnacc_domain.tmp ../data/data_cnacc.txt | sed 's/\/114\.114\.114\.114//g;s/server\=\///g' | tr "A-Z" "a-z" | grep -E "^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-_\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$" | sort | uniq > ./cnacc_data.tmp && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dead_domain.tmp ./cnacc_data.tmp > ./cnacc_alive.tmp && cat ./gfwlist_base64.tmp ./gfwlist_domain.tmp ../data/data_gfwlist.txt | tr -d "|" | tr "A-Z" "a-z" | grep -E "^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-_\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$" | sort | uniq > gfwlist_data.tmp && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dead_domain.tmp ./gfwlist_data.tmp > ./gfwlist_alive.tmp && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./gfwlist_alive.tmp ./cnacc_alive.tmp | awk "{ print $2 }"))
    gfwlist_data=($(awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./cnacc_alive.tmp ./gfwlist_alive.tmp | awk "{ print $2 }"))
    lite_cnacc_data=($(awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./gfwlist_alive.tmp ./cnacc_alive.tmp | rev | cut -d "." -f 1-2 | rev | sort | uniq | awk "{ print $2 }"))
    lite_gfwlist_data=($(awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./cnacc_alive.tmp ./gfwlist_alive.tmp | rev | cut -d "." -f 1-2 | rev | sort | uniq | awk "{ print $2 }"))
}
# Output Data
function OutputData() {
    domestic_dns=(
        "https://doh.pub:443/dns-query"
        "tls://dns.alidns.com:853"
    )
    foreign_dns=(
        "https://doh.opendns.com:443/dns-query"
        "tls://dns.google:853"
    )
    for (( upstream_dns_task = 0; upstream_dns_task < 2; upstream_dns_task++ )); do
        case ${upstream_dns_task} in
            0)
            for domestic_upstream_dns_task in "${!domestic_dns[@]}"; do
                echo "${domestic_dns[$domestic_upstream_dns_task]}" >> ../gfwlist2agh_blacklist.txt
                echo "${domestic_dns[$domestic_upstream_dns_task]}" >> ../gfwlist2agh_blacklist_lite.txt
            done
            ;;
            1)
            for foreign_upstream_dns_task in "${!foreign_dns[@]}"; do
                echo "${foreign_dns[$foreign_upstream_dns_task]}" >> ../gfwlist2agh_whitelist.txt
                echo "${foreign_dns[$foreign_upstream_dns_task]}" >> ../gfwlist2agh_whitelist_lite.txt
            done
            ;;
        esac
    done
    echo -n "[/" >> ../gfwlist2agh_blacklist.txt
    echo -n "[/" >> ../gfwlist2agh_blacklist_lite.txt
    echo -n "[/" >> ../gfwlist2agh_whitelist.txt
    echo -n "[/" >> ../gfwlist2agh_whitelist_lite.txt
    for cnacc_data_task in "${!cnacc_data[@]}"; do
        echo -n "${cnacc_data[$cnacc_data_task]}/" >> ../gfwlist2agh_blacklist.txt
    done
    for gfwlist_data_task in "${!gfwlist_data[@]}"; do
        echo -n "${gfwlist_data[$gfwlist_data_task]}/" >> ../gfwlist2agh_whitelist.txt
    done
    for lite_cnacc_data_task in "${!lite_cnacc_data[@]}"; do
        echo -n "${lite_cnacc_data[$lite_cnacc_data_task]}/" >> ../gfwlist2agh_blacklist_lite.txt
    done
    for lite_gfwlist_data_task in "${!lite_gfwlist_data[@]}"; do
        echo -n "${lite_gfwlist_data[$lite_gfwlist_data_task]}/" >> ../gfwlist2agh_whitelist_lite.txt
    done
    echo -e "]#" >> ../gfwlist2agh_blacklist.txt
    echo -e "]#" >> ../gfwlist2agh_blacklist_lite.txt
    echo -e "]#" >> ../gfwlist2agh_whitelist.txt
    echo -e "]#" >> ../gfwlist2agh_whitelist_lite.txt
    for domestic_dns_task in "${!domestic_dns[@]}"; do
        echo -n "[/" >> ../gfwlist2agh_whitelist.txt
        echo -n "[/" >> ../gfwlist2agh_whitelist_lite.txt
        for cnacc_data_task in "${!cnacc_data[@]}"; do
            echo -n "${cnacc_data[$cnacc_data_task]}/" >> ../gfwlist2agh_whitelist.txt
        done
        for lite_cnacc_data_task in "${!lite_cnacc_data[@]}"; do
            echo -n "${lite_cnacc_data[$lite_cnacc_data_task]}/" >> ../gfwlist2agh_whitelist_lite.txt
        done
        echo -e "]${domestic_dns[domestic_dns_task]}" >> ../gfwlist2agh_whitelist.txt
        echo -e "]${domestic_dns[domestic_dns_task]}" >> ../gfwlist2agh_whitelist_lite.txt
    done
    for foreign_dns_task in "${!foreign_dns[@]}"; do
        echo -n "[/" >> ../gfwlist2agh_blacklist.txt
        echo -n "[/" >> ../gfwlist2agh_blacklist_lite.txt
        for gfwlist_data_task in "${!gfwlist_data[@]}"; do
            echo -n "${gfwlist_data[$gfwlist_data_task]}/" >> ../gfwlist2agh_blacklist.txt
        done
        for lite_gfwlist_data_task in "${!lite_gfwlist_data[@]}"; do
            echo -n "${lite_gfwlist_data[$lite_gfwlist_data_task]}/" >> ../gfwlist2agh_blacklist_lite.txt
        done
        echo -e "]${foreign_dns[foreign_dns_task]}" >> ../gfwlist2agh_blacklist.txt
        echo -e "]${foreign_dns[foreign_dns_task]}" >> ../gfwlist2agh_blacklist_lite.txt
    done
    cd .. && rm -rf ./Temp
    exit 0
}

## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
