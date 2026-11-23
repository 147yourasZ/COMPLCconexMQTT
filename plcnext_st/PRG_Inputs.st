(* ============================================================================
   PROGRAMA: PRG_Inputs
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Lectura de entradas digitales (Start / Stop) con antirrebote,
             detección de flancos y diagnóstico básico de entradas.
   NOTA    : Mapear DI_Start_Raw y DI_Stop_Raw en Port List cuando se
             identifique el módulo Axioline F real (NO inventar direcciones).
   ============================================================================ *)
PROGRAM PRG_Inputs
VAR_EXTERNAL
    DI_Start            : BOOL;   (* Pulsador de arranque filtrado (NA) *)
    DI_Stop             : BOOL;   (* Pulsador de parada filtrado *)
    DIAG_Last_Error     : STRING; (* Último mensaje de diagnóstico *)
END_VAR

VAR_INPUT
    xRaw_Start          : BOOL;   (* Enlazar a canal DI físico del módulo AXL F *)
    xRaw_Stop           : BOOL;   (* Enlazar a canal DI físico del módulo AXL F *)
    xStop_Is_NC         : BOOL := FALSE; (* TRUE si el pulsador físico Stop es NC *)
    tDebounce_Time      : TIME := T#50ms;
END_VAR

VAR_OUTPUT
    xStart_Pulse        : BOOL;   (* Flanco ascendente de arranque válido *)
    xStop_Active        : BOOL;   (* TRUE = condición de parada activa *)
    xInput_Fault        : BOOL;   (* Falla por pulsación simultánea prolongada *)
END_VAR

VAR
    fbTON_Start         : TON;
    fbTON_Stop          : TON;
    fbTON_Both_Pressed  : TON;
    fbRTRIG_Start       : R_TRIG;
    xStop_Normalized    : BOOL;
END_VAR

(* 1. Normalización de lógica NC/NA para el pulsador de parada *)
IF xStop_Is_NC THEN
    xStop_Normalized := NOT xRaw_Stop;
ELSE
    xStop_Normalized := xRaw_Stop;
END_IF;

(* 2. Filtrado antirrebote *)
fbTON_Start(IN := xRaw_Start, PT := tDebounce_Time);
fbTON_Stop(IN := xStop_Normalized, PT := tDebounce_Time);

DI_Start := fbTON_Start.Q;
DI_Stop  := fbTON_Stop.Q;

(* 3. Detección de flanco para arranque *)
fbRTRIG_Start(CLK := DI_Start);
xStart_Pulse := fbRTRIG_Start.Q;
xStop_Active := DI_Stop;

(* 4. Diagnóstico: Start y Stop activos simultáneamente > 2 s *)
fbTON_Both_Pressed(IN := (DI_Start AND DI_Stop), PT := T#2s);
xInput_Fault := fbTON_Both_Pressed.Q;

IF xInput_Fault THEN
    DIAG_Last_Error := 'FAULT_INPUTS_SIMULTANEOUS_START_STOP';
END_IF;

END_PROGRAM
