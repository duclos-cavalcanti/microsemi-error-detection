#ifndef MAIN_H_
#define MAIN_H_

// APB
#include "hal/hal.h"
#include "project_apb_hw_platform.h"

// UART
#include <stdio.h>
#include "CMSIS/system_m2sxxx.h"
#include "drivers/mss_uart/mss_uart.h"

// GPIO functions
#include "drivers/mss_gpio/mss_gpio.h"

// Timers
#include "drivers/mss_timer/mss_timer.h"

// Startup configuration + SystemCoreClock etc.
#include "CMSIS/system_m2sxxx.h"

#define NUM_LEDS 4
#define NUM_SWS  2

#define RX_SIZE 1
#define TX_SIZE 3000
#define IMAGE_SIZE (16 * 12)

#define PAYLOAD_TOTAL 12
#define PAYLOAD_LENGTH 16


static __INLINE void
delay100ms
(
    unsigned int delay
)
{
    unsigned int ms_index = delay;
    volatile uint32_t delay_count;

    while (ms_index > 0) {
    	  ms_index--;
    	  delay_count = ( SystemCoreClock / 128u );
    	  while(delay_count > 0u) { --delay_count; }
    }
}

typedef enum state {
  INIT,
  IDLE,
  RX_IMAGE,
  TX_IMAGE,
  DECODE,
  FETCH,
  DONE,
  FAULT,
} state_t;

#define SLAVE_IDLE      0x00000000
#define MASTER_WRITE    0x00000001
#define SLAVE_DECODE    0x00000002
#define MASTER_READ     0x00000003
#define SLAVE_END       0x00000004

typedef struct slave {
    uint32_t  state;
    uint32_t  data;
    uint32_t  tx_cnt;
} slave_t;

typedef struct system {
    uint32_t  poll;
    state_t   state;

    uint8_t   LEDS[4];
    uint8_t   ld_idx;

    uint8_t   b1_flag;
    uint8_t   b2_flag;
    uint8_t   b1_cnt;
    uint8_t   b2_cnt;

    uint8_t   tx_buf[TX_SIZE];
    uint8_t   rx_buf[RX_SIZE];
    uint8_t   rx_cnt;
    uint8_t   rx_err;

    slave_t slave;

    uint8_t   image[IMAGE_SIZE];
    uint16_t  image_bits[PAYLOAD_TOTAL];
    uint16_t  image_err_bits[PAYLOAD_TOTAL];
    uint16_t  image_dec_bits[PAYLOAD_TOTAL];
} system_t;

#endif /* MAIN_H_ */
