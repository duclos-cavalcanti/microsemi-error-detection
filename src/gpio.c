#include "gpio.h"

void led_on(LED_t LED_INDEX) {
    MSS_GPIO_set_output(LEDS[LED_INDEX], 0);
}

void led_off(LED_t LED_INDEX) {
    MSS_GPIO_set_output(LEDS[LED_INDEX], 1);
}

void led_toggle(LED_t LED_INDEX) {
    if (gpio_led_state(LED_INDEX))
        led_off(LED_INDEX);
    else
        led_on(LED_INDEX);
}

uint32_t gpio_led_state(LED_t LED_INDEX) {
    return ( ((~gpio_outputs()) & LED_MASKS[LED_INDEX]) >> LED_INDEX ) == 0x01;
}

uint32_t gpio_sw_state(SW_t SW_INDEX) {
    return ( ((gpio_inputs()) & SW_MASKS[SW_INDEX]) >> (SW_INDEX + 8) ) == 0x01;
}

uint32_t gpio_inputs(void) {
    return ( MSS_GPIO_get_inputs() );
}

uint32_t gpio_outputs(void) {
    return ( MSS_GPIO_get_outputs() );
}

void gpio_set_all(uint32_t gpio_outs) {
    MSS_GPIO_set_outputs(gpio_outs);
}

