(* ============================================================================
   PROGRAMA: PRG_Communication
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Heartbeat del PLC, monitoreo de Heartbeat del Gateway (Node-RED)
             con watchdog configurable y recuperación segura sin arranques.
   ============================================================================ *)
PROGRAM PRG_Communication
VAR_EXTERNAL
    SYS_PLC_Heartbeat       : UDINT; (* Contador incremental del PLC (cada 1 s) *)
    SYS_Gateway_Heartbeat   : UDINT; (* Contador escrito por Node-RED vía OPC UA *)
    SYS_Communication_OK    : BOOL;  (* TRUE = Gateway activo dentro del watchdog *)
    DIAG_OPC_UA_Status      : BOOL;  (* Estado lógico de enlace OPC UA *)
    DIAG_Last_Error         : STRING;
END_VAR

VAR_INPUT
    tHeartbeat_Period       : TIME := T#1s;
    tWatchdog_Timeout       : TIME := T#5s;
END_VAR

VAR_OUTPUT
    xComm_Lost_Alarm        : BOOL;
    xComm_Restored_Pulse    : BOOL;
END_VAR

VAR
    fbTON_PLC_HB            : TON;
    fbTON_Watchdog          : TON;
    udiLast_Gateway_HB      : UDINT := 0;
    xFirst_Scan             : BOOL := TRUE;
    xPrev_Comm_OK           : BOOL := FALSE;
    fbRTRIG_Comm_OK         : R_TRIG;
END_VAR

(* 1. Generación de Heartbeat del PLC (1 Hz) *)
fbTON_PLC_HB(IN := NOT fbTON_PLC_HB.Q, PT := tHeartbeat_Period);
IF fbTON_PLC_HB.Q THEN
    SYS_PLC_Heartbeat := SYS_PLC_Heartbeat + 1;
END_IF;

(* 2. Watchdog sobre el Heartbeat del Gateway *)
IF xFirst_Scan THEN
    udiLast_Gateway_HB := SYS_Gateway_Heartbeat;
    xFirst_Scan        := FALSE;
END_IF;

IF SYS_Gateway_Heartbeat <> udiLast_Gateway_HB THEN
    (* Hubo actividad nueva del Gateway: reiniciar watchdog *)
    udiLast_Gateway_HB := SYS_Gateway_Heartbeat;
    fbTON_Watchdog(IN := FALSE, PT := tWatchdog_Timeout);
    SYS_Communication_OK := TRUE;
    DIAG_OPC_UA_Status   := TRUE;
    xComm_Lost_Alarm     := FALSE;
ELSE
    fbTON_Watchdog(IN := TRUE, PT := tWatchdog_Timeout);
    IF fbTON_Watchdog.Q THEN
        SYS_Communication_OK := FALSE;
        DIAG_OPC_UA_Status   := FALSE;
        xComm_Lost_Alarm     := TRUE;
        DIAG_Last_Error      := 'ALARM_COMM_WATCHDOG_TIMEOUT';
    END_IF;
END_IF;

(* 3. Pulso de recuperación (solo informativo; NO genera orden de marcha) *)
fbRTRIG_Comm_OK(CLK := SYS_Communication_OK);
xComm_Restored_Pulse := fbRTRIG_Comm_OK.Q;
xPrev_Comm_OK        := SYS_Communication_OK;

END_PROGRAM
