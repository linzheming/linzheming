#!/bin/bash
if [ ! -f /usr/bin/jq ]; then
    echo "Install jq"
    apt update && apt install -y jq
fi

swap=`swapon -s`
if [ -z "$swap" ]; then
        echo "NO SWAP, ADD NOW..."
        mkdir swap
        cd swap
        dd if=/dev/zero of=sfile bs=1024 count=2000000
        mkswap sfile
        swapon sfile
        echo "/root/swap/sfile  none  swap  sw  0  0" >>  /etc/fstab
        echo "Swap Done"
fi

# 检测有无cashout.sh脚本
if [ ! -f /root/cashout.sh ]; then
    # download cashout.sh
    echo "Download Cashout.sh"
    cd ~
    wget -O cashout.sh https://gist.githubusercontent.com/leepood/c121e416703a708ac2c7829525774334/raw/905e084c90b8c0c41eabde551d9e63508f4e6dae/cashout.sh
    chmod +x cashout.sh
fi

cd /tmp

echo "Check has Install Bee-Clef"
echo ""

if [ ! -f /usr/bin/bee-clef-service ]; then
    echo "Bee-Clef not installed, Install Bee-Clef Now"
    wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.9/bee-clef_0.4.9_amd64.deb
    dpkg -i bee-clef_0.4.9_amd64.deb
    systemctl enable bee-clef
    systemctl start bee-clef
else
    echo "Bee-clef Has installed, skip"
fi

echo "Check Has Installed Bee"
echo ""

if [ ! -f /usr/bin/bee ]; then
    echo "Instal Bee"
    wget https://github.com/ethersphere/bee/releases/download/v0.5.3/bee_0.5.3_amd64.deb
    dpkg -i bee_0.5.3_amd64.deb
    systemctl enable bee
    cat>/etc/bee/bee.yaml<< EOF
## Bee configuration - https://gateway.ethswarm.org/bzz/docs.swarm.eth/docs/installation/configuration/
## HTTP API listen address (default ":1633")
# api-addr: :1633
## initial nodes to connect to (default [/dnsaddr/bootnode.ethswarm.org])
# bootnode: [/dnsaddr/bootnode.ethswarm.org]
## cause the node to always accept incoming connections
# bootnode-mode: false
## enable clef signer
clef-signer-enable: true
## clef signer endpoint
clef-signer-endpoint: /var/lib/bee-clef/clef.ipc
## config file (default is /home/<user>/.bee.yaml)
config: /etc/bee/bee.yaml
## origins with CORS headers enabled
# cors-allowed-origins: []
## data directory (default "/home/<user>/.bee")
data-dir: /var/lib/bee
## db capacity in chunks, multiply by 4096 to get approximate capacity in bytes
# db-capacity: 5000000
## number of open files allowed by database
db-open-files-limit: 400
## size of block cache of the database in bytes
# db-block-cache-capacity: 33554432
## size of the database write buffer in bytes
# db-write-buffer-size: 33554432
## disables db compactions triggered by seeks
# db-disable-seeks-compaction: false
## debug HTTP API listen address (default ":1635")
debug-api-addr: 127.0.0.1:1635
## enable debug HTTP API
debug-api-enable: true
## disable a set of sensitive features in the api
# gateway-mode: false
## enable global pinning
# global-pinning-enable: false
## NAT exposed address
# nat-addr: ""
## ID of the Swarm network (default 1)
# network-id: 1
## P2P listen address (default ":1634")
# p2p-addr: :1634
## enable P2P QUIC protocol
# p2p-quic-enable: false
## enable P2P WebSocket transport
# p2p-ws-enable: false
## password for decrypting keys
# password: ""
## path to a file that contains password for decrypting keys
password-file: /var/lib/bee/password
## amount in BZZ below the peers payment threshold when we initiate settlement (default 1000000000000)
# payment-early: 1000000000000
## threshold in BZZ where you expect to get paid from your peers (default 10000000000000)
# payment-threshold: 10000000000000
## excess debt above payment threshold in BZZ where you disconnect from your peer (default 50000000000000)
# payment-tolerance: 50000000000000
## ENS compatible API endpoint for a TLD and with contract address, can be repeated, format [tld:][contract-addr@]url
# resolver-options: []
## whether we want the node to start with no listen addresses for p2p
# standalone: false
## enable swap (default true)
# swap-enable: true
## swap ethereum blockchain endpoint (default "http://localhost:8545")
swap-endpoint: https://goerli.infura.io/v3/14dbc0b2a45f41d6a86d72c22d56ec0d
#swap-endpoint: https://goerli.infura.io/v3/9e2530a1621142f9958a03443eaef1fa
## swap factory address
# swap-factory-address: ""
## initial deposit if deploying a new chequebook (default 100000000000000000)
# swap-initial-deposit: 100000000000000000
## enable tracing
# tracing-enable: false
## endpoint to send tracing data (default "127.0.0.1:6831")
# tracing-endpoint: 127.0.0.1:6831
## service name identifier for tracing (default "bee")
# tracing-service-name: bee
## log verbosity level 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=trace (default "info")
# verbosity: info
## send a welcome message string during handshakes
welcome-message: "您好啊，我是币圈小骚货"
EOF
    echo "Start Bee..."
    rm -rf /var/lib/bee/statestore
    systemctl start bee
else
    echo "Bee Has Started, Skip...."
fi

echo "Check Utils..."
aliasBeeCo=`alias | grep bec`
if [ -z "$aliasBeeCo" ]; then
    echo "alias bec='curl localhost:1635/chequebook/cheque | jq'" >> /root/.bashrc
    source /root/.bashrc
fi

aliasBeeCashout=`alias | grep beco`
if [ -z "$aliasBeeCashout" ]; then
    echo "alias beco='/root/cashout.sh cashout-all 5'" >> /root/.bashrc
    source /root/.bashrc
fi

echo "Export Private Keys...."
privateKey=`ls /var/lib/bee-clef/keystore/`
echo "Key file name: "$privateKey

echo "Private Key: "
cat "/var/lib/bee-clef/keystore/"$privateKey

echo ""
password=`cat /var/lib/bee-clef/password`
echo "Password: "$password


#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 */2 * * * /root/cashout.sh cashout-all" >> mycron
#install new cron file
crontab mycron
rm mycron













