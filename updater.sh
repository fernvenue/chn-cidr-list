#!/bin/bash
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan gitlab.com > ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts
git config --global user.email "$GITLAB_MAIL_ADDRESS"
git config --global user.name "fernvenue"
git clone git@gitlab.com:fernvenue/chn-cidr-list.git
cd './chn-cidr-list'
curl 'https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt' > ipv4.txt
sed -i 's/[[:space:]]//g' './ipv4.txt'
cp ./ipv4.txt ./ipv4.yaml
sed -i "s|^|  - '&|g" ./ipv4.yaml
sed -i "s|$|&'|g" ./ipv4.yaml
sed -i "1s|^|payload:\n|" ./ipv4.yaml
cp ./ipv4.txt ./ipv4.conf
sed -i "s|^|IP-CIDR,|g" ./ipv4.conf
curl 'https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt' > ipv6.txt
sed -i 's/[[:space:]]//g' './ipv6.txt'
cp ./ipv6.txt ./ipv6.yaml
sed -i "s|^|  - '&|g" ./ipv6.yaml
sed -i "s|$|&'|g" ./ipv6.yaml
sed -i "1s|^|payload:\n|" ./ipv6.yaml
cp ./ipv6.txt ./ipv6.conf
sed -i "s|^|IP-CIDR6,|g" ./ipv6.conf
git init
git add .
git commit -m 'Update CIDR list'
git push -u origin master
