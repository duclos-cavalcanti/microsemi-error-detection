#include "timer.h"

// MSS_TIMER_PERIODIC_MODE, MSS_TIMER_ONE_SHOT_MODE
void timer1_setup(mss_timer_mode_t mode, uint32_t ticks) {
    // periodic timer
    MSS_TIM1_init(mode);
    MSS_TIM1_load_immediate(ticks);

    // enable and configure callback
    MSS_TIM1_enable_irq();

    // start it
    MSS_TIM1_start();
}

void timer2_setup(mss_timer_mode_t mode, uint32_t ticks) {
    // periodic timer
    MSS_TIM2_init(mode);
    MSS_TIM2_load_immediate(ticks);

    // enable and configure callback
    MSS_TIM2_enable_irq();

    // start it
    MSS_TIM2_start();
}
