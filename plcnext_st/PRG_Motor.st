(* ============================================================================
   PROGRAMA: PRG_Motor
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Control local y remoto del motor con prioridad de parada física,
             validación de permisos, enclavamiento y control de LED indicador.
   ============================================================================ *)
PROGRAM PRG_Motor
VAR_EXTERNAL
    DO_Motor                : BOOL;   (* Salida física hacia contactor/motor *)
    DO_LED                  : BOOL;   (* Salida física LED indicador *)
    CMD_Motor_Start         : BOOL;   (* Comando remoto de arranque *)
    CMD_Motor_Stop          : BOOL;   (* Comando remoto de parada *)
    CMD_LED                 : BOOL;   (* Comando remoto de LED *)
    SYS_Communication_OK    : BOOL;
    SYS_Motor_Status        : BOOL;
    SYS_Alarm               : BOOL;
    SYS_Sensor_Valid        : BOOL;
    SYS_System_Ready        : BOOL;
    DIAG_Last_Command_ID    : STRING;
    DIAG_Last_Error         : STRING;
END_VAR

VAR_INPUT
    xLocal_Start_Pulse      : BOOL;   (* Flanco de pulsador físico Start *)
    xLocal_Stop_Active      : BOOL;   (* Pulsador físico Stop (PRIORIDAD 1) *)
    xMotor_Feedback         : BOOL := TRUE; (* Opcional: realimentación contactor *)
    xUse_Feedback           : BOOL := FALSE;
    tFeedback_Timeout       : TIME := T#2s;
END_VAR

VAR_OUTPUT
    xActuator_Fault         : BOOL;
    xInvalid_Cmd_Alarm      : BOOL;
END_VAR

VAR
    fbRTRIG_Remote_Start    : R_TRIG;
    fbRTRIG_Remote_Stop     : R_TRIG;
    fbTON_Feedback          : TON;
    xMotor_Latch            : BOOL := FALSE;
    xRemote_Start_Allowed   : BOOL;
END_VAR

(* 1. Detección de flancos de comandos remotos *)
fbRTRIG_Remote_Start(CLK := CMD_Motor_Start);
fbRTRIG_Remote_Stop(CLK := CMD_Motor_Stop);

(* 2. Condición de permiso para comandos remotos *)
xRemote_Start_Allowed := SYS_Communication_OK AND SYS_System_Ready AND (NOT SYS_Alarm) AND SYS_Sensor_Valid;

(* 3. PRIORIDAD 1: Parada física o parada remota o alarma crítica *)
IF xLocal_Stop_Active OR fbRTRIG_Remote_Stop.Q OR SYS_Alarm THEN
    xMotor_Latch := FALSE;
END_IF;

(* 4. Arranque local (siempre permitido si no hay Stop físico ni alarma) *)
IF xLocal_Start_Pulse AND (NOT xLocal_Stop_Active) AND (NOT SYS_Alarm) THEN
    xMotor_Latch := TRUE;
END_IF;

(* 5. Arranque remoto (sujeto a permisos y sin Stop físico) *)
IF fbRTRIG_Remote_Start.Q THEN
    IF xRemote_Start_Allowed AND (NOT xLocal_Stop_Active) THEN
        xMotor_Latch := TRUE;
    ELSE
        xInvalid_Cmd_Alarm := TRUE;
        DIAG_Last_Error    := 'CMD_REMOTE_START_REJECTED_INTERLOCK';
    END_IF;
END_IF;

(* 6. Limpiar comandos remotos tras ser evaluados (evita re-arranques al reconectar) *)
IF CMD_Motor_Start THEN
    CMD_Motor_Start := FALSE;
END_IF;
IF CMD_Motor_Stop THEN
    CMD_Motor_Stop := FALSE;
END_IF;

(* 7. Asignación de salidas físicas *)
DO_Motor         := xMotor_Latch;
SYS_Motor_Status := DO_Motor;

(* LED: encendido si motor activo o si comando remoto de LED está activo y hay comunicación *)
DO_LED := DO_Motor OR (CMD_LED AND SYS_Communication_OK);

(* 8. Diagnóstico opcional de realimentación de contactor *)
IF xUse_Feedback THEN
    fbTON_Feedback(IN := (DO_Motor <> xMotor_Feedback), PT := tFeedback_Timeout);
    xActuator_Fault := fbTON_Feedback.Q;
    IF xActuator_Fault THEN
        xMotor_Latch    := FALSE;
        DO_Motor        := FALSE;
        DIAG_Last_Error := 'FAULT_ACTUATOR_FEEDBACK_MISMATCH';
    END_IF;
ELSE
    xActuator_Fault := FALSE;
END_IF;

END_PROGRAM
