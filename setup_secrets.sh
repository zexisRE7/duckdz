#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# setup_secrets.sh
# รันไฟล์นี้บน Mac ในโฟลเดอร์ duckdz เพื่อ encode ไฟล์ binary เป็น base64
# แล้ว copy ไปใส่ GitHub Secrets
# ──────────────────────────────────────────────────────────────────────────────

echo "=== Encoding binary files to base64 for GitHub Secrets ==="

# 1. JRMemory framework binary (required)
if [ -f "JRMemory.framework/JRMemory" ]; then
    base64 -i JRMemory.framework/JRMemory -o /tmp/JRMEMORY_B64.txt
    echo ""
    echo "✅ JRMEMORY_B64 → /tmp/JRMEMORY_B64.txt"
    echo "   → GitHub repo → Settings → Secrets → Actions → New secret"
    echo "   → Name:  JRMEMORY_B64"
    echo "   → Value: paste ข้อความจาก /tmp/JRMEMORY_B64.txt"
else
    echo "❌ ไม่พบ JRMemory.framework/JRMemory"
fi

# 2. libdobby.a (optional)
if [ -f "libdobby.a" ]; then
    base64 -i libdobby.a -o /tmp/LIBDOBBY_B64.txt
    echo ""
    echo "✅ LIBDOBBY_B64 → /tmp/LIBDOBBY_B64.txt"
    echo "   → Name:  LIBDOBBY_B64"
    echo "   → Value: paste ข้อความจาก /tmp/LIBDOBBY_B64.txt"
fi

# 3. Keystone arm64 (optional)
if [ -f "KittyMemory/Deps/Keystone/libs-ios/arm64/libkeystone.a" ]; then
    base64 -i KittyMemory/Deps/Keystone/libs-ios/arm64/libkeystone.a \
              -o /tmp/KEYSTONE_B64.txt
    echo ""
    echo "✅ KEYSTONE_B64 → /tmp/KEYSTONE_B64.txt"
    echo "   → Name:  KEYSTONE_B64"
    echo "   → Value: paste ข้อความจาก /tmp/KEYSTONE_B64.txt"
fi

echo ""
echo "=== เสร็จแล้ว — ไปเพิ่ม Secret ใน GitHub แล้วกด 'Run workflow' ได้เลย ==="
