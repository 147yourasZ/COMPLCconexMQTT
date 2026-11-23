(* ============================================================================
   PROGRAMA: PRG_Analog
   ENTORNO : Phoenix Contact PLCnext Engineer 2026.6 (AXC F 2152)
   OBJETIVO: Lectura de sensor analógico 0-10 V, conversión a voltaje y %,
             filtrado digital exponencial y validación de rango.
   NOTA    : Ajustar rRaw_Min / rRaw_Max según la hoja de datos del módulo
             Axioline F AI real una vez identificado (ej. 0..30000 en AXL F).
   ============================================================================ *)
PROGRAM PRG_Analog
VAR_EXTERNAL
    AI_Sensor_Raw       : DINT;   (* Valor crudo del módulo analógico *)
    AI_Sensor_Voltage   : REAL;   (* Voltaje calculado [0.0 .. 10.0 V] *)
    AI_Sensor_Percent   : REAL;   (* Porcentaje escalado [0.0 .. 100.0 %] *)
    SYS_Sensor_Valid    : BOOL;   (* TRUE si la lectura está dentro de rango válido *)
    DIAG_Last_Error     : STRING;
END_VAR

VAR_INPUT
    diRaw_Min           : DINT := 0;      (* Ajustar según módulo AXL F real *)
    diRaw_Max           : DINT := 30000;  (* Ajustar según módulo AXL F real *)
    rFilter_Alpha       : REAL := 0.2;    (* Factor de filtro EMA (0.05 .. 1.0) *)
    rVoltage_Min_Valid  : REAL := -0.2;   (* Tolerancia inferior de cero *)
    rVoltage_Max_Valid  : REAL := 10.5;   (* Tolerancia superior de sobre-rango *)
END_VAR

VAR_OUTPUT
    xSensor_Fault       : BOOL;
END_VAR

VAR
    rSpan               : REAL;
    rVoltage_Raw        : REAL;
    rVoltage_Filtered   : REAL := 0.0;
    xFirst_Scan         : BOOL := TRUE;
    rAlpha_Clamped      : REAL;
END_VAR

(* 1. Validar parámetros de escalamiento *)
rSpan := DINT_TO_REAL(diRaw_Max - diRaw_Min);
IF rSpan <= 0.0 THEN
    SYS_Sensor_Valid := FALSE;
    xSensor_Fault    := TRUE;
    DIAG_Last_Error  := 'FAULT_ANALOG_CONFIG_SPAN';
    RETURN;
END_IF;

(* 2. Conversión lineal crudo -> Voltaje (0-10 V) *)
rVoltage_Raw := (DINT_TO_REAL(AI_Sensor_Raw - diRaw_Min) / rSpan) * 10.0;

(* 3. Validación de rango y detección de valores anormales / rotura / corto *)
IF (rVoltage_Raw < rVoltage_Min_Valid) OR (rVoltage_Raw > rVoltage_Max_Valid) THEN
    SYS_Sensor_Valid := FALSE;
    xSensor_Fault    := TRUE;
    DIAG_Last_Error  := 'FAULT_SENSOR_OUT_OF_RANGE';
ELSE
    SYS_Sensor_Valid := TRUE;
    xSensor_Fault    := FALSE;
END_IF;

(* 4. Limitar voltaje físico para cálculo limpio [0.0 .. 10.0 V] *)
IF rVoltage_Raw < 0.0 THEN
    rVoltage_Raw := 0.0;
ELSIF rVoltage_Raw > 10.0 THEN
    rVoltage_Raw := 10.0;
END_IF;

(* 5. Filtro digital exponencial configurable (EMA) *)
rAlpha_Clamped := rFilter_Alpha;
IF rAlpha_Clamped < 0.01 THEN rAlpha_Clamped := 0.01; END_IF;
IF rAlpha_Clamped > 1.0  THEN rAlpha_Clamped := 1.0;  END_IF;

IF xFirst_Scan THEN
    rVoltage_Filtered := rVoltage_Raw;
    xFirst_Scan       := FALSE;
ELSE
    rVoltage_Filtered := (rAlpha_Clamped * rVoltage_Raw) + ((1.0 - rAlpha_Clamped) * rVoltage_Filtered);
END_IF;

(* 6. Publicación de salidas *)
AI_Sensor_Voltage := rVoltage_Filtered;
AI_Sensor_Percent := (AI_Sensor_Voltage / 10.0) * 100.0;

END_PROGRAM
