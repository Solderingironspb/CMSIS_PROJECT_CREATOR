#include "main.h"
#include "usb_device.h"
#include "usbd_customhid.h"

extern PCD_HandleTypeDef hpcd_USB_FS;
extern USBD_HandleTypeDef hUsbDeviceFS;

void USB_LP_CAN1_RX0_IRQHandler(void) {
    HAL_PCD_IRQHandler(&hpcd_USB_FS);
}

void USB_HP_CAN1_TX_IRQHandler(void) {
}

typedef struct __attribute__((packed)) {
    int8_t x;
    int8_t y;
    int8_t z;
    int8_t rx;
    int8_t ry;
    int8_t rz;
    uint8_t hat_switch;
    uint16_t buttons;
} USB_Custom_HID_Gamepad;

USB_Custom_HID_Gamepad Gamepad_data;

int main(void) {
    CMSIS_Debug_init();
    CMSIS_RCC_SystemClock_72MHz();
    CMSIS_SysTick_Timer_init();
    MX_USB_DEVICE_Init();

    while (1) {
        Gamepad_data.buttons++;
        if (Gamepad_data.buttons > 0x7FF) {
            Gamepad_data.buttons = 0;
        }
        USBD_CUSTOM_HID_SendReport(&hUsbDeviceFS, (uint8_t*)&Gamepad_data, sizeof(Gamepad_data));
        Delay_ms(4);
    }
}
