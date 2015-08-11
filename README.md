# autoddvpn
Automatically exported from code.google.com/p/autoddvpn
 how to setup autoddvpn with openvpn
Introduction to openVPN
這份文件說明如何讓autoddvpn搭配OpenVPN環境使用。

autoddvpn最早的設計是搭配PPTP VPN使用，然而在某些不允許PPTP穿透的網路環境可能會造成無法連上的問題，而OpenVPN的方式如果將OpenVPN server listen在TCP 443則可以滿足大部分的網路環境。

目前autoddvpn+openvpn的方式只提供JFFS方式來運行。
Details

    在ddwrt web界面設置openvpn client
    准備JFFS環境
    如何放置腳本到JFFS
    rc_startup設置
    測試

在ddwrt web界面設置openvpn client

基本上按照以下截屏來設置openvpn client即可，注意這個范例是將openvpn server listen在UDP 443 port, 請按照你的server具體來配置，但強烈建議你的server使用UDP or TCP 443。

（說明：部分文件建議openvpn使用UDP會有最好的效能，但也有部分網友表示使用TCP反而更穩定，目前autoddvpn的開發環境是使用UDP 443）

最後的 CA Cert, Public Client Cert, Private Client Key 這三個欄目請跟openvpn服務器管理員索取，你需要講內容當中的

-----BEGIN XXXXXX-----

-----END XXXXXX-----

連同當中的本文一起貼入，見截屏。

准備JFFS環境

您需要參考這份文件裡面關於JFFS設置的說明來啟用JFFS支持，注意，只需要參考該文件來打開JFFS支持即可。
如何放置腳本到JFFS

重啟之後ssh進入ddwrt,切換到/jffs目錄，創建/jffs/openvpn/子目錄之後下載三個files：

$ cd /jffs
$ mkdir /jffs/openvpn
$ cd /jffs/openvpn
$ wget http://autoddvpn.googlecode.com/svn/trunk/openvpn/jffs/run.sh
$ for i in vpnup vpndown; do wget http://autoddvpn.googlecode.com/svn/trunk/$i.sh;done;
$ chmod a+x *.sh

這時記得ls -l /jffs/openvpn/看一下是否檔案確實下載下來了，並且都是可執行的。
rc_startup設置

最後設置rc_startup

$ nvram set rc_startup='/jffs/openvpn/run.sh'
$ nvram commit
$ reboot

重開機之後檢查 autoddvpn.log

