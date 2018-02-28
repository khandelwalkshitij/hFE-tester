
## h<sub>FE</sub> TESTER

A Microprocessor Transistor h<sub>FE</sub> tester to display the h<sub>FE</sub> value of NPN transistors. The transistor under test (TUT) is to be inserted in the socket, and its base is energized with a current from a device DI. The current I produced by the device DI, can be controlled by supplying it with a DC voltage V. The relationship is as follows:

#### I = V * 10<sup>-4</sup> A

The emitter of the transistor is grounded, and the collector is connected to a 2.2K ohms resistor, whose other end is connected to the +5 V supply. The Voltage drop across a 2.2K ohms resistor is measured and this is related to the h<sub>FE</sub> by the following relation:

#### h<sub>FE</sub> * I * 2200 = Voltage drop

The h<sub>FE</sub> value should be displayed on a LCD display. If the hFE value is less than 50, an alarm should be sounded 2 seconds.

## DESCRIPTION AND WORKING METHODOLOGY

The transistor is inserted into the socket and the user presses a switch to indicate that a transistor has been placed. The device DI is then supplied with a voltage from the microprocessor using resistor-relay combination .The voltages supplied are 0.025V, 0.05V, 0.0625V, 0.075V, 0.0875V, 0.1V.

For each of these voltages the base is energized with the corresponding current gain given by the relation -
#### I = V * 10<sup>-4</sup> A

Depending upon the input current and the h<sub>FE</sub> value of the transistor, the collector current and hence the voltage drop across the resistor varies. This voltage drop is fed to ADC 0804 and the h<sub>FE</sub> is calculated using the relation -

#### h<sub>FE</sub> * I * 2200 = Voltage drop

The h<sub>FE</sub> value is then displayed on the LCD. If it is less than 50, the alarm is activated for 2 seconds. The DI device is connected to a resistor circuit as shown on the drawing sheet. There are 7 resistors of resistances 9.8KΩ, 4 resistors of 25Ω and 2 resistors of 50Ω respectively connected in series to a +5V source.

One of the ends of each resistor is connected to a DI device through a relay circuit switch. Each of these switches are connected to the 8086 microprocessor through an 8255. When a switch is closed (i.e., when a logic 1 is placed at one of the terminals of the coil) the voltage at that end of the resistor (to which the switch is connected) is provided to the DI device. The DI device used is a VCCS (Voltage controlled current source) that converts the given voltage to the specified current with the given transconductance of 100 microΩ.
