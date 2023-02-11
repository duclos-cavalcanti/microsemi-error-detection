// ==============================================================================
// Includes
#include "main.h"
#include "uart.h"
#include "gpio.h"
#include "timer.h"
#include "injection.h"

// ==============================================================================
// Prototypes and globals
void system_update(void);
void system_fsm(void);
int  system_snapshot(void);

void UART0_RX_IRQHandler(mss_uart_instance_t * uart);

system_t S = { 0 };

#define SYS_STATE(STATE)                (S.state == STATE)
#define SYS_WRITE_SLAVE(DATA, OFFSET)   HW_set_32bit_reg(EC_SLAVE_0 + 4 +  (OFFSET * 4), (uint32_t) DATA)
#define SYS_READ_SLAVE(OFFSET)          HW_get_32bit_reg(EC_SLAVE_0 + 4 +  (OFFSET * 4))
#define SLAVE_STATE()                   HW_get_32bit_reg(EC_SLAVE_0 + 0)
#define SLAVE_STATE_SET(DATA)           HW_set_32bit_reg(EC_SLAVE_0 , (uint32_t) DATA)

// ==============================================================================
// main
int main() {
    SystemInit();
    uart_setup(UART0_RX_IRQHandler);
    gpio_setup();
    timer1_setup(MSS_TIMER_PERIODIC_MODE, (g_FrequencyPCLK0 * 1.5) ); // 1.5 second
    timer2_setup(MSS_TIMER_PERIODIC_MODE, (g_FrequencyPCLK0 * 0.5) ); // 1 second

    S.state = INIT;

    while(1) {
        system_fsm();
    }

    return 0;
}

// ==============================================================================
void system_update() {
    S.LEDS[0] = gpio_led_state(LED_0);
    S.LEDS[1] = gpio_led_state(LED_1);
    S.LEDS[2] = gpio_led_state(LED_2);
    S.LEDS[3] = gpio_led_state(LED_3);
}

void system_fsm() {
    static int cnt = 0;
    system_update();

    switch(S.state) {
        case INIT:
            S.poll          = 0;
            S.b1_flag       = 0;
            S.b2_flag       = 0;
            S.b1_cnt        = 0;
            S.b2_cnt        = 0;
            S.rx_cnt        = 0;
            S.rx_err        = 0;
            S.ld_idx        = LED_3;

            S.slave.state           = 0xFFFFFFFF;
            S.slave.data            = 0x00000000;
            S.slave.tx_cnt          = 0;

            LED_ON(S.ld_idx);
            S.state = IDLE;
            break;

        case IDLE:
            if (S.rx_cnt > 0 && S.rx_err != 1) {
                S.state = RX_IMAGE;
                LED_OFF(S.ld_idx);
                LED_ON((--S.ld_idx));
            } else if (S.rx_err) {
                S.state = FAULT;
            }
            break;

        case RX_IMAGE:
            if (S.rx_cnt == (PAYLOAD_LENGTH*PAYLOAD_TOTAL)) {
                S.state = TX_IMAGE;
                LED_OFF(S.ld_idx);
                LED_ON((--S.ld_idx));
            }
            break;

        case TX_IMAGE:
            if (S.slave.tx_cnt == (PAYLOAD_TOTAL)) {
                S.state = DECODE;
                SLAVE_STATE_SET(SLAVE_DECODING);
                LED_OFF(S.ld_idx);
                LED_ON((--S.ld_idx));
            }
            break;

        case DECODE:
            if (SLAVE_STATE() == SLAVE_FINISHED) {
                S.state = FETCH;
                LED_OFF(S.ld_idx);
                LED_ON(LED_0);
                LED_ON(LED_1);
            }
            break;

        case FETCH:
            for (int i=0; i<PAYLOAD_TOTAL; i++) {
                delay100ms(2);
                uint32_t data = SYS_READ_SLAVE(i);
                data = data >> 16;
                S.image_dec_bits[i] = (0x0000FFFF & data);
            }
            SLAVE_STATE_SET(SLAVE_END);

            S.state = END;
            break;

        case END:
            LED_ON(LED_0);
            LED_ON(LED_1);
            LED_ON(LED_2);
            LED_ON(LED_3);
            break;

        case FAULT:
            LED_OFF(LED_0);
            LED_OFF(LED_1);
            LED_OFF(LED_2);
            LED_OFF(LED_3);
            break;

        default:
            break;
    }
    if (S.b1_flag) { S.b1_flag = 0; }
    if (S.b2_flag) { S.b2_flag = 0; }
}

