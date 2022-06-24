#!/usr/bin/env python3

import sys

def check_args():
    argl = len(sys.argv)
    if argl == 1 or argl > 2:
        print(f"Expected 1 argument but {argl - 1} given")
        print(f"usage: {sys.argv[0]} '/path/to/file.log'")
        sys.exit(2)

def main():
    check_args()
    file_to_open = sys.argv[1]
    ip_freq = {}

    with open(file_to_open, encoding = 'utf-8') as f:
        while True:
            line = f.readline()
            if not line:
                break
            else:
                ip = line.split(' ')[1]
                if ip in ip_freq.keys():
                    ip_freq[ip] += 1
                else:
                    ip_freq[ip] = 1
    
    for i in sorted(ip_freq, key=ip_freq.get, reverse=True):
        print(f"{ip_freq[i]} {i}")

if __name__ == "__main__":
    main()
