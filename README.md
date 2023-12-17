# Bare Board Framework

Goal of this project is to provide foundation to [Hexapod](https://github.com/godunko/hexapod/) project.

In contrast to may other frameworks, most of interactions with
sensors/controllers are implemented asynchronously with use of hardware
features (interrupts/PDCs) to minimize CPU load as much as possible.

Code is developed and tested on Arduino Due (ARM Cortex-M3, ATSAM3X8E chip).
