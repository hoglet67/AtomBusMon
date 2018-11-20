EESchema Schematic File Version 4
LIBS:6502_adapter-cache
EELAYER 26 0
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
L 65xx:WD65C02 U1
U 1 1 5975BF41
P 5800 3600
F 0 "U1" H 5800 2450 60  0000 C CNN
F 1 "WD65C02" V 5800 3500 60  0000 C CNN
F 2 "footprints:dip40_smt_header" H 5300 3800 60  0001 C CNN
F 3 "" H 5300 3800 60  0000 C CNN
	1    5800 3600
	1    0    0    -1  
$EndComp
$Comp
L 74lvc:74LVC8T245 U4
U 1 1 5975C5CE
P 3650 5600
F 0 "U4" H 3150 6300 60  0000 L CNN
F 1 "74LVC4245" H 3150 4900 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 3650 5500 60  0001 C CNN
F 3 "" H 3650 5500 60  0000 C CNN
	1    3650 5600
	-1   0    0    1   
$EndComp
$Comp
L 6502_adapter-rescue:CONN_02X20 P2
U 1 1 5975C737
P 1200 4100
F 0 "P2" H 1200 5150 50  0000 C CNN
F 1 "CONN_02X20" V 1200 4100 50  0000 C CNN
F 2 "footprints:Socket_Strip_Straight_2x20_Pitch2.54mm" H 1200 3150 50  0001 C CNN
F 3 "" H 1200 3150 50  0000 C CNN
	1    1200 4100
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:CONN_02X20 P1
U 1 1 5975C7A4
P 10450 3950
F 0 "P1" H 10450 5000 50  0000 C CNN
F 1 "CONN_02X20" V 10450 3950 50  0000 C CNN
F 2 "footprints:Socket_Strip_Straight_2x20_Pitch2.54mm" H 10450 3000 50  0001 C CNN
F 3 "" H 10450 3000 50  0000 C CNN
	1    10450 3950
	-1   0    0    1   
$EndComp
$Comp
L 74lvc:74LVC8T245 U5
U 1 1 5975C870
P 8100 3750
F 0 "U5" H 7600 4450 60  0000 L CNN
F 1 "74LVC4245" H 7600 3050 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 8100 3650 60  0001 C CNN
F 3 "" H 8100 3650 60  0000 C CNN
	1    8100 3750
	1    0    0    -1  
$EndComp
$Comp
L 74lvc:74LVC8T245 U2
U 1 1 5975C8C1
P 3300 1650
F 0 "U2" H 2800 2350 60  0000 L CNN
F 1 "74LVC4245" H 2800 950 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 3300 1550 60  0001 C CNN
F 3 "" H 3300 1550 60  0000 C CNN
	1    3300 1650
	-1   0    0    1   
$EndComp
$Comp
L 74lvc:74LVC8T245 U3
U 1 1 5975C914
P 3250 3850
F 0 "U3" H 2750 4550 60  0000 L CNN
F 1 "74LVC4245" H 2750 3150 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 3250 3750 60  0001 C CNN
F 3 "" H 3250 3750 60  0000 C CNN
	1    3250 3850
	-1   0    0    1   
$EndComp
$Comp
L 74lvc:74LVC8T245 U6
U 1 1 5975C957
P 8100 1950
F 0 "U6" H 7600 2650 60  0000 L CNN
F 1 "74LVC4245" H 7600 1250 60  0000 L CNN
F 2 "footprints:SOIC-24W_7.5x15.4mm_Pitch1.27mm" H 8100 1850 60  0001 C CNN
F 3 "" H 8100 1850 60  0000 C CNN
	1    8100 1950
	1    0    0    -1  
