import os
from pathlib import Path
from rich import print
from rich.progress import Progress

def run(target_dir):
    """依檔案大小排序"""
    target_path = Path(target_dir)
    if not target_path.exists():
        print(f"[red]目錄不存在: {target_dir}[/red]")
        return
        
    # 收集所有檔案
    files = list(target_path.glob('**/*'))
    
    # 計算檔案大小
    file_sizes = []
    with Progress() as progress:
        task = progress.add_task("[cyan]計算檔案大小...", total=len(files))
        for file in files:
            if file.is_file():
                size = file.stat().st_size
                file_sizes.append((file, size))
            progress.update(task, advance=1)
    
    # 依大小排序
    file_sizes.sort(key=lambda x: x[1], reverse=True)
    
    # 顯示結果
    print("\n[bold]檔案大小排序結果:[/bold]")
    for file, size in file_sizes:
        print(f"{file}: {size/1024/1024:.2f} MB") 