#!/usr/bin/env bash

## Exit on any error
set -e

## Check number of arguments given
if [[ $# -eq 0 || $# -gt 1 ]]; then
  printf "Expected 1 argument but %d given\n" $#
  printf "usage: %s '/path/to/file.log'\n" "${0##*/}" >&2 ### Instead of using basename command POSIX shells
  exit 2
fi

# References
# https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
# https://www.xmodulo.com/key-value-dictionary-bash.html

declare -A ip_freq

for line in $(cat $1 | cut -d " " -f2)
do
    if [ ! -v ip_freq[$line] ]; then
        ip_freq[$line]=1
    fi
    if [ -v ip_freq[$line] ]; then
        ip_freq[$line]=$(expr ${ip_freq[$line]} + 1)
    fi
done

for ip in "${!ip_freq[@]}"; do
    echo "${ip_freq[$ip]} $ip" 
done | sort -gr

