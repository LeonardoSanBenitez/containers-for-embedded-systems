import time
import qwiic_button

my_button = qwiic_button.QwiicButton()
while True:
    my_button.LED_on(100)
    time.sleep(1)
    my_button.LED_off()
    time.sleep(1)
