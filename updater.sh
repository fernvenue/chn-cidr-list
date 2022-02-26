#!/bin/bash
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d "\r" | ssh-add -
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan gitlab.com > ~/.ssh/known_hosts
git config --global user.email "$GIT_MAIL_ADDRESS"
git config --global user.name "fernvenue"
git clone git@gitlab.com:fernvenue/chn-cidr-list.git
cd "./chn-cidr-list"
curl "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt" > ipv4-bgp.txt
sed -i "s/[[:space:]]//g" "./ipv4-bgp.txt"
curl "http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest" | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > ipv4-apnic.txt
sed -i "s/[[:space:]]//g" "./ipv4-apnic.txt"
wget `curl -s https://api.github.com/repos/zhanhb/cidr-merger/releases/latest | grep -Po '(?<=download_url\"\: \").*linux-amd64'`
mv ./cidr-merger-linux-amd64 ./cidr-merger
chmod +x ./cidr-merger
cat ./ipv4*.txt | ./cidr-merger -s > ./ipv4.txt
cp ./ipv4.txt ./ipv4.yaml
sed -i "s|^|  - '&|g" ./ipv4.yaml
sed -i "s|$|&'|g" ./ipv4.yaml
sed -i "1s|^|payload:\n|" ./ipv4.yaml
cp ./ipv4.txt ./ipv4.conf
sed -i "s|^|IP-CIDR,|g" ./ipv4.conf
curl "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt" > ipv6-bgp.txt
sed -i "s/[[:space:]]//g" "./ipv6-bgp.txt"
curl "http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest" | grep ipv6 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > ipv6-apnic.txt
sed -i "s/[[:space:]]//g" "./ipv6-apnic.txt"
cat ./ipv6*.txt | ./cidr-merger -s > ./ipv6.txt
cp ./ipv6.txt ./ipv6.yaml
sed -i "s|^|  - '&|g" ./ipv6.yaml
sed -i "s|$|&'|g" ./ipv6.yaml
sed -i "1s|^|payload:\n|" ./ipv6.yaml
cp ./ipv6.txt ./ipv6.conf
sed -i "s|^|IP-CIDR,|g" ./ipv6.conf
rm cidr-merger *bgp.txt *apnic.txt
updated=`date --rfc-3339 sec`
sed -i "1{x;p;x;}" ./ipv*
sed -i "1i # GitHub: https://github.com/fernvenue/chn-cidr-list" ./ipv*
sed -i "1i # GitLab: https://gitlab.com/fernvenue/chn-cidr-list" ./ipv*
sed -i "1i # Updated: $updated" ./ipv*
sed -i "1i # License: BSD-3-Clause License" ./ipv*
sed -i "1i # CHN CIDR list" ./ipv*
git init
git add .
git commit -m "$updated"
git push -u origin master
