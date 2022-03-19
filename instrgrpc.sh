cat > /etc/xray/akuntrgrpc.conf << EOF
#xray-trojangrpc user
EOF

cat > /etc/systemd/system/x-trgrpc.service << EOF
[Unit]
Description=XRay Trojan Grpc Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/trojangrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/xray/trojangrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access5.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 653,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "${uuid}"
#xtrgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "$domain",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 653 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 653 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl enable x-trgrpc.service
systemctl start x-trgrpc.service

cd /usr/bin
wget -O addxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpnauthip/main/addxtrgrpc.sh"
wget -O delxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpnauthip/main/delxtrgrpc.sh"
wget -O cekxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpnauthip/main/cekxtrgrpc.sh"
chmod +x addxtrgrpc
chmod +x delxtrgrpc
chmod +x cekxtrgrpc