$EndComp
Text Label 6700 3400 0    60   ~ 0
D0
Text Label 6700 3500 0    60   ~ 0
D1
Text Label 6700 3600 0    60   ~ 0
D2
Text Label 6700 3700 0    60   ~ 0
D3
Text Label 6700 3800 0    60   ~ 0
D4
Text Label 6700 3900 0    60   ~ 0
D5
Text Label 6700 4000 0    60   ~ 0
D6
Text Label 6700 4100 0    60   ~ 0
D7
Text Label 6450 4600 0    60   ~ 0
GND
Text Label 7400 4300 2    60   ~ 0
GND
Text Label 7400 4200 2    60   ~ 0
GND
Text Label 7400 3200 2    60   ~ 0
5V
Text Label 8800 3200 0    60   ~ 0
3V3
Text Label 8800 3300 0    60   ~ 0
3V3
Text Label 3950 3300 0    60   ~ 0
GND
Text Label 3950 3400 0    60   ~ 0
GND
Text Label 3950 4300 0    60   ~ 0
GND
Text Label 3950 4400 0    60   ~ 0
5V
Text Label 2550 4400 2    60   ~ 0
3V3
Text Label 2550 4300 2    60   ~ 0
3V3
Text Label 2550 3300 2    60   ~ 0
GND
Text Label 4600 3500 2    60   ~ 0
A0
Text Label 4600 3600 2    60   ~ 0
A1
Text Label 4600 3700 2    60   ~ 0
A2
Text Label 4600 3800 2    60   ~ 0
A3
Text Label 4600 3900 2    60   ~ 0
A4
Text Label 4600 4000 2    60   ~ 0
A5
Text Label 4600 4100 2    60   ~ 0
A6
Text Label 4600 4200 2    60   ~ 0
A7
Text Label 5150 3400 2    60   ~ 0
5V
Text Label 8800 4300 0    60   ~ 0
3V3
Text Label 4500 5650 0    60   ~ 0
A8
Text Label 4500 5750 0    60   ~ 0
A9
Text Label 4500 5850 0    60   ~ 0
A10
Text Label 4500 5950 0    60   ~ 0
A11
Text Label 4500 5250 0    60   ~ 0
A15
Text Label 4500 5350 0    60   ~ 0
A14
Text Label 4500 5450 0    60   ~ 0
A13
Text Label 4500 5550 0    60   ~ 0
A12
Text Label 4350 5050 0    60   ~ 0
GND
Text Label 4350 5150 0    60   ~ 0
GND
Text Label 4350 6050 0    60   ~ 0
GND
Text Label 4350 6150 0    60   ~ 0
5V
Text Label 2950 5050 2    60   ~ 0
GND
Text Label 2950 6050 2    60   ~ 0
3V3
Text Label 2950 6150 2    60   ~ 0
3V3
Text Label 950  3650 2    60   ~ 0
5V
Text Label 1450 3650 0    60   ~ 0
GND
Text Label 950  4550 2    60   ~ 0
3V3
Text Label 1450 4550 0    60   ~ 0
GND
Text Label 10200 4400 2    60   ~ 0
GND
Text Label 10200 3500 2    60   ~ 0
GND
Text Label 10700 4400 0    60   ~ 0
5V
Text Label 10700 3500 0    60   ~ 0
3V3
Text Label 4000 1100 0    60   ~ 0
GND
Text Label 4000 1200 0    60   ~ 0
GND
Text Label 4000 2200 0    60   ~ 0
5V
Text Label 2600 2200 2    60   ~ 0
3V3
Text Label 2600 2100 2    60   ~ 0
3V3
Text Label 2600 1100 2    60   ~ 0
GND
Text Label 7400 2400 2    60   ~ 0
GND
Text Label 7400 2500 2    60   ~ 0
GND
Text Label 7400 1400 2    60   ~ 0
5V
Text Label 8800 1400 0    60   ~ 0
3V3
Text Label 8800 1500 0    60   ~ 0
3V3
Text Label 8800 2500 0    60   ~ 0
GND
Text Label 4450 1500 0    60   ~ 0
nVP
Text Label 4450 1600 0    60   ~ 0
PHI2OUT
Text Label 4450 1700 0    60   ~ 0
PHI1OUT
Text Label 4450 1800 0    60   ~ 0
nML
Text Label 4450 1900 0    60   ~ 0
RnW
Text Label 4450 2000 0    60   ~ 0
SYNC
Text Label 7250 1700 2    60   ~ 0
nRST
Text Label 7250 1800 2    60   ~ 0
RDY
Text Label 7250 1900 2    60   ~ 0
nSO
Text Label 7250 2000 2    60   ~ 0
nIRQ
Text Label 7250 2100 2    60   ~ 0
PHI2
Text Label 7250 2200 2    60   ~ 0
BE
Text Label 7250 2300 2    60   ~ 0
nNMI
NoConn ~ 6450 3200
$Comp
L 6502_adapter-rescue:CONN_01X03 P3
U 1 1 59760CE2
P 5150 1050
F 0 "P3" H 5150 1250 50  0000 C CNN
F 1 "CONN_01X03" V 5250 1050 50  0000 C CNN
F 2 "footprints:Pin_Header_Straight_1x03_Pitch2.00mm" H 5150 1050 50  0001 C CNN
F 3 "" H 5150 1050 50  0000 C CNN
	1    5150 1050
	0    -1   -1   0   
