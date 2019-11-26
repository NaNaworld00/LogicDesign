# Lab 09

## 실습 내용

### **IR CONTROLLER (개별)**

#### **Module 설명**

#### **ir_rx** : IR 리모컨의 송신 신호를  수신하고, 32비트의 Custom&DataCode 출력

#### **fnd_dec** : 32비트 Custom&DataCode를 각각 4 bit씩 할당받아 각 LED(6개)의 7 bit segment 값 출력

#### **led_disp** : fnd_dec에서 출력한 segment 값을 입력받아 6개 LED 전부 display되도록 함

#### **Top module** : ir_rx, fnd_dec, led_disp module을 활용하여 실습장비의 LED에 맞는 Display Module 설계

### FPGA 실습 : IR 리모컨 버튼을 눌렀을 때 6개의 LED에 그에 상응하는 24비트 데이터 display

: 리모컨 버튼을 바꿔가며 모든 데이터가 바르게 display되는지 확인


## 결과

### **Top module의 DUT/Testbench Code 및 Waveform 검증**

![]([https://raw.githubusercontent.com/NaNaworld00/LogicDesign/master/Practice09/fig/%EC%BA%A1%EC%B2%98.PNG](https://raw.githubusercontent.com/NaNaworld00/LogicDesign/master/Practice09/fig/%EC%BA%A1%EC%B2%98.PNG)