#!/bin/sh
# Copyright (c) 2026 Eng / Ahmed Abdel-Moati - VU Only V1
# Vu+ Only - Novaler Plugins Skip
clear; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - VU Only V1"; sleep 2
P="/usr/script/allscript_progress.txt"; touch "$P"; DONE=$(cat "$P" 2>/dev/null); [ -z "$DONE" ] && DONE=0

# ===== كشف نوع الصورة =====
get_image_raw() { cat /etc/image-version 2>/dev/null; echo ""; cat /etc/issue 2>/dev/null; echo ""; cat /etc/os-release 2>/dev/null; echo ""; cat /etc/version 2>/dev/null; echo ""; ls /etc/*atv* /etc/*egami* /etc/*pli* /etc/*vix* /etc/*bh* 2>/dev/null; }
IMAGE_RAW="$(get_image_raw)"
IS_ATV=0; IS_EGAMI=0; IS_PLI=0; IS_BH=0; IS_VIX=0
echo "$IMAGE_RAW" | grep -qi "openatv" && IS_ATV=1
echo "$IMAGE_RAW" | grep -qi "egami" && IS_EGAMI=1
echo "$IMAGE_RAW" | grep -qi "openpli" && IS_PLI=1
echo "$IMAGE_RAW" | grep -qi "openbh\|blackhole" && IS_BH=1
echo "$IMAGE_RAW" | grep -qi "openvix" && IS_VIX=1

# ===== كشف VU+ بكل الطرق =====
get_device_raw() {
  echo ""
  cat /proc/stb/info/model 2>/dev/null; echo ""
  cat /proc/stb/info/boxtype 2>/dev/null; echo ""
  cat /proc/stb/info/chipset 2>/dev/null; echo ""
  cat /proc/stb/info/version 2>/dev/null; echo ""
  cat /proc/stb/info/board 2>/dev/null; echo ""
  cat /proc/stb/info/hw 2>/dev/null; echo ""
  cat /etc/hostname 2>/dev/null; echo ""
  cat /etc/machine 2>/dev/null; echo ""
  cat /etc/brand 2>/dev/null; echo ""
  cat /etc/boxtype 2>/dev/null; echo ""
  cat /proc/cpuinfo 2>/dev/null | grep -i "hardware\|model\|machine"; echo ""
  cat /sys/firmware/devicetree/base/model 2>/dev/null; echo ""
  cat /proc/stb/fp/version 2>/dev/null; echo ""
  cat /proc/stb/info/mID 2>/dev/null; echo ""
  ls /proc/stb/info/ 2>/dev/null; echo ""
  cat /etc/enigma2/settings 2>/dev/null | grep -i "boxtype\|model" | head -5; echo ""
  cat /proc/stb/info/vumodel 2>/dev/null; echo ""
  cat /proc/stb/info/boxname 2>/dev/null; echo ""
  cat /proc/stb/info/vu 2>/dev/null; echo ""
}
DEV_RAW="$(get_device_raw)"
DEV=$(echo "$DEV_RAW" | tr 'A-Z' 'a-z' | tr '\n' ' ')
echo "Device Raw: $DEV"
IS_VU=0
echo "$DEV" | grep -q "vu\|vusolo\|vuuno\|vuduo\|vuultimo\|vuzero\|vu+ \|vu+\|vusolo2\|vuduo2\|vusolo4k\|vuuno4k\|vuduo4k\|vuultimo4k\|vuzero4k\|vu solo\|vu uno\|vu duo\|vu ultimo\|vu zero" && IS_VU=1
# حماية: لو الجهاز Dream او Zgemma او Octagon او Novaler صريح، الغي الـ VU
echo "$DEV" | grep -q "dream\|dreambox\|dm520\|dm525\|dm900\|dm920" && IS_VU=0
echo "$DEV" | grep -q "novaler\|multibox" && IS_VU=0
echo "$DEV" | grep -q "zgemma" && IS_VU=0
echo "$DEV" | grep -q "octagon\|sf8008\|sf4008" && IS_VU=0
if [ "$IS_VU" = "0" ]; then echo "=============================================="; echo "This Script is for Vu+ Only"; echo "Your Device : $DEV"; echo "Stopped to protect your device"; echo "=============================================="; exit 1; fi
echo "Detect: VU=$IS_VU"
echo "Image: ATV=$IS_ATV EGAMI=$IS_EGAMI PLI=$IS_PLI BH=$IS_BH VIX=$IS_VIX"
echo "=> Vu+ DETECTED - SAFE MODE ON"
IS_NON_NOVALER=1; IS_NOVALER=0

# ===== منع الريستارت =====
mkdir -p /tmp/noreboot
for c in reboot shutdown halt poweroff systemctl busybox; do printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/$c; chmod 755 /tmp/noreboot/$c; done
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/init; chmod 755 /tmp/noreboot/init
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/killall; chmod 755 /tmp/noreboot/killall
ORIG_PATH="$PATH"; export PATH="/tmp/noreboot:$PATH"
wait_for_net() { T=0; while [ $T -lt 40 ]; do ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || wget -q --no-check-certificate --spider https://raw.githubusercontent.com >/dev/null 2>&1 && return 0; T=$((T+1)); sleep 30; export PATH="/tmp/noreboot:$PATH"; done; return 1; }

SKIP_PLI=0; SKIP_FHD=0
if [ "$IS_ATV" = "1" ] || [ "$IS_EGAMI" = "1" ]; then SKIP_PLI=1; fi
if [ "$IS_PLI" = "1" ] || [ "$IS_BH" = "1" ] || [ "$IS_VIX" = "1" ]; then SKIP_FHD=1; fi
if [ "$IS_VIX" = "1" ]; then SKIP_PLI=1; SKIP_FHD=1; fi

install_one() { NUM="$1"; NAME="$2"; URL="$3"
if [ "$NAME" = "aglare-pli" ] || [ "$NAME" = "aglare-fhd" ]; then
  LIVE_RAW="$(get_image_raw)"
  echo "$LIVE_RAW" | grep -qi "openatv" && SKIP_PLI=1
  echo "$LIVE_RAW" | grep -qi "egami" && SKIP_PLI=1
  echo "$LIVE_RAW" | grep -qi "openpli" && SKIP_FHD=1
  echo "$LIVE_RAW" | grep -qi "openbh\|blackhole" && SKIP_FHD=1
  echo "$LIVE_RAW" | grep -qi "openvix" && SKIP_FHD=1
fi
case "$NAME" in
  RaedQuickSignal|novalerdownloader|novalerStore|ipaudiolpus|ipaudiolplus)
    echo "[SKIP $NUM] $NAME - Novaler Only - SAFE SKIP"
    echo "$NUM" > "$P"; DONE=$NUM; return 0
  ;;
esac
if [ "$NAME" = "aglare-pli" ] && [ "$SKIP_PLI" = "1" ]; then echo "[SKIP $NUM] $NAME - Wrong Image"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "aglare-fhd" ] && [ "$SKIP_FHD" = "1" ]; then echo "[SKIP $NUM] $NAME - Wrong Image"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NUM" -le "$DONE" ]; then echo "[SKIP $NUM] $NAME done"; return 0; fi
echo "== [$NUM] $NAME =="; wait_for_net; OK=0
for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_i.sh; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/_i.sh; if [ -s /tmp/_i.sh ]; then OK=1; break; fi; echo "[RETRY] $NAME $i/10"; sleep 15; wait_for_net; done
if [ "$OK" = "0" ]; then echo "[FAIL] $NAME"; echo "$((NUM-1))" > "$P"; return 0; fi
sed -i -e '/^[[:space:]]*reboot/d' -e '/reboot[[:space:]]*$/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e 's/&&[[:space:]]*reboot/ \&\& echo [BLOCKED]/g' -e '/shutdown.*-r/d' -e '/systemctl.*reboot/d' -e '/systemctl.*poweroff/d' -e '/init[[:space:]]*6/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' -e '/killall.*enigma2/d' /tmp/_i.sh
if [ "$NAME" = "FootOnsat" ]; then echo "[AUTO] FootOnsat=1"; sed -i -e 's/^[[:space:]]*read[[:space:]].*/choice=1; REPLY=1; install_method=1 # AUTO/' -e 's/read -p.*/choice=1; REPLY=1 # AUTO/' /tmp/_i.sh; ( sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1" ) | PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; else PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; fi
echo "Done $NAME"; echo "$NUM" > "$P"; DONE=$NUM; rm -f /tmp/_i.sh; sleep 2; export PATH="/tmp/noreboot:$PATH"; }

