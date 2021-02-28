# ScifiBaseControlConsole
Console unit to control a scifi base with. 

It can be run using: 

```bash
python3 run.py
```

If you don't have an RFID reader, the authentication step can be skipped with:

```bash
python3 run.py --rfid_card=whatever
```

# Troubleshooting

### RFID card reader is not recognised
Ensure that the user that runs it is added to the dialout group and reboot after that.

``` 
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
```
