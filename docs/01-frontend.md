# Informe Técnico – Tecnologías Front-End en la Arquitectura del BP Banking System

## 1. Introducción
El BP Banking System contempla una **arquitectura omnicanal** que atiende a clientes a través de **navegadores web** y **dispositivos móviles**.  
La estrategia front-end busca:
- Experiencia de usuario fluida y responsiva.
- Seguridad y cumplimiento normativo en entornos financieros.
- Capacidad de evolucionar y escalar a futuro.
- Reutilización de lógica y componentes para optimizar costos.

Para lograrlo, se han definido **dos pilares tecnológicos**:
1. **React.js + TypeScript** para la aplicación web SPA.
2. **Flutter + Dart** para la aplicación móvil multiplataforma.


## 2. Aplicación Web SPA con React.js + TypeScript
  * [Aplicación Web](../diagrams/c4-model/Web_App.png)

### 2.1. Características Clave
- **Tipo:** SPA (Single Page Application)
- **Lenguaje:** TypeScript (superset tipado de JavaScript)
- **Framework/Biblioteca:** React.js
- **Ejecución:** Navegadores modernos (Chrome, Edge, Safari, Firefox)
- **Estilo:** CSS Modules / Styled Components / TailwindCSS
- **Estado:** Redux Toolkit o Zustand para gestión global.

### 2.2. Justificación Técnica
- **Rendimiento:** React utiliza Virtual DOM, actualizando solo los elementos que cambian, mejorando la respuesta en interfaces complejas como la banca online.
- **Mantenibilidad:** TypeScript permite detectar errores en tiempo de desarrollo gracias al tipado estático.
- **Escalabilidad:** Componentes reutilizables que facilitan la expansión de la aplicación sin comprometer rendimiento.
- **Seguridad:** Integración sencilla con librerías de autenticación OAuth2 y validación de sesiones JWT.
- **Comunidad y Ecosistema:** Gran cantidad de librerías maduras para formularios, gráficas, accesibilidad y pruebas.
- **Integración con APIs:** Facilidad para consumir APIs REST y gRPC, con soporte para WebSockets en tiempo real.


## 3. Aplicación Móvil con Flutter + Dart
  * [Aplicación Móvil](../diagrams/c4-model/Movil_App.png)

### 3.1. Características Clave
- **Tipo:** Aplicación móvil multiplataforma (iOS y Android)
- **Lenguaje:** Dart
- **Framework:** Flutter
- **UI:** Widgets nativos renderizados por motor gráfico propio (Skia)
- **Despliegue:** App Store y Google Play.

### 3.2. Justificación Técnica
- **Código Único:** Un solo repositorio para ambas plataformas, reduciendo costos de desarrollo y mantenimiento.
- **Rendimiento:** Compila a código nativo, evitando capas intermedias y asegurando tiempos de respuesta óptimos.
- **Consistencia Visual:** UI unificada en diferentes dispositivos, asegurando que la experiencia de banca sea igual en iOS y Android.
- **Soporte Offline:** Capacidad de almacenar datos localmente y sincronizar cuando hay conexión.
- **Seguridad:** Integración con almacenamiento seguro (Keychain, Keystore) y autenticación biométrica (FaceID, TouchID).

## 4. Comparativa con Otras Opciones SPA

| **Criterio**           | **React.js + TypeScript** | **Angular + TypeScript** |
|------------------------|---------------------------|---------------------------|
| Curva de Aprendizaje   | Media                     | Alta                      |
| Flexibilidad           | Alta                      | Media (más rígido)        |
| Ecosistema             | Muy amplio                | Amplio                    |
| Rendimiento SPA        | Muy alto                  | Alto                      |
| Comunidad              | Muy grande                | Grande                    |
| Integración móvil      | React Native              | Ionic / NativeScript      |
| Mantenibilidad         | Alta (componentes)        | Alta (estructura rígida)  |

**Decisión:** React.js ofrece mayor flexibilidad y rapidez para iterar sobre nuevas funcionalidades de banca digital. Angular, aunque robusto, tiene una curva de aprendizaje más pronunciada y menor flexibilidad para personalizaciones rápidas.


## 5. Integración Front-End con la Arquitectura

- **Con API Gateway:**  
  React y Flutter consumen APIs expuestas por el API Gateway vía HTTPS, autenticadas con OAuth2 y tokens JWT.
  
- **Seguridad en Front-End:**  
  - Sanitización de entradas para prevenir XSS.  
  - CSRF tokens en formularios críticos.  
  - HTTPS obligatorio con HSTS.  
  - Almacenamiento seguro de credenciales en `SecureStorage` (móvil) y `HttpOnly Cookies` (web).

- **Despliegue y Distribución:**  
  - SPA Web: Azure CDN + Application Gateway.  
  - Mobile: Publicación en App Store / Google Play, con integración CI/CD para releases.


## 6. Beneficios Clave de la Elección Tecnológica

1. **Experiencia de usuario consistente** en web y móvil.  
2. **Menor costo de mantenimiento** gracias a la reutilización de componentes y lógica.  
3. **Alta productividad del equipo** con herramientas modernas y ecosistema maduro.  
4. **Escalabilidad futura**, incluyendo integración con Progressive Web Apps (PWA) o banca abierta.  
5. **Seguridad reforzada** en cumplimiento con normativas financieras.


## 7. Conclusión

La elección de **React.js + TypeScript** para el canal web y **Flutter + Dart** para el canal móvil ofrece una solución balanceada entre rendimiento, flexibilidad y seguridad.  
Esta estrategia front-end permite a BP Bank ofrecer una experiencia digital de primer nivel, soportando alta concurrencia, manteniendo integridad de datos y garantizando escalabilidad para futuras demandas.