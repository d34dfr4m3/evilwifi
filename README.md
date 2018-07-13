# evilwifi
### Projeto
Projeto visa ataques Wifi moveis, conhecidos como warwalking. Para esse objetivo, será empregado os seguintes hardwares:
- Raspberry Pi 3 B+, alimentado pela bateria de litio.
- Bateria de Litio, autonomia segundo fabricante de 9h.
- Antena NetSys de 95Dbi, alimentada via USB pela bateria de litio.
- Smartphone

Com todo o setup realizado, a ideia é que raspberry, bateria e antena fiquem na mochila. Enquanto o smarphone que estará conectado no raspberry será utilizado para controlar os ataques. 



### First 
- Create a AP, use dns poisoning to redirect the requests to fake webpages to intercept credentials. 

#### To do 
- Fake AP -> OK (hostapd/dnsmasq(DHCP))
- DNS Poisoning -> OK (dnsmasq)
- Security and Redirect -> OK (Iptables)
- WebServer -> OK (nginx)
- MITM HSTS -> 
- JS Injection -> 
- Console de status de conexões estabelecidades(DHCP), requisições DNS e dump de credenciais.

```
tail -f /var/log/syslog | grep -i dnsmasq
``` 

###### Fontes:
- https://www.reddit.com/r/darknetplan/comments/ou7jj/quick_and_dirty_captive_portal_with_dnsmasq/
- http://www.instructables.com/id/How-to-make-a-WiFi-Access-Point-out-of-a-Raspberry/
