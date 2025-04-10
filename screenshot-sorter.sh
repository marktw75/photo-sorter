#!/bin/bash

# 預設值
DEFAULT_OUTPUT_DIR="screenshots"
OUTPUT="screenshots_list.txt"

# 顯示使用說明
show_help() {
    echo "用法: $0 [選項] 目錄路徑"
    echo ""
    echo "選項:"
    echo "  -o DIR     設定輸出目錄 (預設: $DEFAULT_OUTPUT_DIR)"
    echo "  -c         複製檔案到輸出目錄"
    echo "  -h         顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 /path/to/photos          # 只輸出清單"
    echo "  $0 -c /path/to/photos       # 輸出清單並複製檔案"
    echo "  $0 -o my_screenshots -c /path/to/photos  # 自訂輸出目錄並複製"
}

# 檢查是否為手機截圖
is_screenshot() {
    local file="$1"
    
    # 檢查檔案名稱
    if [[ "$file" =~ [Ss]creenshot|[截圖] ]]; then
        return 0
    fi
    
    # 如果有 exiftool，檢查 EXIF 資訊
    if command -v exiftool >/dev/null 2>&1; then
        # 只執行一次 exiftool，檢查多個條件
        local exif_info=$(exiftool "$file" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            if echo "$exif_info" | grep -q "Screen Capture" || \
               echo "$exif_info" | grep -q "PNG"; then
                return 0
            fi
        fi
    fi
    
    # 如果有 file 命令，檢查檔案類型
    if command -v file >/dev/null 2>&1; then
        file_type=$(file "$file" 2>/dev/null)
        if [[ "$file_type" =~ "PNG image data" ]]; then
            return 0
        fi
    fi
    
    # 如果有 imagemagick，檢查圖片尺寸
    if command -v identify >/dev/null 2>&1; then
        local dimensions=$(identify -format "%wx%h" "$file" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            # 常見的手機螢幕比例
            if [[ "$dimensions" =~ ^(1080x1920|1440x3120|1170x2532|1284x2778|1179x2556|1080x2340|720x1280)$ ]]; then
                return 0
            fi
        fi
    fi
    
    return 1
}

# 初始化變數
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
DO_COPY=false

# 解析參數
while getopts "o:ch" opt; do
    case $opt in
        o)
            OUTPUT_DIR="$OPTARG"
            ;;
        c)
            DO_COPY=true
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "錯誤: 無效的選項 -$OPTARG"
            show_help
            exit 1
            ;;
    esac
done

# 移除已處理的選項
shift $((OPTIND-1))

# 檢查必要參數
if [[ $# -ne 1 ]]; then
    echo "錯誤: 必須指定目錄路徑"
    show_help
    exit 1
fi

TARGET_DIR="$1"

# 取得完整路徑
OUTPUT_DIR_FULL="$(pwd)/$OUTPUT_DIR"

# 檢查目錄是否存在
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "錯誤: 目錄 '$TARGET_DIR' 不存在"
    exit 1
fi

# 建立輸出目錄（如果需要複製）
if [[ "$DO_COPY" = true ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# 執行掃描
echo "開始掃描目錄: $TARGET_DIR"
echo "尋找手機截圖..."

# 清空輸出檔案
> "$OUTPUT"

# 掃描目錄並找出截圖
total_files=0

# 使用 find 命令的跨平台版本
if command -v find >/dev/null 2>&1; then
    # 使用 find 命令，並在找到檔案時立即處理
    while IFS= read -r file_path; do
        if [[ -f "$file_path" ]]; then
            if is_screenshot "$file_path"; then
                echo "$file_path" >> "$OUTPUT"
                ((total_files++))
                
                # 如果需要複製，立即複製
                if [[ "$DO_COPY" = true ]]; then
                    relative_path="${file_path#$TARGET_DIR/}"
                    target_dir="$OUTPUT_DIR/$(dirname "$relative_path")"
                    mkdir -p "$target_dir"
                    cp "$file_path" "$OUTPUT_DIR/$relative_path"
                fi
            fi
        fi
    done < <(find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))
else
    # 如果沒有 find 命令，使用遞迴函數
    scan_directory() {
        local dir="$1"
        for item in "$dir"/*; do
            if [[ -f "$item" ]]; then
                if [[ "$item" =~ \.(jpg|jpeg|png)$ ]]; then
                    if is_screenshot "$item"; then
                        echo "$item" >> "$OUTPUT"
                        ((total_files++))
                        
                        # 如果需要複製，立即複製
                        if [[ "$DO_COPY" = true ]]; then
                            relative_path="${item#$TARGET_DIR/}"
                            target_dir="$OUTPUT_DIR/$(dirname "$relative_path")"
                            mkdir -p "$target_dir"
                            cp "$item" "$OUTPUT_DIR/$relative_path"
                        fi
                    fi
                fi
            elif [[ -d "$item" ]]; then
                scan_directory "$item"
            fi
        done
    }
    scan_directory "$TARGET_DIR"
fi

if [[ $? -eq 0 ]]; then
    if [[ "$DO_COPY" = true ]]; then
        echo "總計複製 $total_files 個截圖到 $OUTPUT_DIR_FULL"
        echo ""
        echo "截圖清單："
        cat "$OUTPUT"
    else
        # 只顯示檔案清單
        echo ""
        echo "截圖清單："
        cat "$OUTPUT"
    fi
    
    echo ""
    echo "結果將輸出到: $OUTPUT"
    echo "完成！共找到 $total_files 個截圖"
    
    # 將結果寫入 log 檔案
    {
        echo ""
        echo "結果將輸出到: $OUTPUT"
        echo "完成！共找到 $total_files 個截圖"
    } >> "$OUTPUT"
else
    echo "執行過程中發生錯誤"
    exit 1
fi 