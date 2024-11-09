echo "Enter main target/program name (enter . if none):"
read program

echo "Enter target:"
read target

echo "Enter provider config filename[Press enter if none]:"
read pc

mkdir $program 
cd $program

mkdir $target
cd $target

printf "[+] Horizontal domain correlation/acquisitions"
printf "Searching horizontal domains..."
email=$(whois $target | grep "Registrant Email" | egrep -ho "[[:graph:]]+@[[:graph:]]+")
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36" "https://viewdns.info/reversewhois/?q=$email" | html2text | grep -Po "[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)" | tail -n +4  | head -n -1 | tee -a acquisation.txt

echo "[*] Finding subdomains..."
subfinder -d $target -t 100 -v -o allsub.txt
python3 ~/Documents/tools/github-subdomains.py -t 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 -d $target | anew allsub.txt


echo "[*] Checking for alive targets using httpx..."
cat allsub.txt | httpx -t 100 | tee -a probedsub.txt
httpx -status-code -title -tech-detect -cl -list allsub.txt -t 100 -o httpx.txt

echo "[*] Fetching all the URLs using katana and performing pattern matching..."
katana -u allsub.txt -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -kf -jc -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -o allurls.txt
cat allurls.txt | grep -E "\.js$" | anew | tee -a js.txt
cat allurls.txt | gf xss | tee -a gfxss.txt
cat allurls.txt | gf sqli | tee -a gfsqli.txt
cat allurls.txt | gf rce | tee -a gfrce.txt
cat allurls.txt | gf lfi | tee -a gflfi.txt
cat allurls.txt | gf ssrf | tee -a gfssrf.txt
cat allurls.txt | gf idor | tee -a gfidor.txt
cat allurls.txt | gf redirect | tee -a gfredirect.txt

echo "[*] Fetching all the ip's from hosts and shodan..."
while read -r domain; do dig +short "$domain"  | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'; done < allsub.txt | sort -u > ips.txt
python3 ~/Documents/tools/freedan/freedan.py -S $target | anew ips.txt


echo "Finished Automation1 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
