Comportamientos por revisar:
1. [x] renderizado del logo, para la tab 'facturacion' en academyscreen
2. [x] revisar flujo de pagos para los atletas. 
    creo un nuevo atleta sin plan ni pago registrado:
    2.1. [x] en @register_payment_screen.dart (estado sin plan asignado) asigno un plan al darle tap al ElevatedButton 'Asignar Plan', veo el snackbar 'plan asignado correctamente'. para este momento el comportamiento que espero, es la reconstruccion de la pantalla con el (estado con plan asignado)
    2.2 [x] en @register_payment_sctreen.dart (estado con plan asignado), registro un pago al darle tap al ElevatedButton 'Registrar Pago'. 
    tengo estos logs:
    [ArcinusApp.AcademyUserCard] Procesando datos de pago para usuario vyEJ0aEZCSsKY6NtPprS {nombre: Carlos Rodríguez, tiene_plan: true, estado_pago: PaymentStatus.active, fecha_próximo_pago: 2025-06-22 00:00:00.000, fecha_último_pago: null, días_restantes: 30}
    [ArcinusApp.AcademyUserCard] Cálculo unificado de barra de progreso para usuario vyEJ0aEZCSsKY6NtPprS {fecha_inicio: 2025-05-23 00:00:00.000, fecha_próximo_pago: 2025-06-22 00:00:00.000, duración_plan_días: 30, días_transcurridos: 1, días_restantes: 28, progreso: 0.03333333333333333, está_vencido: false}
    [ArcinusApp.ClientUserRepositoryImpl.getClientUser] Obteniendo plan de suscripción {academyId: Plb0nTMuPUTenkqVi6Av, subscriptionPlanId: LuH3APpSlmVwalb85BfN}
    [ArcinusApp.ClientUserRepositoryImpl.getClientUser] Usuario cliente obtenido exitosamente {academyId: Plb0nTMuPUTenkqVi6Av, userId: 8JAC3khkD0OUDguXrxXs, clientType: atleta}
    [ArcinusApp.ClientUserRepositoryImpl.updateClientUser] Usuario cliente actualizado exitosamente {academyId: Plb0nTMuPUTenkqVi6Av, userId: 8JAC3khkD0OUDguXrxXs}.
    al ser exitoso el registro de pago espero un snackbar de 'pago registrado' y una redireccion a @academy_members_screen.dart, con un .pop creo que lo tenemos, asegurandonos que @academy_members_screen.dart y sus widget de member o atlete card, se actualize el componente encargado de mostrar el estado del atleta 'inactivo' => 'activo'.
3. [x] pantalla para el historial de pagos
    3.1 [x] crear una pantalla para el historial de pagos
    3.2 [x] asignar navegacion a el historial de pagos el TextButton 'ver pagos' de @academy_user_details_screen.dart.
    3.3 [x] investigar donde se guardan los datos de los pagos y construir la logica para consultarlos (ver si hay un servicio existente)
    3.4 [x] adicional (revisar el funcionamiento de la asignacion de la fecha de pago en register_payment_screen.dart revisa si la toma del formulario o la fuerza a la fecha actual)
  