#include "main.h"
#include "stm32f103xx_CMSIS.h"
#include "FreeRTOS.h"
#include "task.h"



 /**
 ***************************************************************************************
 *  @breif vApplicationIdleHook
 *  Задача бездействия
 *  Задача бездействия создается автоматически при запуске планировщика RTOS,
 *  чтобы гарантировать, что всегда есть хотя бы одна задача, которая может быть запущена.
 *  Она создается с самым низким возможным приоритетом , чтобы гарантировать, что он
 *  не использует процессорное время, если есть задачи приложения
 *  с более высоким приоритетом в состоянии готовности.
 ***************************************************************************************
 */
#if (USE_DEBUG == 1)
uint32_t HeapSize; //Свободное место в куче
#endif

#if (configUSE_IDLE_HOOK==1)
void vApplicationIdleHook(void) {

/*Проверка свободного места в куче, выделенной под FreeRTOS*/
#if (USE_DEBUG == 1)
	HeapSize = xPortGetFreeHeapSize();
#endif

}
#endif



/**
***************************************************************************************
*  @breif vApplicationGetIdleTaskMemory
*  Если configSUPPORT_STATIC_ALLOCATION == 1, то объекты RTOS могут создаваться
*  с использованием ОЗУ, предоставленного автором приложения.
*  Если для configSUPPORT_STATIC_ALLOCATION установлено значение 1, то автор приложения
*  должен также предоставить две функции обратного вызова:
*  vApplicationGetIdleTaskMemory(), чтобы предоставить память для использования
*  задачей бездействия RTOS, и (если для configUSE_TIMERS установлено значение 1)
*  vApplicationGetTimerTaskMemory(), чтобы предоставить память
*  для использования задача службы демона/таймера RTOS
***************************************************************************************
*/
#if (configSUPPORT_STATIC_ALLOCATION == 1)
void vApplicationGetIdleTaskMemory(StaticTask_t **ppxIdleTaskTCBBuffer, StackType_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize) {
	/* If the buffers to be provided to the Idle task are declared inside this
	 function then they must be declared static - otherwise they will be allocated on
	 the stack and so not exists after this function exits. */
	static StaticTask_t xIdleTaskTCB;
	static StackType_t uxIdleTaskStack[configMINIMAL_STACK_SIZE];

	/* Pass out a pointer to the StaticTask_t structure in which the Idle task's
	 state will be stored. */
	*ppxIdleTaskTCBBuffer = &xIdleTaskTCB;

	/* Pass out the array that will be used as the Idle task's stack. */
	*ppxIdleTaskStackBuffer = uxIdleTaskStack;

	/* Pass out the size of the array pointed to by *ppxIdleTaskStackBuffer.
	 Note that, as the array is necessarily of type StackType_t,
	 configMINIMAL_STACK_SIZE is specified in words, not bytes. */
	*pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}
#endif
