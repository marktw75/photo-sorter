import os
import cv2
from pathlib import Path
from rich import print
from rich.progress import Progress

class FaceSorter:
    def __init__(self):
        # 載入人臉偵測模型
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
    def detect_faces(self, image_path):
        """偵測圖片中的人臉"""
        try:
            # 讀取圖片
            img = cv2.imread(str(image_path))
            if img is None:
                return False
                
            # 轉換為灰階
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            
            # 偵測人臉
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30)
            )
            
            return len(faces) > 0
        except Exception as e:
            print(f"[red]處理圖片時發生錯誤: {image_path}[/red]")
            print(f"[red]錯誤訊息: {str(e)}[/red]")
            return False

    def run(self, target_dir):
        """執行人臉偵測"""
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
            
        print(f"找到 {len(image_files)} 個圖片檔案")
        
        # 偵測人臉
        face_images = []
        with Progress() as progress:
            task = progress.add_task("[cyan]處理圖片...", total=len(image_files))
            for file in image_files:
                if self.detect_faces(file):
                    face_images.append(file)
                progress.update(task, advance=1)
        
        # 只顯示含有人臉的圖片檔名
        if face_images:
            print("\n[bold]含有人臉的圖片:[/bold]")
            for file in face_images:
                print(f"[green]{file}[/green]")
        else:
            print("\n[red]沒有找到含有人臉的圖片[/red]") 