root@DD-WRT:/tmp# tail -f /tmp/autoddvpn.log 
[INFO#357] 01/Jan/1970:00:00:17 log starts
[INFO#357] 01/Jan/1970:00:00:17 modifying /tmp/openvpncl/route-up.sh
[INFO#357] 01/Jan/1970:00:00:17 /tmp/openvpncl/route-up.sh not exists, sleep 10sec.
[INFO#357] 01/Jan/1970:00:00:28 /tmp/openvpncl/route-up.sh not exists, sleep 10sec.
[INFO#357] 28/Jul/2010:03:10:48 /tmp/openvpncl/route-up.sh modified
[INFO#357] 28/Jul/2010:03:10:48 modifying /tmp/openvpncl/route-down.sh
[INFO#357] 28/Jul/2010:03:10:48 /tmp/openvpncl/route-down.sh modified
[INFO#357] 28/Jul/2010:03:10:48 ALL DONE. Let's wait for VPN being connected.
[INFO#687] 28/Jul/2010:03:11:14 vpnup.sh started
[INFO#687] 28/Jul/2010:03:11:37 vpnup.sh ended

測試

這時如果你打開 http://whatismyip.org 應該會看到你的OpenVPN public IP, 表示你是透過OpenVPN訪問國外，同時打開 http://myip.cn 應該會看到國內的IP， 表示透過正常路由訪問國內，這樣就表示成功了。 



Introduction to PPTP

這份文件說明如何設置 autoddvpn 環境
Details

autoddvpn目前有三種運行模式，各有不同的優缺點，大家可以選擇適合的模式來運行：
wget遠程腳本模式
jffs模式
custom firmware自制韌體模式
wget遠程腳本模式

autoddvpn開機之後，藉由rc_firewall腳本來執行wget取得遠程腳本來運行，這是最早期autoddvpn開發的模式

優點：只需要在ddwrt的web界面設定即可，技術門檻最低。

缺點：存在一些已知的問題，可能會有不穩定的情況。
jffs模式

將所需要執行的腳本放入/jffs/可寫入的filesystem裡面，並且定義rc_startup使其一開機就能自動執行

優點：同時具備升級的彈性以及執行的獨立性，完全不需要依賴網路就能執行腳本。 這是目前最推薦的方式

缺點：用戶需要具備ssh以及基本linux操作經驗，每次升級都需要ssh進入ddwrt裡面操作。
custom firmware自制韌體模式

自己制作具備autoddvpn功能的DDWRT韌體，經由韌體升級之後使其韌體本身就具備autoddvpn功能

    優點：非常適合大批同一款路由器的升級，開發人員只要准備好.bin韌體，所有用戶只要透過web來升級韌體即可，對用戶來說是最簡單的方式。 

    缺點：對開發者來說比較麻煩，每一次腳本升級都需要重新包裝韌體。 

在選擇使用哪一種模式之前，請先進行下面的基本設置：
設置PPTP client

如下圖

說明：

    PPTP主機請用IP設置， 不要設置FQDN，否則之後會斷線
    MPPE Encryption裡面輸入 mppe required,no40,no56,stateless
    Remote Subnet 與Remote Subnet Mask是你PPTP撥上之後的VPN子網路與遮罩，請依據自己的環境設置，必要的話可以先用電腦嘗試連上PPTP, 觀察取得的VPN IP/Netmask是多少，假如是取得192.168.199.3, 則通常設置成Remote Subnet 192.168.199.0 Remote Subnet Mask 255.255.255.0即可，以此類推。(注意：這兩個參數不用設定也是可以連上PPTP, 但是無法調整正確的路由表，造成無法順利運作，請務必弄清楚這兩個數值，如果設定錯的話會運行失敗的) 

如果實在不知道怎麼找出這兩個數值，請參考這裡的教學

    Username Password是你的PPTP撥號的帳戶密碼 

設置DNS

DD-WRT使用dnsmasq來做簡易的name cache服務，因為dnsmasq只會forward到上游DNS以及cache查詢結果，並不會跟bind9一樣從Root DNS一路查詢下來，因此如果上游DNS資料被污染的話，dnsmasq的資料也會被污染。

這裡我們關閉了dnsmasq服務，強迫使用Google DNS與OpenDNS, 因為建立VPN之後DD-WRT跟境外DNS之間就走加密VPN了，因此不用擔心被污染的問題，請注意，DDWRT提供的三台靜態DNS全部都要設置上去，分別設置為：

8.8.8.8
8.8.4.4
208.67.222.222

注意： # 必須三台都設置，如果設置少於三台，DDWRT會使用ISP動態發放的國內DNS來補上，這會造成風險

設定方式如下：

這樣的設置的優缺點是：

優點

    建立VPN之後，將完全不會有DNS劫持問題 

缺點

    DD-WRT下面的所有電腦的DNS都會被設置為Google DNS
    DD-WRT本身不做name cache, 因此所有查詢都會經由VPN到Google去，相對的會比較慢
    國內一些CDN加速的網站，例如www.qq.com, 很可能Google查詢的結果並不會是最優化的結果，可能訪問會比較慢一點，實際要看每個人的感受。 

然而可以透過DNSMasq自定域名國內查詢的方式來解決以上缺點，但建議第一次使用autoddvpn的用戶先不要理會這部分，等autoddvpn正常運行之後再來看這份文件。
接著請選擇三種模式其中一種來操作即可
wget模式
jffs模式
custom firmware自制韌體模式
