EESchema Schematic File Version 4
LIBS:z80_adapter-cache
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74lvc:74LVC8T245 U4
U 1 1 5975C5CE
P 1500 5650
F 0 "U4" H 1450 6350 60  0000 L CNN
F 1 "74LVC4245" H 1250 4950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 1500 5550 60  0001 C CNN
F 3 "" H 1500 5550 60  0000 C CNN
	1    1500 5650
	-1   0    0    1   
$EndComp
$Comp
L 74lvc:74LVC8T245 U5
U 1 1 5975C870
P 6000 5650
F 0 "U5" H 5950 6350 60  0000 L CNN
F 1 "74LVC4245" H 5700 4950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 6000 5550 60  0001 C CNN
F 3 "" H 6000 5550 60  0000 C CNN
	1    6000 5650
	1    0    0    -1  
$EndComp
$Comp
L 74lvc:74LVC8T245 U2
U 1 1 5975C8C1
P 1500 1650
F 0 "U2" H 1450 2350 60  0000 L CNN
F 1 "74LVC4245" H 1250 950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 1500 1550 60  0001 C CNN
F 3 "" H 1500 1550 60  0000 C CNN
	1    1500 1650
	-1   0    0    1   
$EndComp
$Comp
L 74lvc:74LVC8T245 U3
U 1 1 5975C914
P 1500 3650
F 0 "U3" H 1450 4350 60  0000 L CNN
F 1 "74LVC4245" H 1250 2950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 1500 3550 60  0001 C CNN
F 3 "" H 1500 3550 60  0000 C CNN
	1    1500 3650
	-1   0    0    1   
$EndComp
Text Label 9450 1700 2    60   ~ 0
5V
Text Label 10550 1700 0    60   ~ 0
GND
Text Label 10050 2600 2    60   ~ 0
3V3
Text Label 10550 2600 0    60   ~ 0
GND
Text Label 9000 1700 0    60   ~ 0
GND
Text Label 9000 2600 0    60   ~ 0
GND
$Comp
L Device:C_Small C1
U 1 1 597620E8
P 1100 7400
F 0 "C1" H 1110 7470 50  0000 L CNN
F 1 "100nF" H 1110 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1100 7400 50  0001 C CNN
F 3 "" H 1100 7400 50  0000 C CNN
	1    1100 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C2
U 1 1 5976220A
P 1400 7400
F 0 "C2" H 1410 7470 50  0000 L CNN
F 1 "100nF" H 1410 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1400 7400 50  0001 C CNN
F 3 "" H 1400 7400 50  0000 C CNN
	1    1400 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C3
U 1 1 59762254
P 1700 7400
F 0 "C3" H 1710 7470 50  0000 L CNN
F 1 "100nF" H 1710 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1700 7400 50  0001 C CNN
F 3 "" H 1700 7400 50  0000 C CNN
	1    1700 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 59762296
P 2000 7400
F 0 "C4" H 2010 7470 50  0000 L CNN
F 1 "100nF" H 2010 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2000 7400 50  0001 C CNN
F 3 "" H 2000 7400 50  0000 C CNN
	1    2000 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C5
U 1 1 597622DF
P 2300 7400
F 0 "C5" H 2310 7470 50  0000 L CNN
F 1 "100nF" H 2310 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2300 7400 50  0001 C CNN
F 3 "" H 2300 7400 50  0000 C CNN
	1    2300 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C7
U 1 1 597624D7
P 3650 7400
F 0 "C7" H 3660 7470 50  0000 L CNN
F 1 "100nF" H 3660 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3650 7400 50  0001 C CNN
F 3 "" H 3650 7400 50  0000 C CNN
	1    3650 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C8
U 1 1 5976252A
P 3950 7400
F 0 "C8" H 3960 7470 50  0000 L CNN
F 1 "100nF" H 3960 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3950 7400 50  0001 C CNN
F 3 "" H 3950 7400 50  0000 C CNN
	1    3950 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C9
U 1 1 59762588
P 4250 7400
F 0 "C9" H 4260 7470 50  0000 L CNN
F 1 "100nF" H 4260 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4250 7400 50  0001 C CNN
F 3 "" H 4250 7400 50  0000 C CNN
	1    4250 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C10
U 1 1 597625E5
P 4550 7400
F 0 "C10" H 4560 7470 50  0000 L CNN
F 1 "100nF" H 4560 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4550 7400 50  0001 C CNN
F 3 "" H 4550 7400 50  0000 C CNN
	1    4550 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C11
U 1 1 59762645
P 4850 7400
F 0 "C11" H 4860 7470 50  0000 L CNN
F 1 "100nF" H 4860 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4850 7400 50  0001 C CNN
F 3 "" H 4850 7400 50  0000 C CNN
	1    4850 7400
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1_Small C14
U 1 1 59763501
P 5450 7400
F 0 "C14" H 5460 7470 50  0000 L CNN
F 1 "10uF" H 5460 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5450 7400 50  0001 C CNN
F 3 "" H 5450 7400 50  0000 C CNN
	1    5450 7400
	1    0    0    -1  
