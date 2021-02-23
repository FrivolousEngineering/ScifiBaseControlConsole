# ScifiBaseControlConsole
Console unit to control a scifi base with


# Troubleshooting

### RFID card reader is not recognised
Ensure that the user that runs it is added to the dialout group and reboot after that.

``` sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
```
