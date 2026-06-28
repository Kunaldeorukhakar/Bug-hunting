echo "Enter main target/program name (enter . if none):"
read program

echo "Enter target:"
read target

echo "Enter provider config filename[Press enter if none]:"
read pc

org=${target%%.*}

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
github-subdomains -d $target -raw | anew allsub.txt

echo "[*] Permutation submains ..."
shuffledns -d $target -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -r ~/Downloads/resolvers-trusted.txt -mode bruteforce | anew allsub.txt
cat allsub.txt | alterx | shuffledns -d $target -r /usr/share/wordlists/SecLists/Miscellaneous/dns-resolvers.txt -mode resolve | anew subs.txt

echo "[*] Checking for alive targets using httpx..."
cat allsub.txt | httpx -t 100 -duc | tee -a probedsub.txt

echo "[*] Fetching all the URLs using katana and performing pattern matching..."
timeout 30m katana -list probedsub.txt -d 3 -kf -jc \
-ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg \
-duc -o allurls.txt || echo "Katana timed out after 30 minutes"

timeout 30m bash -c \
"cat probedsub.txt | gau --threads 10 \
| grep -vE '\.(woff|css|png|svg|jpg|woff2|jpeg|gif|svg)$' \
| anew allurls.txt" || echo "Gau timed out after 30 minutes"

cat allurls.txt | grep -E "\.js$" | grep -vE "jquery|momentjs|bootstrap|lodash|polyfills|angular|modernizr|react|vue|backbone|ember|knockout|meteor|node|express|socket.io|d3|highcharts|leaflet|phaser" | anew | tee -a js.txt
cat allurls.txt | gf xss | tee -a gfxss.txt
cat allurls.txt | gf sqli | tee -a gfsqli.txt
cat allurls.txt | gf rce | tee -a gfrce.txt
cat allurls.txt | gf lfi | tee -a gflfi.txt
cat allurls.txt | gf ssrf | tee -a gfssrf.txt
cat allurls.txt | gf idor | tee -a gfidor.txt
cat allurls.txt | gf ssti | tee -a gfssti.txt

echo "[*] Fetching all the ip's from hosts and shodan..."
while read -r domain; do dig +short "$domain"  | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'; done < allsub.txt | anew ips.txt
python3 ~/Documents/tools/freedan/freedan.py -S $target | anew ips.txt

httpx -status-code -title -tech-detect -cl -list allsub.txt -t 100 -duc -o httpx.txt


echo "Finished Automation1 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
