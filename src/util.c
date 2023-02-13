#include "util.h"


int sprintf_char_array(uint8_t* buf, int* total, const char* str) {
    int len;
    buf += (len = snprintf(buf, *(total), str));
    *(total) -= len;

    return (*(total) > 0) && (len > 0);
}

int sprintf_uart16(uint8_t* buf, int* total, uint16_t val) {
    int len;
    buf += (len = snprintf(buf, *(total), "["));
    *(total) -= len;

    for (int k=15; k>=0; k--) {
        uint16_t lsb = ((val >> k) & 0x0001);
        buf += (len = snprintf(buf, *(total), "%d", lsb));
        *(total) -= len;
    }

    buf += (len = snprintf(buf, *(total), "]"));
    *(total) -= len;

    return (*(total) > 0);
}
