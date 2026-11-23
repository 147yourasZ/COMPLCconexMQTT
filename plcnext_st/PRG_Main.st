(* ============================================================================
   PROGRAMA: PRG_Main
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Programa principal coordinador y declaración de variables globales
             compartidas con OPC UA.
   ============================================================================ *)
PROGRAM PRG_Main
VAR
    (* Entradas físicas / simbólicas *)
    DI_Start                : BOOL := FALSE;
    DI_Stop                 : BOOL := FALSE;
    AI_Sensor_Raw           : DINT := 0;
    AI_Sensor_Voltage       : REAL := 0.0;
    AI_Sensor_Percent       : REAL := 0.0;

    (* Salidas físicas / simbólicas *)
    DO_Motor                : BOOL := FALSE;
    DO_LED                  : BOOL := FALSE;

    (* Comandos remotos OPC UA (Lectura/Escritura) *)
    CMD_Motor_Start         : BOOL := FALSE;
    CMD_Motor_Stop          : BOOL := FALSE;
    CMD_LED                 : BOOL := FALSE;
    CMD_Reset_Alarm         : BOOL := FALSE;

    (* Estado del sistema *)
    SYS_PLC_Heartbeat       : UDINT := 0;
    SYS_Gateway_Heartbeat   : UDINT := 0;
    SYS_Communication_OK    : BOOL := FALSE;
    SYS_Motor_Status        : BOOL := FALSE;
    SYS_Alarm               : BOOL := FALSE;
    SYS_Sensor_Valid        : BOOL := FALSE;
    SYS_System_Ready        : BOOL := FALSE;

    (* Diagnóstico *)
    DIAG_OPC_UA_Status      : BOOL := FALSE;
    DIAG_MQTT_Status        : BOOL := FALSE;
    DIAG_Last_Command_ID    : STRING := '';
    DIAG_Last_Error         : STRING := '';

    (* Instancias de subprogramas *)
    instInputs              : PRG_Inputs;
    instAnalog              : PRG_Analog;
    instComm                : PRG_Communication;
    instAlarms              : PRG_Alarms;
    instMotor               : PRG_Motor;
END_VAR

(* 1. Lectura y filtrado de entradas digitales *)
instInputs();

(* 2. Lectura y escalamiento analógico 0-10 V *)
instAnalog();

(* 3. Watchdog y Heartbeats *)
instComm();

(* 4. Estado listo del sistema *)
SYS_System_Ready := (NOT SYS_Alarm) AND SYS_Sensor_Valid;

(* 5. Control del motor *)
instMotor(
    xLocal_Start_Pulse := instInputs.xStart_Pulse,
    xLocal_Stop_Active := instInputs.xStop_Active
);

(* 6. Gestión centralizada de alarmas *)
instAlarms(
    xSensor_Fault      := instAnalog.xSensor_Fault,
    xComm_Lost_Alarm   := instComm.xComm_Lost_Alarm,
    xActuator_Fault    := instMotor.xActuator_Fault,
    xInvalid_Cmd_Alarm := instMotor.xInvalid_Cmd_Alarm,
    xInput_Fault       := instInputs.xInput_Fault
);

END_PROGRAM