#define EMPTY_SPACE ' '
int system_snapshot() {
    uint8_t* buf = S.tx_buf;
    int total = sizeof(S.tx_buf);
    uint16_t payload, payload_err, payload_dec;

    int len = snprintf(buf, total,
                   "POLL[%d]\n\r"
                   "------\n\r"
                   "SW1:  %d   \t| %dx\n\r"
                   "SW2:  %d   \t| %dx\n\r"
                   "LEDS[4-7]: \t| [%d%d%d%d]\n\r"
                   "UART[%d]:  \t| Bytes: [%d]\n\r"
                   "SLAVE[%d]  \t| 0x%08x:\n\r"
                   "CURRENT PAYLOAD:\n\r"
                   "-------------------------------------------------------\n\r",
                   ++S.poll,
                   S.b1_flag,
                   S.b1_cnt,
                   S.b2_flag,
                   S.b2_cnt,
                   S.LEDS[0], S.LEDS[1], S.LEDS[2], S.LEDS[3],
                   (S.rx_cnt/16),
                   S.rx_cnt,
                   S.slave.tx_cnt,
                   S.slave.data
                   );

    buf += len;
    total -= len;

    len = snprintf(buf, total, "IMAGE BITS%*cIMAGE ERR BITS%*cIMAGE DEC BITS\n\r",
                   (21 - 10),  EMPTY_SPACE,
                   (21 - 14),  EMPTY_SPACE);
    buf += len;
    total -= len;

    for (int i=0; i<PAYLOAD_TOTAL; i++) {
        payload     = *(S.image_bits + i);
        payload_err = *(S.image_err_bits + i);
        payload_dec = *(S.image_dec_bits + i);

        len = snprintf(buf, total, "[");
        buf += len;
        total -= len;

        for (int k=PAYLOAD_LENGTH-1; k>=0; k--) {
            uint16_t lsb = ((payload >> k) & 0x0001);
            len = snprintf(buf, total, "%d", lsb);
            buf += len;
            total -= len;
        }

        len = snprintf(buf, total, "] | [");
        buf += len;
        total -= len;

        for (int l=PAYLOAD_LENGTH-1; l>=0; l--) {
            uint16_t lsb = ((payload_err >> l) & 0x0001);
            len = snprintf(buf, total, "%d", lsb);
            buf += len;
            total -= len;
        }

        len = snprintf(buf, total, "] | [");
        buf += len;
        total -= len;

        for (int j=PAYLOAD_LENGTH-1; j>=0; j--) {
            uint16_t lsb = ((payload_dec >> j) & 0x0001);
            len = snprintf(buf, total, "%d", lsb);
            buf += len;
            total -= len;
        }

        len = snprintf(buf, total, "]\n\r");
        buf += len;
        total -= len;
    }

    len += snprintf(buf + len, total - len,
                   "-------------------------------------------------------\n\r",
                   "\n");

    return (total > 0);
}

// interrupt handlers
// timer1 handler for uart transmission
void Timer1_IRQHandler(void) {
    if (system_snapshot()) {
        uart_tx_write(S.tx_buf);
    }
    MSS_TIM1_clear_irq();
}

// timer2 handler
void Timer2_IRQHandler(void) {
    if (SYS_STATE(TX_IMAGE)) {
        // write to slave
        if (SLAVE_STATE() == SLAVE_IDLE) {
            SLAVE_STATE_SET(SLAVE_WRITE);
        } else {
            if (S.slave.tx_cnt < PAYLOAD_TOTAL) {
                SYS_WRITE_SLAVE( (S.slave.data = S.image_err_bits[S.slave.tx_cnt]), S.slave.tx_cnt);
                S.slave.tx_cnt++;
            }
        }
    }
    MSS_TIM2_clear_irq();
}

// uart rx handler
void UART0_RX_IRQHandler(mss_uart_instance_t * uart) {
    uint32_t rx_size  = 0;
    uint8_t* buf  = NULL;
    uint8_t byte  = 0;

    if (MSS_UART_NO_ERROR == MSS_UART_get_rx_status(&g_mss_uart0)) {
        if ( (rx_size = MSS_UART_get_rx(&g_mss_uart0, S.rx_buf, sizeof(S.rx_buf)) ) > 0) {
            if (S.rx_cnt < sizeof(S.image)) {
                for (int i=0; i<rx_size; i++) {
                    buf =  (S.image + (S.rx_cnt++) + i);
                    byte = *(S.rx_buf + i);
                    if (byte == '1') *buf = 0x01;
                    else if (byte == '0') *buf = 0x00;
                    else S.rx_err = 1;

                    if ((S.rx_cnt%16) == 0) {
                        int j = (S.rx_cnt/16) - 1;
                        S.image_bits[j] = image_transform_bytes(&S.image[S.rx_cnt - 16]);
                        S.image_err_bits[j] = image_inject_err(S.image_bits[j]);
                    }
                }
            } else {
                // should disable IRQ
            }
        }
    }
}

// switch 1 handler
void GPIO4_IRQHandler(void) {
    S.b1_flag = 1;
    ++S.b1_cnt;
    MSS_GPIO_clear_irq( MSS_GPIO_4 );
}

// switch 2 handler
void GPIO5_IRQHandler(void) {
    S.b2_flag = 1;
    ++S.b2_cnt;
    MSS_GPIO_clear_irq( MSS_GPIO_5 );
}

// EXTRA PIN
void GPIO6_IRQHandler(void) {
    MSS_GPIO_clear_irq( MSS_GPIO_6 );
}
