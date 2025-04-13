import os
from pathlib import Path
from PIL import Image
from rich import print
from rich.progress import Progress

def run(target_dir):
    """依解析度排序"""
    target_path = Path(target_dir)
    if not target_path.exists():
        print(f"[red]目錄不存在: {target_dir}[/red]")
        return
        
    # 支援的圖片格式
    image_extensions = {'.jpg', '.jpeg', '.png', '.bmp'}
    
    # 收集所有圖片
    image_files = []
    for ext in image_extensions:
        image_files.extend(target_path.glob(f'**/*{ext}'))
    
    # 讀取圖片解析度
    resolutions = []
    with Progress() as progress:
        task = progress.add_task("[cyan]讀取圖片解析度...", total=len(image_files))
        for file in image_files:
            try:
                with Image.open(file) as img:
                    width, height = img.size
                    resolutions.append((file, width, height))
            except Exception as e:
                print(f"[red]無法讀取圖片: {file}[/red]")
                print(f"[red]錯誤訊息: {str(e)}[/red]")
            progress.update(task, advance=1)
    
    # 依解析度排序（以寬度為主要排序依據）
    resolutions.sort(key=lambda x: (x[1], x[2]), reverse=True)
    
    # 顯示結果
    print("\n[bold]圖片解析度排序結果:[/bold]")
    for file, width, height in resolutions:
        print(f"{file}: {width}x{height}") 