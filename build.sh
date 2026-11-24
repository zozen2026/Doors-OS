#!/bin/bash
echo "🚀 بدء بناء نظام Doors OS v1.0 المصغر..."

# 1. تحديث وتثبيت أدوات بناء التوزيعات الخفيفة
sudo apt-get update
sudo apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools

# 2. إنشاء مجلدات العمل
mkdir -p ~/doors-build/{chroot,image/{casper,boot/grub}}

# 3. بناء نواة ونظام مصغر جداً (Minimal Base) لتوفير المساحة
sudo debootstrap --arch=amd64 --variant=minbase bookworm ~/doors-build/chroot http://deb.debian.org/debian/

# 4. نسخ واجهة Doors OS الخاصة بك إلى داخل النظام الجديد
sudo mkdir -p ~/doors-build/chroot/opt/doors-os
sudo cp -r ./index.html ~/doors-build/chroot/opt/doors-os/

# 5. إعداد التشغيل التلقائي للواجهة (Kiosk Mode بدون أي أثر للمتصفح)
cat << 'EOF' | sudo tee ~/doors-build/chroot/etc/rc.local
#!/bin/bash
xinit /usr/bin/chromium --no-sandbox --kiosk --app=file:///opt/doors-os/index.html &
exit 0
EOF
sudo chmod +x ~/doors-build/chroot/etc/rc.local

# 6. ضغط النظام وتوليد ملف الـ ISO النهائي
sudo mksquashfs ~/doors-build/chroot ~/doors-build/image/casper/filesystem.squashfs -comp xz
sudo grub-mkrescue -o Doors-OS-v1.iso ~/doors-build/image

echo "✅ اكتمل البناء! ملف النظام جاهز باسم: Doors-OS-v1.iso"