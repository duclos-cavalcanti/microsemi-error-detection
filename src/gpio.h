#ifndef GPIO_H_
#define GPIO_H_

#include "main.h"

typedef enum LED {
  LED_0 = 0,
  LED_1 = 1,
  LED_2 = 2,
  LED_3 = 3,
} LED_t;

typedef enum SW {
  SW_0 = 0,
  SW_1 = 1,
} SW_t;

static const mss_gpio_id_t LEDS[8] = {
    MSS_GPIO_0, MSS_GPIO_1, MSS_GPIO_2, MSS_GPIO_3,
};

static long unsigned int LED_MASKS[4] = {
    MSS_GPIO_0_MASK, MSS_GPIO_1_MASK, MSS_GPIO_2_MASK, MSS_GPIO_3_MASK,
};

static const mss_gpio_id_t SWS[2] = {
    MSS_GPIO_4, MSS_GPIO_5,
};

static long unsigned int SW_MASKS[2] = {
    MSS_GPIO_4_MASK, MSS_GPIO_5_MASK,
};

static const mss_gpio_id_t DECODED_FLAG = MSS_GPIO_6;
static long unsigned int   DECODED_FLAG_MASK = MSS_GPIO_6_MASK;

#define LED_TOGGLE(CHAR)  led_toggle(CHAR)
#define LED_ON(CHAR)      led_on(CHAR)
#define LED_OFF(CHAR)     led_off(CHAR)

void led_on(LED_t LED_INDEX);
void led_off(LED_t LED_INDEX);

uint32_t gpio_led_state(LED_t LED_INDEX);
uint32_t gpio_sw_state(SW_t SW_INDEX);

uint32_t gpio_inputs(void);
uint32_t gpio_outputs(void);

void gpio_set_all(uint32_t gpio_outs);

#endif /* GPIO_H_ */
