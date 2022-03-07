#  아이패드 드로잉 앱
by Eddy

## Step 1. 사각형 객체 설계

**Screenshot**
![step1_1](https://user-images.githubusercontent.com/17468015/156973068-df1d1ae6-10c4-4a2b-b10a-c9123a0aa4ab.png)

**주요 기능**
- 팩토리에서 Rectangle 객체 를 생성하고, 시스템 로그 함수로 출력한다.

**완료 일자**
2022.03.01

## Step 2. 사각형 추가, 선택, 변경

**Screenshot**

![step2](https://user-images.githubusercontent.com/17468015/156528888-ed8208ed-dca1-4c15-86a6-86517a3d8135.gif)

**주요 기능**
- 시작 시 4개의 랜덤 사각형을 추가한다.
- '사각형 추가'를 누르면 랜덤 사각형이 추가된다.
- 사각형을 탭하면 선택되고 테두리 모양이 바뀐다.
- 선택된 사각형의 속성이 측면 패널에 보인다.
- 패널에서 사각형의 속성을 바꾸면 사각형 색깔과 투명도가 변한다. 

**완료 일자**
2022.03.03

## Step 3. Observer 패턴 적용

**Screenshot**

![step3](https://user-images.githubusercontent.com/17468015/156721080-a82e45de-b4a4-434e-b78a-280596b8e00d.gif)

**주요 기능**
- 기능은 그대로 유지.

**변경 사항**
- ViewController - Model 간의 Delegate 패턴을 모두 제거.
- ViewController (Canvas) - ViewController (Panel) 간의 직접 연결도 제거. 
- Notification Center를 통해, Model과 Control 변화를 Canvas ViewController가 관찰하도록 수정

**완료 일자**
2022.03.04

## Step 4. 사진 추가 기능 & Photo 모델 추가

**Screenshot**

![step4](https://user-images.githubusercontent.com/17468015/156972996-d4d6341f-b954-4b31-be7f-6d33b9a04f73.gif)

**주요 기능**
- 사진 추가 버튼을 누르면 Image Picker가 등장
- 사진을 선택하면 Photo Model을 생성하고 변화를 Canvas에 업데이트
- Photo의 경우, Color 속성이 없기 때문에 Panel에서 Color가 Disabled.

**완료 일자**
2022.03.07
