
read target

echo "Enter provider config filename:"
read pc

mkdir $program 
cd $program

mkdir $target
cd $target

nuclei -l allsub.txt -v -t ~/nuclei-templates/http/cves -o nucleicves.txt | notify -pc ~/Documents/BugBounty/$pc
nuclei -l allsub.txt -v -t ~/nuclei-templates/http/cnvd -o nucleicnvd.txt | notify -pc ~/Documents/BugBounty/$pc
nuclei -l allsub.txt -v -t ~/nuclei-templates/http/exposed-panels -o nucleiexposedpanels.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -v -t ~/nuclei-templates/http/takeovers -o nucleitakeovers.txt | notify -pc ~/Documents/BugBounty/$pc  

nuclei -l allsub.txt -v -t ~/nuclei-templates/http/exposures -o nucleiexposures.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l allsub.txt -v -t ~/nuclei-templates/network -o nucleinetwork.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l gfssrf.txt -v -t ~/nuclei-templates/fuzzing-templates/ssrf -o nucleifuzzssrf.txt| notify -pc ~/Documents/BugBounty/$pc

nuclei -l gfsqli.txt -v -t ~/nuclei-templates/fuzzing-templates/sqli -o nucleifuzzsqli.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l gflfi.txt -v -t ~/nuclei-templates/fuzzing-templates/lfi -o nucleifuzzlfi.txt | notify -pc ~/Documents/BugBounty/$pc

nuclei -l gfredirect.txt -v -t ~/nuclei-templates/fuzzing-templates/redirect -o nucleifuzzredirect.txt | notify -pc ~/Documents/BugBounty/$pc

echo "Finished Automation3 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
