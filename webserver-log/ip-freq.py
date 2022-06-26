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

    # Calculate the number of ips frequency iside the log file
    with open(file_to_open, encoding = 'utf-8') as f:
        while True:
            line = f.readline() # Read the file line by line
            if not line:
                break
            else:
                ip = line.split(' ')[1] # split each line and the the ip
                if ip in ip_freq.keys():
                    ip_freq[ip] += 1
                else:
                    ip_freq[ip] = 1
    
    for i in sorted(ip_freq, key=ip_freq.get, reverse=True):
        print(f"{ip_freq[i]} {i}")

if __name__ == "__main__":
    main()
