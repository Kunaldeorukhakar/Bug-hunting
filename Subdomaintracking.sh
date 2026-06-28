echo "Enter main target/program name (enter . if none):"
read program

echo "Enter target:"
read target

echo "Enter provider config filename:"
read pc

org=${target%%.*}

mkdir $program 
cd $program

mkdir $target
cd $target

# Output file
output_file="new_sub.txt"

echo "Scan Date: $(date +"%d-%m-%Y %H:%M:%S")" >> "$output_file"
echo "-------------------------------------" >> "$output_file"

echo "[*] Scanning and finding new subdomains..."
# old
# subfinder -d $target -t 100 -v;github-subdomains -t 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 -d $target | anew  allsub.txt |tee -a newsubdomain_$(date +"%d;%m;%Y_%H;%M;%S").txt | notify -pc ~/Documents/BugBounty/$pc

# new
echo "--------------Subdomains-------------" >> $output_file
subfinder -d $target -t 100 -silent | shuffledns -d $target -r /usr/share/wordlists/SecLists/Miscellaneous/dns-resolvers.txt -mode resolve | anew allsub.txt | tee -a $output_file


echo "[*] Scanning for any changes in applications/servers..."
# old
# httpx -status-code -title -tech-detect -cl -list allsub.txt -duc | anew httpx.txt |tee -a newhttpx_$(date +"%d;%m;%Y_%H;%M;%S").txt | notify -pc ~/Documents/BugBounty/$pc

#new
echo "--------------URLs-------------" >> $output_file
httpx -status-code -title -tech-detect -cl -list allsub.txt -duc | anew httpx.txt | tee -a $output_file

echo "[*] Scanning and finding new Github secrets..."
# old
# trufflehog github --org=$org --results=verified --no-update | anew gitsecrets.txt |tee -a newgitsecrets_$(date +"%d;%m;%Y_%H;%M;%S").txt | notify -pc ~/Documents/BugBounty/$pc

# new
echo "--------------Secrets-------------" >> $output_file
trufflehog github --org=$org --token=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 --results=verified --no-update | anew gitsecrets.txt | tee -a $output_file


echo "[*] Checking for Subdomain takeover..."
# old
# subzy run --targets allsub.txt --hide_fails | tee -a newSubdomaintakeover_$(date +"%d;%m;%Y_%H;%M;%S").txt

# new
echo "--------------Subdomain-Takeover-------------" >> $output_file
subzy run --targets allsub.txt --hide_fails | anew Subdomaintakeover.txt | tee -a $output_file

echo "Finished subdomain tracking of $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
