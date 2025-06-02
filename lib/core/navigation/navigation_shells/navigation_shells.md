# Navigation Shells

## Descripción General
Los Navigation Shells son componentes estructurales que encapsulan la interfaz de usuario base para diferentes roles de usuario en la aplicación Arcinus. Estos shells proporcionan consistencia en la navegación y experiencia de usuario según el rol, mientras permiten que el contenido interno cambie dinámicamente.

## Estructura de Shells

### Manager Shell (Anteriormente Owner Shell)
- **Propósito**: Shell unificado para usuarios con roles de gestión (propietarios y colaboradores)
- **Características**: 
  - AppBar con título dinámico
  - Drawer lateral con navegación a funciones principales
  - Acciones rápidas (notificaciones, mensajes)
  - Gestión centralizada del título de pantalla

### Client Shell (Anteriormente Athlete Shell)
- **Propósito**: Shell para usuarios tipo cliente (atletas y padres)
- **Características**:
  - Interfaz simplificada adaptada a consumidores de servicios
  - BottomNavigationBar para acceso a funciones principales
  - Experiencia optimizada para visualización de información

### SuperAdmin Shell
- **Propósito**: Shell para administradores de la plataforma
- **Características**:
  - Interfaz administrativa avanzada
  - Acceso a funciones de gestión global

## Funcionamiento

1. **Integración con GoRouter**:
   - Cada shell se implementa como un `ShellRoute` en GoRouter
   - Las rutas secundarias se anidan dentro del shell correspondiente
   - Cada shell tiene su propio `NavigatorKey` para gestionar la navegación

2. **Adaptación según Rol**:
   - El router redirige al usuario al shell apropiado según su rol (AppRole)
   - Los permisos y funcionalidades disponibles se adaptan al rol

3. **Gestión de Estado**:
   - Cada shell puede acceder a providers globales
   - Los shells pueden tener providers específicos (ejemplo: currentScreenTitleProvider)

## Patrones de Diseño

### Separación UI/Navegación
- **Shell**: Maneja la estructura y navegación
- **Screens**: Proporcionan el contenido específico
- **Providers**: Gestionan el estado y la lógica de negocio

### Adaptabilidad según Rol
- Diferentes shells exponen diferentes funcionalidades basadas en el rol
- Las pantallas comunes pueden adaptarse según el rol que las visualiza (ejemplo: PaymentDetailScreen)

## Ejemplo de Uso

Para navegar desde cualquier pantalla a otra dentro del mismo shell:
```dart
context.push('/manager/payments');
```

Para navegar con parámetros:
```dart
context.push('/manager/academy/$academyId/payments/$paymentId');
```

## Mejores Prácticas

1. **Títulos Dinámicos**:
   ```dart
   ref.read(currentScreenTitleProvider.notifier).state = 'Nuevo Título';
   ```

2. **Verificación de Permisos**:
   - Verificar el rol del usuario antes de mostrar acciones específicas
   - Usar condicionales para adaptación de UI según el rol

3. **Uso de Providers**:
   - Asociar providers a la estructura de navegación cuando sea apropiado
   - Utilizar providers para compartir estado entre rutas del mismo shell 