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


subfinder -d $target -t 100 -v | anew  allsub.txt |tee -a newsubdomain_$(date +"%Y%m%d_%H%M%S").txt | notify -pc ~/Documents/BugBounty/$pc | tee -a allsub.txt


httpx -status-code -title -tech-detect -cl -list allsub.txt | anew  httpx.txt |tee -a newhttpx_$(date +"%Y%m%d_%H%M%S").txt | notify -pc ~/Documents/BugBounty/$pc | tee -a httpx.txt


echo "Finished subdomain tracking of $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
