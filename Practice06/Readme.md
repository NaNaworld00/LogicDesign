
# Lab 06

## 실습 내용

### **7 – Segment Display Decoder (개별)**

#### **Submodule 1** : 0~9의 값을 갖는 4bit 입력 신호를 받아 7bit FND  segment  값 출력

#### **Submodule 2** : 0~59의 값을 갖는 6bit 입력 신호를 받아 십의 자리 수와 일의 자리 수를 각각 4bit으로 출력

#### **Top Module** : 저번 시간에 만든 second counter  및 Submodule 1/2를 이용하여 실습 장비의 LED에 맞는 Display Module 설계

### FPGA 실습 (팀) : 6개의 LED 중 가장 오른쪽 2개의 LED에 1초간격으로 0~59까지 증가하는 Counter 값 Display

: NCO(Numerical Controlled Oscillator) 입력 바꿔서 4초 간격으로 증가하는 코드 테스트

## 결과 ### **Top Module 의 DUT/TestBench Code 및 Waveform 검증**


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNzYwMTgyMzhdfQ==
-->