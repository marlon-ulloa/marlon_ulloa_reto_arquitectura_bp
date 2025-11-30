# Informe Técnico – Patrones de Diseño y Descripción de Servicios en el BP Banking System

## 1. Patrón de Caché

### 1.1. Justificación
El **Patrón de Caché** se utiliza para optimizar el rendimiento del sistema, reduciendo la carga sobre las bases de datos y mejorando los tiempos de respuesta en operaciones de alta frecuencia.

### 1.2. Implementación
- **Tecnología:** Redis Cluster (Azure Cache for Redis)
- **Ubicación en la Arquitectura:**  
  - **Authentication Service:** Almacena sesiones activas y tokens para validación rápida.
  - **Account Service:** Guarda información frecuente de cuentas y saldos para evitar consultas repetitivas a la base de datos.
  - **Fraud Detection Service:** Cachea listas negras y parámetros de reglas.
- **Expiración de Datos (TTL):**
  - Sesiones: 15-30 min.
  - Datos de cuenta: 1-5 min.
  - Listas de fraude: 1-24 h según tipo.
- **Estrategia de Invalidación:**
  - **Write-through:** La actualización en DB actualiza el caché inmediatamente.
  - **Time-based eviction:** Expiración automática por tiempo definido.

### 1.3. Beneficios
1. Reducción de latencia en consultas recurrentes.
2. Menor carga sobre bases de datos transaccionales.
3. Mayor resiliencia ante picos de tráfico.


## 2. Otros Patrones de Diseño en la Arquitectura

| **Patrón**                | **Aplicación en el Sistema** |
|---------------------------|------------------------------|
| **API Gateway**           | Centraliza autenticación, autorización, rate limiting y enrutamiento. |
| **Saga**                  | Gestión de transferencias distribuidas en `Transfer Service`. |
| **Event Sourcing**        | Registro inmutable de eventos en `Audit Service`. |
| **CQRS**                  | Separación de consultas y comandos en `Account Service` y `Audit Service`. |
| **Circuit Breaker**       | En `API Gateway` e `Integration Layer` para tolerancia a fallos externos. |
| **Retry Pattern**         | Reintentos controlados en integraciones con sistemas externos. |
| **Adapter**               | En `Integration Layer` para múltiples protocolos (SOAP, REST, ISO20022). |
| **Publisher-Subscriber**  | Comunicación asíncrona con Apache Kafka entre microservicios. |
| **Bulkhead**              | Aislamiento de recursos en AKS para evitar que fallos afecten todo el sistema. |


## 3. Descripción de Servicios

### 3.1. Authentication Service
- **Responsabilidad:** Autenticación y autorización OAuth2 con soporte MFA y biometría.
- **Tecnologías:** Keycloak, Spring Boot, Redis.
- **Patrones aplicados:** Adapter (proveedor biométrico), Cache, Circuit Breaker.
- **Integraciones:** Proveedor biométrico, Redis, Primary Database.

### 3.2. Account Service
- **Responsabilidad:** Gestión de cuentas, saldos y movimientos.
- **Tecnologías:** Java Spring Boot, PostgreSQL, Redis.
- **Patrones aplicados:** CQRS, Cache.
- **Integraciones:** Integration Layer, Event Bus, Primary Database.

### 3.3. Transfer Service
- **Responsabilidad:** Procesamiento de transferencias internas e interbancarias.
- **Tecnologías:** Java Spring Boot, PostgreSQL, Apache Kafka.
- **Patrones aplicados:** Saga, Event Sourcing (eventos de transacciones), Retry Pattern.
- **Integraciones:** Integration Layer, Event Bus, Fraud Detection Service.

### 3.4. Notification Service
- **Responsabilidad:** Envío multicanal de notificaciones (SMS, email, push).
- **Tecnologías:** Java Spring Boot, Apache Kafka.
- **Patrones aplicados:** Publisher-Subscriber, Template Method (generación de mensajes).
- **Integraciones:** Proveedores de SMS y Email, Event Bus.

### 3.5. Fraud Detection Service
- **Responsabilidad:** Detección de fraude en tiempo real usando Machine Learning.
- **Tecnologías:** Spring Boot, TensorFlow, scikit-learn, Redis.
- **Patrones aplicados:** Cache, Rule Engine, Anomaly Detection Pattern.
- **Integraciones:** Event Bus, Primary Database, Integration Layer.

### 3.6. Audit Service
- **Responsabilidad:** Auditoría y trazabilidad de transacciones.
- **Tecnologías:** Spring Boot, EventStore DB, MongoDB, Elasticsearch.
- **Patrones aplicados:** Event Sourcing, CQRS.
- **Integraciones:** Event Bus, Audit Database.

### 3.7. Integration Layer
- **Responsabilidad:** Integración con sistemas externos usando patrones EIP.
- **Tecnologías:** Apache Camel, Java Spring Boot.
- **Patrones aplicados:** Adapter, Circuit Breaker, Retry Pattern.
- **Integraciones:** Core Banking, Red Interbancaria, Sistema Complementario.


## 4. Diagrama de Patrones de Diseño (Mermaid)

```mermaid
graph TD
    A[API Gateway] -->|Circuit Breaker, Rate Limiting| B[Authentication Service]
    A --> C[Account Service]
    A --> D[Transfer Service]
    D -->|Saga| E[Integration Layer]
    B -->|Cache| F[Redis]
    C -->|CQRS + Cache| F
    D -->|Event Sourcing| G[Audit Service]
    E -->|Adapter| H[Core Banking System]
    E --> H2[Red Interbancaria]
    E --> H3[Sistema Complementario]
    C -->|Publisher/Subscriber| I[Event Bus]
    D --> I
    G --> I
    F --> B
    F --> C
