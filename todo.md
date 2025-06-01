[ ] 3. comportamientos extraños en los widgets que reflejan los dias pendientes,al momento de la redireccion despues de realizar un pago.

[ ] 4. modificaciones en el manejo del appbar/scaffold (si bien todos estan wrap en el managerscafold, que cada pantalla interna tenga una instancia del manager appbar, con el manager drawer)
    3.1. @AcademyUserDetailsScreen
    3.2. @RegisterPaymentScreen
    3.3. @AcademyScreen
    3.4  @PaymentHistoryScreen

[ ] 5. ajuste de estilos de la ui de los nuevos widgets de @RegisterPaymentScreen.

[ ] 6. que pasa para el dato fecha efectiva de inicio del plan o activacion del plan cuando quiero hacer otro pago en las posibles configuraciones de un plan mensual antes de que este acabe, por ejemplo:

a. caso 'por adelantado' pago 2 planes. 
b. caso 'mes vencido' pago 7 dias antes de la fecha de vencimiento
c. caso 'mes en curso, pago 2 planes.

deberian empezar justo donde termino el otro? que piensas?

[ ] 6. datos extraños en widgets que renderizan los dias pendientes en la redireccion al registrar un pago

[ ] 7. impedir la modificacion del plan 'actual' solo modificar los planes futuros.
