from sorter import size_sorter, resolution_sorter, screenshot_sorter, face_sorter
from rich import print

def main():
    print("[bold green]Welcome to Photo Sorter v0.1[/bold green]")

    # 固定使用 photo 目錄
    target_dir = "photo"

    print("選擇篩選方式:")
    print("1. 依檔案大小")
    print("2. 依解析度")
    print("3. 判斷是否為截圖")
    print("4. 人臉偵測")
    
    choice = input("請輸入選項 (1/2/3/4): ")

    if choice == "1":
        size_sorter.run(target_dir)
    elif choice == "2":
        resolution_sorter.run(target_dir)
    elif choice == "3":
        screenshot_sorter.run(target_dir)
    elif choice == "4":
        face_sorter.FaceSorter().run(target_dir)
    else:
        print("[red]無效的選項[/red]")

if __name__ == "__main__":
    main()
