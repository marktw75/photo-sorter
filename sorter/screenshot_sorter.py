import os
from pathlib import Path
from PIL import Image
from rich import print
from rich.progress import Progress

def is_screenshot(image_path):
    """判斷是否為截圖"""
    try:
        with Image.open(image_path) as img:
            # 檢查圖片是否為 PNG 格式（截圖常用格式）
            if img.format == 'PNG':
                return True
                
            # 檢查圖片是否為常見的截圖解析度
            common_resolutions = {
                (1920, 1080),  # Full HD
                (2560, 1440),  # 2K
                (3840, 2160),  # 4K
                (1366, 768),   # 常見筆電解析度
                (1440, 900),   # 常見筆電解析度
            }
            
            if img.size in common_resolutions:
                return True
                
            return False
    except Exception as e:
        print(f"[red]無法讀取圖片: {image_path}[/red]")
        print(f"[red]錯誤訊息: {str(e)}[/red]")
        return False

def run(target_dir):
    """判斷是否為截圖"""
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
    
    # 判斷是否為截圖
    screenshots = []
    non_screenshots = []
    with Progress() as progress:
        task = progress.add_task("[cyan]分析圖片...", total=len(image_files))
        for file in image_files:
            if is_screenshot(file):
                screenshots.append(file)
            else:
                non_screenshots.append(file)
            progress.update(task, advance=1)
    
    # 顯示結果
    print("\n[bold]截圖分析結果:[/bold]")
    print(f"[green]截圖數量: {len(screenshots)}[/green]")
    print(f"[yellow]非截圖數量: {len(non_screenshots)}[/yellow]")
    
    if screenshots:
        print("\n[bold]截圖列表:[/bold]")
        for file in screenshots:
            print(f"[green]{file}[/green]")
    
    if non_screenshots:
        print("\n[bold]非截圖列表:[/bold]")
        for file in non_screenshots:
            print(f"[yellow]{file}[/yellow]") 