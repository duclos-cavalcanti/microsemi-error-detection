#ifndef GPIO_H_
#define GPIO_H_

#include "main.h"

typedef enum LED {
  LED_0 = 0,
  LED_1 = 1,
  LED_2 = 2,
  LED_3 = 3,
} LED_t;

typedef enum LED_ACTION {
  LED_ON,
  LED_OFF,
} LED_ACTION_t;

typedef enum SW {
  SW_0 = 0,
  SW_1 = 1,
} SW_t;

static const mss_gpio_id_t LEDS[8] = {
    MSS_GPIO_0, MSS_GPIO_1, MSS_GPIO_2, MSS_GPIO_3,
};

static long unsigned int LED_MASKS[8] = {
    MSS_GPIO_0_MASK, MSS_GPIO_1_MASK, MSS_GPIO_2_MASK, MSS_GPIO_3_MASK,
};

static const mss_gpio_id_t SWS[2] = {
    MSS_GPIO_4, MSS_GPIO_5,
};

static long unsigned int SW_MASKS[2] = {
    MSS_GPIO_4_MASK, MSS_GPIO_5_MASK,
};

static const mss_gpio_id_t     CALL_PIN             =  MSS_GPIO_6;
static const long unsigned int CALL_PIN_MASK        =  MSS_GPIO_6_MASK;

static const mss_gpio_id_t     READ_PIN             =  MSS_GPIO_7;
static const long unsigned int READ_PIN_MASK        =  MSS_GPIO_7_MASK;;

#define LED_TOGGLE(CHAR)  gpio_led_toggle(CHAR)
#define LED_ON(CHAR)      gpio_led_set(CHAR, LED_ON)
#define LED_OFF(CHAR)     gpio_led_set(CHAR, LED_OFF)

#define READ_PIN_HIGH()   MSS_GPIO_set_output(READ_PIN, 1)
#define READ_PIN_LOW()    MSS_GPIO_set_output(READ_PIN, 0)

void gpio_setup(void);
uint32_t gpio_inputs(void);
uint32_t gpio_outputs(void);

void gpio_led_set(LED_t LED_INDEX, LED_ACTION_t ACTION);
void gpio_led_toggle(LED_t LED_INDEX);

uint32_t gpio_led_state(LED_t LED_INDEX);
uint32_t gpio_sw_state(SW_t SW_INDEX);

void gpio_set_all(uint32_t gpio_outs);

#endif /* GPIO_H_ */
