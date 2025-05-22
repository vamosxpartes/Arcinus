vamos ha hacer un cambio en la ui de manejo de pagos.

primero tenemos @academy_members_screen.dart. Que mediante widgets especificos tenemos acceso a @athlete_payments_screen.dart y a @register_screen.dart.

pero por mi analisis visual @register_payment_screen.dart:
1. permite hacer pagos 'seleccionando' un atleta de una lista, cuando deberia tener referenciado el atleta. 
2. permite ingresar un monto aun si no estan 'configurado' los pagos parciales etc.

vamos ha hacer ajustes importantes:

1. vamos a descartar @athlete_payments_screen.dart. (que aparentemente es un resumen de los pagos totales y historial de pagos).

2. vamos a tomar @register_payment_screen.dart que va a ser ahora la screen de pagos y vamos refactorizarla para: 

    2.1. verifica como se maneja y donde se guarda la configuracion de pagos de @academy_screen.dart (ver si hay un modelo de payment config)
    2.2. inicializar de manera asincrona verificando que traiga el id del atleta y la configuracion de pagos.
    2.3. ajustarse la ui a la configuracion de pagos
    2.4. consumir la informacion del plan asignado al atleta
    2.5. desarrollar la logica o verificar si hay una existente para registrar pagos y establecer como 'activos' al atleta en cuestion.

3. crear una pantalla de historial y incluir un boton en la nueva pantalla de pagos de 'ver historial'
  