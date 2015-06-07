#ifndef HD44780_SETTINGS_H
#define HD44780_SETTINGS_H

// This is done in the makefile
// #define F_CPU                    15855484     // Set Clock Frequency

#define USE_ADELAY_LIBRARY       0           // Set to 1 to use my ADELAY library, 0 to use internal delay functions
#define LCD_BITS                 4           // 4 for 4 Bit I/O Mode, 8 for 8 Bit I/O Mode
#define RW_LINE_IMPLEMENTED      1           // 0 for no RW line (RW on LCD tied to ground), 1 for RW line present
#define WAIT_MODE                1           // 0=Use Delay Method (Faster if running <10Mhz)
                                             // 1=Use Check Busy Flag (Faster if running >10Mhz) ***Requires RW Line***
#define DELAY_RESET              15          // in mS

#if (LCD_BITS==8)                            // If using 8 bit mode, you must configure DB0-DB7
  #define LCD_DB0_PORT           PORTA
  #define LCD_DB0_PIN            0
  #define LCD_DB1_PORT           PORTA
  #define LCD_DB1_PIN            1
  #define LCD_DB2_PORT           PORTA
  #define LCD_DB2_PIN            2
  #define LCD_DB3_PORT           PORTA
  #define LCD_DB3_PIN            3
#endif
#define LCD_DB4_PORT             PORTA       // If using 4 bit omde, yo umust configure DB4-DB7
#define LCD_DB4_PIN              4
#define LCD_DB5_PORT             PORTA
#define LCD_DB5_PIN              5
#define LCD_DB6_PORT             PORTA
#define LCD_DB6_PIN              6
#define LCD_DB7_PORT             PORTA
#define LCD_DB7_PIN              7

#define LCD_RS_PORT              PORTA       // Port for RS line
#define LCD_RS_PIN               0           // Pin for RS line

#define LCD_RW_PORT              PORTA       // Port for RW line (ONLY used if RW_LINE_IMPLEMENTED=1)
#define LCD_RW_PIN               1           // Pin for RW line (ONLY used if RW_LINE_IMPLEMENTED=1)

#define LCD_DISPLAYS             1           // Up to 4 LCD displays can be used at one time
                                             // All pins are shared between displays except for the E
                                             // pin which each display will have its own

                                             // Display 1 Settings - if you only have 1 display, YOU MUST SET THESE
#define LCD_DISPLAY_LINES        1           // Number of Lines, Only Used for Set I/O Mode Command
#define LCD_E_PORT               PORTA       // Port for E line
#define LCD_E_PIN                2           // Pin for E line

#endif

