[x] 3. comportamientos extraños en los widgets que reflejan los dias pendientes,al momento de la redireccion despues de realizar un pago.

[x] 4. modificaciones en el manejo del appbar/scaffold (si bien todos estan wrap en el managerscafold, que cada pantalla interna tenga una instancia del manager appbar, con el manager drawer)
    3.1. @AcademyUserDetailsScreen
    3.2. @RegisterPaymentScreen
    3.3. @AcademyScreen
    3.4  @PaymentHistoryScreen

[x] 5. ajuste de estilos de la ui de los nuevos widgets de @RegisterPaymentScreen.

[x] 6. propuesta de migrar la logica del 'plan' para no ligarlo al usuario sino al 'periodo', asi informacion como el tipo de facturacion 'por adelantado', mes en 'curso' y demas estaria ligado al periodo, ademas la preguntas siguientes se resolverian teniendo en cuenta el periodo actual, que piensas?

que pasa para el dato fecha efectiva de inicio del plan o activacion del plan cuando quiero hacer otro pago en las posibles configuraciones de un plan mensual antes de que este acabe, por ejemplo:

a. caso 'por adelantado' pago 2 planes. 
b. caso 'mes vencido' pago 7 dias antes de la fecha de vencimiento
c. caso 'mes en curso, pago 2 planes.

deberian empezar justo donde termino el otro? que piensas?

[x] 7. impedir la modificacion del plan 'actual' solo modificar los planes futuros.

[x] 8. NUEVOS UPGRADES EN PAGOS - COMPLETADOS:
    8.1. ✅ Impedir 'editar' un plan registrado cuando hay períodos activos
         - Se implementó protección mediante `_canEditPlans` basado en `_hasActivePeriods`
         - Banner informativo cuando hay períodos registrados
         - Eliminado botón de editar plan en AthleteInfoCard

    8.2. ✅ Seleccionar 'plan' al pagar y no antes
         - Eliminados los 2 steps separados (asignar plan -> registrar pago)
         - Nuevo flujo unificado: selección de plan integrada en formulario de pago
         - Selector de plan mejorado con información detallada
         - Validación requerida de plan antes de enviar pago

    8.3. ✅ Migración de lógica del 'plan' desligado del usuario hacia el período
         - Plan ahora se selecciona por pago/período específico
         - Variables `_selectedPlan` y `_selectedPlanId` para manejo local
         - Pre-selección inteligente basada en último plan del usuario (como sugerencia)
         - Cálculo de fechas de servicio basado en plan seleccionado
         - Previsualización de períodos múltiples con plan seleccionado

    8.4. ✅ Mejoras en UX y validación
         - Botón de envío con validación visual (deshabilitado sin plan)
         - Información detallada del plan seleccionado
         - Autocompletado de campos basado en plan seleccionado
         - Mensajes informativos sobre el nuevo flujo
