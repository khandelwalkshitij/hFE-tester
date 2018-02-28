
# hFE-tester

A Microprocessor Transistor h-FE tester to display the h<sub>FE</sub> value of NPN transistors.

## Problem Statement

The transistor under test (TUT) is to be inserted in the socket, and its base is energized with a current from a device DI. The current I produced by the device DI, can be controlled by supplying it with a DC voltage V. The relationship is as follows:

# I = V * 10<sup>-4</sup> A

The emitter of the transistor is grounded, and the collector is connected to a 2.2K ohms resistor, whose other end is connected to the +5 V supply. The Voltage drop across a 2.2K ohms resistor is measured and this is related to the h<sub>FE</sub> by the following relation:

# h<sub>FE</sub> * I * 2200 = Voltage drop

The h<sub>FE</sub> value should be displayed on a LCD display. If the hFE value is less than 50, an alarm should be sounded 2 seconds.
