echo "Enter main target/program name (enter . if none):"
read program

echo "Enter target:"
read target

echo "Enter provider config filename:"
read pc

mkdir $program 
cd $program

mkdir $target
cd $target


echo "[*] Finding secrets from js files..."
cat js.txt | while read url; do python3 ~/Documents/tools/SecretFinder/SecretFinder.py -i $url -o cli >> secrets.txt; done

echo "[*] Finding secrets from Github ..."
trufflehog github --org=$target --results=verified --no-update | tee -a gitsecrets.txt

echo "[*] Fuzzing for sensitive files/directories..."
ffuf -u https://$target/FUZZ -w /usr/share/wordlists/WordList/god.txt -e sql,config,xml,json

echo "[*] Finding open ports using rustscan..."
rustscan -a ips.txt --range 1-1000 --ulimit 3000 -- -Pn | tee -a nmap.txt

echo "[*] Enumerating cloud environment..."
enumkey="${target%%.*}"
python3 ~/Documents/tools/cloud_enum/cloud_enum.py -k $enumkey --quickscan -t 10 | tee cloud.txt


echo "Finished Automation2 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
