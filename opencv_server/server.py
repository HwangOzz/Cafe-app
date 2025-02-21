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

# 🔹 **더 세밀하게 외곽선 감지하는 함수**
def detect_cartoon_edges(image_data: bytes):
    # ✅ 1. 이미지 읽기
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # ✅ 2. 이미지 크기 조정 (속도 최적화)
    image = cv2.resize(image, (512, 512))

    # ✅ 3. **부드러운 효과 추가 (Bilateral Filter)**
    filtered = cv2.bilateralFilter(image, d=9, sigmaColor=100, sigmaSpace=100)

    # ✅ 4. **흑백 변환 (Grayscale)**
    gray = cv2.cvtColor(filtered, cv2.COLOR_BGR2GRAY)

    # ✅ 5. **명암 조정 (히스토그램 평활화)**
    gray = cv2.equalizeHist(gray)

    # ✅ 6. **노이즈 제거 (Median Blur)**
    blurred = cv2.medianBlur(gray, 5)

    # ✅ 7. **Canny Edge Detection (더 세밀하게 조정)**
    edges_canny = cv2.Canny(blurred, 10, 100)

    # ✅ 8. **적응형 이진화 적용 (Adaptive Threshold)**
    edges_threshold = cv2.adaptiveThreshold(
        blurred, 255, cv2.ADAPTIVE_THRESH_MEAN_C,
        cv2.THRESH_BINARY, 15, 4  # 블록 크기 15, C 값 4로 변경
    )

    # ✅ 9. **Canny + Adaptive Threshold 조합**
    combined_edges = cv2.bitwise_and(edges_threshold, edges_canny)

    # ✅ 10. **색 반전 (배경 흰색, 선 검은색)**
    final_result = cv2.bitwise_not(combined_edges)

    # ✅ 11. PNG 변환 후 반환
    _, encoded_img = cv2.imencode('.png', final_result)
    return encoded_img.tobytes()


# 🔹 API 엔드포인트: 이미지 업로드 & 외곽선 추출
@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        print(f"✅ [POST] 요청 받음, 이미지 크기: {len(image_data)} 바이트")

        edge_image = detect_cartoon_edges(image_data)
        print(f"✅ 외곽선 감지 완료, 변환된 이미지 크기: {len(edge_image)} 바이트")

        return Response(content=edge_image, media_type="image/png")

    except Exception as e:
        return {"error": f"서버 오류 발생: {str(e)}"}

# ✅ FastAPI 실행
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