install_simply() { if [ "17" -le "$DONE" ]; then return 0; fi; echo "== [17] SimplySports NO killall =="; wait_for_net; cd /usr/lib/enigma2/python/Plugins/Extensions || return 0; rm -rf SimplySports; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f SimplySports.zip; wget --no-check-certificate --tries=3 --timeout=30 https://github.com/Ahmed-Mohammed-Abbas/SimplySports/archive/refs/heads/main.zip -O SimplySports.zip; if [ -s SimplySports.zip ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] SimplySports"; echo "16" > "$P"; return 0; fi; unzip -o SimplySports.zip; mv SimplySports-main SimplySports; rm -f SimplySports.zip; echo "17" > "$P"; DONE=17; export PATH="/tmp/noreboot:$PATH"; }
install_autosub() { if [ "35" -le "$DONE" ]; then return 0; fi; echo "== [35] AutoSub NO reboot =="; wait_for_net; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/AutoSub.tar.gz; wget -q --no-check-certificate --tries=3 --timeout=30 -O /tmp/AutoSub.tar.gz https://raw.githubusercontent.com/HBK2010/AutoSub/main/AutoSub.tar.gz; if [ -s /tmp/AutoSub.tar.gz ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] AutoSub"; echo "34" > "$P"; return 0; fi; tar xzf /tmp/AutoSub.tar.gz -C /usr/lib/enigma2/python/Plugins/Extensions; rm -f /tmp/AutoSub.tar.gz; echo "[BLOCKED] init skipped"; echo "35" > "$P"; DONE=35; }
install_last() { if [ "36" -le "$DONE" ]; then return 0; fi; echo "== [36] SubExtractorLite LAST VERIFY =="; wait_for_net; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_s.sh; echo "[TRY $i/10] SubExtractorLite..."; wget --no-check-certificate --tries=3 --timeout=30 https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/installer.sh -O /tmp/_s.sh; if [ -s /tmp/_s.sh ]; then echo "Size: $(wc -c < /tmp/_s.sh)"; grep -q SubExtractor /tmp/_s.sh && echo "Content OK" && OK=1 && break; echo "[WARN] Wrong content"; else echo "[RETRY] $i/10"; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] SubExtractorLite NOT INSTALLED"; echo "35" > "$P"; return 0; fi; sed -i -e '/^[[:space:]]*reboot/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e '/killall.*enigma2/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' /tmp/_s.sh; PATH="$ORIG_PATH" /bin/sh /tmp/_s.sh; sleep 3; ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -i SubExtractor >/dev/null 2>&1 && echo "[OK] SubExtractorLite Installed" || { echo "[WARN] Retry 2nd..."; PATH="$ORIG_PATH" /bin/sh /tmp/_s.sh; sleep 3; ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -i SubExtractor && echo "[OK] Installed 2nd try" || echo "[FAIL] Still not found"; }; echo "36" > "$P"; DONE=36; rm -f /tmp/_s.sh; export PATH="/tmp/noreboot:$PATH"; }

install_one "1" "update-all-python" "https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh"
opkg install wget
install_one "2" "MyStreamer" "https://raw.githubusercontent.com/popking159/MyStreamer/refs/heads/main/myinstaller.sh"
install_one "3" "novalerdownloader" "https://raw.githubusercontent.com/popking159/novalerdownloader/refs/heads/main/myinstaller.sh"
install_one "4" "AJPanel" "http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer.sh"
install_one "5" "SubsSupportPro" "https://github.com/popking159/SubsSupportPro/raw/refs/heads/main/myinstaller.sh"
install_one "6" "internet-speedtest" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/internet-speedtest.sh"
install_one "7" "EmuInstaller" "https://raw.githubusercontent.com/popking159/EmuInstaller/refs/heads/main/myinstaller.sh"
install_one "8" "IPAudioPro" "https://raw.githubusercontent.com/zKhadiri/IPAudioPro-Releases-/main/installer.sh"
install_one "9" "Epg-Grabber" "https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh"
install_one "10" "EmilRemovePackage" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.sh"
install_one "11" "customchannelselection" "https://raw.githubusercontent.com/popking159/customchannelselection/refs/heads/main/myinstaller.sh"
install_one "12" "crashlogviewer" "https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/crashlogviewer_1.9.sh"
install_one "13" "cacheflush" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cacheflush/cacheflush.sh"
install_one "14" "bitrate" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bitrate/bitrate.sh"
install_one "15" "AutoZap-Recovery" "https://raw.githubusercontent.com/HBK2010/-AutoZap-Recovery-by-Ahmad-Alamri/main/installer.sh"
install_one "16" "ArabicSavior" "http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh"
install_simply
install_one "18" "buttonpatcher" "https://raw.githubusercontent.com/popking159/buttonpatcher/refs/heads/main/myinstaller.sh"
install_one "19" "FootOnsat" "https://raw.githubusercontent.com/fairbird/FootOnsat/main/Download/install.sh"
install_one "20" "LukaTV" "https://raw.githubusercontent.com/popking159/LukaTV/refs/heads/main/myinstaller.sh"
install_one "21" "novalerStore" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/novalerStore.sh"
install_one "22" "ipaudiolplus" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/ipaudioplus.sh"
install_one "23" "aglare-pli" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd-pli.sh"
install_one "24" "aglare-fhd" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd.sh"
install_one "25" "RaedQuickSignal" "https://raw.githubusercontent.com/fairbird/RaedQuickSignal/main/installer.sh"
install_one "26" "NewVirtualKeyBoard" "https://raw.githubusercontent.com/fairbird/NewVirtualKeyBoard/main/installer.sh"
install_one "27" "AutoBiss" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutoBiss/AutoBiss.sh"
install_one "28" "auto-dcw-key-add" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/auto-dcw-key-add/auto-dcw-key-add.sh"
install_one "29" "FuryBiss" "https://raw.githubusercontent.com/islam-2412/FuryBiss/refs/heads/main/fury/installer.sh"
install_one "30" "hisnmuslim" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/hisnmuslim/hisnmuslim.sh"
install_one "31" "netusagepro" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/netusagepro/netusagepro.sh"
install_one "32" "quran" "https://raw.githubusercontent.com/emil237/quran/main/installer.sh"
install_one "33" "xtraevent" "https://github.com/popking159/xtraeventplugin/raw/main/xtraevent-install.sh"
install_one "34" "myhits" "https://raw.githubusercontent.com/popking159/myhits/refs/heads/main/myinstaller.sh"
install_autosub
install_last
clear; echo "=========================================================="; echo "   All-Script By Eng Ahmed Abdel-Moati"; echo "   Copyright (c) 2026 Eng / Ahmed Abdel-Moati"; echo "=========================================================="; echo ""; echo "   Choose the channel list you want to install :"; echo ""; echo "----------------------------------------------------------"; echo "   [ 1 ]  Emil Nabil"; echo "          Full List - Main List"; echo ""; echo "   [ 2 ]  Mnasr"; echo "          Full List - Alternative List"; echo ""; echo "   [ 3 ]  Khaled"; echo "          Full List - Alternative List"; echo ""; echo "   [ 4 ]  Hazem Wahba"; echo "          Full List - Alternative List"; echo "----------------------------------------------------------"; echo "   [ 0 ]  Skip"; echo "          Continue without channel list"; echo "----------------------------------------------------------"; echo ""; echo "   Note : Choose only one number from 0 to 4"
while true; do printf "   Enter number here and press Enter  [ 0-4 ] : "; read CH; case "$CH" in 1) CH_NAME="Emil Nabil"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh"; break ;; 2) CH_NAME="Mnasr"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-mnasr/main/installer.sh"; break ;; 3) CH_NAME="Khaled"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh"; break ;; 4) CH_NAME="Hazem Wahba"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-hazem-wahba/main/installer.sh"; break ;; 0) CH_NAME="Skip"; break ;; *) echo ""; echo "   !!! Wrong number - Enter number from 0 to 4 only !!!"; echo ""; continue ;; esac; done
if [ "$CH" = "0" ]; then echo ""; echo "   Skipped - Continue without channel list"; else echo ""; echo "   You selected : $CH_NAME"; printf "   Are you sure ? Type y for Yes or n for No [ y/n ] : "; read CONFIRM; if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || [ "$CONFIRM" = "1" ]; then echo ""; echo "   Downloading channel list ... Please wait ..."; wget -q --no-check-certificate "$CH_URL" -O - | /bin/sh; echo ""; echo "   Done - Channel list installed successfully"; else echo ""; echo "   Cancelled - Continue without channel list"; fi; fi
echo ""; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - ALL DONE - REAL restart now"; export PATH="$ORIG_PATH"; rm -rf /tmp/noreboot /tmp/_i.sh; rm -f "$P"; sleep 2; reboot; exit 0