$EndComp
Text Label 5450 7200 2    60   ~ 0
3V3
Text Label 3350 7600 2    60   ~ 0
GND
$Comp
L power:PWR_FLAG #FLG02
U 1 1 59767405
P 3650 7200
F 0 "#FLG02" H 3650 7295 50  0001 C CNN
F 1 "PWR_FLAG" H 3650 7380 50  0000 C CNN
F 2 "" H 3650 7200 50  0000 C CNN
F 3 "" H 3650 7200 50  0000 C CNN
	1    3650 7200
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG03
U 1 1 59767675
P 800 7600
F 0 "#FLG03" H 800 7695 50  0001 C CNN
F 1 "PWR_FLAG" H 800 7780 50  0000 C CNN
F 2 "" H 800 7600 50  0000 C CNN
F 3 "" H 800 7600 50  0000 C CNN
	1    800  7600
	1    0    0    -1  
$EndComp
Wire Wire Line
	1100 7500 1100 7600
Wire Wire Line
	800  7600 1100 7600
Wire Wire Line
	4850 7600 4850 7500
Wire Wire Line
	4550 7500 4550 7600
Connection ~ 4550 7600
Wire Wire Line
	4250 7500 4250 7600
Connection ~ 4250 7600
Wire Wire Line
	3950 7500 3950 7600
Connection ~ 3950 7600
Wire Wire Line
	3650 7500 3650 7600
Connection ~ 3650 7600
Wire Wire Line
	2300 7500 2300 7600
Connection ~ 2300 7600
Wire Wire Line
	2000 7500 2000 7600
Connection ~ 2000 7600
Wire Wire Line
	1700 7500 1700 7600
Connection ~ 1700 7600
Wire Wire Line
	1400 7500 1400 7600
Connection ~ 1400 7600
Wire Wire Line
	1100 7300 1100 7200
Wire Wire Line
	1100 7200 1400 7200
Wire Wire Line
	2300 7200 2300 7300
Wire Wire Line
	2000 7300 2000 7200
Connection ~ 2000 7200
Wire Wire Line
	1700 7300 1700 7200
Connection ~ 1700 7200
Wire Wire Line
	1400 7300 1400 7200
Connection ~ 1400 7200
Wire Wire Line
	3650 7300 3650 7200
Wire Wire Line
	3650 7200 3950 7200
Wire Wire Line
	4850 7200 4850 7300
Wire Wire Line
	4550 7300 4550 7200
Connection ~ 4550 7200
Wire Wire Line
	4250 7300 4250 7200
Connection ~ 4250 7200
Wire Wire Line
	3950 7300 3950 7200
Connection ~ 3950 7200
Connection ~ 2300 7200
Connection ~ 4850 7200
Connection ~ 4850 7600
Connection ~ 1100 7600
Wire Wire Line
	4550 7600 4850 7600
Wire Wire Line
	3650 7600 3950 7600
Wire Wire Line
	2000 7600 2300 7600
Wire Wire Line
	1700 7600 2000 7600
Wire Wire Line
	1400 7600 1700 7600
Wire Wire Line
	2000 7200 2300 7200
Wire Wire Line
	1700 7200 2000 7200
Wire Wire Line
	1400 7200 1700 7200
Wire Wire Line
	4550 7200 4850 7200
Wire Wire Line
	4250 7200 4550 7200
Wire Wire Line
	3950 7200 4250 7200
Wire Wire Line
	1100 7600 1400 7600
Wire Wire Line
	3950 7600 4250 7600
Wire Wire Line
	4250 7600 4550 7600
$Comp
L Device:D_Schottky D4
U 1 1 5D7BB685
P 9600 1700
F 0 "D4" H 9600 1600 50  0000 C CNN
F 1 "MBR130" H 9600 1800 50  0000 C CNN
F 2 "Diode_SMD:D_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9600 1700 50  0001 C CNN
F 3 "~" H 9600 1700 50  0001 C CNN
	1    9600 1700
	-1   0    0    1   
$EndComp
Wire Wire Line
	9750 1700 10050 1700
$Comp
L Device:D_Schottky D5
U 1 1 5D7DCB4D
P 8050 1700
F 0 "D5" H 8050 1600 50  0000 C CNN
F 1 "MBR130" H 8050 1800 50  0000 C CNN
F 2 "Diode_SMD:D_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8050 1700 50  0001 C CNN
F 3 "~" H 8050 1700 50  0001 C CNN
	1    8050 1700
	-1   0    0    1   
$EndComp
$Comp
L Device:LED D3
U 1 1 5D81F17A
P 10000 4450
F 0 "D3" V 10039 4333 50  0000 R CNN
F 1 "LED" V 9948 4333 50  0000 R CNN
F 2 "LED_THT:LED_D3.0mm" H 10000 4450 50  0001 C CNN
F 3 "~" H 10000 4450 50  0001 C CNN
	1    10000 4450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10000 4200 10000 4300
Wire Wire Line
	10000 4600 10000 4700
$Comp
L Device:LED D2
U 1 1 5D84BFB8
P 10350 4450
F 0 "D2" V 10389 4333 50  0000 R CNN
F 1 "LED" V 10298 4333 50  0000 R CNN
F 2 "LED_THT:LED_D3.0mm" H 10350 4450 50  0001 C CNN
F 3 "~" H 10350 4450 50  0001 C CNN
	1    10350 4450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10350 4200 10350 4300
