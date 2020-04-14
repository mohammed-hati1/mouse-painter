# mouse-painter
developing a mouse painter using assembly language
like the desktop app (paint) written by assembly language PS2 Mouse Commands After the PS2 Aux port has been enabled, you can send commands to the mouse. It is recommended to disable automatic packet streaming mode while "reprogramming" the mouse. You can do this by either sending command 0xF5 to the mouse, or disabling the "master mouse clock" by setting bit 5 of the Compaq Status byte (see below).

Waiting to Send Bytes to Port 0x60 and 0x64 All output to port 0x60 or 0x64 must be preceded by waiting for bit 1 (value=2) of port 0x64 to become clear. Similarly, bytes cannot be read from port 0x60 until bit 0 (value=1) of port 0x64 is set. See PS2 Keyboard for further details.

0xD4 Byte, Command Byte, Data Byte Sending a command or data byte to the mouse (to port 0x60) must be preceded by sending a 0xD4 byte to port 0x64 (with appropriate waits on port 0x64, bit 1, before sending each output byte). Note: this 0xD4 byte does not generate any ACK, from either the keyboard or mouse.

Wait for ACK from Mouse It is required to wait until the mouse sends back the 0xFA acknowledgement byte after each command or data byte before sending the next byte (Note: reset commands might not be ACK'ed -- wait for the 0xAA after a reset). A few commands require an additional data byte, and both bytes will generate an ACK.

Useful Mouse Command Set Note: remember that the mouse responds to all command bytes and data bytes with an ACK (0xFA). Note2: the commands given in the table are sent to port 0x60. If a command needs additional byte (like sampling rate), this byte goes to port 0x60 too. Hex value Meaning Description 0xFF Reset The mouse probably sends ACK (0xFA) plus several more bytes, then resets itself, and always sends 0xAA. 0xFE Resend This command makes the mouse send its most recent packet to the host again. 0xF6 Set Defaults Disables streaming, sets the packet rate to 100 per second, and resolution to 4 pixels per mm. 0xF5 Disable Packet Streaming The mouse stops sending automatic packets. 0xF4 Enable Packet Streaming The mouse starts sending automatic packets when the mouse moves or is clicked. 0xF3 Set Sample Rate Requires an additional data byte: automatic packets per second (see below for legal values). 0xF2 Get MouseID The mouse sends sends its current "ID", which may change with mouse initialization. 0xEB Request Single Packet The mouse sends ACK, followed by a complete mouse packet with current data. 0xE9 Status Request The mouse sends ACK, then 3 status bytes. See below for the status byte format. 0xE8 Set Resolution Requires an additional data byte: pixels per millimeter resolution (value 0 to 3) Additional Useless Mouse Commands Hex value Meaning Description 0xF0 Set Remote Mode The mouse sends ACK (0xFA) and then reset its movement counters, and enters remote mode 0xEE Set Wrap Mode The mouse sends ACK (0xFA) and then reset its movement counters, and enters wrap mode 0xEC Reset Wrap Mode The mouse sends ACK, and then enters the last mode, before entering wrap mode, it also resets its movement counters 0xEA Set Stream Mode The mouse sends ACK (0xFA) and then reset its movement counters, and enters reporting mode 0xE7 Set Scaling 2:1 The mouse sends ACK and sets non-linear scaling "2:1" 0xE6 Set Scaling 1:1 The mouse sends ACK and sets normal linear scaling "1:1"

The status bytes look like this: Byte 1:

Always 0 mode enable scaling Always 0 left btn middle right btn Byte 2:

resolution Byte 3:

sample rate

Mode: if it is 1, the current mode is remote mode; if 0 then it is stream mode Enable: if it is 1, then data reporting is enabled; if 0 then data reporting is disabled Scaling: if it is 1, scaling 2:1 is enabled; if 0 then scaling 1:1 is enabled. Resolution, Scaling and Sample Rate Definitions:

Resolution: DeltaX or DeltaY for each millimeter of mouse movement. Scaling: Apply a simple non-linear distortion to mouse movement (see Non-Linear Movement, above). Sampling Rate: Packets the mouse can send per second. Resolution:

value resolution 0x00 1 count /mm 0x01 2 count /mm 0x02 4 count /mm 0x03 8 count /mm

Scaling can either be "1:1" (linear = no scaling) or "2:1" (non-linear). This is the non-linear scaling:

Movement Counter Reported Movement 0 0 1 1 2 1 3 3 4 6 5 9 more than 5 2 * Movement Counter Sample Rate can have the following values: (all values are Decimal, NOT hex) value Samples pr second 10 10 20 20 40 40 60 60 80 80 100 100 200 200 Note: human eyes don't see movement faster than 30 samples per second, and human fingers cannot click a button that fast either. A sample rate lower than 30 will cause visibly jerky mouse movement, and may miss mousedown events. A sample rate significantly higher than 30 will waste precious I/O bus bandwidth. You may test these things for yourself, but sample rates of 10, 20, 100, or 200 are generally not recommended.

Initializing a PS2 Mouse The PS2 mouse port on a PC is attached to the auxiliary input of the PS2 keyboard controller. That input might be disabled at bootup, and needs to be enabled. It is usually also desirable to have the mouse generate IRQ12 interrupts when it sends bytes through the keyboard controller to IO port 0x60. Additionally, it is necessary to tell the mouse to enable the transmission of packets. Optionally, you may also want to enable additional mouse features, such as scroll wheels, faster response times, increased resolution, or additional mouse buttons.

PS/2 Device Unplugging/Hot Plugging Some idiot who created the PS/2 device specs did not specify that PS/2 devices can be unplugged and replugged while the computer remains turned on ("hot plugging"). A long time ago, some other idiots actually designed motherboards that would be slightly damaged if PS2 hot plugging occurs. However, mice and keyboards have cords that were made to be tripped over, and sometimes it is very logical to try moving a mouse from one machine to another, temporarily, without powering both systems down. So all computers made in the last 15 years should, in fact, support hot plugging of PS2 devices. When a mouse is plugged into a running system it may send a 0xAA, then a 0x00 byte, and then go into default state (see below).

Set Compaq Status/Enable IRQ12 On some systems, the PS2 aux port is disabled at boot. Data coming from the aux port will not generate any interrupts. To know that data has arrived, you need to enable the aux port to generate IRQ12. There is only one way to do that, which involves getting/modifying the "compaq status" byte. You need to send the command byte 0x20 ("Get Compaq Status Byte") to the PS2 controller on port 0x64. If you look at RBIL, it says that this command is Compaq specific, but this is no longer true. This command does not generate a 0xFA ACK byte. The very next byte returned should be the Status byte. (Note: on some versions of Bochs, you will get a second byte, with a value of 0xD8, after sending this command, for some reason.) After you get the Status byte, you need to set bit number 1 (value=2, Enable IRQ12), and clear bit number 5 (value=0x20, Disable Mouse Clock). Then send command byte 0x60 ("Set Compaq Status") to port 0x64, followed by the modified Status byte to port 0x60. This might generate a 0xFA ACK byte from the keyboard.

Aux Input Enable Command Send the Enable Auxiliary Device command (0xA8) to port 0x64. This will generate an ACK response from the keyboard, which you must wait to receive. Please note that using this command is not necessary if setting the Compaq Status byte is successful -- but it does no harm, either.

Mouse State at Power-on When the mouse is reset, either by applying power or with a reset command (0xFF), it always goes into the following default state:

packets disabled emulate 3 button mouse (buttons 4, 5, and scroll wheels disabled) 3 byte packets 4 pixel/mm resolution 100 packets per second sample rate MouseID Byte During initialization, a mouse indicates that it has various features (a scroll wheel, a 4th and 5th mouse button) by changing its mouseID in response to initialization commands. So you send a set of mouse commands, and then ask for the mouseID byte with the Get MouseID command (0xF2). If the mouseID changed from its previous value, then the mouse has changed modes. The mouseID byte is always the next byte sent after the ACK for the Read MouseID command. At initialization, the mouseID is always 0. Other current legal values are 3 and 4.

Init/Detection Command Sequences If you would like more than just 3 buttons, you will have to use the following sequence(s). If the first sequence is accepted: the number of bytes in the mouse packets changes to 4, the scroll wheel on the mouse becomes activated, and the mouseID changes from 0 to 3.

The first magic sequence goes like this:

set sample rate to 200 set sample rate to 100 set sample rate to 80 get the new id to verify acceptance

After using the above sequence to activate the scroll wheel, the 4th and 5th mouse buttons can be activated with the following additional magic sequence:

set sample rate to 200 set sample rate to 200 set sample rate to 80 get the new id to verify acceptance

If this second sequence is accepted, the returned mouse ID value changes from 3 to 4.

Enable Packets After the mouse has been initialized to your desired mouseID value, its Samplerate is probably 80 samples per second, its Resolution is probably 4 pixels/mm, and packets are still disabled. You may want to modify the Samplerate and Resolution, and then send a 0xF4 command to the mouse to make the mouse automatically generate movement packets.

Streaming Advantages and Disadvantages Instead of enabling automatic streaming packet mode, it is possible to request mouse packets one at a time. Doing this has some advantages over streaming packet mode. You may see that you need to send or receive at least 4 extra bytes over the I/O bus in order to get each 0xEB command to the mouse, and the I/O bus is very slow. On the other hand, a typical streaming mode probably sends hundreds more mouse packet bytes over the I/O bus than you need, every second -- so if there is a disadvantage, it is probably small.

One of the biggest problems with streaming mode is "alignment" -- the packets were never defined to have an obvious boundary. This means that it is very easy to lose track of which mouse byte is supposed to be the first byte of the next packet. This problem is completely avoided if you specifically request single packets (instead of using streaming mode) because every packet begins with an ACK (0xFA), which is easily recognizable.
