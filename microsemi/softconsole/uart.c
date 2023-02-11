#include "uart.h"

void uart_setup(uart_handler handler) {
    // Initialize SmartFusion UART
    MSS_UART_init(&g_mss_uart0,
                  MSS_UART_57600_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

    MSS_UART_set_rx_handler(&g_mss_uart0,
                            handler,
                            MSS_UART_FIFO_SINGLE_BYTE);
}
void uart_disable(void) {
    MSS_UART_disable_irq(&g_mss_uart0 ,0x111);
}

int uart_rx_poll(uint32_t* rx_idx, uint8_t rx_buf[], size_t rx_size) {
    *rx_idx = MSS_UART_get_rx(&g_mss_uart0, rx_buf, rx_size);
    return ((*rx_idx) > 0);
}

int uart_tx_write(const uint8_t msg[]) {
    MSS_UART_polled_tx_string(&g_mss_uart0, msg);
    return 0;
}
