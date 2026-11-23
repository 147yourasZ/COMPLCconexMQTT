# Tabla Maestra de Variables (Tags) — AXC F 2152

**Proyecto:** `App1.plcnx2` (`PLCnext Engineer 2026.6`)  
**Nota:** Las direcciones físicas se mantienen como `PENDIENTE_MODULO_AXL_F` hasta identificar los módulos Axioline F reales en el bus local.

| Nombre del Tag | Tipo IEC | Dirección Física | Dirección Simbólica | Valor Inicial | Lectura | Escritura | OPC UA | Función |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `DI_Start` | `BOOL` | `PENDIENTE_MODULO_AXL_F` | `PRG_Main.DI_Start` | `FALSE` | Sí | No | Read | Pulsador de arranque filtrado |
| `DI_Stop` | `BOOL` | `PENDIENTE_MODULO_AXL_F` | `PRG_Main.DI_Stop` | `FALSE` | Sí | No | Read | Pulsador de parada filtrado (Prioridad 1) |
| `AI_Sensor_Raw` | `DINT` | `PENDIENTE_MODULO_AXL_F` | `PRG_Main.AI_Sensor_Raw` | `0` | Sí | No | Read | Valor crudo del módulo analógico |
| `AI_Sensor_Voltage` | `REAL` | Interna (calculada) | `PRG_Main.AI_Sensor_Voltage` | `0.0` | Sí | No | Read | Voltaje escalado `0.0 - 10.0 V` |
| `AI_Sensor_Percent` | `REAL` | Interna (calculada) | `PRG_Main.AI_Sensor_Percent` | `0.0` | Sí | No | Read | Porcentaje escalado `0.0 - 100.0 %` |
| `DO_Motor` | `BOOL` | `PENDIENTE_MODULO_AXL_F` | `PRG_Main.DO_Motor` | `FALSE` | Sí | No | Read | Salida física contactor / motor |
| `DO_LED` | `BOOL` | `PENDIENTE_MODULO_AXL_F` | `PRG_Main.DO_LED` | `FALSE` | Sí | No | Read | Salida física LED indicador |
| `CMD_Motor_Start` | `BOOL` | Interna (comando) | `PRG_Main.CMD_Motor_Start` | `FALSE` | Sí | Sí | Read/Write | Orden remota de arranque |
| `CMD_Motor_Stop` | `BOOL` | Interna (comando) | `PRG_Main.CMD_Motor_Stop` | `FALSE` | Sí | Sí | Read/Write | Orden remota de parada |
| `CMD_LED` | `BOOL` | Interna (comando) | `PRG_Main.CMD_LED` | `FALSE` | Sí | Sí | Read/Write | Orden remota de LED |
| `CMD_Reset_Alarm` | `BOOL` | Interna (comando) | `PRG_Main.CMD_Reset_Alarm` | `FALSE` | Sí | Sí | Read/Write | Restablecimiento remoto de alarmas |
| `SYS_PLC_Heartbeat` | `UDINT` | Interna (sistema) | `PRG_Main.SYS_PLC_Heartbeat` | `0` | Sí | No | Read | Latido incremental del PLC (1 Hz) |
| `SYS_Gateway_Heartbeat` | `UDINT` | Interna (sistema) | `PRG_Main.SYS_Gateway_Heartbeat` | `0` | Sí | Sí | Read/Write | Latido enviado por Node-RED |
| `SYS_Communication_OK` | `BOOL` | Interna (sistema) | `PRG_Main.SYS_Communication_OK` | `FALSE` | Sí | No | Read | Estado del watchdog de comunicación |
| `SYS_Motor_Status` | `BOOL` | Interna (sistema) | `PRG_Main.SYS_Motor_Status` | `FALSE` | Sí | No | Read | Confirmación de estado del motor |
| `SYS_Alarm` | `BOOL` | Interna (sistema) | `PRG_Main.SYS_Alarm` | `FALSE` | Sí | No | Read | Alarma general activa |
| `SYS_Sensor_Valid` | `BOOL` | Interna (sistema) | `PRG_Main.SYS_Sensor_Valid` | `FALSE` | Sí | No | Read | Sensor 0-10 V dentro de rango válido |
| `SYS_System_Ready` | `BOOL` | Interna (sistema) | `PRG_Main.SYS_System_Ready` | `FALSE` | Sí | No | Read | Sistema listo para operación remota |
| `DIAG_OPC_UA_Status` | `BOOL` | Interna (diagnóstico) | `PRG_Main.DIAG_OPC_UA_Status` | `FALSE` | Sí | No | Read | Estado lógico enlace OPC UA |
| `DIAG_MQTT_Status` | `BOOL` | Interna (diagnóstico) | `PRG_Main.DIAG_MQTT_Status` | `FALSE` | Sí | Sí | Read/Write | Estado lógico enlace MQTT |
| `DIAG_Last_Command_ID` | `STRING` | Interna (diagnóstico) | `PRG_Main.DIAG_Last_Command_ID` | `''` | Sí | Sí | Read/Write | Último `cmd_id` procesado |
| `DIAG_Last_Error` | `STRING` | Interna (diagnóstico) | `PRG_Main.DIAG_Last_Error` | `''` | Sí | No | Read | Último error registrado en el PLC |
