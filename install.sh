#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# KALI NETHUNTER TERMUX INSTALLER (FULL)
# ==========================================

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}   KALI NETHUNTER INSTALLER (NO ROOT) ${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}[*] Đang yêu cầu quyền truy cập bộ nhớ...${NC}"
termux-setup-storage
sleep 2

echo -e "${YELLOW}[*] Đang cập nhật môi trường Termux...${NC}"
pkg update -y && pkg upgrade -y
pkg install wget curl proot tar xz-utils pulseaudio -y

KALI_FILE="kali-nethunter-rootfs-full-arm64.tar.xz"
KALI_URL="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-full-arm64.tar.xz"
INSTALL_DIR="$HOME/kali-nethunter"

if [ ! -f "$HOME/$KALI_FILE" ]; then
    echo -e "${YELLOW}[*] Đang tải Kali NetHunter Rootfs (Bản Full - Khoảng 1.5GB)...${NC}"
    echo -e "${YELLOW}[!] Quá trình này có thể mất 10-20 phút tùy tốc độ mạng.${NC}"
    wget -O "$HOME/$KALI_FILE" "$KALI_URL"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Lỗi tải file. Vui lòng kiểm tra mạng và thử lại!${NC}"
        rm -f "$HOME/$KALI_FILE"
        exit 1
    fi
else
    echo -e "${GREEN}[+] File Rootfs đã tồn tại, bỏ qua bước tải.${NC}"
fi

echo -e "${YELLOW}[*] Đang giải nén Kali Linux (Quá trình này mất vài phút)...${NC}"
mkdir -p "$INSTALL_DIR"
tar -xJf "$HOME/$KALI_FILE" -C "$INSTALL_DIR"

echo -e "${YELLOW}[*] Đang tạo lệnh khởi động 'kali'...${NC}"
cat > $PREFIX/bin/kali << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
cd $HOME
proot --link2symlink -0 -r $HOME/kali-nethunter -b /dev -b /proc -b /sys -b /sdcard -b /data/data/com.termux/files/home -b /storage/emulated/0 -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=xterm-256color LANG=C.UTF-8 /bin/bash
EOF
chmod +x $PREFIX/bin/kali

cat > "$INSTALL_DIR/setup.sh" << 'EOF'
#!/bin/bash
clear
echo "=================================================="
echo "     KALI NETHUNTER GUI SETUP (XFCE + VNC)"
echo "=================================================="
echo "[*] Đang cập nhật hệ thống Kali..."
apt update && apt upgrade -y

echo "[*] Đang cài đặt giao diện XFCE và VNC Server..."
apt install xfce4 xfce4-goodies tigervnc-standalone-server dbus-x11 -y

echo "[*] Đang cấu hình VNC..."
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'VNC_EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
VNC_EOF
chmod +x ~/.vnc/xstartup

clear
echo "=================================================="
echo "✅ CÀI ĐẶT GIAO DIỆN HOÀN TẤT!"
echo ""
echo "Bước 1: Đặt mật khẩu VNC bằng lệnh: vncpasswd"
echo "Bước 2: Khởi động đồ họa bằng lệnh: vncserver :1"
echo "Bước 3: Tải app VNC Viewer trên điện thoại."
echo "Bước 4: Kết nối tới địa chỉ: 127.0.0.1:5901"
echo "=================================================="
EOF
chmod +x "$INSTALL_DIR/setup.sh"

echo -e "${YELLOW}[*] Đang dọn dẹp file tải tạm...${NC}"
rm -f "$HOME/$KALI_FILE"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}   CÀI ĐẶT KALI THÀNH CÔNG!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Để vào Kali, gõ lệnh: ${GREEN}kali${NC}"
echo -e "Lần đầu vào Kali, hãy chạy lệnh: ${YELLOW}bash /setup.sh${NC} để cài giao diện."
