#include "main.h"
#include "stm32f103xx_CMSIS.h"
#include "FreeRTOS.h"
#include "task.h"
#include "tasks_list.h"


int main(void) {
	CMSIS_Debug_init(); //Настройка дебага
	CMSIS_RCC_SystemClock_72MHz(); //Настроим МК на 72 МГц
	CMSIS_SysTick_Timer_init(); //Настроим системный таймер


	vTaskStartScheduler();

	for (;;) {

	}
}
