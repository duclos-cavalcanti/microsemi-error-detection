#include "uart.h"

int uart_tx_write(const uint8_t msg[]) {
    MSS_UART_polled_tx_string(&g_mss_uart0, msg);
    return 0;
}

int uart_rx_poll(uint32_t* rx_idx, uint8_t rx_buf[], size_t rx_size) {
    *rx_idx = MSS_UART_get_rx(&g_mss_uart0, rx_buf, rx_size);
    return ((*rx_idx) > 0);
}

void uart_disable_irq(void) {
    MSS_UART_disable_irq(&g_mss_uart0 ,0x111);
}

