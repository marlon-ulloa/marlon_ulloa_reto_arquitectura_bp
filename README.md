# Reto de Arquitectura de Soluciones - BP

Este repositorio contiene la solución propuesta para el reto de arquitectura de una plataforma de banca por internet para la entidad BP.

## Requisitos Funcionales y No Funcionales
Como primer paso, es necesario identificar todos los requerimientos funcionales y no funcionales para diseñar la arquitectura para el sistema.
### Requerimientos Funcionales
    - Acceso al histórico de movimientos
	- Transferencias entre cuentas propias e interbancarias
	- Pagos diversos
    - Onboarding con reconocimiento facial
	- Autenticación multifactor (usuario/clave, huella, facial)
	- Notificaciones de movimientos (mínimo 2 canales)
### Requerimientos No Funcionales
	- Alta disponibilidad (HA)
	- Tolerancia a fallos
	- Recuperación ante desastres (DR)
	- Seguridad robusta
	- Monitoreo y observabilidad
	- Excelencia operativa
	- Auto-healing
	- Baja latencia
	- Escalabilidad


## Solución Propuesta

Este repositorio y documento presenta el diseño arquitectónico del sistema "BP Banking System", una solución de banca por internet para BP Bank que cubre desde la interacción con los usuarios finales hasta la integración con sistemas externos críticos para el negocio. 

El modelo propuesto enfatiza la seguridad, la escalabilidad y la alta disponibilidad, incorporando tecnologías modernas y patrones arquitectónicos robustos que aseguran la resiliencia y la eficiencia operativa.

Se utilizan contenedores que incluyen aplicaciones web y móviles para el acceso del cliente, un API Gateway para centralizar el acceso y manejo de seguridad, y múltiples microservicios que gestionan funcionalidades claves como autenticación, gestión de cuentas, transferencias, notificaciones, detección de fraude, auditoría e integración con sistemas externos.

El despliegue se realiza en Azure Cloud utilizando servicios gestionados como Azure Kubernetes Service (AKS), bases de datos PostgreSQL y Cosmos DB, Redis para caching, y Kafka para mensajería asíncrona. La arquitectura de red está cuidadosamente diseñada con firewalls, load balancers y políticas de seguridad segmentadas para proteger los activos y garantizar cumplimiento regulatorio.

Se destacan dos opciones para el desarrollo Front-End: React.js para la SPA web y Flutter para la aplicación móvil multiplataforma. React.js fue elegido por su madurez, ecosistema robusto y capacidad para construir interfaces rápidas y responsivas, mientras que Flutter permite un desarrollo ágil y consistente en iOS y Android con una sola base de código.

La solución contempla componentes internos especializados y un sistema de monitoreo integral para mantener la observabilidad y el control continuo de la plataforma, asegurando una operación segura y confiable.

Esta propuesta está alineada con las mejores prácticas del mercado y los estándares de la industria financiera, ofreciendo una base sólida para futuras extensiones y mejoras del sistema de banca digital.


## Estructura del Repositorio

* **`/diagrams`**: Contiene todos los diagramas de la solución.
    * [Diagrama de Contexto (C1)](./diagrams/c4-model/C1-DIAGRAMA_DE_CONTEXTO.png)
    * [Diagrama de Contenedores (C2)](./diagrams/c4-model/C2-FIAGRAMA_DE_CONTENEDOR.png)
    * [Diagrama de Componentes (C3) - Transfer Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-TRANSFER_SERVICE.png)
    * [Diagrama de Componentes (C3) - Account Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-ACCOUNT_SERVICE.png)
    * [Diagrama de Componentes (C3) - API Gateway](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-API_GATEWAY.png)
    * [Diagrama de Componentes (C3) - Audit Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-AUDIT_SERVICE.png)
    * [Diagrama de Componentes (C3) - Authentication Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-AUTHENTICATION_SERVICE.png)
    * [Diagrama de Componentes (C3) - Fraud Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-FRAUD_SERVICE.png)
    * [Diagrama de Componentes (C3) - Integration Layer](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-INTEGRATION_LAYER.png)
    * [Diagrama de Componentes (C3) - Notification Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-NOTIFICATION_SERVICE.png)
    * [Diagrama de Componentes (C3) - Disaster Recovery Service](./diagrams/c4-model/C3-DRS.png)
    * [Diagrama de Componentes (C3) - Customer Profile Service](./diagrams/c4-model/C3-CUSTOMER_PROFILE_SERVICE.png)
    * [Diagrama de Componentes (C3) - Paymet Service](./diagrams/c4-model/C3-PAYMENT_SERVICE.png)
    * [Diagrama de Componentes (C3) - Disaster Recovery Service](./diagrams/c4-model/C3-DIAGRAMA_DE_COMPONENTE-NOTIFICATION_SERVICE.png)
    * [Diagrama de Infraestructura Azure Cloud](./diagrams/infrastructure/DIAGRAMA_DE_INFRAESTRUCTURA.png)
    * [Diagrama de Infraestructura de Red Azure Cloud](./diagrams/infrastructure/DIAGRAMA_DE_INFRAESTRUCTURA_DE_RED.png)
    * [Diagrama de Infraestructura de Seguridad Azure Cloud](./diagrams/infrastructure/DIAGRAMA_DE_INFRAESTRUCTURA_DE_SEGURIDAD.png)
    * [Proceso de Autenticación](./diagrams/c4-model/Flujo_Autenticación.png)
    * [Proceso de Transferencias](./diagrams/c4-model/Proceso_transferencias.png)
    * [Proceso de Onboarding](./diagrams/c4-model/Onboarding.png)
    * [Aplicación Móvil](./diagrams/c4-model/Movil_App.png)
    * [Aplicación Web](./diagrams/c4-model/Web_App.png)
    * [Arquitectura de Datos](./diagrams/c4-model/Arquitectura_Datos.png)
    * [Aplicación Web](./diagrams/infrastructure/Seguridad_capas.png)
* **`/docs`**: Documentación detallada que justifica las decisiones de arquitectura.
    * [1. Selección de Tecnologías Frontend](./docs/01-frontend.md)
    * [2. Flujo de Autenticación](./docs/02-authentication-flow.md)
    * [3. Patrones de Diseño y Servicios](./docs/03-design-patterns-and-services.md)
    * [4. Principios de Arquitectura usados](./docs/04-architectural-principles.md)
    * [5. Cumplimiento Normativo](./docs/05-regulatory-compliance.md)
    * [6. Documento a Detalle Consolidado más Estrategias de Implementación](./docs/general/Arquitectura%20de%20Sistema%20de%20Banca%20por%20Internet.pdf)
* **`/src`**: Código en formato dsl (structurizr) para visualizar cada uno de los diagramas antes descritos. Para visualizar los diagramas, es necesario acceder a [www.structurizer.com/dsl](https://www.structurizr.com/dsl), copiar el código que se encuentra en el archivo dsl, pegarlo en el editor de la página, y seleccionar el botón **Render** para visualizar los diagramas.
    * [Archivo dsl con el código de los diagramas](./src/c4-model_and_infrastructure.dsl)
