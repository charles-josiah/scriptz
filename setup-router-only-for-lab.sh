#!/bin/bash

#####
# NAO USAR EM AMBIENTES DE PRODUCAO
# VERSAO BETA DO ALFA
# SOMENTE PARA TESTES EM LABORATORIO
# PREENCHA AS VARIAIS INICIAIS DAS INTERFACES



# Define as interfaces
WAN_IFACE="eth0"      # interface conectada a internet
LAN_IFACE="eth1"      # interface interna para os clientes

# 1. Ativa o roteamento IP
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

ifup $WAN_IFACE
ifup $LAN_IFACE

# 2. Configura regras NAT (masquerade)
apt-get install -y iptables
iptables -t nat -A POSTROUTING -o $WAN_IFACE -j MASQUERADE
iptables -A FORWARD -i $LAN_IFACE -o $WAN_IFACE -j ACCEPT
iptables -A FORWARD -i $WAN_IFACE -o $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT

# 3. Instala servidor DHCP
apt update && apt install -y isc-dhcp-server

# 4. Configura o DHCP para a rede interna
cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.10 192.168.100.100;
  option routers 192.168.100.1;
  option domain-name-servers 8.8.8.8;
}
EOF

# 5. Define a interface usada pelo DHCP
echo "INTERFACESv4=\"$LAN_IFACE\"" > /etc/default/isc-dhcp-server

# 6. Define IP fixo para a interface LAN
cat <<EOF >> /etc/network/interfaces
auto $LAN_IFACE
iface $LAN_IFACE inet static
  address 192.168.100.1
  netmask 255.255.255.0
EOF

# 7. Salva regras do iptables
iptables-save > /etc/iptables.rules

# 8. Cria script para restaurar no boot
cat <<EOF > /etc/network/if-pre-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF
chmod +x /etc/network/if-pre-up.d/iptables

# 9. Reinicia o servidor DHCP
systemctl restart isc-dhcp-server