Wire Wire Line
	10350 4600 10350 4700
$Comp
L Device:LED D1
U 1 1 5D8531A5
P 10700 4450
F 0 "D1" V 10739 4333 50  0000 R CNN
F 1 "LED" V 10648 4333 50  0000 R CNN
F 2 "LED_THT:LED_D3.0mm" H 10700 4450 50  0001 C CNN
F 3 "~" H 10700 4450 50  0001 C CNN
	1    10700 4450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10700 4200 10700 4300
Wire Wire Line
	10700 4600 10700 4700
Wire Wire Line
	10000 4700 10350 4700
Connection ~ 10350 4700
Wire Wire Line
	10350 4700 10700 4700
Text Label 10500 4700 0    50   ~ 0
GND
Wire Wire Line
	8300 4900 8050 4900
Wire Wire Line
	8300 5600 8050 5600
Wire Wire Line
	8850 5600 8700 5600
Wire Wire Line
	8850 4900 8700 4900
Connection ~ 8850 4900
Connection ~ 8850 5600
Text Label 8850 4500 0    50   ~ 0
3V3
Text Label 8850 5200 0    50   ~ 0
3V3
Wire Wire Line
	9000 4900 8850 4900
Wire Wire Line
	8850 5600 9000 5600
Text Label 8850 3950 0    50   ~ 0
3V3
Wire Wire Line
	9000 4350 8850 4350
Wire Wire Line
	8450 4350 8050 4350
Wire Wire Line
	8050 4350 8050 4900
Connection ~ 8050 4900
Wire Wire Line
	8550 4350 8850 4350
Connection ~ 8850 4350
Wire Wire Line
	8850 4250 8850 4350
Text Label 9650 6250 0    60   ~ 0
GND
$Comp
L 74lvc:74LVC8T245 U7
U 1 1 5975C957
P 6000 1650
F 0 "U7" H 5900 2350 60  0000 L CNN
F 1 "74LVC4245" H 5750 950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 6000 1550 60  0001 C CNN
F 3 "" H 6000 1550 60  0000 C CNN
	1    6000 1650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R3
U 1 1 5DAD83A7
P 9900 5450
F 0 "R3" H 9930 5470 50  0000 L CNN
F 1 "22K" H 9930 5410 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9900 5450 50  0001 C CNN
F 3 "" H 9900 5450 50  0000 C CNN
	1    9900 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 5350 9750 5250
Wire Wire Line
	9900 5350 9900 5250
$Comp
L Device:R_Small R5
U 1 1 5DB1C0F5
P 8850 4700
F 0 "R5" H 8880 4720 50  0000 L CNN
F 1 "22K" H 8880 4660 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8850 4700 50  0001 C CNN
F 3 "" H 8850 4700 50  0000 C CNN
	1    8850 4700
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R9
U 1 1 5DB1C76D
P 10000 4100
F 0 "R9" H 10030 4120 50  0000 L CNN
F 1 "330" H 10030 4060 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10000 4100 50  0001 C CNN
F 3 "" H 10000 4100 50  0000 C CNN
	1    10000 4100
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R8
U 1 1 5DB1CD21
P 10350 4100
F 0 "R8" H 10380 4120 50  0000 L CNN
F 1 "330" H 10380 4060 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10350 4100 50  0001 C CNN
F 3 "" H 10350 4100 50  0000 C CNN
	1    10350 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	10000 3900 10000 4000
Wire Wire Line
	10350 3900 10350 4000
Wire Wire Line
	10700 3900 10700 4000
$Comp
L Device:R_Small R6
U 1 1 5DB3B488
P 8850 5400
F 0 "R6" H 8880 5420 50  0000 L CNN
F 1 "22K" H 8880 5360 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8850 5400 50  0001 C CNN
F 3 "" H 8850 5400 50  0000 C CNN
	1    8850 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 4900 8850 4800
Wire Wire Line
	8850 4600 8850 4500
Wire Wire Line
	8850 5200 8850 5300
Wire Wire Line
	8850 5500 8850 5600
$Comp
L Device:R_Small R4
U 1 1 5DB3B00F
P 8850 4150
F 0 "R4" H 8880 4170 50  0000 L CNN
F 1 "22K" H 8880 4110 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8850 4150 50  0001 C CNN
F 3 "" H 8850 4150 50  0000 C CNN
	1    8850 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 4050 8850 3950
Wire Wire Line
	9750 5550 9750 6150
Connection ~ 9900 6050
Wire Wire Line
	9650 6050 9900 6050
Connection ~ 3650 7200
$Comp
L Device:R_Small R7
U 1 1 5DB1D074
P 10700 4100
F 0 "R7" H 10730 4120 50  0000 L CNN
F 1 "330" H 10730 4060 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10700 4100 50  0001 C CNN
F 3 "" H 10700 4100 50  0000 C CNN
	1    10700 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	8200 1700 8500 1700
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5DD1CC9C
P 1100 7200
F 0 "#FLG0101" H 1100 7295 50  0001 C CNN
F 1 "PWR_FLAG" H 1100 7380 50  0000 C CNN
F 2 "" H 1100 7200 50  0000 C CNN
F 3 "" H 1100 7200 50  0000 C CNN
	1    1100 7200
	1    0    0    -1  
