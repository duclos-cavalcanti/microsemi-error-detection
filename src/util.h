#ifndef __UTIL__H
#define __UTIL__H

#include "main.h"

#define EMPTY_SPACE ' '

int sprintf_uart16(uint8_t* buf, int* size, uint16_t value);
int sprintf_char_array(uint8_t* buf, int* total, const char* str);

#endif /* __UTIL__H */
