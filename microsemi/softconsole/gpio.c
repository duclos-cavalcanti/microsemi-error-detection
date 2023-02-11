#include "gpio.h"

void gpio_led_on(LED_t LED_INDEX) {
    MSS_GPIO_set_output(LEDS[LED_INDEX], 0);
}

void gpio_led_off(LED_t LED_INDEX) {
    MSS_GPIO_set_output(LEDS[LED_INDEX], 1);
}

void gpio_led_toggle(LED_t LED_INDEX) {
    if (gpio_led_state(LED_INDEX)) gpio_led_off(LED_INDEX);
    else gpio_led_on(LED_INDEX);
}

uint32_t gpio_led_state(LED_t LED_INDEX) {
    return ( ((~gpio_outputs()) & LED_MASKS[LED_INDEX]) >> LED_INDEX ) == 0x01;
}

uint32_t gpio_sw_state(SW_t SW_INDEX) {
    return ( ((gpio_inputs()) & SW_MASKS[SW_INDEX]) >> (SW_INDEX + 8) ) == 0x01;
}

void gpio_led_set(LED_t LED_INDEX, LED_ACTION_t ACTION) {
    if (ACTION == LED_ON) gpio_led_on(LED_INDEX);
    else gpio_led_off(LED_INDEX);
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

void gpio_setup(void) {
    // Initialize SmartFusion MSS GPIOs
    MSS_GPIO_init();

    // Configure MSS GPIOs LEDs
    MSS_GPIO_config( LEDS[0] , MSS_GPIO_OUTPUT_MODE );
    MSS_GPIO_config( LEDS[1] , MSS_GPIO_OUTPUT_MODE );
    MSS_GPIO_config( LEDS[2] , MSS_GPIO_OUTPUT_MODE );
    MSS_GPIO_config( LEDS[3] , MSS_GPIO_OUTPUT_MODE );
    MSS_GPIO_set_output(LEDS[0], 1);
    MSS_GPIO_set_output(LEDS[1], 1);
    MSS_GPIO_set_output(LEDS[2], 1);
    MSS_GPIO_set_output(LEDS[3], 1);

    // Switches/Buttons
    MSS_GPIO_config( SWS[0] , MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE );
    MSS_GPIO_config( SWS[1] , MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE );
    MSS_GPIO_enable_irq(SWS[0]);
    MSS_GPIO_enable_irq(SWS[1]);

    // Extra pins
    MSS_GPIO_config( CALL_PIN , MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE );
    MSS_GPIO_enable_irq(CALL_PIN);
}