$EndComp
Text Label 5350 1250 0    60   ~ 0
GND
$Comp
L 6502_adapter-rescue:CONN_01X02 P4
U 1 1 5976110F
P 4300 2850
F 0 "P4" H 4300 3000 50  0000 C CNN
F 1 "CONN_01X02" V 4400 2850 50  0000 C CNN
F 2 "footprints:Pin_Header_Straight_1x02_Pitch2.00mm" H 4300 2850 50  0001 C CNN
F 3 "" H 4300 2850 50  0000 C CNN
	1    4300 2850
	-1   0    0    1   
$EndComp
Text Label 2550 3400 2    60   ~ 0
LV_A0
Text Label 2550 3500 2    60   ~ 0
LV_A1
Text Label 2550 3600 2    60   ~ 0
LV_A2
Text Label 2550 3700 2    60   ~ 0
LV_A3
Text Label 2550 3800 2    60   ~ 0
LV_A4
Text Label 2550 3900 2    60   ~ 0
LV_A5
Text Label 2550 4000 2    60   ~ 0
LV_A6
Text Label 2550 4100 2    60   ~ 0
LV_A7
Text Label 2550 4200 2    60   ~ 0
LV_OEAL
Text Label 2950 5150 2    60   ~ 0
LV_A15
Text Label 2950 5250 2    60   ~ 0
LV_A14
Text Label 2950 5350 2    60   ~ 0
LV_A13
Text Label 2950 5450 2    60   ~ 0
LV_A12
Text Label 2950 5550 2    60   ~ 0
LV_A8
Text Label 2950 5650 2    60   ~ 0
LV_A9
Text Label 2950 5750 2    60   ~ 0
LV_A10
Text Label 2950 5850 2    60   ~ 0
LV_A11
Text Label 2950 5950 2    60   ~ 0
LV_OEAH
Text Label 8800 3400 0    60   ~ 0
LV_OED
Text Label 8800 3500 0    60   ~ 0
LV_D0
Text Label 8800 3600 0    60   ~ 0
LV_D1
Text Label 8800 3700 0    60   ~ 0
LV_D2
Text Label 8800 3800 0    60   ~ 0
LV_D3
Text Label 8800 3900 0    60   ~ 0
LV_D4
Text Label 8800 4000 0    60   ~ 0
LV_D5
Text Label 8800 4100 0    60   ~ 0
LV_D6
Text Label 8800 4200 0    60   ~ 0
LV_D7
Text Label 8800 1600 0    60   ~ 0
GND
Text Label 8800 1800 0    60   ~ 0
LV_nRST
Text Label 8800 1900 0    60   ~ 0
LV_RDY
Text Label 8800 2000 0    60   ~ 0
LV_nSO
Text Label 8800 2100 0    60   ~ 0
LV_nIRQ
Text Label 8800 2200 0    60   ~ 0
LV_PHI2
Text Label 8800 2300 0    60   ~ 0
LV_BE
Text Label 8800 2400 0    60   ~ 0
LV_nNMI
NoConn ~ 8800 1700
NoConn ~ 7400 1600
NoConn ~ 4000 1300
NoConn ~ 4000 1400
NoConn ~ 2600 1300
Text Label 2600 2000 2    60   ~ 0
GND
Text Label 4000 2100 0    60   ~ 0
GND
Text Label 2600 1400 2    60   ~ 0
LV_nVP
Text Label 2600 1500 2    60   ~ 0
LV_PHI2OUT
Text Label 2600 1600 2    60   ~ 0
LV_PHI1OUT
Text Label 2600 1700 2    60   ~ 0
LV_nML
Text Label 2600 1800 2    60   ~ 0
LV_RnW
Text Label 2600 1900 2    60   ~ 0
LV_SYNC
$Comp
L 6502_adapter-rescue:R_Small R1
U 1 1 59761BB3
P 7050 1100
F 0 "R1" H 7080 1120 50  0000 L CNN
F 1 "4K7" H 7080 1060 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 7050 1100 50  0001 C CNN
F 3 "" H 7050 1100 50  0000 C CNN
	1    7050 1100
	1    0    0    -1  
