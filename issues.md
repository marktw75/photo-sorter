## v0.1 Issues

### #1 建立專案目錄與基本架構
- sorter/ 子模組
- main.py
- requirements.txt
- tests/
- .gitignore
- LICENSE
- README.md

---

### #2 功能：依檔案大小篩選
- 實作 sorter/size_sorter.py
- 傳入 size 上下限
- 輸出符合條件的檔案清單

---

### #3 功能：依解析度篩選
- 實作 sorter/resolution_sorter.py
- 傳入解析度上下限
- 輸出符合條件的檔案清單

---

### #4 功能：判斷是否為截圖
- 實作 sorter/screenshot_sorter.py
- 判斷依據 EXIF or 檔名 pattern
- 輸出符合條件的檔案清單

---

### #5 CLI 介面基本版
- main.py
- 讓使用者輸入：
    - 要篩的目錄
    - 要篩的條件
- 結果輸出到 .txt
