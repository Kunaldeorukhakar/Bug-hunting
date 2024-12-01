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


echo "[*] Checking for Subdomain Takeover ..."
subzy run --targets allsub.txt | tee -a Subdomaintakeover.txt

echo "[*] Checking for SQLi using Nuclei fuzzing templates..."
nuclei -l gfsqli.txt -no-httpx -v -t ~/nuclei-templates/fuzzing-templates/sqli -o nucleifuzzsqli.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for LFI using Nuclei fuzzing templates..."
nuclei -l gflfi.txt -no-httpx -v -t ~/nuclei-templates/fuzzing-templates/lfi -o nucleifuzzlfi.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for Open-redirect using Nuclei fuzzing templates..."
nuclei -l gfredirect.txt -no-httpx -v -t ~/nuclei-templates/fuzzing-templates/redirect -o nucleifuzzredirect.txt | notify -pc ~/Documents/BugBounty/$pc

echo "[*] Checking for vulnerabilites using Nuclei templates..."
nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/cves -severity critical,high,medium -o nucleicves.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/cnvd -severity critical,high,medium -o nucleicnvd.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/exposed-panels -severity critical,high,medium -o nucleiexposedpanels.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/takeovers -severity critical,high,medium -o nucleitakeovers.txt | notify -pc ~/Documents/BugBounty/$pc  

nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/http/exposures -severity critical,high,medium -o nucleiexposures.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -no-httpx -v -t ~/nuclei-templates/network -severity critical,high,medium -o nucleinetwork.txt | notify -pc ~/Documents/BugBounty/$pc


echo "Finished Automation3 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