$EndComp
Text Label 7050 900  2    60   ~ 0
5V
$Comp
L 6502_adapter-rescue:C_Small C1
U 1 1 597620E8
P 1100 6900
F 0 "C1" H 1110 6970 50  0000 L CNN
F 1 "100nF" H 1110 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1100 6900 50  0001 C CNN
F 3 "" H 1100 6900 50  0000 C CNN
	1    1100 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C2
U 1 1 5976220A
P 1400 6900
F 0 "C2" H 1410 6970 50  0000 L CNN
F 1 "100nF" H 1410 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1400 6900 50  0001 C CNN
F 3 "" H 1400 6900 50  0000 C CNN
	1    1400 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C3
U 1 1 59762254
P 1700 6900
F 0 "C3" H 1710 6970 50  0000 L CNN
F 1 "100nF" H 1710 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1700 6900 50  0001 C CNN
F 3 "" H 1700 6900 50  0000 C CNN
	1    1700 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C4
U 1 1 59762296
P 2000 6900
F 0 "C4" H 2010 6970 50  0000 L CNN
F 1 "100nF" H 2010 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 2000 6900 50  0001 C CNN
F 3 "" H 2000 6900 50  0000 C CNN
	1    2000 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C5
U 1 1 597622DF
P 2300 6900
F 0 "C5" H 2310 6970 50  0000 L CNN
F 1 "100nF" H 2310 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 2300 6900 50  0001 C CNN
F 3 "" H 2300 6900 50  0000 C CNN
	1    2300 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C7
U 1 1 597624D7
P 3250 6900
F 0 "C7" H 3260 6970 50  0000 L CNN
F 1 "100nF" H 3260 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 3250 6900 50  0001 C CNN
F 3 "" H 3250 6900 50  0000 C CNN
	1    3250 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C8
U 1 1 5976252A
P 3550 6900
F 0 "C8" H 3560 6970 50  0000 L CNN
F 1 "100nF" H 3560 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 3550 6900 50  0001 C CNN
F 3 "" H 3550 6900 50  0000 C CNN
	1    3550 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C9
U 1 1 59762588
P 3850 6900
F 0 "C9" H 3860 6970 50  0000 L CNN
F 1 "100nF" H 3860 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 3850 6900 50  0001 C CNN
F 3 "" H 3850 6900 50  0000 C CNN
	1    3850 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C10
U 1 1 597625E5
P 4150 6900
F 0 "C10" H 4160 6970 50  0000 L CNN
F 1 "100nF" H 4160 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 4150 6900 50  0001 C CNN
F 3 "" H 4150 6900 50  0000 C CNN
	1    4150 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:C_Small C11
U 1 1 59762645
P 4450 6900
F 0 "C11" H 4460 6970 50  0000 L CNN
F 1 "100nF" H 4460 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 4450 6900 50  0001 C CNN
F 3 "" H 4450 6900 50  0000 C CNN
	1    4450 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:CP1_Small C6
U 1 1 597630BE
P 2600 6900
F 0 "C6" H 2610 6970 50  0000 L CNN
F 1 "10uF" H 2610 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 2600 6900 50  0001 C CNN
F 3 "" H 2600 6900 50  0000 C CNN
	1    2600 6900
	1    0    0    -1  
$EndComp
$Comp
L 6502_adapter-rescue:CP1_Small C12
U 1 1 59763501
P 4750 6900
F 0 "C12" H 4760 6970 50  0000 L CNN
F 1 "10uF" H 4760 6820 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 4750 6900 50  0001 C CNN
F 3 "" H 4750 6900 50  0000 C CNN
	1    4750 6900
	1    0    0    -1  
