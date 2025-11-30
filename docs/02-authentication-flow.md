# Informe Técnico – Flujo de Autenticación en la Arquitectura del BP Banking System  

## 1. Introducción
El **flujo de autenticación** en el BP Banking System está diseñado para garantizar **seguridad, cumplimiento regulatorio y experiencia de usuario fluida**, combinando autenticación tradicional, multifactor (MFA) y validación biométrica.

La solución se apoya en el **Authentication Service** desplegado en la nube, integrado con **Keycloak** para OAuth2/OpenID Connect, y complementado con validación biométrica externa y manejo seguro de sesiones.


## 2. Tecnologías y Patrones Utilizados

- **OAuth 2.0 / OpenID Connect** – Estándar para autenticación y autorización.
- **Keycloak** – Servidor de identidad para manejar tokens, roles y flujos de autenticación.
- **Spring Boot** – Backend del Authentication Service y lógica de integración biométrica.
- **JWT (JSON Web Tokens)** – Tokens firmados para autenticación y autorización.
- **TLS 1.3** – Cifrado en tránsito para toda la comunicación.
- **MFA (Multi-Factor Authentication)** – Segundo factor vía OTP, correo o notificación push.
- **Biometría** – Validación mediante proveedor externo (reconocimiento facial/huella).
- **Redis** – Almacenamiento de sesiones y control de expiración.

## 3. Flujo de Autenticación – Paso a Paso

1. **Inicio de Sesión (Cliente Web/Móvil)**  
   - El usuario ingresa credenciales en la aplicación (SPA React o App Flutter).
   - Los datos se envían al **API Gateway** mediante conexión HTTPS.

2. **Validación Inicial en API Gateway**  
   - Verificación de formato de credenciales y políticas de acceso.
   - Enrutamiento seguro hacia el **Authentication Service**.

3. **Autenticación con Keycloak**  
   - Keycloak valida las credenciales contra la base de datos de usuarios.
   - Si el usuario tiene MFA habilitado, se solicita el segundo factor.

4. **Validación MFA**  
   - OTP vía SMS/email, app autenticadora o push notification.
   - Confirmación antes de continuar.

5. **Validación Biométrica (Opcional/Regulatorio)**  
   - Integración con proveedor biométrico vía API segura.
   - Validación de rostro/huella para usuarios de alto riesgo o transacciones sensibles.

6. **Generación de Token JWT**  
   - Keycloak emite un **Access Token** (corto plazo) y un **Refresh Token** (largo plazo).
   - Los tokens incluyen información de roles y permisos.

7. **Almacenamiento de Sesión**  
   - Redis guarda la sesión activa y fecha de expiración.
   - Se asocian tokens con el ID de dispositivo.

8. **Respuesta al Cliente**  
   - El front-end almacena el token de forma segura:
     - Web: `HttpOnly Cookie` con `Secure` flag.
     - Móvil: `SecureStorage` o equivalente.


## 4. Consideraciones de Seguridad

- **Prevención de ataques de fuerza bruta**: bloqueo temporal por intentos fallidos.
- **Protección contra XSS/CSRF**:
  - Cookies con `SameSite=Strict`.
  - Tokens CSRF en formularios.
- **Cifrado extremo a extremo** con TLS 1.3.
- **Rotación periódica de tokens** para reducir riesgo de robo.
- **Revalidación biométrica** para transacciones críticas.
- **Registro y auditoría** de cada inicio de sesión en el **Audit Service**.

## 5. Diagrama de Flujo de Autenticación (Mermaid)

```mermaid
sequenceDiagram
    participant Cliente as Cliente Web/Móvil
    participant API as API Gateway
    participant Auth as Authentication Service
    participant KC as Keycloak
    participant Bio as Proveedor Biométrico
    participant Redis as Redis (Sesiones)

    Cliente->>API: Envío de credenciales (HTTPS)
    API->>Auth: Redirige petición
    Auth->>KC: Validación de credenciales
    KC-->>Auth: Credenciales válidas / requerir MFA
    Auth->>Cliente: Solicitud MFA
    Cliente->>Auth: Código MFA
    Auth->>Bio: (Opcional) Validación biométrica
    Bio-->>Auth: OK
    KC-->>Auth: Generación de Access/Refresh Token
    Auth->>Redis: Guardar sesión
    Auth-->>API: Respuesta con tokens
    API-->>Cliente: Tokens seguros
