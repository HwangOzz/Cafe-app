from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import uvicorn
import base64
from fastapi.responses import JSONResponse

app = FastAPI()

# ✅ CORS 설정 추가 (Flutter에서 요청 가능하도록 설정)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용
    allow_headers=["*"],  # 모든 HTTP 헤더 허용
)

# 🔹 테두리 감지 함수
def detect_edges(image_data: bytes):
    print("🔹 이미지 처리 시작")
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 100, 200)

    _, encoded_img = cv2.imencode('.png', edges)
    print("✅ 테두리 감지 완료")
    return encoded_img.tobytes()

# 🔹 API 엔드포인트: 이미지 업로드 & 테두리 감지 실행
@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        print("✅ [POST] 요청 받음")
        image_data = await file.read()
        print(f"✅ 이미지 데이터 크기: {len(image_data)} 바이트")
        
        edge_image = detect_edges(image_data)

        encoded_str = base64.b64encode(edge_image).decode("utf-8")
        print("✅ Base64 인코딩 완료")

        return JSONResponse(content={"image_data": encoded_str})
    
    except Exception as e:
        print(f"🚨 서버 오류 발생: {str(e)}")
        return JSONResponse(status_code=500, content={"error": f"서버 오류 발생: {str(e)}"})

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
