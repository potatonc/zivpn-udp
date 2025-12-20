#!/bin/bash
# Zivpn UDP Module installer
# Creator Zahid Islam
#
# Script by Potato
##############################

NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
Sysctl="/etc/sysctl.conf"
FileSys="/etc/systemd/system/zivpn.service"
Dir="/etc/zivpn"
FileBackup="/root/config.json.zivpn"
MACHINE=

Machine() {
  if [[ "$(uname)" == 'Linux' ]]; then
    case "$(uname -m)" in
      'amd64' | 'x86_64')
        MACHINE='amd64'
        ;;
      'armv5tel')
        MACHINE='arm'
        ;;
      'armv8' | 'aarch64')
        MACHINE='arm64'
        ;;
      *)
        echo
        echo "➜ error: Arsitektur ini tidak didukung."
        echo
        MACHINE=''
        ;;
    esac
  else
    echo
    echo "➜ error: Sistem operasi ini tidak didukung."
    echo
    MACHINE=''
  fi
}

AppendLine() {
  local file="$1"
  local text="$2"
  
  if ! grep -Fxq "$text" "$file"; then
    printf '%s\n' "$text" >> "$file"
    return 0
  fi

  return 1
}

Utils() {
  case "$1" in
    'cmd') command -v "$2" >/dev/null 2>&1 ;;
    'file') [ -f "$2" ] ;;
    'folder') [ -d "$2" ] ;;
    *) return 1 ;;
  esac
}

FileConfigAndCtl() {
  cat > "$Dir/config.json" <<-END
{
  "listen": ":5667",
   "cert": "$Dir/zivpn.crt",
   "key": "$Dir/zivpn.key",
   "obfs":"zivpn",
   "auth": {
    "mode": "passwords", 
    "config": []
  }
}  
END

  cat > /etc/systemd/system/zivpn.service <<-END
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$Dir
ExecStart=/usr/local/bin/zivpn server -c $Dir/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
END
}

Certificate() {
  echo
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "$Dir/zivpn.key" -out "$Dir/zivpn.crt"
  echo
}

PostKernel() {
  AppendLine "$Sysctl" "net.core.rmem_max=16777216"
  AppendLine "$Sysctl" "net.core.wmem_max=16777216"
  sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
  sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null
}

RoutingTables() {
  iptables -t nat -D PREROUTING -i $NIC -p udp --dport 6000:19999 -j DNAT --to-destination :5667
  iptables -t nat -A PREROUTING -i $NIC -p udp --dport 6000:19999 -j DNAT --to-destination :5667
}

DownloadAndChmod() {
  wget "https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-$MACHINE" -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null
  chmod +x /usr/local/bin/zivpn
}

Deps() {
  if Utils file "$Dir/config.json"; then
    BackupConfig
  fi
  
  if Utils file $FileSys; then
    systemctl -q stop zivpn
    systemctl -q disable zivpn
    rm -f $FileSys
  fi
  
  if Utils cmd zivpn; then
    rm -f $(command -v zivpn)
  fi
}

ReplaceConfig() {
  echo
  read -rp "➜ Timpa konfigurasi lama? [y/n]: " ask
  
  case "$ask" in
  [yY])
    mv "$Dir/config.json" $FileBackup
    echo
    echo -e "➜ File Backup: $FileBackup"
    echo
  ;;
  [nN])
    return
  ;;
  *)
    ReplaceConfig
  ;;
  esac
  echo
}

BackupConfig() {
  echo
  read -rp "➜ Backup konfigurasi lama? [y/n]: " ask
  
  case "$ask" in
  [yY])
    if Utils file $FileBackup; then
      ReplaceConfig
    else
      mv "$Dir/config.json" $FileBackup
      echo
      echo -e "➜ File Backup: $FileBackup"
      echo
    fi
  ;;
  [nN])
    return
  ;;
  *)
    BackupConfig
  ;;
  esac
  echo
}

RestoreConfig() {
  echo
  if Utils file $FileBackup; then
    read -rp "➜ Restore konfigurasi lama? [y/n]: " ask
    
    case "$ask" in
    [yY])
      mv $FileBackup "$Dir/config.json"
      systemctl -q restart zivpn
      echo
      echo -e "➜ Berhasil memulihkan konfigurasi"
      echo
    ;;
    [nN])
      return
    ;;
    *)
      RestoreConfig
    ;;
    esac
  fi
  echo
}

Uninstall() {
  if Utils file "$Dir/config.json"; then
    BackupConfig
  fi
  
  if Utils file $FileSys; then
    systemctl -q stop zivpn
    systemctl -q disable zivpn
    rm -f $FileSys
  fi
  
  if Utils cmd zivpn; then
    killall zivpn 1> /dev/null 2> /dev/null
    rm -f $(command -v zivpn)
  fi
  
  if Utils folder $Dir; then
    rm -rf $Dir
  fi
}

Install() {
  Machine
  if [ -z "$MACHINE" ]; then
    exit 1
  fi
  
  Deps
  DownloadAndChmod
  FileConfigAndCtl
  Certificate
  
  systemctl -q enable zivpn
  systemctl -q start zivpn
  
  if [[ $(systemctl is-active zivpn) == 'active' ]]; then
    PostKernel
    RoutingTables
    RestoreConfig
    systemctl -q restart zivpn
    echo
    echo -e "➜ ZIVPN UDP Terpasang"
    echo
  else
    echo
    echo -e "➜ ZIVPN UDP Tidak Terpasang"
    echo
    Uninstall
    echo
    echo -e "➜ ZIVPN UDP Berhasil dibersihkan"
    echo
  fi
}

main() {
  if [ $EUID -ne 0 ]; then
    echo
    echo -e "➜ error: Membutuhkan akses root"
    echo
  fi
  
  if ! Utils folder $Dir; then
    mkdir -p $Dir
  fi
  
  case "$1" in
  'install') Install ;;
  'uninstall')
    Uninstall
    echo
    echo -e "➜ ZIVPN UDP Berhasil dibersihkan"
    echo
  ;;
  'backup')
    if Utils file "$Dir/config.json"; then
      BackupConfig
    else
      echo
      echo "➜ error: Tidak ada file konfigurasi: $Dir/config.json"
      echo
    fi
  ;;
  'restore')
    if Utils file $FileBackup; then
      if Utils cmd zivpn && Utils folder $Dir && Utils file $FileSys; then
        RestoreConfig
      else
        echo
        echo -e "➜ ZIVPN UDP Tidak Terpasang"
        echo
      fi
    else
      echo
      echo "➜ error: Tidak ada file konfigurasi: $FileBackup"
      echo
    fi
  ;;
  *)
    echo
    echo -e " Argument:"
    echo -e "    install   - Memasang ZIVPN UDP"
    echo -e "    uninstall - Menghapus ZIVPN UDP"
    echo -e "    backup    - Menyalin konfigurasi ke $FileBackup"
    echo -e "    restore   - Memulihkan konfigurasi dari $FileBackup"
    echo
  ;;
  esac
}

main "$@"