$EndComp
Text Label 2600 6700 2    60   ~ 0
5V
Text Label 4750 6700 2    60   ~ 0
3V3
Text Label 2900 7100 2    60   ~ 0
GND
Text Label 10700 3100 0    60   ~ 0
LV_nRST
Text Label 10700 3200 0    60   ~ 0
LV_nSO
Text Label 10700 3300 0    60   ~ 0
LV_PHI2
Text Label 10700 3400 0    60   ~ 0
LV_nNMI
Text Label 10200 3200 2    60   ~ 0
LV_RDY
Text Label 10200 3300 2    60   ~ 0
LV_nIRQ
Text Label 10200 3400 2    60   ~ 0
LV_BE
Text Label 10700 4200 0    60   ~ 0
LV_D7
Text Label 10700 4100 0    60   ~ 0
LV_D5
Text Label 10700 4000 0    60   ~ 0
LV_D3
Text Label 10700 3900 0    60   ~ 0
LV_D1
Text Label 10200 4200 2    60   ~ 0
LV_D6
Text Label 10200 4100 2    60   ~ 0
LV_D4
Text Label 10200 4000 2    60   ~ 0
LV_D2
Text Label 10200 3900 2    60   ~ 0
LV_D0
NoConn ~ 10700 3000
NoConn ~ 10200 3000
Text Label 10700 3800 0    60   ~ 0
LV_OED
Text Label 1450 4650 0    60   ~ 0
LV_A15
Text Label 1450 4750 0    60   ~ 0
LV_A13
Text Label 1450 4850 0    60   ~ 0
LV_A8
Text Label 1450 4950 0    60   ~ 0
LV_A10
Text Label 950  4650 2    60   ~ 0
LV_A14
Text Label 950  4750 2    60   ~ 0
LV_A12
Text Label 950  4850 2    60   ~ 0
LV_A9
Text Label 950  4950 2    60   ~ 0
LV_A11
Text Label 1450 5050 0    60   ~ 0
LV_OEAH
Text Label 1450 3950 0    60   ~ 0
LV_A0
Text Label 1450 4050 0    60   ~ 0
LV_A2
Text Label 1450 4150 0    60   ~ 0
LV_A4
Text Label 1450 4250 0    60   ~ 0
LV_A6
Text Label 1450 4350 0    60   ~ 0
LV_OEAL
Text Label 950  3950 2    60   ~ 0
LV_A1
Text Label 950  4050 2    60   ~ 0
LV_A3
Text Label 950  4150 2    60   ~ 0
LV_A5
Text Label 950  4250 2    60   ~ 0
LV_A7
NoConn ~ 950  5050
NoConn ~ 950  4450
NoConn ~ 950  4350
NoConn ~ 1450 4450
NoConn ~ 1450 3750
NoConn ~ 1450 3850
NoConn ~ 950  3850
NoConn ~ 950  3750
NoConn ~ 10200 3100
NoConn ~ 10200 3600
NoConn ~ 10700 3600
NoConn ~ 10700 3700
NoConn ~ 10200 3700
NoConn ~ 10200 3800
NoConn ~ 10200 4300
NoConn ~ 10200 4500
NoConn ~ 10200 4600
NoConn ~ 10200 4700
NoConn ~ 10200 4800
NoConn ~ 10200 4900
NoConn ~ 10700 4300
NoConn ~ 10700 4500
NoConn ~ 10700 4600
NoConn ~ 10700 4700
NoConn ~ 10700 4800
NoConn ~ 10700 4900
NoConn ~ 2600 1200
Text Label 950  3550 2    60   ~ 0
LV_SYNC
Text Label 950  3450 2    60   ~ 0
LV_nML
Text Label 950  3350 2    60   ~ 0
LV_PHI2OUT
Text Label 1450 3550 0    60   ~ 0
LV_RnW
Text Label 1450 3450 0    60   ~ 0
LV_PHI1OUT
Text Label 1450 3350 0    60   ~ 0
LV_nVP
NoConn ~ 950  3250
NoConn ~ 950  3150
NoConn ~ 1450 3150
NoConn ~ 1450 3250
$Comp
L power:PWR_FLAG #FLG01
U 1 1 597673C3
P 1100 6700
F 0 "#FLG01" H 1100 6795 50  0001 C CNN
F 1 "PWR_FLAG" H 1100 6880 50  0000 C CNN
F 2 "" H 1100 6700 50  0000 C CNN
F 3 "" H 1100 6700 50  0000 C CNN
	1    1100 6700
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG02
U 1 1 59767405
P 3250 6700
F 0 "#FLG02" H 3250 6795 50  0001 C CNN
F 1 "PWR_FLAG" H 3250 6880 50  0000 C CNN
F 2 "" H 3250 6700 50  0000 C CNN
F 3 "" H 3250 6700 50  0000 C CNN
	1    3250 6700
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG03
U 1 1 59767675
P 800 7100
F 0 "#FLG03" H 800 7195 50  0001 C CNN
F 1 "PWR_FLAG" H 800 7280 50  0000 C CNN
F 2 "" H 800 7100 50  0000 C CNN
F 3 "" H 800 7100 50  0000 C CNN
	1    800  7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 3400 7400 3400
