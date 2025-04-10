from sorter import size_sorter, resolution_sorter, screenshot_sorter
from rich import print

def main():
    print("[bold green]Welcome to Photo Sorter v0.1[/bold green]")

    target_dir = input("請輸入要檢查的目錄路徑: ")

    print("選擇篩選方式:")
    print("1. 依檔案大小")
    print("2. 依解析度")
    print("3. 判斷是否為截圖")
    
    choice = input("請輸入選項 (1/2/3): ")

    if choice == "1":
        size_sorter.run(target_dir)
    elif choice == "2":
        resolution_sorter.run(target_dir)
    elif choice == "3":
        screenshot_sorter.run(target_dir)
    else:
        print("[red]無效的選項[/red]")

if __name__ == "__main__":
    main()
