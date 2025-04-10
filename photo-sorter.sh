#!/bin/bash

# 預設值
DEFAULT_SIZE="1M"
DEFAULT_FILTERED_DIR="filtered_photos"
OUTPUT="smaller_1mb.txt"

# 顯示使用說明
show_help() {
    echo "用法: $0 [選項] 目錄路徑"
    echo ""
    echo "選項:"
    echo "  -m SIZE    設定過濾大小 (預設: $DEFAULT_SIZE)"
    echo "             例如: -m 2M, -m 500K"
    echo "  -c [DIR]   複製檔案到指定目錄 (預設: $DEFAULT_FILTERED_DIR)"
    echo "             例如: -c, -c my_photos"
    echo "  -h         顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 /path/to/photos          # 只輸出 log，使用預設 1MB"
    echo "  $0 -m 2M /path/to/photos    # 只輸出 log，使用 2MB"
    echo "  $0 -c /path/to/photos       # 輸出 log 並複製到預設目錄"
    echo "  $0 -m 500K -c my_photos /path/to/photos  # 自訂大小和目錄"
}

# 將大小字串轉換為位元組數
parse_size() {
    local size_str="$1"
    size_str=$(echo "$size_str" | tr '[:lower:]' '[:upper:]')
    local num=${size_str%[KMG]}
    local unit=${size_str: -1}
    
    case $unit in
        K) echo $((num*1024));;
        M) echo $((num*1024*1024));;
        G) echo $((num*1024*1024*1024));;
        *) echo $num;;
    esac
}

# 取得檔案大小（跨平台版本）
get_file_size() {
    local file="$1"
    if command -v stat >/dev/null 2>&1; then
        # Linux/BSD 系統
        if stat -c %s "$file" >/dev/null 2>&1; then
            stat -c %s "$file"
        else
            # macOS 系統
            stat -f %z "$file"
        fi
    elif command -v wc >/dev/null 2>&1; then
        # 如果沒有 stat 命令，使用 wc
        wc -c < "$file"
    else
        echo "錯誤：無法取得檔案大小，請安裝 stat 或 wc 命令" >&2
        exit 1
    fi
}

# 初始化變數
SIZE="$DEFAULT_SIZE"
DO_COPY=false
FILTERED_DIR="$DEFAULT_FILTERED_DIR"

# 解析參數
while getopts "m:c:h" opt; do
    case $opt in
        m)
            SIZE="$OPTARG"
            ;;
        c)
            DO_COPY=true
            if [[ -n "$OPTARG" ]]; then
                FILTERED_DIR="$OPTARG"
            fi
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
MAX_SIZE_BYTES=$(parse_size "$SIZE")

# 取得完整路徑
FILTERED_DIR_FULL="$(pwd)/$FILTERED_DIR"

# 檢查目錄是否存在
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "錯誤: 目錄 '$TARGET_DIR' 不存在"
    exit 1
fi

# 建立過濾後的檔案目錄（如果需要複製）
if [[ "$DO_COPY" = true ]]; then
    mkdir -p "$FILTERED_DIR"
fi

# 執行掃描
echo "開始掃描目錄: $TARGET_DIR"
echo "尋找小於 $SIZE 的檔案..."

# 清空輸出檔案
> "$OUTPUT"

# 掃描目錄並找出小於指定大小的檔案
total_files=0

# 使用 find 命令的跨平台版本
if command -v find >/dev/null 2>&1; then
    # 使用 find 命令
    while IFS= read -r file_path; do
        if [[ -f "$file_path" ]]; then
            file_size=$(get_file_size "$file_path")
            if [[ $file_size -le $MAX_SIZE_BYTES ]]; then
                size_kb=$((file_size/1024))
                echo "$file_path  ${size_kb}KB" >> "$OUTPUT"
                ((total_files++))
            fi
        fi
    done < <(find "$TARGET_DIR" -type f)
else
    # 如果沒有 find 命令，使用遞迴函數
    scan_directory() {
        local dir="$1"
        for item in "$dir"/*; do
            if [[ -f "$item" ]]; then
                file_size=$(get_file_size "$item")
                if [[ $file_size -le $MAX_SIZE_BYTES ]]; then
                    size_kb=$((file_size/1024))
                    echo "$item  ${size_kb}KB" >> "$OUTPUT"
                    ((total_files++))
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
        # 複製檔案到指定目錄
        echo "開始複製檔案到 $FILTERED_DIR 目錄..."
        
        # 先複製所有檔案
        while IFS= read -r line; do
            file_path=${line%  *}  # 移除最後的 KB 部分
            if [[ -f "$file_path" ]]; then
                # 保持原始目錄結構
                relative_path="${file_path#$TARGET_DIR/}"
                target_dir="$FILTERED_DIR/$(dirname "$relative_path")"
                mkdir -p "$target_dir"
                cp "$file_path" "$FILTERED_DIR/$relative_path"
            fi
        done < "$OUTPUT"
        
        echo "總計複製 $total_files 個 Size < $SIZE 到 $FILTERED_DIR_FULL"
        echo ""
        echo "檔案清單："
        cat "$OUTPUT"
    else
        # 只顯示檔案清單
        echo ""
        echo "檔案清單："
        cat "$OUTPUT"
    fi
    
    echo ""
    echo "結果將輸出到: $OUTPUT"
    echo "完成！共找到 $total_files 個小於 $SIZE 的檔案"
    
    # 將結果寫入 log 檔案
    {
        echo ""
        echo "結果將輸出到: $OUTPUT"
        echo "完成！共找到 $total_files 個小於 $SIZE 的檔案"
    } >> "$OUTPUT"
else
    echo "執行過程中發生錯誤"
    exit 1
fi 