Wire Wire Line
	6450 3500 7400 3500
Wire Wire Line
	6450 3600 7400 3600
Wire Wire Line
	6450 3700 7400 3700
Wire Wire Line
	6450 3800 7400 3800
Wire Wire Line
	6450 3900 7400 3900
Wire Wire Line
	6450 4000 7400 4000
Wire Wire Line
	6450 4100 7400 4100
Wire Wire Line
	5150 3500 3950 3500
Wire Wire Line
	3950 3600 5150 3600
Wire Wire Line
	5150 3700 3950 3700
Wire Wire Line
	3950 3800 5150 3800
Wire Wire Line
	3950 3900 5150 3900
Wire Wire Line
	3950 4000 5150 4000
Wire Wire Line
	3950 4100 5150 4100
Wire Wire Line
	3950 4200 5150 4200
Wire Wire Line
	5150 4300 4850 4300
Wire Wire Line
	5150 4400 4950 4400
Wire Wire Line
	5150 4500 5050 4500
Wire Wire Line
	6450 4500 6650 4500
Wire Wire Line
	6450 4400 6750 4400
Wire Wire Line
	6450 4300 6850 4300
Wire Wire Line
	6450 4200 6950 4200
Wire Wire Line
	6450 2800 6550 2800
Wire Wire Line
	6550 2800 6550 1600
Wire Wire Line
	6550 1600 4000 1600
Wire Wire Line
	5150 2900 4950 2900
Wire Wire Line
	4950 2900 4950 1700
Wire Wire Line
	4950 1700 4000 1700
Wire Wire Line
	6450 3300 6650 3300
Wire Wire Line
	5150 3300 4550 3300
Wire Wire Line
	4550 3300 4550 2000
Wire Wire Line
	6450 2700 6750 2700
Wire Wire Line
	6750 2700 6750 1700
Wire Wire Line
	6750 1700 7400 1700
Wire Wire Line
	5150 2800 5050 2800
Wire Wire Line
	5050 2800 5050 1800
Wire Wire Line
	5050 1800 7400 1800
Wire Wire Line
	6450 2900 6850 2900
Wire Wire Line
	6850 2900 6850 1900
Wire Wire Line
	6850 1900 7400 1900
Wire Wire Line
	5150 3000 4850 3000
Wire Wire Line
	4850 3000 4850 2000
Wire Wire Line
	4850 2000 7400 2000
Wire Wire Line
	6450 3000 6950 3000
Wire Wire Line
	6950 3000 6950 2100
Wire Wire Line
	6950 2100 7400 2100
Wire Wire Line
	6450 3100 7050 3100
Wire Wire Line
	7050 3100 7050 2200
Wire Wire Line
	7050 2200 7400 2200
Wire Wire Line
	5150 3200 4650 3200
Wire Wire Line
	4650 3200 4650 2300
Wire Wire Line
	4650 2300 7400 2300
Wire Wire Line
	4550 2000 4000 2000
Wire Wire Line
	6650 1900 4000 1900
Wire Wire Line
	6650 3300 6650 1900
Wire Wire Line
	5050 1500 5050 1250
Wire Wire Line
	5150 1250 5150 2700
Wire Wire Line
	5250 1250 5350 1250
Wire Wire Line
	4000 1500 5050 1500
Wire Wire Line
	5150 3100 4750 3100
Wire Wire Line
	4750 3100 4750 2900
Wire Wire Line
	4750 2900 4500 2900
Wire Wire Line
	4500 2800 4750 2800
Wire Wire Line
	4750 2800 4750 1800
Wire Wire Line
	4750 1800 4000 1800
