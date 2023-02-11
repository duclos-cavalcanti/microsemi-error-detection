#include "util.h"

int sprintf_uart16(uint8_t* buf, int* size, uint16_t value) {
    uint16_t lsb = 0;
    int len = snprintf(buf, *size, "[");
    buf += len;
    *size -= len;
    for (int k=16-1; k>=0; k--) {
        lsb = ((value >> k) & 0x0001);
        len = snprintf(buf, *size, "%d", lsb);
        buf += len;
        *size -= len;
        }
    len = snprintf(buf, *size, "]");
    buf += len;
    *size -= len;
    return *(size);
}
