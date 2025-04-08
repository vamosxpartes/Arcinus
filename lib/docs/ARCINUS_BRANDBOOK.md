# ARCINUS - Brandbook: Inspirado en la App de NBA 🏀

## Introducción

Este brandbook define el estilo visual y la identidad de Arcinus, una aplicación para gestión de academias deportivas. Inspirados en la moderna y dinámica interfaz de la aplicación oficial de la NBA, hemos creado una identidad visual oscura, vibrante y contemporánea que refleja la pasión por el deporte y la excelencia.

## Logo e Identidad

El logo de Arcinus es una orca, simbolizando fuerza, inteligencia y trabajo en equipo. Este emblema se presenta en dos versiones:
- `Logo_white.png` para fondos oscuros (versión principal)
- `Logo_black.png` para fondos claros (uso alternativo)

La orca funciona como un símbolo de poder y estrategia, características fundamentales en el deporte de alto rendimiento y la gestión de academias deportivas.

## Paleta de Colores

### Colores Primarios
- **Negro Profundo**: `#121212` - Color de fondo principal
- **Azul Arcinus**: `#0063FF` - Color principal de acento e identidad
- **Blanco**: `#FFFFFF` - Texto principal y elementos destacados

### Colores de Acento
- **Rojo Energía**: `#F82C2C` - Notificaciones, alertas y énfasis
- **Oro**: `#FFC400` - Elementos premium, logros destacados
- **Verde Éxito**: `#00C853` - Indicadores positivos, confirmaciones
- **Turquesa**: `#00E5FF` - Elementos interactivos secundarios
- **Morado**: `#9C27B0` - Elementos especiales y destacados

### Escala de Grises
- **Gris Oscuro**: `#1E1E1E` - Fondos de tarjetas y elementos elevados
- **Gris Medio**: `#323232` - Bordes y separadores
- **Gris Claro**: `#8A8A8A` - Texto secundario
- **Gris Ultraclaro**: `#E0E0E0` - Texto deshabilitado

## Tipografía

La aplicación utilizará la familia tipográfica **Roboto**, disponible en los siguientes pesos:
- Roboto Black: Para títulos principales y números destacados
- Roboto Bold: Para encabezados y botones
- Roboto Medium: Para subtítulos y elementos de navegación
- Roboto Regular: Para texto de contenido general
- Roboto Light: Para información secundaria
- Roboto Thin: Para elementos decorativos y estadísticas

### Jerarquía Tipográfica
- **Títulos H1**: 32px, Roboto Black
- **Títulos H2**: 24px, Roboto Bold
- **Títulos H3**: 20px, Roboto Bold
- **Subtítulos**: 18px, Roboto Medium
- **Cuerpo de texto**: 16px, Roboto Regular
- **Texto secundario**: 14px, Roboto Light
- **Notas pequeñas**: 12px, Roboto Light
- **Estadísticas destacadas**: 48px, Roboto Black
- **Botones**: 16px, Roboto Medium
- **Etiquetas**: 14px, Roboto Medium

## Estilo Visual y Componentes

### Tema General
- **Modo Oscuro**: Predominante, con fondos negros profundos y contrastes de color vibrantes
- **Bordes Redondeados**: Radio de 12px para tarjetas, 8px para botones, 24px para elementos flotantes
- **Elevación**: Sistema de sombras sutiles para indicar jerarquía visual
- **Transiciones**: Animaciones suaves de 300ms para cambios de estado

### Iconografía
- Estilo minimalista con líneas delgadas, rellenado para indicar estado activo
- Tamaño principal de 24px, secundario de 20px
- Colores adaptados a la paleta principal
- Uso de iconos de desplazamiento lateral para navegación principal

### Tarjetas y Contenedores
- Fondo en `#1E1E1E` con elevación sutil
- Bordes con radio de 12px
- Padding interno consistente de 16px
- Transiciones suaves al interactuar

### Botones
- **Botón Primario**: Fondo `#0063FF`, texto blanco, radio 8px
- **Botón Secundario**: Borde `#0063FF`, texto `#0063FF`, fondo transparente
- **Botón de Acción**: Circular, 56px de diámetro, con icono centrado
- **Estados**: Hover y press con cambios de opacidad (0.8 y 0.6 respectivamente)

### Barras de Navegación
- Fondo negro con efecto de desenfoque al superponer contenido
- Iconos de 24px con indicador de selección mediante línea inferior
- Transiciones suaves entre estados

### Listas y Tablas
- Divisores sutiles con `#323232`
- Filas alternadas con variación mínima de opacidad
- Indicadores de selección con barra lateral de color de acento

### Avatares y Perfiles
- Circular para usuarios, radio del 50%
- Rectangular con bordes redondeados para equipos
- Indicador de estado con pequeño círculo de color en la esquina

### Estadísticas y Visualización de Datos
- Gráficos con gradientes vibrantes
- Números grandes en Roboto Black
- Indicadores de tendencia con flechas e iconos coloreados
- Animaciones al cargar y actualizar datos

## Widgets a Implementar

### Componentes Básicos
- [  ] **ArcinusAppTheme**: Wrapper para aplicar el tema completo
- [  ] **ArcinusText**: Texto estilizado según la jerarquía tipográfica
- [  ] **ArcinusColors**: Clase con todos los colores del sistema
- [  ] **ArcinusButton**: Botones primarios, secundarios y variantes
- [  ] **ArcinusCard**: Tarjeta elevada con estilos consistentes
- [  ] **ArcinusAvatar**: Avatar para usuarios y equipos
- [  ] **ArcinusIcon**: Iconos estilizados del sistema

