# VelonaCore Basys3 Memory Map

The following table denotes the memory map of the Basys3 peripherals,
as specified in the `VelonaCore_basys3mem.vhd` file.

| Address                  | Name                  |
| ------------------------ | --------------------- |
| 0x0 - 0x3FF              | RAM                   |
| 0x9FFF0000               | LEDs                  |
| 0x9FFF0004               | Switches              |
| 0x9FFF0100 -  0x9FFF0110 | 4 x 7 Segment Display |

For a full list of the available I/O on the Basys3 board and its functionality,
refer to: https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual

## Peripherals

| Type  | Description |
| :---: | ----------- |
|  INV  | Undefined   |
|   W   | Write only  |
|   R   | Read only   |
|  R/W  | Read/Write  |

### LEDs

| bit(s) | Type  | Description   |
| :----: | :---: | ------------- |
| 31:16  |  INV  | Unused        |
|  15:0  |   W   | 16 Board LEDs |

### Switches

| bit(s) | Type  | Description       |
| :----: | :---: | ----------------- |
| 31:16  |  INV  | Unused            |
|  15:0  |   R   | 16 Board switches |

### 4 x 7-Segment Display

| Offset | Name       |
| ------ | ---------- |
| 0x0    | Segment[0] |
| 0x4    | Segment[1] |
| 0x8    | Segment[2] |
| 0x10   | Segment[3] |

**Segment[\#]:**

| bit(s) | Type  | Description                     |
| :----: | :---: | ------------------------------- |
|  31:8  |  INV  | Unused                          |
|   7    |   W   | Decimal point                   |
|  6:0   |   W   | Bit 6 -> G,F,E,D,C,B,A <- Bit 0 |
