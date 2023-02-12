#ifndef UART_H_
#define UART_H_

#include "main.h"

int uart_tx_write(const uint8_t msg[]);
int uart_rx_poll(uint32_t* rx_idx, uint8_t rx_buf[], size_t rx_size);

void uart_disable_irq(void);

#endif /* UART_H_ */