$EndComp
Connection ~ 1100 7200
Text Label 9000 4900 0    60   ~ 0
SW1
Text Label 9000 5600 0    60   ~ 0
SW2
Text Label 10700 3900 0    60   ~ 0
LED1
Text Label 10350 3900 0    60   ~ 0
LED2
Text Label 10000 3900 0    60   ~ 0
LED3
$Comp
L Device:R_Small R2
U 1 1 5DAD7D35
P 9750 5450
F 0 "R2" H 9780 5470 50  0000 L CNN
F 1 "22K" H 9780 5410 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9750 5450 50  0001 C CNN
F 3 "" H 9750 5450 50  0000 C CNN
	1    9750 5450
	-1   0    0    -1  
$EndComp
Text Label 8050 4350 0    50   ~ 0
GND
Text Label 8500 1700 2    60   ~ 0
VIN1
Text Label 10050 1700 2    60   ~ 0
VIN2
$Comp
L Switch:SW_Push SW1
U 1 1 5DEE6A68
P 8500 4900
F 0 "SW1" H 8500 5185 50  0000 C CNN
F 1 "SW_Push" H 8500 5094 50  0000 C CNN
F 2 "footprints:SW_Tactile_SKHH_Angled" H 8500 5100 50  0001 C CNN
F 3 "~" H 8500 5100 50  0001 C CNN
	1    8500 4900
	-1   0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW2
U 1 1 5DEE72B2
P 8500 5600
F 0 "SW2" H 8500 5885 50  0000 C CNN
F 1 "SW_Push" H 8500 5794 50  0000 C CNN
F 2 "footprints:SW_Tactile_SKHH_Angled" H 8500 5800 50  0001 C CNN
F 3 "~" H 8500 5800 50  0001 C CNN
	1    8500 5600
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 4900 8050 5600
Text Label 9750 5250 0    60   ~ 0
5V
Wire Wire Line
	9750 5250 9900 5250
Connection ~ 9750 6150
Wire Wire Line
	9650 6150 9750 6150
Wire Wire Line
	9900 5550 9900 6050
Wire Wire Line
	9900 6050 10000 6050
Text Label 9000 4350 0    60   ~ 0
JUMPER
Text Label 10050 3100 2    60   ~ 0
JUMPER
Text Label 10550 1200 0    60   ~ 0
LED1
Text Label 10550 1300 0    60   ~ 0
LED2
Text Label 10050 1200 2    60   ~ 0
SW1
$Comp
L Connector_Generic:Conn_01x03 P3
U 1 1 5D79943A
P 9450 6150
F 0 "P3" H 9368 6467 50  0000 C CNN
F 1 "Conn_01x03" H 9368 6376 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 9450 6150 50  0001 C CNN
F 3 "~" H 9450 6150 50  0001 C CNN
	1    9450 6150
	-1   0    0    1   
$EndComp
$Comp
L Connector_Generic:Conn_01x02 LK1
U 1 1 5D79B15B
P 8450 4150
F 0 "LK1" V 8600 4150 50  0000 R CNN
F 1 "Conn_01x02" V 8550 4300 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Horizontal" H 8450 4150 50  0001 C CNN
F 3 "~" H 8450 4150 50  0001 C CNN
	1    8450 4150
	0    -1   -1   0   
$EndComp
Text Label 10000 6150 0    60   ~ 0
TRIG0
Text Label 10000 6050 0    60   ~ 0
TRIG1
Wire Wire Line
	5450 7300 5450 7200
Wire Wire Line
	5450 7500 5450 7600
Wire Wire Line
	2900 7600 3650 7600
Connection ~ 2900 7600
Wire Wire Line
	2900 7500 2900 7600
Wire Wire Line
	2900 7200 2900 7300
Text Label 2900 7200 2    60   ~ 0
5V
$Comp
L Device:CP1_Small C13
U 1 1 597630BE
P 2900 7400
F 0 "C13" H 2910 7470 50  0000 L CNN
F 1 "10uF" H 2910 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2900 7400 50  0001 C CNN
F 3 "" H 2900 7400 50  0000 C CNN
	1    2900 7400
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 7200 2600 7200
Wire Wire Line
	4850 7200 5150 7200
Wire Wire Line
	4850 7600 5150 7600
$Comp
L Device:R_Small R10
U 1 1 5D7EEC6E
P 10700 5500
F 0 "R10" V 10600 5450 50  0000 L TNN
F 1 "0" V 10700 5500 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10700 5500 50  0001 C CNN
F 3 "" H 10700 5500 50  0000 C CNN
	1    10700 5500
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R11
U 1 1 5D802707
P 10700 5750
F 0 "R11" V 10600 5700 50  0000 L TNN
F 1 "0" V 10700 5750 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10700 5750 50  0001 C CNN
F 3 "" H 10700 5750 50  0000 C CNN
	1    10700 5750
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R12
U 1 1 5D802C8C
P 10700 6000
F 0 "R12" V 10600 5950 50  0000 L TNN
F 1 "0" V 10700 6000 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10700 6000 50  0001 C CNN
F 3 "" H 10700 6000 50  0000 C CNN
	1    10700 6000
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R13
U 1 1 5D802F0D
P 10700 6250
F 0 "R13" V 10600 6200 50  0000 L TNN
F 1 "0" V 10700 6250 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10700 6250 50  0001 C CNN
F 3 "" H 10700 6250 50  0000 C CNN
	1    10700 6250
	0    1    1    0   
