echo "Enter main target/program name (enter . if none):"
read program

echo "Enter target:"
read target

echo "Enter provider config filename[Press enter if none]:"
read pc

echo "Enter rate-limit:"
read rate_limit

# Set default if empty
if [[ -z "$rate_limit" ]]; then
  rate_limit=120
  echo "[*] No rate-limit entered. Using default: $rate_limit"
fi

# Validate numeric input
if ! [[ "$rate_limit" =~ ^[0-9]+$ ]]; then
  echo "[!] Invalid rate-limit. Please enter a number."
  exit 1
fi

org=${target%%.*}

mkdir $program 
cd $program

mkdir $target
cd $target

echo "[*] Checking for XSS ..."
dalfox file gfxss.txt -b 'https://harboursec.bxss.in' -w 200 | tee -a xss.txt 

echo "[*] Checking for SSRF using Nuclei templates..."
nuclei -l gfssrf.txt -v -t ~/nuclei-templates/dast/vulnerabilities/ssrf -dast -rate-limit $rate_limit -o nucleissrf.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for SQLI using Nuclei templates..."
nuclei -l gfsqli.txt -v -t ~/nuclei-templates/dast/vulnerabilities/sqli -dast -rate-limit $rate_limit -o nucleisqli.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for SSTI using Nuclei templates..."
nuclei -l gfssti.txt -v -t ~/nuclei-templates/dast/vulnerabilities/ssti -dast -rate-limit $rate_limit -o nucleissti.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for LFI using Nuclei fuzzing templates..."
nuclei -l gflfi.txt -v -t ~/nuclei-templates/dast/vulnerabilities/lfi -dast -rate-limit $rate_limit -o nucleilfi.txt | notify -pc ~/Documents/BugBounty/$pc

#echo "[*] Checking for exposures using Nuclei..."
#nuclei -l allsub.txt -t exposures,exposed-panels -v | anew nucleifindings.txt


#echo "[*] Checking for LFI using Nuclei fuzzing templates..."
#nuclei -l gflfi.txt -no-httpx -v -t ~/nuclei-templates/fuzzing-templates/lfi -o nucleifuzzlfi.txt | notify -pc ~/Documents/BugBounty/$pc

#echo "[*] Checking for Open-redirect using Nuclei fuzzing templates..."
#nuclei -l gfredirect.txt -no-httpx -v -t ~/nuclei-templates/fuzzing-templates/redirect -o nucleifuzzredirect.txt | notify -pc ~/Documents/BugBounty/$pc

#echo "[*] Checking for vulnerabilites using Nuclei templates..."
#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/cves -severity critical,high,medium -o nucleicves.txt | notify -pc ~/Documents/BugBounty/$pc

#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/cnvd -severity critical,high,medium -o nucleicnvd.txt | notify -pc ~/Documents/BugBounty/$pc

#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/exposed-panels -severity critical,high,medium -o nucleiexposedpanels.txt | notify -pc ~/Documents/BugBounty/$pc

#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/takeovers -severity critical,high,medium -o nucleitakeovers.txt | notify -pc ~/Documents/BugBounty/$pc  

#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/exposures -severity critical,high,medium -o nucleiexposures.txt | notify -pc ~/Documents/BugBounty/$pc

#nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/network -severity critical,high,medium -o nucleinetwork.txt | notify -pc ~/Documents/BugBounty/$pc


echo "Finished Automation3 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
