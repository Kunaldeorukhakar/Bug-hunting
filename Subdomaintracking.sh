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


echo "[*] Scanning and finding new subdomains..."
subfinder -d $target -t 100 -v;python3 ~/Documents/tools/github-subdomains.py -t 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 -d $target | anew  allsub.txt |tee -a newsubdomain_$(date +"%Y%m%d_%H%M%S").txt | notify -pc ~/Documents/BugBounty/$pc | tee -a allsub.txt

echo "[*] Scanning for any changes in applications/servers..."
httpx -status-code -title -tech-detect -cl -list allsub.txt | anew  httpx.txt |tee -a newhttpx_$(date +"%Y%m%d_%H%M%S").txt | notify -pc ~/Documents/BugBounty/$pc | tee -a httpx.txt

echo "[*] Scanning and finding new Github secrets..."
trufflehog github --org=$target --results=verified --no-update | anew gitsecrets.txt |tee -a newgitsecrets_$(date +"%Y%m%d_%H%M%S").txt | notify -pc ~/Documents/BugBounty/$pc | tee -a gitsecrets.txt

echo "Finished subdomain tracking of $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