$EndComp
Text Label 10950 5500 0    60   ~ 0
GND
Wire Wire Line
	10800 5500 10950 5500
Wire Wire Line
	10950 5500 10950 5750
Wire Wire Line
	10950 6250 10800 6250
Wire Wire Line
	10800 6000 10950 6000
Connection ~ 10950 6000
Wire Wire Line
	10950 6000 10950 6250
Wire Wire Line
	10800 5750 10950 5750
Connection ~ 10950 5750
Wire Wire Line
	10950 5750 10950 6000
Text Label 10600 5500 2    60   ~ 0
ID0
Text Label 10600 5750 2    60   ~ 0
ID1
Text Label 10600 6000 2    60   ~ 0
ID2
Text Label 10600 6250 2    60   ~ 0
ID3
$Comp
L Connector_Generic:Conn_02x20_Odd_Even P1
U 1 1 5D790677
P 8700 2100
F 0 "P1" H 8750 3100 50  0000 C CNN
F 1 "Conn_02x20_Odd_Even" H 8800 1000 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x20_P2.54mm_Vertical" H 8700 2100 50  0001 C CNN
F 3 "~" H 8700 2100 50  0001 C CNN
	1    8700 2100
	1    0    0    -1  
$EndComp
Text Label 9000 2400 0    60   ~ 0
ID0
Text Label 9000 2500 0    60   ~ 0
ID2
$Comp
L CPU:Z80CPU U1
U 1 1 5D824EAF
P 3750 3650
F 0 "U1" H 3750 5331 50  0000 C CNN
F 1 "Z80CPU" H 3750 5240 50  0000 C CNN
F 2 "footprints:dip40_smt_header" H 3750 4050 50  0001 C CNN
F 3 "www.zilog.com/manage_directlink.php?filepath=docs/z80/um0080" H 3750 4050 50  0001 C CNN
	1    3750 3650
	1    0    0    -1  
$EndComp
Text Label 4450 2450 0    60   ~ 0
A0
Text Label 4450 2550 0    60   ~ 0
A1
Text Label 4450 2650 0    60   ~ 0
A2
Text Label 4450 2750 0    60   ~ 0
A3
Text Label 4450 2850 0    60   ~ 0
A4
Text Label 4450 2950 0    60   ~ 0
A5
Text Label 4450 3050 0    60   ~ 0
A6
Text Label 4450 3150 0    60   ~ 0
A7
Text Label 4450 3250 0    60   ~ 0
A8
Text Label 4450 3350 0    60   ~ 0
A9
Text Label 4450 3450 0    60   ~ 0
A10
Text Label 4450 3550 0    60   ~ 0
A11
Text Label 4450 3650 0    60   ~ 0
A12
Text Label 4450 3750 0    60   ~ 0
A13
Text Label 4450 3850 0    60   ~ 0
A14
Text Label 4450 3950 0    60   ~ 0
A15
Text Label 4450 4150 0    60   ~ 0
D0
Text Label 4450 4250 0    60   ~ 0
D1
Text Label 4450 4350 0    60   ~ 0
D2
Text Label 4450 4450 0    60   ~ 0
D3
Text Label 4450 4550 0    60   ~ 0
D4
Text Label 4450 4650 0    60   ~ 0
D5
Text Label 4450 4750 0    60   ~ 0
D6
Text Label 4450 4850 0    60   ~ 0
D7
Text Label 3750 2150 0    60   ~ 0
5V
Text Label 3750 5150 0    60   ~ 0
GND
Text Label 3050 2450 2    60   ~ 0
RESET
Text Label 3050 2750 2    60   ~ 0
CLK
Text Label 3050 3050 2    60   ~ 0
NMI
Text Label 3050 3150 2    60   ~ 0
INT
Text Label 3050 3450 2    60   ~ 0
M1
Text Label 3050 3550 2    60   ~ 0
RFSH
Text Label 3050 3650 2    60   ~ 0
WAIT
Text Label 3050 3750 2    60   ~ 0
HALT
Text Label 3050 4150 2    60   ~ 0
RD
Text Label 3050 4250 2    60   ~ 0
WR
Text Label 3050 4350 2    60   ~ 0
MREQ
Text Label 3050 4450 2    60   ~ 0
IORQ
Text Label 3050 4750 2    60   ~ 0
BUSRQ
Text Label 3050 4850 2    60   ~ 0
BUSACK
Wire Wire Line
	9750 6150 10000 6150
Text Label 8500 2500 2    60   ~ 0
ID3
Text Label 8500 2400 2    60   ~ 0
ID1
Text Label 8500 2600 2    60   ~ 0
3V3
Text Label 8500 3100 2    60   ~ 0
SW2
Text Label 9000 3100 0    60   ~ 0
LED3
$Comp
L 74lvc:74LVC8T245 U6
U 1 1 5D8E5B96
P 6000 3650
F 0 "U6" H 5950 4350 60  0000 L CNN
F 1 "74LVC4245" H 5700 2950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 6000 3550 60  0001 C CNN
F 3 "" H 6000 3550 60  0000 C CNN
	1    6000 3650
	1    0    0    -1  
