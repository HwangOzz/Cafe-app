from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import uvicorn
from fastapi.responses import Response

app = FastAPI()

# ✅ CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🔹 테두리 감지 함수 (더 세밀하게!)
def detect_edges(image_data: bytes):
    # OpenCV로 바이트 데이터를 이미지로 변환
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # ✅ 1. 흑백 변환 (Grayscale)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # ✅ 2. 히스토그램 평활화 적용 (명암 대비 향상)
    equalized = cv2.equalizeHist(gray)

    # ✅ 3. 블러 적용 (GaussianBlur) → 노이즈 제거
    blurred = cv2.GaussianBlur(equalized, (5, 5), 0)

    # ✅ 4. Canny Edge Detection 적용
    edges_canny = cv2.Canny(blurred, 50, 150)

    # ✅ 5. 적응형 이진화 적용 (Adaptive Threshold)
    edges_threshold = cv2.adaptiveThreshold(
        equalized, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY_INV, 11, 2
    )

    # ✅ 6. 두 개의 결과를 합침 (Canny + Threshold)
    combined_edges = cv2.bitwise_or(edges_canny, edges_threshold)

    # ✅ 7. 색상 반전 (흰 배경 + 검은 선)
    final_result = cv2.bitwise_not(combined_edges)

    # ✅ 8. 결과 이미지를 PNG 바이너리 데이터로 변환
    _, encoded_img = cv2.imencode('.png', final_result)

    return encoded_img.tobytes()

# 🔹 API 엔드포인트: 이미지 업로드 & 테두리 감지 실행
@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        print(f"✅ [POST] 요청 받음, 이미지 크기: {len(image_data)} 바이트")

        edge_image = detect_edges(image_data)
        print(f"✅ 테두리 감지 완료, 변환된 이미지 크기: {len(edge_image)} 바이트")

        # ✅ 바이너리 PNG 데이터 그대로 반환 (Base64 X)
        return Response(content=edge_image, media_type="image/png")

    except Exception as e:
        return {"error": f"서버 오류 발생: {str(e)}"}

# ✅ FastAPI 실행
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
