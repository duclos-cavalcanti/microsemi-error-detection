#ifndef UART_H_
#define UART_H_

#include "main.h"

typedef void (*uart_handler)( mss_uart_instance_t * uart);

void uart_setup(uart_handler handler);
int uart_tx_write(const uint8_t msg[]);
int uart_rx_poll(uint32_t* rx_idx, uint8_t rx_buf[], size_t rx_size);

typedef struct name {

} name_t;


#endif /* UART_H_ */