$EndComp
Text Label 6700 2200 0    60   ~ 0
GND
Text Label 6700 6200 0    60   ~ 0
GND
Text Label 6700 4200 0    60   ~ 0
GND
Text Label 5300 4200 2    60   ~ 0
GND
Text Label 5300 4100 2    60   ~ 0
GND
Text Label 5300 6200 2    60   ~ 0
GND
Text Label 5300 6100 2    60   ~ 0
GND
Text Label 5300 2200 2    60   ~ 0
GND
Text Label 5300 2100 2    60   ~ 0
GND
Text Label 2200 1100 0    60   ~ 0
GND
Text Label 2200 1200 0    60   ~ 0
GND
Text Label 2200 3100 0    60   ~ 0
GND
Text Label 2200 3200 0    60   ~ 0
GND
Text Label 2200 5100 0    60   ~ 0
GND
Text Label 2200 5200 0    60   ~ 0
GND
Text Label 800  5100 2    60   ~ 0
GND
Text Label 800  3100 2    60   ~ 0
GND
Text Label 800  1100 2    60   ~ 0
GND
Text Label 800  2100 2    60   ~ 0
3V3
Text Label 800  2200 2    60   ~ 0
3V3
Text Label 800  4100 2    60   ~ 0
3V3
Text Label 800  4200 2    60   ~ 0
3V3
Text Label 800  6100 2    60   ~ 0
3V3
Text Label 800  6200 2    60   ~ 0
3V3
Text Label 6700 1100 0    60   ~ 0
3V3
Text Label 6700 1200 0    60   ~ 0
3V3
Text Label 6700 5100 0    60   ~ 0
3V3
Text Label 6700 5200 0    60   ~ 0
3V3
Text Label 6700 3100 0    60   ~ 0
3V3
Text Label 6700 3200 0    60   ~ 0
3V3
Text Label 5300 3100 2    60   ~ 0
5V
Text Label 5300 5100 2    60   ~ 0
5V
Text Label 5300 1100 2    60   ~ 0
5V
Text Label 2200 2200 0    60   ~ 0
5V
Text Label 2200 4200 0    60   ~ 0
5V
Text Label 2200 6200 0    60   ~ 0
5V
Text Label 2200 3300 0    60   ~ 0
D4
Text Label 2200 3400 0    60   ~ 0
D3
Text Label 2200 3500 0    60   ~ 0
D5
Text Label 2200 3600 0    60   ~ 0
D6
Text Label 2200 3700 0    60   ~ 0
D2
Text Label 2200 3800 0    60   ~ 0
D7
Text Label 2200 3900 0    60   ~ 0
D0
Text Label 2200 4000 0    60   ~ 0
D1
Text Label 2200 4100 0    60   ~ 0
LV_DIRD
Text Label 800  4000 2    60   ~ 0
LV_OED
Text Label 800  3900 2    60   ~ 0
LV_D1
Text Label 800  3200 2    60   ~ 0
LV_D4
Text Label 800  3300 2    60   ~ 0
LV_D3
Text Label 800  3400 2    60   ~ 0
LV_D5
Text Label 800  3500 2    60   ~ 0
LV_D6
Text Label 800  3600 2    60   ~ 0
LV_D2
Text Label 800  3700 2    60   ~ 0
LV_D7
Text Label 800  3800 2    60   ~ 0
LV_D0
Text Label 2200 2000 0    60   ~ 0
A15
Text Label 2200 1800 0    60   ~ 0
A14
Text Label 2200 1600 0    60   ~ 0
A13
Text Label 2200 1400 0    60   ~ 0
A12
Text Label 2200 1300 0    60   ~ 0
A11
Text Label 5300 1300 2    60   ~ 0
A10
Text Label 5300 1400 2    60   ~ 0
A9
Text Label 5300 1600 2    60   ~ 0
A8
Text Label 800  2000 2    60   ~ 0
LV_OEA1
Text Label 2200 2100 0    60   ~ 0
GND
Text Label 800  1800 2    60   ~ 0
LV_A2
Text Label 800  1600 2    60   ~ 0
LV_A3
Text Label 800  1400 2    60   ~ 0
LV_A4
Text Label 800  1200 2    60   ~ 0
LV_A11
Text Label 800  1300 2    60   ~ 0
LV_A12
Text Label 800  1500 2    60   ~ 0
LV_A13
Text Label 800  1700 2    60   ~ 0
LV_A14
Text Label 800  1900 2    60   ~ 0
LV_A15
Text Label 5300 1200 2    60   ~ 0
GND
Text Label 6700 1300 0    60   ~ 0
LV_OEA2
Text Label 5300 1800 2    60   ~ 0
A7
Text Label 5300 1900 2    60   ~ 0
A6
Text Label 5300 2000 2    60   ~ 0
A5
Text Label 2200 1500 0    60   ~ 0
A4
Text Label 2200 1700 0    60   ~ 0
A3
Text Label 2200 1900 0    60   ~ 0
A2
Text Label 5300 1700 2    60   ~ 0
A1
Text Label 5300 1500 2    60   ~ 0
A0
Text Label 6700 1400 0    60   ~ 0
LV_A10
Text Label 6700 1500 0    60   ~ 0
LV_A9
Text Label 6700 1600 0    60   ~ 0
LV_A0
Text Label 6700 1700 0    60   ~ 0
LV_A8
Text Label 6700 1800 0    60   ~ 0
LV_A1
Text Label 6700 1900 0    60   ~ 0
LV_A7
Text Label 6700 2000 0    60   ~ 0
LV_A6
Text Label 6700 2100 0    60   ~ 0
LV_A5
Text Label 2200 5900 0    60   ~ 0
MREQ
Text Label 2200 6000 0    60   ~ 0
IORQ
Text Label 2200 5800 0    60   ~ 0
RD
Text Label 2200 5700 0    60   ~ 0
WR
NoConn ~ 2200 5600
NoConn ~ 2200 5500
NoConn ~ 2200 5300
NoConn ~ 2200 5400
Text Label 2200 6100 0    60   ~ 0
GND
NoConn ~ 800  5500
NoConn ~ 800  5400
NoConn ~ 800  5300
NoConn ~ 800  5200
Text Label 800  5800 2    60   ~ 0
LV_MREQ
Text Label 800  5900 2    60   ~ 0
LV_IORQ
Text Label 800  5700 2    60   ~ 0
LV_RD
Text Label 800  5600 2    60   ~ 0
LV_WR
Text Label 800  6000 2    60   ~ 0
LV_OEC
$Comp
L Device:R_Small R1
U 1 1 5D916113
P 5050 4850
F 0 "R1" H 5080 4870 50  0000 L CNN
F 1 "22K" H 5080 4810 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5050 4850 50  0001 C CNN
F 3 "" H 5050 4850 50  0000 C CNN
	1    5050 4850
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5300 5200 5050 5200
Wire Wire Line
	5050 5200 5050 4950