### Componentes de Navegación
- [  ] **ArcinusBottomBar**: Barra inferior personalizada
- [  ] **ArcinusNavigationPanel**: Panel expandible de navegación
- [  ] **ArcinusTabBar**: Barra de pestañas personalizada
- [  ] **ArcinusBackButton**: Botón de regreso estilizado

### Componentes de Entrada
- [  ] **ArcinusTextField**: Campo de texto personalizado
- [  ] **ArcinusSearchField**: Campo de búsqueda con iconos
- [  ] **ArcinusDropdown**: Menú desplegable
- [  ] **ArcinusCheckbox**: Casilla de verificación
- [  ] **ArcinusRadio**: Botón de opción
- [  ] **ArcinusSwitch**: Interruptor de palanca

### Componentes de Visualización
- [  ] **ArcinusStatCard**: Tarjeta para estadísticas destacadas
- [  ] **ArcinusBadge**: Indicador de notificación o conteo
- [  ] **ArcinusChip**: Etiqueta pequeña para categorías o filtros
- [  ] **ArcinusTimeline**: Línea de tiempo para eventos
- [  ] **ArcinusProgressIndicator**: Indicador de progreso circular y lineal
- [  ] **ArcinusEmptyState**: Estado vacío personalizado

### Componentes Específicos de la Aplicación
- [  ] **ArciniusUserListItem**: Elemento de lista para usuarios
- [  ] **ArcinusGroupCard**: Tarjeta para grupos/equipos
- [  ] **ArcinusTrainingCard**: Tarjeta para entrenamientos
- [  ] **ArcinusSessionCard**: Tarjeta para sesiones
- [  ] **ArcinusNotificationItem**: Elemento de notificación
- [  ] **ArcinusMessageBubble**: Burbuja de mensaje para el chat
- [  ] **ArcinusCalendarDay**: Día en el calendario con indicadores

## Pantallas a Estilizar

### Autenticación
- [  ] Splash Screen
- [  ] Login
- [  ] Registro
- [  ] Recuperación de Contraseña

### Dashboards
- [  ] Dashboard Principal (Home)
- [  ] Dashboard de Propietario
- [  ] Dashboard de Manager
- [  ] Dashboard de Entrenador
- [  ] Dashboard de Atleta

### Usuarios y Permisos
- [  ] Perfil de Usuario
- [  ] Edición de Perfil
- [  ] Gestión de Usuarios
- [  ] Administración de Permisos
- [  ] Gestión de Roles Personalizados

### Academia y Grupos
- [  ] Creación de Academia
- [  ] Detalles de Academia
- [  ] Lista de Grupos
- [  ] Detalle de Grupo
- [  ] Creación/Edición de Grupo

### Entrenamientos y Sesiones
- [  ] Lista de Entrenamientos
- [  ] Detalle de Entrenamiento
- [  ] Creación/Edición de Entrenamiento
- [  ] Lista de Sesiones
- [  ] Detalle de Sesión
- [  ] Registro de Asistencia

### Comunicación
- [  ] Lista de Chats
- [  ] Conversación de Chat
- [  ] Centro de Notificaciones

### Calendario y Programación
- [  ] Vista de Calendario
- [  ] Detalle de Evento
- [  ] Creación de Evento

## Implementación Técnica

### Estructura de Archivos

```
lib/
├── ui/
│   ├── shared/
│   │   ├── theme/
│   │   │   ├── arcinus_theme.dart
│   │   │   ├── arcinus_colors.dart
│   │   │   ├── arcinus_text_styles.dart
│   │   │   └── arcinus_theme_data.dart
│   │   └── widgets/
│   │       ├── buttons/
│   │       ├── cards/
│   │       ├── navigation/
│   │       └── ...
```

### Compatibilidad de Dependencias

Las siguientes dependencias serán necesarias para implementar correctamente el tema:

- **flutter_svg**: Para manejo de iconos SVG
- **google_fonts**: Si necesitamos fuentes adicionales
- **shimmer**: Para efectos de carga en tarjetas
- **cached_network_image**: Para manejo eficiente de imágenes

Se recomienda agregar estas dependencias al pubspec.yaml y asegurar la compatibilidad con las versiones actuales.

## Guía de Animaciones y Transiciones

Para mantener una experiencia de usuario fluida y moderna, similar a la app de la NBA:

1. **Navegación entre pantallas**: Transición tipo slide horizontal con curva de ease-in-out
2. **Carga de datos**: Efectos shimmer en contenedores mientras se cargan
3. **Expansión de paneles**: Animación suave con curva decelerate
4. **Aparición de elementos**: Fade in secuencial para listas
5. **Tarjetas interactivas**: Ligero efecto de escala al seleccionar (scale 1.02)

## Modo Oscuro

El tema está diseñado primariamente para modo oscuro, inspirado en la app de la NBA. Si en el futuro se requiere un modo claro, se crearán variantes de los colores principales manteniendo la identidad visual.

## Accesibilidad

A pesar del enfoque en diseño oscuro y vibrante, los siguientes principios de accesibilidad deben mantenerse:

1. **Contraste adecuado**: Mantener ratios mínimos de 4.5:1 para texto pequeño
2. **Tamaños de texto ajustables**: Soporte para escalado de texto del sistema
3. **Alternativas a colores**: No depender únicamente del color para transmitir información
4. **Zonas táctiles adecuadas**: Mínimo 48x48px para elementos táctiles

## Conclusión

Este brandbook establece las bases para transformar la interfaz de Arcinus en una experiencia visual moderna, atractiva y funcional, inspirada en la exitosa aplicación de la NBA. La implementación progresiva de estos elementos visuales elevará la percepción de calidad y profesionalismo de la aplicación. 