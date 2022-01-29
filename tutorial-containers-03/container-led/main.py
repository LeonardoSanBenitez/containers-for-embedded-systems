import time
import qwiic_button

my_button = qwiic_button.QwiicButton()
while True:
    my_button.LED_on(50)
    time.sleep(0.3)
    my_button.LED_off()
    time.sleep(0.3)