Connection ~ 6650 3300
Wire Wire Line
	7050 1000 7050 900 
Wire Wire Line
	1100 7000 1100 7100
Wire Wire Line
	800  7100 1100 7100
Wire Wire Line
	4450 7100 4450 7000
Wire Wire Line
	4150 7000 4150 7100
Connection ~ 4150 7100
Wire Wire Line
	3850 7000 3850 7100
Connection ~ 3850 7100
Wire Wire Line
	3550 7000 3550 7100
Connection ~ 3550 7100
Wire Wire Line
	3250 7000 3250 7100
Connection ~ 3250 7100
Wire Wire Line
	2300 7000 2300 7100
Connection ~ 2300 7100
Wire Wire Line
	2000 7000 2000 7100
Connection ~ 2000 7100
Wire Wire Line
	1700 7000 1700 7100
Connection ~ 1700 7100
Wire Wire Line
	1400 7000 1400 7100
Connection ~ 1400 7100
Wire Wire Line
	1100 6800 1100 6700
Wire Wire Line
	1100 6700 1400 6700
Wire Wire Line
	2300 6700 2300 6800
Wire Wire Line
	2000 6800 2000 6700
Connection ~ 2000 6700
Wire Wire Line
	1700 6800 1700 6700
Connection ~ 1700 6700
Wire Wire Line
	1400 6800 1400 6700
Connection ~ 1400 6700
Wire Wire Line
	3250 6800 3250 6700
Wire Wire Line
	3250 6700 3550 6700
Wire Wire Line
	4450 6700 4450 6800
Wire Wire Line
	4150 6800 4150 6700
Connection ~ 4150 6700
Wire Wire Line
	3850 6800 3850 6700
Connection ~ 3850 6700
Wire Wire Line
	3550 6800 3550 6700
Connection ~ 3550 6700
Wire Wire Line
	2600 6700 2600 6800
Connection ~ 2300 6700
Wire Wire Line
	2600 7000 2600 7100
Connection ~ 2600 7100
Wire Wire Line
	4750 6700 4750 6800
Connection ~ 4450 6700
Wire Wire Line
	4750 7100 4750 7000
Connection ~ 4450 7100
Connection ~ 1100 7100
Wire Wire Line
	7400 1500 7050 1500
Wire Wire Line
	7050 1500 7050 1200
Wire Wire Line
	4350 5250 6950 5250
Wire Wire Line
	6950 5250 6950 4200
Wire Wire Line
	6850 4300 6850 5350
Wire Wire Line
	6850 5350 4350 5350
Wire Wire Line
	6750 4400 6750 5450
Wire Wire Line
	6750 5450 4350 5450
Wire Wire Line
	4350 5550 6650 5550
Wire Wire Line
	6650 5550 6650 4500
Wire Wire Line
	4850 4300 4850 5650
Wire Wire Line
	4850 5650 4350 5650
Wire Wire Line
	4350 5750 4950 5750
Wire Wire Line
	4950 5750 4950 4400
Wire Wire Line
	5050 4500 5050 5850
Wire Wire Line
	5050 5850 4350 5850
Wire Wire Line
	5150 4600 5150 5950
Wire Wire Line
	5150 5950 4350 5950
Wire Wire Line
	6650 3300 7400 3300
Wire Wire Line
	4150 7100 4450 7100
Wire Wire Line
	3250 7100 3550 7100
Wire Wire Line
	2300 7100 2600 7100
Wire Wire Line
	2000 7100 2300 7100
Wire Wire Line
	1700 7100 2000 7100
Wire Wire Line
	1400 7100 1700 7100
Wire Wire Line
	2000 6700 2300 6700
Wire Wire Line
	1700 6700 2000 6700
Wire Wire Line
	1400 6700 1700 6700
Wire Wire Line
	4150 6700 4450 6700
Wire Wire Line
	3850 6700 4150 6700
Wire Wire Line
	3550 6700 3850 6700
Wire Wire Line
	2300 6700 2600 6700
Wire Wire Line
	2600 7100 3250 7100
Wire Wire Line
	4450 6700 4750 6700
Wire Wire Line
	4450 7100 4750 7100
Wire Wire Line
	1100 7100 1400 7100
Wire Wire Line
	3550 7100 4150 7100
$EndSCHEMATC