Text Label 5050 4750 2    60   ~ 0
5V
Text Label 5300 5900 2    60   ~ 0
TRIG0
Text Label 5300 6000 2    60   ~ 0
TRIG1
Text Label 5300 5300 2    60   ~ 0
RESET
Text Label 5300 5400 2    60   ~ 0
BUSRQ
Text Label 5300 5500 2    60   ~ 0
WAIT
Text Label 5300 5700 2    60   ~ 0
INT
Text Label 5300 5800 2    60   ~ 0
NMI
Text Label 6700 5300 0    60   ~ 0
GND
Text Label 6700 5400 0    60   ~ 0
LV_RESET
Text Label 6700 5500 0    60   ~ 0
LV_BUSRQ
Text Label 6700 5600 0    60   ~ 0
LV_WAIT
Text Label 6700 5800 0    60   ~ 0
LV_INT
Text Label 6700 5900 0    60   ~ 0
LV_NMI
Text Label 6700 6100 0    60   ~ 0
LV_TRIG1
Text Label 6700 6000 0    60   ~ 0
LV_TRIG0
Text Label 6700 5700 0    60   ~ 0
LV_CLK
Text Label 6700 3300 0    60   ~ 0
GND
Text Label 5300 3200 2    60   ~ 0
GND
Text Label 6700 3800 0    60   ~ 0
LV_RFSH
Text Label 6700 3900 0    60   ~ 0
LV_M1
Text Label 6700 4000 0    60   ~ 0
LV_HALT
NoConn ~ 5300 3300
NoConn ~ 5300 3400
NoConn ~ 5300 3500
NoConn ~ 5300 3600
NoConn ~ 6700 3700
NoConn ~ 6700 3600
NoConn ~ 6700 3500
NoConn ~ 6700 3400
Text Label 6700 4100 0    60   ~ 0
LV_BUSACK
Text Label 7900 1700 2    60   ~ 0
5V
$Comp
L Device:C_Small C6
U 1 1 5D96CD25
P 2600 7400
F 0 "C6" H 2610 7470 50  0000 L CNN
F 1 "100nF" H 2610 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2600 7400 50  0001 C CNN
F 3 "" H 2600 7400 50  0000 C CNN
	1    2600 7400
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 7300 2600 7200
Connection ~ 2600 7200
Wire Wire Line
	2600 7200 2900 7200
Wire Wire Line
	2600 7500 2600 7600
Wire Wire Line
	2300 7600 2600 7600
Connection ~ 2600 7600
Wire Wire Line
	2600 7600 2900 7600
$Comp
L Device:C_Small C12
U 1 1 5D9722BE
P 5150 7400
F 0 "C12" H 5160 7470 50  0000 L CNN
F 1 "100nF" H 5160 7320 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5150 7400 50  0001 C CNN
F 3 "" H 5150 7400 50  0000 C CNN
	1    5150 7400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5150 7300 5150 7200
Connection ~ 5150 7200
Wire Wire Line
	5150 7200 5450 7200
Wire Wire Line
	5150 7500 5150 7600
Connection ~ 5150 7600
Wire Wire Line
	5150 7600 5450 7600
