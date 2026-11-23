(* ============================================================================
   PROGRAMA: PRG_Alarms
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Gestión centralizada de alarmas (sensor, comunicación, actuador,
             comando inválido) y restablecimiento controlado por flanco.
   ============================================================================ *)
PROGRAM PRG_Alarms
VAR_EXTERNAL
    SYS_Alarm           : BOOL;   (* Alarma activa general *)
    CMD_Reset_Alarm     : BOOL;   (* Comando remoto de reset *)
    DIAG_Last_Error     : STRING;
END_VAR

VAR_INPUT
    xSensor_Fault       : BOOL;
    xComm_Lost_Alarm    : BOOL;
    xActuator_Fault     : BOOL;
    xInvalid_Cmd_Alarm  : BOOL;
    xInput_Fault        : BOOL;
    xLocal_Reset        : BOOL := FALSE;
END_VAR

VAR_OUTPUT
    xAlarm_Latched      : BOOL;
    xAny_Fault_Active   : BOOL;
END_VAR

VAR
    fbRTRIG_Remote_Rst  : R_TRIG;
    fbRTRIG_Local_Rst   : R_TRIG;
    xReset_Pulse        : BOOL;
END_VAR

(* 1. Evaluar fallas activas *)
xAny_Fault_Active := xSensor_Fault OR xComm_Lost_Alarm OR xActuator_Fault OR xInvalid_Cmd_Alarm OR xInput_Fault;

(* 2. Enclavamiento de alarma *)
IF xAny_Fault_Active THEN
    xAlarm_Latched := TRUE;
END_IF;

(* 3. Detección de flanco de restablecimiento *)
fbRTRIG_Remote_Rst(CLK := CMD_Reset_Alarm);
fbRTRIG_Local_Rst(CLK := xLocal_Reset);
xReset_Pulse := fbRTRIG_Remote_Rst.Q OR fbRTRIG_Local_Rst.Q;

(* Limpiar comando remoto tipo pulso después de procesarlo *)
IF CMD_Reset_Alarm THEN
    CMD_Reset_Alarm := FALSE;
END_IF;

(* 4. Restablecimiento controlado: solo si ya no hay falla física/comunicación *)
IF xReset_Pulse THEN
    IF NOT xAny_Fault_Active THEN
        xAlarm_Latched  := FALSE;
        DIAG_Last_Error := 'OK_ALARM_RESET';
    ELSE
        DIAG_Last_Error := 'WARN_RESET_REJECTED_FAULT_ACTIVE';
    END_IF;
END_IF;

SYS_Alarm := xAlarm_Latched;

END_PROGRAM
