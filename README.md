# ZIVPN UDP

**Script Install ZIVPN UDP**

Script ini digunakan untuk **memasang, menghapus, membackup, dan merestore konfigurasi ZIVPN UDP**

---

## 📌 Fitur
- Install ZIVPN UDP
- Uninstall ZIVPN UDP
- Backup konfigurasi
- Restore konfigurasi dari backup

---

## 📥 Download Script
```bash
wget https://raw.githubusercontent.com/potatonc/zivpn-udp/refs/heads/main/zivpn.sh
chmod +x zivpn.sh
```

### ▶️ Install ZIVPN UDP
```bash
bash <(wget -qO- https://raw.githubusercontent.com/potatonc/zivpn-udp/refs/heads/main/zivpn.sh) install
```

### 💾 Backup Konfigurasi
```bash
bash <(wget -qO- https://raw.githubusercontent.com/potatonc/zivpn-udp/refs/heads/main/zivpn.sh) backup
```

### ♻️ Restore Konfigurasi
```bash
bash <(wget -qO- https://raw.githubusercontent.com/potatonc/zivpn-udp/refs/heads/main/zivpn.sh) restore
```

### ❌ Uninstall ZIVPN UDP
```bash
bash <(wget -qO- https://raw.githubusercontent.com/potatonc/zivpn-udp/refs/heads/main/zivpn.sh) uninstall
```

## 🔁 Backup & Restore
### 📦 Lokasi Backup
File backup konfigurasi ZIVPN UDP disimpan di lokasi berikut:
```text
/root/config.json.zivpn
```
File ini digunakan sebagai sumber utama pada proses restore.

## ♻️ Restore dari Konfigurasi Lain
Jika ingin melakukan restore menggunakan konfigurasi lain, silakan ikuti langkah berikut:

1. Buat atau siapkan file konfigurasi yang diinginkan.
2. Simpan file konfigurasi tersebut ke lokasi berikut: **/root/config.json.zivpn**
3. Pastikan struktur dan format konfigurasi **sesuai dengan standar ZIVPN UDP**.
4. Jalankan perintah **restore** seperti yang telah dijelaskan pada bagian **penggunaan** di atas.


## ⚠️ Note
> Jangan menggunakan konfigurasi yang berbeda atau tidak kompatibel.
>
> Struktur konfigurasi **harus mengikuti sumber asli** dari repository resmi:  
> https://github.com/zahidbd2/udp-zivpn
>
> Penggunaan konfigurasi yang tidak sesuai dapat menyebabkan service gagal berjalan
> atau error saat startup.
