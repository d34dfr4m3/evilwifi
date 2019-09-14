# evilwifi
### Projeto
Projeto visa ataques Wifi moveis, conhecidos como warwalking. Para esse objetivo, será empregado os seguintes hardwares:
- Raspberry Pi 3 B+, alimentado pela bateria de litio.
- Bateria de Litio, autonomia segundo fabricante de 9h.
- Antena NetSys de 95Dbi, alimentada via USB pela bateria de litio.
- Smartphone

Com todo o setup realizado, a ideia é que raspberry, bateria e antena fiquem na mochila. Enquanto o smarphone que estará conectado no raspberry será utilizado para controlar os ataques. 

## How Install 
##### Dependências: 
- git
```

apt get install git 
git clone https://github.com/d34dfr4m3/evilwifi.git
cd evilwifi
./install.sh
```

## How to run: 

```
./setup 

```

### First 
- Create a AP, use dns poisoning to redirect the requests to fake webpages to intercept credentials. 

#### To do 
- Fake AP -> OK (hostapd/dnsmasq(DHCP))
- DNS Poisoning -> OK (dnsmasq)
- Security and Redirect -> OK (Iptables)
- WebServer -> OK (nginx)
- Captive Portal stuff
- MITM HSTS -> 
- JS Injection -> 
- Console de status de conexões estabelecidades(DHCP), requisições DNS e dump de credenciais.

```
tail -f /var/log/syslog | grep -i dnsmasq
``` 
#### Captive Portal
- https://tools.ietf.org/html/rfc7710
- https://en.wikipedia.org/wiki/Captive_portal
- https://andrewwippler.com/2016/03/11/wifi-captive-portal/
- https://www.reddit.com/r/darknetplan/comments/ou7jj/quick_and_dirty_captive_portal_with_dnsmasq/
- https://www.chromium.org/chromium-os/chromiumos-design-docs/network-portal-detection

#### SSH over Bluetooth 
- https://www.reddit.com/r/raspberry_pi/comments/25c1ok/how_to_ssh_over_bluetooth_to_an_rpi/

###### Fontes:
- http://www.instructables.com/id/How-to-make-a-WiFi-Access-Point-out-of-a-Raspberry/
- https://blog.heckel.xyz/2013/07/18/how-to-dns-spoofing-with-a-simple-dns-server-using-dnsmasq/
- https://en.wikipedia.org/wiki/DNS_spoofing
