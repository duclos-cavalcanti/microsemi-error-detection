#include "injection.h"

uint16_t image_inject_err(uint16_t image_payload) {
    uint16_t copy = image_payload;
    return (copy & 0xFFFE);
}

uint16_t image_transform_bytes(uint8_t* image) {
    uint16_t data = 0x0000;
    for (int i=0; i<16;i++) {
        uint16_t value = *(image + i);
        if (value)  data |= 0x0001;
        if (i < 15) data = data << 1;
    }

    return data;
}
