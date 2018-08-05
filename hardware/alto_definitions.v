`define ALTO_BS_READ_R		3'o0
`define ALTO_BS_LOAD_R		3'o1
`define ALTO_BS_NONE			3'o2
`define ALTO_BS_TASK1		3'o3 // Task-specific bus source 1
`define ALTO_BS_TASK2		3'o4 // Task-specific bus source 2
`define ALTO_BS_MD			3'o5 // Memory data
`define ALTO_BS_MOUSE		3'o6 // Mouse data
`define ALTO_BS_DISP			3'o7

`define ALTO_F1_NONE			4'o0
`define ALTO_F1_MAR_LOAD	4'o1
`define ALTO_F1_TASK			4'o2
`define ALTO_F1_BLOCK		4'o3
`define ALTO_F1_L_LSH_1		4'o4
`define ALTO_F1_L_RSH_1		4'o5
`define ALTO_F1_L_LCY_8		4'o6
`define ALTO_F1_CONSTANT	4'o7

`define ALTO_F2_NONE			4'o0
`define ALTO_F2_BUS_ZERO	4'o1
`define ALTO_F2_SH_NEG		4'o2
`define ALTO_F2_SH_ZERO		4'o3
`define ALTO_F2_BUS			4'o4
`define ALTO_F2_ALUCY		4'o5
`define ALTO_F2_MD_STORE	4'o6
`define ALTO_F2_CONSTANT	4'o7

`define ALTO_ALUF_BUS						4'o0
`define ALTO_ALUF_T   						4'o1
`define ALTO_ALUF_BUS_OR_T					4'o2
`define ALTO_ALUF_BUS_AND_T				4'o3
`define ALTO_ALUF_BUS_XOR_T				4'o4
`define ALTO_ALUF_BUS_PLUS_1				4'o5
`define ALTO_ALUF_BUS_MINUS_1				4'o6
`define ALTO_ALUF_BUS_PLUS_T				4'o7
`define ALTO_ALUF_BUS_MINUS_T				4'o10
`define ALTO_ALUF_BUS_MINUS_T_MINUS_1	4'o11
`define ALTO_ALUF_BUS_PLUS_T_PLUS_1		4'o12
`define ALTO_ALUF_BUS_PLUS_SKIP			4'o13
`define ALTO_ALUF_BUS_AND_T_ALT			4'o14
`define ALTO_ALUF_BUS_AND_NOT_T			4'o15

`define ALTO_EMULATOR_F2_BUSODD			4'o10
`define ALTO_EMULATOR_F2_MAGIC			4'o11
`define ALTO_EMULATOR_F2_IR_LOAD			4'o14

`define ALTO_DISK_BS_KSTAT					3'o3
`define ALTO_DISK_BS_KDAT					3'o4

`define ALTO_DISK_F1_STROBE				4'o11
`define ALTO_DISK_F1_KSTAT_LOAD			4'o12
`define ALTO_DISK_F1_INCRECNO				4'o13
`define ALTO_DISK_F1_CLRSTAT				4'o14
`define ALTO_DISK_F1_KCOMM_LOAD			4'o15
`define ALTO_DISK_F1_KADR_LOAD			4'o16
`define ALTO_DISK_F1_KDATA_LOAD			4'o17

`define ALTO_DISK_F2_INIT					4'o10
`define ALTO_DISK_F2_RWC					4'o11
`define ALTO_DISK_F2_RECNO					4'o12
`define ALTO_DISK_F2_XFRDAT				4'o13
`define ALTO_DISK_F2_SWRNRDY				4'o14
`define ALTO_DISK_F2_NFER					4'o15
`define ALTO_DISK_F2_STROBON				4'o16

`define ALTO_TASK_EMULATOR             4'o0
`define ALTO_TASK_DISK_SECTOR				4'o4
`define ALTO_TASK_DISK_WORD				4'o16
