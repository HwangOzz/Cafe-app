from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from fastapi.responses import Response
import uvicorn

app = FastAPI()

# 🔹 테두리 감지 함수 (OpenCV 사용)
def detect_edges(image_data: bytes):
    # 바이트 데이터를 OpenCV 이미지로 변환
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # 이미지를 그레이스케일로 변환
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Canny Edge Detection 적용 (테두리 감지)
    edges = cv2.Canny(gray, 100, 200)

    # 결과 이미지를 다시 바이너리 데이터로 변환
    _, encoded_img = cv2.imencode('.png', edges)
    return encoded_img.tobytes()

# 🔹 API 엔드포인트: 이미지 업로드 & 테두리 감지 실행
@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    image_data = await file.read()
    edge_image = detect_edges(image_data)
    return Response(content=edge_image, media_type="image/png")

# 🔹 FastAPI 실행 (uvicorn)
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
