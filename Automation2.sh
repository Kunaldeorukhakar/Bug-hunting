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

echo "[*] Checking for Subdomain Takeover ..."
subzy run --targets allsub.txt | tee -a Subdomaintakeover.txt

echo "[*] Finding reflected params for manual testing.."
cat gfxss.txt | qsreplace KRD | httpx -silent -mr KRD | tee -a reflected.txt

echo "[*] Finding exposed .git files.."
cat allsub.txt | httpx -sc -server -cl -path "/.git/" -mc 200 -location -ms "Index of" -probe | tee -a dotgitexposed.txt

#echo "[*] Finding secrets from js files..."
#cat js.txt | while read url; do python3 ~/Documents/tools/SecretFinder/SecretFinder.py -i $url -o cli >> secrets.txt; done

echo "[*] Finding secrets from Github ..."
trufflehog github --org=$org --token=$GITHUB_TOKEN --results=verified --no-update | tee -a gitsecrets.txt

echo "[*] Finding open ports ..."
naabu -list ips.txt -top-ports 1000 -Pn -rate 1000 -o open_ports.txt 

echo "[*] Enumerating cloud environment..."
enumkey="${target%%.*}"
python3 ~/Documents/tools/cloud_enum/cloud_enum.py -k $enumkey --quickscan -t 10 | tee cloud.txt


echo "Finished Automation2 for $target on $(date)" | notify -pc ~/Documents/BugBounty/$pc
