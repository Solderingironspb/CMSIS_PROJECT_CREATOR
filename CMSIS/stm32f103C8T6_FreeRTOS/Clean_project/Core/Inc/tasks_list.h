#ifndef INC_TASKS_LIST_H_
#define INC_TASKS_LIST_H_

#include "main.h"



#if (configUSE_IDLE_HOOK==1)
void vApplicationIdleHook(void);
#endif

#if (configSUPPORT_STATIC_ALLOCATION == 1)
void vApplicationGetIdleTaskMemory(StaticTask_t **ppxIdleTaskTCBBuffer, StackType_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize);
#endif

#endif /* INC_TASKS_LIST_H_ */