Text Label 5300 4000 2    60   ~ 0
BUSACK
Text Label 5300 3900 2    60   ~ 0
HALT
Text Label 5300 3800 2    60   ~ 0
M1
Text Label 5300 3700 2    60   ~ 0
RFSH
$Comp
L Connector_Generic:Conn_02x20_Odd_Even P2
U 1 1 5D781733
P 10250 2100
F 0 "P2" H 10300 3100 50  0000 C CNN
F 1 "Conn_02x20_Odd_Even" H 10350 1000 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x20_P2.54mm_Vertical" H 10250 2100 50  0001 C CNN
F 3 "~" H 10250 2100 50  0001 C CNN
	1    10250 2100
	1    0    0    -1  
$EndComp
Text Label 10050 1300 2    60   ~ 0
LV_A11
Text Label 10050 1400 2    60   ~ 0
LV_A4
Text Label 10050 1500 2    60   ~ 0
LV_A3
Text Label 10050 1600 2    60   ~ 0
LV_A2
Text Label 10050 1800 2    60   ~ 0
LV_OEA1
Text Label 10550 1400 0    60   ~ 0
LV_A12
Text Label 10550 1500 0    60   ~ 0
LV_A13
Text Label 10550 1600 0    60   ~ 0
LV_A14
Text Label 10550 1800 0    60   ~ 0
LV_A15
Text Label 9000 3000 0    60   ~ 0
LV_OEA2
Text Label 9000 2900 0    60   ~ 0
LV_A9
Text Label 9000 2800 0    60   ~ 0
LV_A8
Text Label 9000 2700 0    60   ~ 0
LV_A7
Text Label 9000 2300 0    60   ~ 0
LV_A5
Text Label 8500 2700 2    60   ~ 0
LV_A6
Text Label 8500 2800 2    60   ~ 0
LV_A1
Text Label 8500 2900 2    60   ~ 0
LV_A0
Text Label 8500 3000 2    60   ~ 0
LV_A10
Text Label 10550 1900 0    60   ~ 0
LV_D4
NoConn ~ 10050 1900
Text Label 10550 2000 0    60   ~ 0
LV_D5
Text Label 10550 2100 0    60   ~ 0
LV_D2
Text Label 10550 2200 0    60   ~ 0
LV_D0
Text Label 10550 2300 0    60   ~ 0
LV_OED
Text Label 10050 2000 2    60   ~ 0
LV_D3
Text Label 10050 2100 2    60   ~ 0
LV_D6
Text Label 10050 2200 2    60   ~ 0
LV_D7
Text Label 10050 2300 2    60   ~ 0
LV_D1
Text Label 10050 2700 2    60   ~ 0
LV_DIRD
Text Label 10050 2800 2    60   ~ 0
LV_WR
Text Label 10050 2900 2    60   ~ 0
LV_MREQ
Text Label 10050 3000 2    60   ~ 0
LV_OEC
Text Label 10550 2800 0    60   ~ 0
LV_RD
Text Label 10550 2900 0    60   ~ 0
LV_IORQ
Text Label 9000 1200 0    60   ~ 0
LV_TRIG0
Text Label 9000 1300 0    60   ~ 0
LV_INT
Text Label 9000 1400 0    60   ~ 0
LV_WAIT
Text Label 9000 1500 0    60   ~ 0
LV_RESET
Text Label 8500 1300 2    60   ~ 0
LV_NMI
Text Label 8500 1200 2    60   ~ 0
LV_TRIG1
Text Label 8500 1400 2    60   ~ 0
LV_CLK
Text Label 8500 1500 2    60   ~ 0
LV_BUSRQ
Text Label 9000 1900 0    60   ~ 0
LV_HALT
Text Label 9000 2000 0    60   ~ 0
LV_RFSH
Text Label 8500 1900 2    60   ~ 0
LV_BUSACK
Text Label 8500 2000 2    60   ~ 0
LV_M1
NoConn ~ 8500 1600
NoConn ~ 9000 1600
NoConn ~ 9000 1800
NoConn ~ 8500 1800
NoConn ~ 8500 2100
NoConn ~ 8500 2200
NoConn ~ 8500 2300
NoConn ~ 9000 2200
NoConn ~ 9000 2100
NoConn ~ 10050 2400
NoConn ~ 10050 2500
NoConn ~ 10550 2400
NoConn ~ 10550 2500
NoConn ~ 10550 2700
NoConn ~ 10550 3000
NoConn ~ 10550 3100
$Comp
L Device:C_Small C15
U 1 1 5D84DB65
P 4600 5800
F 0 "C15" H 4610 5870 50  0000 L CNN
F 1 "0pF" H 4610 5720 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4600 5800 50  0001 C CNN
F 3 "" H 4600 5800 50  0000 C CNN
	1    4600 5800
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R14
U 1 1 5D84D2A8
P 4400 5600
F 0 "R14" V 4300 5550 50  0000 L TNN
F 1 "0" V 4400 5600 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4400 5600 50  0001 C CNN
F 3 "" H 4400 5600 50  0000 C CNN
	1    4400 5600
	0    1    1    0   
$EndComp
Text Label 4300 5600 2    60   ~ 0
CLK
Text Label 4600 5900 3    60   ~ 0
GND
Wire Wire Line
	4600 5700 4600 5600
Wire Wire Line
	4500 5600 4600 5600
Wire Wire Line
	4600 5600 5300 5600
Connection ~ 4600 5600
Text Label 5300 5600 2    60   ~ 0
FILTERED_CLK
$EndSCHEMATC
