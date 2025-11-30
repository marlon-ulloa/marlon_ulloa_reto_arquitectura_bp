workspace "BP Banking System" "Sistema de Banca por Internet para BP Bank" {

    model {
        # Personas/Actores
        customer = person "Cliente" "Cliente del banco que utiliza los servicios de banca por internet"
        bankEmployee = person "Empleado del Banco" "Empleado que administra y monitorea el sistema"
        auditor = person "Auditor" "Auditor que revisa transacciones y cumplimiento normativo"
        
        # Sistemas Externos
        coreBankingSystem = softwareSystem "Core Banking System" "Sistema principal del banco con información de clientes, cuentas y productos" "External"
        complementarySystem = softwareSystem "Sistema Complementario" "Sistema independiente con información detallada del cliente" "External"
        smsProvider = softwareSystem "Proveedor SMS" "Servicio externo de envío de SMS" "External"
        emailProvider = softwareSystem "Proveedor Email" "Servicio externo de envío de emails" "External"
        interbankingNetwork = softwareSystem "Red Interbancaria" "Red para transferencias interbancarias (ACH, SWIFT)" "External"
        biometricProvider = softwareSystem "Proveedor Biométrico" "Servicio de reconocimiento facial y biometría" "External"
        
        # Sistema Principal BP Banking
        bpBankingSystem = softwareSystem "BP Banking System" "Sistema de banca por internet de BP Bank" {
            
            # NIVEL 2 - CONTENEDORES
            webApp = container "Web Application" "Single Page Application que proporciona funcionalidades de banca por internet" "React.js, TypeScript" "Web Browser"{
                uiLayer = component "UI Layer" "Vistas React, rutas, componentes" "React.js" webApp
                serviceLayer = component "Service Layer" "Lógica cliente y adaptadores a API" "TypeScript" webApp
                authAdapter = component "Auth Adapter" "Manejo de tokens, refresh, PKCE flow" "Oidc-client / Custom" webApp
                offlineManager = component "Offline Manager" "Service Worker, Cache API, fallback para malas redes" "Workbox/ServiceWorker" webApp
                storage = component "Local Storage/IndexedDB" "Persistencia local de datos frecuentes y session" "IndexedDB" webApp
                apiClient = component "API Client" "HTTP client con retries y circuit-breaker local" "Axios + Retry" webApp
            }
            mobileApp = container "Mobile Application" "Aplicación móvil multiplataforma para banca por internet" "Flutter, Dart" "Mobile App"{
                ui = component "UI Widgets" "Pantallas y flujo de navegación" "Flutter" mobileApp
                networkLayer = component "Network Layer" "HTTP client, interceptores, token refresh" "Dio / http" mobileApp
                authAdapterMobile = component "Auth Adapter Mobile" "Implementa Authorization Code + PKCE, biometría, fingerprint" "Flutter plugins" mobileApp
                offlineSync = component "Offline Sync" "Persistencia local y sincronización" "SQLite / Hive" mobileApp
                biometricIntegration = component "Biometric Integration" "Interacción con proveedor biométrico para onboarding" "Platform channels" mobileApp
            }
            
            firewall = container "Firewall" "Controla el tráfico de red entrante y saliente, filtrado de paquetes y protección perimetral" "Azure Firewall/FortiGate" "Firewall"
            
            loadBalancer = container "Load Balancer" "Distribuye tráfico entrante entre múltiples instancias del API Gateway para alta disponibilidad" "Azure Load Balancer/NGINX" "Load Balancer"
            
            apiGateway = container "API Gateway" "Punto de entrada único para todas las solicitudes, manejo de autenticación, rate limiting y enrutamiento" "Kong, NGINX" "API Gateway" {
            # NIVEL 3 - COMPONENTES DEL API GATEWAY
                rateLimiter = component "Rate Limiter" "Controla la velocidad de peticiones por cliente" "Kong Plugin" apiGateway
                loadBalancerComponent = component "Load Balancer Component" "Distribuye carga entre instancias de microservicios" "Kong Plugin" apiGateway
                securityGateway = component "Security Gateway" "Valida JWT tokens, CORS, API Keys" "Kong Plugin" apiGateway
                circuitBreaker = component "Circuit Breaker" "Implementa patrón circuit breaker para tolerancia a fallos" "Kong Plugin" apiGateway
                requestTransformer = component "Request Transformer" "Transforma requests entre diferentes formatos" "Kong Plugin" apiGateway
                responseTransformer = component "Response Transformer" "Transforma responses para clientes" "Kong Plugin" apiGateway
        }
            
            authService = container "Authentication Service" "Servicio de autenticación y autorización OAuth2 con soporte biométrico" "Keycloak, Java Spring Boot" "Microservice" {
                 # NIVEL 3 - COMPONENTES DEL AUTHENTICATION SERVICE
                oauthServer = component "OAuth2 Authorization Server" "Maneja flujos OAuth2 y emisión de tokens" "Keycloak" authService
                userManager = component "User Management" "CRUD de usuarios y gestión de perfiles" "Spring Boot" authService
                biometricValidator = component "Biometric Validation" "Integración con servicios de validación biométrica" "Spring Boot" authService
                mfaManager = component "MFA Manager" "Gestión de autenticación multifactor" "Spring Boot" authService
                sessionManager = component "Session Management" "Control de sesiones activas y timeout" "Spring Boot" authService
                tokenValidator = component "Token Validator" "Validación y renovación de tokens JWT" "Spring Boot" authService
                coreBankingValidator = component "Core Banking Validator" "Valida existencia y estado de usuarios en Core Banking durante onboarding y cambios de estado" "Spring Boot + Feign Client + Circuit Breaker" authService
            }
            
            accountService = container "Account Service" "Servicio de gestión de cuentas, consulta de saldos y movimientos" "Java Spring Boot, PostgreSQL" "Microservice" {
                 # NIVEL 3 - COMPONENTES DEL ACCOUNT SERVICE
                accountQueryHandler = component "Account Query Handler" "Maneja consultas de información de cuentas" "Spring Boot" accountService
                balanceCalculator = component "Balance Calculator" "Calcula saldos en tiempo real" "Spring Boot" accountService
                movementHistoryManager = component "Movement History Manager" "Gestiona histórico de movimientos" "Spring Boot" accountService
                accountValidator = component "Account Validator" "Valida permisos y estado de cuentas" "Spring Boot" accountService
                cacheManager = component "Cache Manager" "Gestiona estrategias de caché para datos frecuentes" "Spring Boot" accountService
            }
            
            #Perfil de cliente
            customerProfileService = container "Customer Profile Service" "Servicio de gestión de perfil de cliente con datos de ambos sistemas" "Java Spring Boot, PostgreSQL" "Microservice" {
                profileAggregator = component "Profile Aggregator" "Agrega datos de Core Banking y Sistema Complementario" "Spring Boot" customerProfileService
                cacheStrategyManager = component "Cache Strategy Manager" "Implementa Cache-Aside pattern para clientes frecuentes" "Spring Boot + Redis" customerProfileService
                dataEnricher = component "Data Enricher" "Enriquece datos básicos con información detallada" "Spring Boot" customerProfileService
                profileValidator = component "Profile Validator" "Valida completitud de perfil" "Spring Boot" customerProfileService
                profileQueryHandler = component "Profile Query Handler" "Maneja consultas de perfil implementando CQRS Read Model" "Spring Boot" customerProfileService
                profileUpdateHandler = component "Profile Update Handler" "Maneja actualizaciones de perfil implementando CQRS Write Model" "Spring Boot" customerProfileService
                eventPublisher = component "Event Publisher" "Publica eventos de cambios en perfil" "Spring Boot + Kafka" customerProfileService
            }
            
            transferService = container "Transfer Service" "Servicio de transferencias entre cuentas propias e interbancarias" "Java Spring Boot, PostgreSQL" "Microservice" {
                        # NIVEL 3 - COMPONENTES DEL TRANSFER SERVICE
                transferProcessor = component "Transfer Processor" "Procesa transferencias usando patrón Saga" "Spring Boot" transferService
                validationEngine = component "Validation Engine" "Valida reglas de negocio para transferencias" "Spring Boot" transferService
                externalBankIntegrator = component "External Bank Integrator" "Integración con redes interbancarias" "Spring Boot" transferService
                transactionLogger = component "Transaction Logger" "Registra transacciones para auditoría" "Spring Boot" transferService
                sagaOrchestrator = component "Saga Orchestrator" "Orquesta transacciones distribuidas" "Spring Boot" transferService
            }
            
            paymentService = container "Payment Service" "Servicio de pagos de servicios públicos, facturas y recaudos" "Java Spring Boot, PostgreSQL" "Microservice" {
                paymentProcessor = component "Payment Processor" "Procesa pagos a servicios" "Spring Boot" paymentService
                billerIntegrator = component "Biller Integrator" "Integración con empresas de servicios" "Spring Boot" paymentService
                paymentValidator = component "Payment Validator" "Valida pagos y referencias" "Spring Boot" paymentService
                scheduledPaymentManager = component "Scheduled Payment Manager" "Gestión de pagos programados" "Spring Boot" paymentService
                billQueryHandler = component "Bill Query Handler" "Consulta facturas y servicios disponibles" "Spring Boot" paymentService
                paymentHistoryManager = component "Payment History Manager" "Gestiona histórico de pagos realizados" "Spring Boot" paymentService
                reconciliationEngine = component "Reconciliation Engine" "Motor de conciliación de pagos con empresas" "Spring Boot + Batch Processing" paymentService
            }
            
            notificationService = container "Notification Service" "Servicio de envío de notificaciones multicanal" "Java Spring Boot, Apache Kafka" "Microservice" {
                # NIVEL 3 - COMPONENTES DEL NOTIFICATION SERVICE
                eventListener = component "Event Listener" "Escucha eventos del bus de mensajes" "Spring Boot" notificationService
                messageRouter = component "Message Router" "Enruta mensajes según canal y preferencias" "Spring Boot" notificationService
                templateEngine = component "Template Engine" "Genera contenido de notificaciones" "Spring Boot" notificationService
                deliveryStatusTracker = component "Delivery Status Tracker" "Rastrea estado de entrega de notificaciones" "Spring Boot" notificationService
                channelManager = component "Channel Manager" "Gestiona múltiples canales de notificación" "Spring Boot" notificationService
            }
            
            fraudService = container "Fraud Detection Service" "Servicio de detección de fraude en tiempo real" "Java Spring Boot, Machine Learning" "Microservice" {
                # NIVEL 3 - COMPONENTES DEL FRAUD DETECTION SERVICE
                riskEngine = component "Risk Engine" "Motor de análisis de riesgo en tiempo real usando ML" "Spring Boot + TensorFlow" fraudService
                ruleEngine = component "Rule Engine" "Motor de reglas de negocio para detección de patrones sospechosos" "Drools + Spring Boot" fraudService
                anomalyDetector = component "Anomaly Detector" "Detector de anomalías usando algoritmos de ML" "Python + scikit-learn" fraudService
                blacklistValidator = component "Blacklist Validator" "Validador contra listas negras y watchlists" "Spring Boot + Redis" fraudService
                behaviorAnalyzer = component "Behavior Analyzer" "Analizador de patrones de comportamiento del usuario" "Spring Boot + ML" fraudService
                geoLocationValidator = component "GeoLocation Validator" "Validador de ubicación geográfica y velocidad imposible" "Spring Boot" fraudService
                deviceFingerprinter = component "Device Fingerprinter" "Generador de huella digital de dispositivos" "Spring Boot + JavaScript" fraudService
                scoreCalculator = component "Score Calculator" "Calculador de score de riesgo consolidado" "Spring Boot" fraudService
                alertManager = component "Alert Manager" "Gestor de alertas y escalamiento automático" "Spring Boot + Kafka" fraudService
                mlModelManager = component "ML Model Manager" "Gestor de modelos de machine learning y reentrenamiento" "MLflow + Spring Boot" fraudService
            }
            
            auditService = container "Audit Service" "Servicio de auditoría y trazabilidad de transacciones" "Java Spring Boot, Event Sourcing" "Microservice" {
                # NIVEL 3 - COMPONENTES DEL AUDIT SERVICE
                eventStore = component "Event Store" "Almacén inmutable de eventos para auditoría" "EventStore DB + Spring Boot" auditService
                auditLogger = component "Audit Logger" "Logger especializado para eventos de auditoría" "Spring Boot + Logback" auditService
                complianceReporter = component "Compliance Reporter" "Generador de reportes regulatorios" "Spring Boot + JasperReports" auditService
                traceabilityManager = component "Traceability Manager" "Gestor de trazabilidad end-to-end de transacciones" "Spring Boot" auditService
                dataRetentionManager = component "Data Retention Manager" "Gestor de políticas de retención de datos" "Spring Boot + Scheduler" auditService
                encryptionManager = component "Encryption Manager" "Gestor de cifrado para datos sensibles en auditoría" "Spring Security + AES" auditService
                auditQueryEngine = component "Audit Query Engine" "Motor de consultas para búsquedas de auditoría" "Elasticsearch + Spring Boot" auditService
                regulatoryReporter = component "Regulatory Reporter" "Reportes automáticos a entidades reguladoras" "Spring Boot + SFTP" auditService
                integrityValidator = component "Integrity Validator" "Validador de integridad de logs de auditoría" "Spring Boot + Hash" auditService
                alertProcessor = component "Alert Processor" "Procesador de alertas de compliance y auditoría" "Spring Boot + Kafka" auditService
            }
            
            integrationLayer = container "Integration Layer" "Capa de integración con sistemas externos usando patrones de integración" "Apache Camel, Java Spring Boot" "Integration" {
                # NIVEL 3 - COMPONENTES DEL INTEGRATION LAYER
                messageRouterint = component "Message Router" "Enrutador de mensajes entre sistemas usando EIP" "Apache Camel" integrationLayer
                protocolAdapter = component "Protocol Adapter" "Adaptador para múltiples protocolos (SOAP, REST, FIX, ISO20022)" "Apache Camel + CXF" integrationLayer
                dataTransformer = component "Data Transformer" "Transformador de formatos de datos entre sistemas" "Apache Camel + XSLT" integrationLayer
                connectionPoolManager = component "Connection Pool Manager" "Gestor de pools de conexiones a sistemas externos" "Spring Boot + HikariCP" integrationLayer
                circuitBreakerManager = component "Circuit Breaker Manager" "Gestor de circuit breakers para sistemas externos" "Hystrix + Spring Boot" integrationLayer
                retryPolicyManager = component "Retry Policy Manager" "Gestor de políticas de reintento y fallback" "Spring Retry" integrationLayer
                messageQueue = component "Message Queue" "Cola de mensajes para procesamiento asíncrono" "Apache Camel + JMS" integrationLayer
                errorHandler = component "Error Handler" "Manejador centralizado de errores de integración" "Apache Camel + Spring Boot" integrationLayer
                securityGatewayint = component "Security Gateway" "Gateway de seguridad para sistemas externos" "Spring Security + OAuth2" integrationLayer
                monitoringCollector = component "Monitoring Collector" "Recolector de métricas de integraciones" "Micrometer + Spring Boot" integrationLayer
                schemaRegistry = component "Schema Registry" "Registro de esquemas para versionado de APIs" "Confluent Schema Registry" integrationLayer
            }
            
            
            drService = container "Disaster Recovery Service" "Servicio de respaldo, replicación y recuperación ante desastres" "Java Spring Boot, Azure Site Recovery" "Microservice" {
                backupOrchestrator = component "Backup Orchestrator" "Orquesta backups automáticos de bases de datos y estado de aplicaciones" "Spring Boot + Quartz" drService
                replicationManager = component "Replication Manager" "Gestiona replicación geo-redundante en múltiples regiones" "Azure Site Recovery SDK + Spring Boot" drService
                recoveryPlanner = component "Recovery Planner" "Planifica y ejecuta procedimientos de recuperación (RTO/RPO)" "Spring Boot + State Machine" drService
                healthChecker = component "Health Checker" "Monitorea salud de sistemas para failover automático" "Spring Boot + Actuator" drService
                failoverController = component "Failover Controller" "Ejecuta failover automático cuando se detectan fallos" "Spring Boot + Azure Traffic Manager API" drService
                snapshotManager = component "Snapshot Manager" "Gestiona snapshots point-in-time de datos críticos" "Spring Boot + Azure Backup API" drService
                recoveryTestExecutor = component "Recovery Test Executor" "Ejecuta pruebas periódicas de recuperación sin impacto" "Spring Boot + JUnit" drService
                dataConsistencyValidator = component "Data Consistency Validator" "Valida consistencia entre primario y réplicas" "Spring Boot + Checksum" drService
            }
            
            # Bases de Datos
            primaryDatabase = container "Primary Database" "Base de datos principal con información de clientes, cuentas y transacciones" "PostgreSQL" "Database"
            auditDatabase = container "Audit Database" "Base de datos de auditoría con eventos inmutables" "MongoDB" "Database"
            cacheLayer = container "Cache Layer" "Cache distribuido para datos de clientes frecuentes y sesiones" "Redis Cluster" "Cache"
            
            # Messaging
            eventBus = container "Event Bus" "Bus de eventos para comunicación asíncrona entre microservicios" "Apache Kafka" "Message Broker"
            
            # Monitoreo
            monitoringService = container "Monitoring Service" "Servicio de monitoreo, métricas y observabilidad" "Prometheus, Grafana, Jaeger" "Monitoring"
            
            
            #CONTENEDORES DE SEGURIDAD
            wafService = container "Web Application Firewall" "Protección contra OWASP Top 10, SQL injection, XSS, CSRF" "Azure Application Gateway WAF v2" "Security"
            
            ddosProtection = container "DDoS Protection" "Protección contra ataques de denegación de servicio distribuido" "Azure DDoS Protection Standard" "Security"
            
            secretsVault = container "Secrets Management" "Gestión centralizada de secretos, certificados y claves de cifrado" "Azure Key Vault Premium (HSM)" "Security"
        }
        
        
        # Definir los entornos de despliegue
    deploymentEnvironment "Production" {
        deploymentNode "Azure Cloud" {
            deploymentNode "Resource Group: bp-banking-prod" "" "Azure Resource Group" {
                deploymentNode "Azure Firewall" "" "Network Security" {
                    firewallInstance = deploymentNode "Firewall Instance" "" "Azure Firewall Premium" {
                        containerInstance firewall
                    }
                }
                deploymentNode "Azure Load Balancer" "" "Layer 4 Load Balancer" {
                    loadBalancerInstance = deploymentNode "Load Balancer Instance" "" "Azure Load Balancer Standard" {
                        containerInstance loadBalancer
                    }
                }
                deploymentNode "AKS Cluster" "" "Azure Kubernetes Service" {
                    deploymentNode "API Namespace" "" "Kubernetes Namespace" {
                        apiGatewayInstance = deploymentNode "API Gateway Pods" "" "Kubernetes Pod" {
                            containerInstance apiGateway
                        }
                        authServiceInstance = deploymentNode "Auth Service Pods" "" "Kubernetes Pod" {
                            containerInstance authService
                        }
                        accountServiceInstance = deploymentNode "Account Service Pods" "" "Kubernetes Pod" {
                            containerInstance accountService
                        }
                        customerProfileServiceInstance = deploymentNode "Customer Profile Service Pods" "" "Kubernetes Pod" {
                            containerInstance customerProfileService
                        }
                        transferServiceInstance = deploymentNode "Transfer Service Pods" "" "Kubernetes Pod" {
                            containerInstance transferService
                        }
                        paymentServiceInstance = deploymentNode "Payment Service Pods" "" "Kubernetes Pod" {
                            containerInstance paymentService
                        }
                        notificationServiceInstance = deploymentNode "Notification Service Pods" "" "Kubernetes Pod" {
                            containerInstance notificationService
                        }
                        fraudServiceInstance = deploymentNode "Fraud Service Pods" "" "Kubernetes Pod" {
                            containerInstance fraudService
                        }
                        auditServiceInstance = deploymentNode "Audit Service Pods" "" "Kubernetes Pod" {
                            containerInstance auditService
                        }
                        integrationServiceInstance = deploymentNode "Integration Service Pods" "" "Kubernetes Pod" {
                            containerInstance integrationLayer
                        }
                        drServiceInstance = deploymentNode "Disaster Recovery Service Pods" "" "Kubernetes Pod" {
                            containerInstance drService
                        }
                    }
                    deploymentNode "Azure Database for PostgreSQL" "" "PaaS Database" {
                        primaryDbInstance = deploymentNode "Primary DB Instance" "" "PostgreSQL 14" {
                            containerInstance primaryDatabase
                        }
                    }
                    deploymentNode "Azure Cosmos DB" "" "NoSQL Database" {
                        auditDbInstance = deploymentNode "Audit DB Instance" "" "MongoDB API" {
                            containerInstance auditDatabase
                        }
                    }
                    deploymentNode "Azure Cache for Redis" "" "Managed Redis" {
                        cacheInstance = deploymentNode "Redis Cluster" "" "Redis 6.2" {
                            containerInstance cacheLayer
                        }
                    }
                    deploymentNode "Azure Event Hubs" "" "Event Streaming" {
                        eventBusInstance = deploymentNode "Event Hub Namespace" "" "Event Hubs Standard" {
                            containerInstance eventBus
                        }
                    }
                    deploymentNode "Azure Monitor" "" "Monitoring Suite" {
                        monitoringInstance = deploymentNode "Monitoring Stack" "" "Azure Monitor + Grafana" {
                            containerInstance monitoringService
                        }
                    }
                }
                deploymentNode "Azure CDN" "" "Content Delivery Network" {
                    cdnInstance = deploymentNode "CDN Endpoint" "" "Azure CDN Standard"
                }
                deploymentNode "Azure Application Gateway" "" "Layer 7 Load Balancer" {
                    appGatewayInstance = deploymentNode "Application Gateway" "" "WAF v2"
                }
                
            }
            
            deploymentNode "Mobile Devices" "" "Client Devices" {
                deploymentNode "iOS/Android" "" "Mobile OS" {
                    mobileAppInstance = deploymentNode "BP Banking App" "" "Flutter Application" {
                        containerInstance mobileApp
                    }
                }
            }
            deploymentNode "Web Browsers" "" "Client Browsers" {
                deploymentNode "Browser" "" "Chrome/Safari/Edge" {
                    webBrowserInstance = deploymentNode "BP Banking Web" "" "React SPA" {
                        containerInstance webApp
                    }
                }
            }
        }
    }
    
    # DEPLOYMENT ENVIRONMENT - VISTA DE RED
    deploymentEnvironment "Network" {
        deploymentNode "Azure Cloud" {
            deploymentNode "Subscription: BP Banking" "" "Azure Subscription" {
                deploymentNode "Resource Group: bp-banking-network" "" "Network Resources" {
                    deploymentNode "Virtual Network: bp-banking-vnet" "" "10.0.0.0/16" {
                        deploymentNode "DMZ Subnet" "" "10.0.1.0/24 - Public Facing" {
                            deploymentNode "Azure Firewall" "" "10.0.1.4" {
                                containerInstance firewall
                            }
                            deploymentNode "Application Gateway" "" "10.0.1.5" {
                                appGatewayNetworkInstance = deploymentNode "WAF v2" "" "Layer 7 Load Balancer"
                            }
                            deploymentNode "Load Balancer" "" "10.0.1.6" {
                                containerInstance loadBalancer
                            }
                        }
                        deploymentNode "Application Subnet" "" "10.0.2.0/24 - Private" {
                            deploymentNode "AKS Cluster Network" "" "10.0.2.0/25" {
                                deploymentNode "API Gateway Nodes" "" "10.0.2.10-15" {
                                    containerInstance apiGateway
                                }
                                deploymentNode "Microservices Nodes" "" "10.0.2.20-50" {
                                    containerInstance authService
                                    containerInstance accountService
                                    containerInstance customerProfileService
                                    containerInstance paymentService
                                    containerInstance transferService
                                    containerInstance notificationService
                                    containerInstance drService
                                }
                            }
                        }
                        deploymentNode "Data Subnet" "" "10.0.3.0/24 - Private" {
                            deploymentNode "Database Cluster" "" "10.0.3.10-20" {
                                containerInstance primaryDatabase
                                containerInstance auditDatabase
                                containerInstance cacheLayer
                            }
                        }
                        deploymentNode "Integration Subnet" "" "10.0.4.0/24 - Private" {
                            deploymentNode "Event Hub Namespace" "" "10.0.4.10" {
                                containerInstance eventBus
                            }
                            deploymentNode "Integration Services" "" "10.0.4.20" {
                                containerInstance integrationLayer
                            }
                        }
                    }
                }
                deploymentNode "Network Security Groups" "" "Firewall Rules" {
                    deploymentNode "DMZ-NSG" "" "Allow HTTPS (443), Block all others"
                    deploymentNode "App-NSG" "" "Allow from DMZ only"
                    deploymentNode "Data-NSG" "" "Allow from App subnet only"
                    deploymentNode "Integration-NSG" "" "Allow App + External systems"
                }
                deploymentNode "Route Tables" "" "Traffic Routing" {
                    deploymentNode "DMZ-RouteTable" "" "Force tunnel to Firewall"
                    deploymentNode "App-RouteTable" "" "Route through Firewall"
                    deploymentNode "Data-RouteTable" "" "Internal only routing"
                }
            }
        }
    }
    
    # DEPLOYMENT ENVIRONMENT - VISTA DE SEGURIDAD
    deploymentEnvironment "Security" {
        deploymentNode "Azure Cloud Security" {
            deploymentNode "Identity & Access Management" "" "Azure AD / Entra ID" {
                deploymentNode "Azure Active Directory" "" "Identity Provider" {
                    deploymentNode "Service Principals" "" "App Registrations" {
                        containerInstance authService
                    }
                    deploymentNode "Managed Identities" "" "AKS Pod Identities" {
                        deploymentNode "Auth Service Identity" "" "MI for Key Vault access"
                        deploymentNode "Database Identities" "" "MI for DB access"
                    }
                }
                deploymentNode "Key Vault Premium" "" "HSM-backed Secrets Management" {
                    containerInstance secretsVault
                    deploymentNode "Secrets Store" "" "Secrets Management" {
                        deploymentNode "Certificates" "" "TLS/SSL Certificates"
                        deploymentNode "API Keys" "" "External service keys"
                        deploymentNode "Database Credentials" "" "Connection strings"
                        deploymentNode "JWT Signing Keys" "" "Token validation"
                        deploymentNode "Encryption Keys" "" "Data encryption keys"
                    }
                }
            }
            
            deploymentNode "Network Security" "" "Perimeter Defense" {
                # DDoS Protection (Capa más externa)
                deploymentNode "Azure DDoS Protection Standard" "" "Network Layer Protection" {
                    containerInstance ddosProtection
                    deploymentNode "DDoS Policies" "" "Protection policies" {
                        deploymentNode "Traffic Analytics" "" "Real-time monitoring"
                        deploymentNode "Attack Mitigation" "" "Automatic mitigation"
                        deploymentNode "Cost Protection" "" "SLA-backed protection"
                    }
                }
                
                # WAF (Capa de aplicación)
                deploymentNode "Application Gateway WAF v2" "" "OWASP Top 10 Protection" {
                    containerInstance wafService
                    deploymentNode "WAF Policies" "" "Protection rules" {
                        deploymentNode "OWASP Core Rules" "" "CRS 3.2"
                        deploymentNode "Custom Rules" "" "Banking-specific rules"
                        deploymentNode "Rate Limiting" "" "Request throttling"
                        deploymentNode "Geo-blocking" "" "Country restrictions"
                        deploymentNode "Bot Protection" "" "Anti-bot detection"
                    }
                }
                
                # Firewall (Capa de red tradicional)
                deploymentNode "Azure Firewall Premium" "" "IDPS + TLS Inspection" {
                    containerInstance firewall
                    deploymentNode "Firewall Rules" "" "Network filtering" {
                        deploymentNode "Network Rules" "" "IP/Port filtering"
                        deploymentNode "Application Rules" "" "FQDN filtering"
                        deploymentNode "IDPS" "" "Intrusion detection"
                        deploymentNode "TLS Inspection" "" "Deep packet inspection"
                    }
                }
            }
            
            deploymentNode "Application Security" "" "Runtime Protection" {
                deploymentNode "API Gateway Security" "" "OAuth2 + JWT validation" {
                    containerInstance apiGateway
                    deploymentNode "Security Policies" "" "API protection" {
                        deploymentNode "OAuth2 Server" "" "Token validation"
                        deploymentNode "Rate Limiter" "" "Request throttling"
                        deploymentNode "IP Whitelist" "" "Allowed IPs"
                        deploymentNode "Circuit Breaker" "" "Fault tolerance"
                    }
                }
                deploymentNode "Pod Security Policies" "" "Kubernetes security" {
                    deploymentNode "Non-root containers" "" "Security context"
                    deploymentNode "Read-only filesystems" "" "Immutable containers"
                    deploymentNode "Network policies" "" "Micro-segmentation"
                    deploymentNode "Resource limits" "" "CPU/Memory quotas"
                }
                deploymentNode "Service Mesh Security" "" "mTLS between services" {
                    deploymentNode "Istio/Linkerd" "" "Service mesh"
                    deploymentNode "mTLS Certificates" "" "Auto-rotation"
                    deploymentNode "Authorization Policies" "" "RBAC"
                }
            }
            
            deploymentNode "Data Security" "" "Encryption & Compliance" {
                deploymentNode "Encryption at Rest" "" "Database encryption" {
                    containerInstance primaryDatabase
                    containerInstance auditDatabase
                    containerInstance cacheLayer
                    deploymentNode "TDE" "" "Transparent Data Encryption"
                    deploymentNode "Backup Encryption" "" "Encrypted backups"
                }
                deploymentNode "Encryption in Transit" "" "TLS 1.3 everywhere" {
                    deploymentNode "TLS Configuration" "" "Strong ciphers only"
                    deploymentNode "Certificate Management" "" "Auto-renewal"
                }
                deploymentNode "Key Management" "" "Centralized key management" {
                    deploymentNode "HSM Integration" "" "Hardware Security Module"
                    deploymentNode "Key Rotation" "" "Automatic rotation policies"
                    deploymentNode "Key Versioning" "" "Key lifecycle management"
                }
                deploymentNode "Compliance" "" "PCI DSS, SOX, Basel III" {
                    containerInstance auditService
                    deploymentNode "Compliance Reports" "" "Automated reporting"
                    deploymentNode "Data Retention" "" "7-year retention policy"
                    deploymentNode "Right to be Forgotten" "" "GDPR compliance"
                }
            }
            
            deploymentNode "Monitoring & Threat Detection" "" "Security Operations" {
                deploymentNode "Azure Sentinel" "" "SIEM + SOAR" {
                    deploymentNode "Threat Intelligence" "" "Global threat feeds"
                    deploymentNode "Security Playbooks" "" "Automated response"
                    deploymentNode "Incident Management" "" "Case management"
                }
                deploymentNode "Defender for Cloud" "" "Workload protection" {
                    deploymentNode "Container Security" "" "AKS protection"
                    deploymentNode "Database Security" "" "SQL protection"
                    deploymentNode "Key Vault Protection" "" "Secrets monitoring"
                }
                deploymentNode "Log Analytics Workspace" "" "Centralized logging" {
                    containerInstance monitoringService
                    deploymentNode "Security Logs" "" "All security events"
                    deploymentNode "Audit Logs" "" "Compliance logs"
                    deploymentNode "Performance Metrics" "" "System metrics"
                }
                deploymentNode "Fraud Detection" "" "ML-based detection" {
                    containerInstance fraudService
                    deploymentNode "Real-time Scoring" "" "Transaction scoring"
                    deploymentNode "Anomaly Detection" "" "Behavioral analysis"
                    deploymentNode "Alert Management" "" "Incident alerts"
                }
            }
        }
    }
        
        # RELACIONES NIVEL 1 - CONTEXTO
        customer -> bpBankingSystem "Utiliza servicios de banca por internet"
        bankEmployee -> bpBankingSystem "Administra y monitorea el sistema"
        auditor -> bpBankingSystem "Revisa transacciones y cumplimiento"
        
        bpBankingSystem -> coreBankingSystem "Consulta información de clientes, cuentas y productos"
        bpBankingSystem -> complementarySystem "Obtiene información detallada del cliente"
        bpBankingSystem -> smsProvider "Envía notificaciones SMS"
        bpBankingSystem -> emailProvider "Envía notificaciones por email"
        bpBankingSystem -> interbankingNetwork "Procesa transferencias interbancarias"
        bpBankingSystem -> biometricProvider "Valida identidad biométrica"
        
        # RELACIONES NIVEL 2 - CONTENEDORES CON FIREWALL Y LOAD BALANCER
        customer -> webApp "Accede a banca por internet"
        customer -> mobileApp "Utiliza aplicación móvil"
        bankEmployee -> monitoringService "Monitorea sistema y transacciones"
        auditor -> auditService "Consulta logs de auditoría"
        
        # NUEVO FLUJO: Web/Mobile -> Firewall -> Load Balancer -> API Gateway
        webApp -> firewall "Peticiones HTTPS [Port 443/HTTPS]"
        mobileApp -> firewall "Peticiones HTTPS [Port 443/HTTPS]"
        
        firewall -> loadBalancer "Tráfico filtrado [HTTPS]"
        
        loadBalancer -> apiGateway "Tráfico balanceado [HTTPS/JSON]"
        
        apiGateway -> authService "Valida tokens JWT [HTTPS]"
        apiGateway -> accountService "Enruta consultas de cuentas [HTTPS]"
        apiGateway -> transferService "Enruta transferencias [HTTPS]"
        apiGateway -> notificationService "Enruta notificaciones [HTTPS]"
        apiGateway -> customerProfileService "Enruta consultas de perfil [HTTPS]"
        apiGateway -> paymentService "Enruta pagos de servicios [HTTPS]"
        
        authService -> integrationLayer "Valida usuario en Core Banking durante onboarding [HTTPS/REST]"
        authService -> biometricProvider "Valida biometría [HTTPS/REST]"
        authService -> primaryDatabase "Consulta usuarios [JDBC]"
        authService -> cacheLayer "Almacena sesiones [Redis Protocol]"
        authService -> customerProfileService "Obtiene perfil después de login [HTTPS/gRPC]"
        
        accountService -> integrationLayer "Consulta datos de cuentas [HTTP/JMS]"
        accountService -> customerProfileService "Consulta datos de cliente [HTTPS/gRPC]"
        accountService -> primaryDatabase "Almacena información de cuentas [JDBC]"
        accountService -> cacheLayer "Cache datos frecuentes [Redis Protocol]"
        accountService -> eventBus "Publica eventos de consulta [Kafka Protocol]"
        
        #Relaciones Perfil de Cliente
        customerProfileService -> integrationLayer "Consulta ambos sistemas [HTTP]"
        customerProfileService -> primaryDatabase "Almacena perfil consolidado [JDBC]"
        customerProfileService -> cacheLayer "Cache-Aside pattern [Redis]"
        customerProfileService -> eventBus "Publica eventos de perfil [Kafka]"
        
        transferService -> accountService "Valida saldo y estado de cuenta [HTTPS/gRPC]"
        transferService -> customerProfileService "Valida perfil para transferencias [HTTPS/gRPC]"
        transferService -> integrationLayer "Procesa transferencias [HTTP/JMS]"
        transferService -> primaryDatabase "Almacena transacciones [JDBC]"
        transferService -> eventBus "Publica eventos de transferencia [Kafka Protocol]"
        transferService -> fraudService "Valida fraude [HTTPS]"
        
        
        # Hacia sistemas externos
        paymentService -> integrationLayer "Procesa pagos en Core Banking y empresas de servicios [HTTP/JMS]"
        paymentService -> primaryDatabase "Almacena transacciones de pago [JDBC]"
        paymentService -> eventBus "Publica eventos de pago [Kafka Protocol]"
        
        # Interacción con otros servicios
        paymentService -> fraudService "Valida pago antes de procesar [HTTPS/gRPC]"
        paymentService -> accountService "Verifica saldo disponible [HTTPS/gRPC]"
        paymentService -> notificationService "Solicita envío de confirmación [HTTPS]"
        
        notificationService -> eventBus "Consume eventos [Kafka Protocol]"
        notificationService -> smsProvider "Envía SMS [HTTPS/REST]"
        notificationService -> emailProvider "Envía emails [SMTP/HTTPS]"
        
        fraudService -> eventBus "Consume eventos de transacciones [Kafka Protocol]"
        fraudService -> primaryDatabase "Consulta patrones [JDBC]"
        fraudService -> integrationLayer "Consulta listas externas [HTTP]"
        fraudService -> customerProfileService "Consulta patrones de comportamiento [HTTPS/gRPC]"
        
        auditService -> eventBus "Consume todos los eventos [Kafka Protocol]"
        auditService -> auditDatabase "Almacena eventos de auditoría [MongoDB Protocol]"
        
        integrationLayer -> coreBankingSystem "Integra con core banking [SOAP/REST]"
        integrationLayer -> complementarySystem "Integra con sistema complementario [REST]"
        integrationLayer -> interbankingNetwork "Procesa transferencias externas [ISO 20022/SWIFT]"
        integrationLayer -> paymentService "Notificaciones de empresas de servicios [HTTP Webhook]"

        
        monitoringService -> apiGateway "Recolecta métricas [HTTP]"
        monitoringService -> authService "Recolecta métricas [HTTP]"
        monitoringService -> accountService "Recolecta métricas [HTTP]"
        monitoringService -> transferService "Recolecta métricas [HTTP]"
        monitoringService -> notificationService "Recolecta métricas [HTTP]"
        monitoringService -> paymentService "Recolecta métricas de pagos [HTTP]"
        
        
        # RELACIONES NIVEL 2 - DR SERVICE

        # Acceso administrativo
        bankEmployee -> drService "Gestiona planes de DR y ejecuta recuperaciones [HTTPS]"
        apiGateway -> drService "API de estado de DR [HTTPS]"
        
        # Monitoreo de servicios críticos
        drService -> apiGateway "Health check continuo [HTTP]"
        drService -> authService "Health check [HTTP]"
        drService -> accountService "Health check [HTTP]"
        drService -> transferService "Health check [HTTP]"
        drService -> paymentService "Health check [HTTP]"
        
        # Gestión de bases de datos
        drService -> primaryDatabase "Backup y replicación [PostgreSQL Protocol]"
        drService -> auditDatabase "Backup y replicación [MongoDB Protocol]"
        drService -> cacheLayer "Snapshot de estado [Redis Protocol]"
        
        # Integración con infraestructura
        drService -> loadBalancer "Control de failover [API]"
        drService -> eventBus "Backup de eventos [Kafka Protocol]"
        
        # Notificaciones
        drService -> notificationService "Alertas de DR [HTTPS]"
        drService -> eventBus "Publica eventos de DR [Kafka]"
        
        # Monitoreo
        monitoringService -> drService "Recolecta métricas de DR [HTTP]"
        drService -> monitoringService "Estado de backups y réplicas [HTTP]"
        
        
        
        # RELACIONES NIVEL 2 - SEGURIDAD

        # ============ WAF SERVICE ============
        
        # Tráfico de clientes pasa por WAF primero
        customer -> wafService "Tráfico HTTPS desde clientes [Port 443]"
        webApp -> wafService "Peticiones HTTPS [Port 443]"
        mobileApp -> wafService "Peticiones HTTPS [Port 443]"
        
        # WAF filtra y pasa a Firewall
        wafService -> firewall "Tráfico filtrado sin amenazas [HTTPS]"
        
        # WAF analiza patrones
        wafService -> monitoringService "Logs de amenazas detectadas [HTTP]"
        wafService -> auditService "Registra intentos de ataque [HTTPS]"
        
        wafService -> wafService "Inspecciona OWASP Top 10"
        
        # Configuración dinámica
        fraudService -> wafService "Actualiza reglas de bloqueo dinámico [Azure API]"
        
        # ============ DDoS PROTECTION ============
        
        # DDoS protege antes que WAF (capa de red)
        customer -> ddosProtection "Todo el tráfico de red [Layer 3/4]"
        webApp -> ddosProtection "Tráfico de aplicaciones [Layer 3/4]"
        mobileApp -> ddosProtection "Tráfico móvil [Layer 3/4]"
        
        # DDoS pasa tráfico legítimo a WAF
        ddosProtection -> wafService "Tráfico validado [Layer 7]"
        
        # Monitoreo y alertas
        ddosProtection -> monitoringService "Métricas de ataques mitigados [HTTP]"
        ddosProtection -> notificationService "Alerta de ataque DDoS [HTTPS]"
        ddosProtection -> ddosProtection "Valida rate & patterns"
        
        # ============ SECRETS VAULT ============
        
        # Todos los servicios consultan secretos
        apiGateway -> secretsVault "Obtiene certificados TLS [Azure Key Vault API]"
        authService -> secretsVault "Obtiene JWT signing keys [Azure Key Vault API]"
        accountService -> secretsVault "Obtiene DB credentials [Azure Key Vault API]"
        transferService -> secretsVault "Obtiene API keys externas [Azure Key Vault API]"
        paymentService -> secretsVault "Obtiene certificados de empresas [Azure Key Vault API]"
        notificationService -> secretsVault "Obtiene API keys de SMS/Email [Azure Key Vault API]"
        integrationLayer -> secretsVault "Obtiene credenciales Core Banking [Azure Key Vault API]"
        fraudService -> secretsVault "Obtiene ML model encryption keys [Azure Key Vault API]"
        auditService -> secretsVault "Obtiene encryption keys [Azure Key Vault API]"
        
        # Gestión de secretos
        bankEmployee -> secretsVault "Administra secretos y rotación [Azure Portal/CLI]"
        
        # Integración con bases de datos
        primaryDatabase -> secretsVault "Transparent Data Encryption keys [Azure API]"
        auditDatabase -> secretsVault "Encryption keys [Azure API]"
        
        # Auditoría de acceso
        secretsVault -> auditService "Registra acceso a secretos [HTTPS]"
        secretsVault -> monitoringService "Métricas de uso de secretos [HTTP]"
        
        # Rotación automática
        secretsVault -> authService "Notifica rotación de keys [Webhook]"
        secretsVault -> integrationLayer "Notifica cambio de credenciales [Webhook]"
        
        
        
        
        
        
        
        
        
        
        
        

        
        # RELACIONES NIVEL 3 - COMPONENTES API GATEWAY (ACTUALIZADAS)
        loadBalancer -> rateLimiter "Peticiones balanceadas [HTTPS]"
        rateLimiter -> loadBalancerComponent "Peticiones filtradas"
        loadBalancerComponent -> securityGateway "Peticiones balanceadas"
        securityGateway -> circuitBreaker "Peticiones autenticadas"
        circuitBreaker -> requestTransformer "Peticiones validadas"
        requestTransformer -> responseTransformer "Peticiones transformadas"
        
        # RELACIONES NIVEL 3 - COMPONENTES AUTH SERVICE
        securityGateway -> tokenValidator "Validación de tokens [HTTP]"
        requestTransformer -> oauthServer "Solicitudes de autenticación [HTTP]"
        oauthServer -> coreBankingValidator "Valida usuario antes de registro [Java]"
        coreBankingValidator -> integrationLayer "Consulta cliente en Core Banking [HTTPS/REST]"
        #Para la validacion de usuario en el corebank
        coreBankingValidator -> userManager "Usuario validado en Core Banking [Java]"
        userManager -> primaryDatabase "Crea usuario local [JPA]"
        
        
        oauthServer -> userManager "Gestión de usuarios [JPA]"
        oauthServer -> mfaManager "Validación MFA [HTTP]"
        mfaManager -> biometricValidator "Validación biométrica [HTTP]"
        sessionManager -> cacheLayer "Almacenar sesiones [Redis]"
        
        # RELACIONES NIVEL 3 - COMPONENTES ACCOUNT SERVICE
        requestTransformer -> accountQueryHandler "Consultas de cuenta [HTTP]"
        accountQueryHandler -> accountValidator "Validación de permisos [Java]"
        accountValidator -> balanceCalculator "Cálculo de saldos [Java]"
        balanceCalculator -> movementHistoryManager "Consulta movimientos [Java]"
        cacheManager -> cacheLayer "Operaciones de caché [Redis]"
        
        #RELACIONES NIVEL 3 - COMPONENTES CUSTOMER PROFILE SERVICE

        #Flujo de consulta (CQRS Read)
        requestTransformer -> profileQueryHandler "Consultas de perfil [HTTP]"
        profileQueryHandler -> cacheStrategyManager "Verifica cache primero [Java]"
        
        #Cache Hit
        cacheStrategyManager -> cacheLayer "GET profile:{customerId} [Redis]"
        cacheLayer -> cacheStrategyManager "Perfil en cache [Redis]"
        cacheStrategyManager -> profileQueryHandler "Retorna perfil cacheado [Java]"
        
        #Cache Miss
        cacheStrategyManager -> profileAggregator "Cache miss, consultar fuentes [Java]"
        profileAggregator -> integrationLayer "Consulta paralela Core Banking + Complementario [HTTP]"
        integrationLayer -> profileAggregator "Datos de ambos sistemas [HTTP]"
        profileAggregator -> dataEnricher "Enriquece datos agregados [Java]"
        dataEnricher -> profileValidator "Valida perfil enriquecido [Java]"
        profileValidator -> cacheStrategyManager "Almacena en cache [Java]"
        cacheStrategyManager -> cacheLayer "SET profile:{customerId} TTL 3600 [Redis]"
        
        #Flujo de actualización (CQRS Write)
        requestTransformer -> profileUpdateHandler "Actualización de perfil [HTTP]"
        profileUpdateHandler -> profileValidator "Valida datos de entrada [Java]"
        profileValidator -> primaryDatabase "UPDATE customer_profiles [JDBC]"
        profileUpdateHandler -> eventPublisher "Publica ProfileUpdated event [Java]"
        eventPublisher -> eventBus "Publish: ProfileUpdated [Kafka]"
        
        #Sincronización con sistemas externos
        profileUpdateHandler -> integrationLayer "Sincroniza cambios con Core Banking [HTTP]"
        
        # RELACIONES NIVEL 3 - COMPONENTES TRANSFER SERVICE
        requestTransformer -> transferProcessor "Solicitudes de transferencia [HTTP]"
        transferProcessor -> validationEngine "Validación de reglas [Java]"
        validationEngine -> sagaOrchestrator "Orquestación de transacción [Java]"
        validationEngine -> accountService "Valida cuentas (saldos, estados, etc) [HTTPS/grpc]"
        sagaOrchestrator -> externalBankIntegrator "Transferencias externas [HTTP]"
        transactionLogger -> eventBus "Eventos de transacción [Kafka]"
        
        # RELACIONES NIVEL 3 - COMPONENTES NOTIFICATION SERVICE
        eventListener -> eventBus "Consumo de eventos [Kafka]"
        eventListener -> messageRouter "Procesamiento de eventos [Java]"
        messageRouter -> templateEngine "Generación de contenido [Java]"
        templateEngine -> channelManager "Envío por canales [Java]"
        channelManager -> deliveryStatusTracker "Tracking de entrega [Java]"
        
         # RELACIONES NIVEL 3 - COMPONENTES FRAUD SERVICE
        requestTransformer -> riskEngine "Solicitudes de validación de fraude [HTTP]"
        riskEngine -> ruleEngine "Evaluación de reglas [Java]"
        riskEngine -> anomalyDetector "Detección de anomalías [HTTP/gRPC]"
        ruleEngine -> blacklistValidator "Validación contra listas [Redis]"
        behaviorAnalyzer -> geoLocationValidator "Análisis de ubicación [Java]"
        deviceFingerprinter -> scoreCalculator "Datos de dispositivo [Java]"
        scoreCalculator -> alertManager "Scores de riesgo [Java]"
        mlModelManager -> anomalyDetector "Modelos actualizados [MLflow API]"
        alertManager -> eventBus "Alertas de fraude [Kafka]"
        
        # RELACIONES NIVEL 3 - COMPONENTES AUDIT SERVICE
        eventListener -> auditLogger "Eventos para auditoría [Java]"
        auditLogger -> eventStore "Almacenamiento de eventos [EventStore Protocol]"
        traceabilityManager -> auditQueryEngine "Consultas de trazabilidad [Elasticsearch]"
        complianceReporter -> regulatoryReporter "Reportes regulatorios [Java]"
        encryptionManager -> eventStore "Cifrado de eventos [AES]"
        integrityValidator -> eventStore "Validación de integridad [Hash verification]"
        dataRetentionManager -> eventStore "Políticas de retención [Scheduled tasks]"
        alertProcessor -> eventBus "Alertas de compliance [Kafka]"
        
        # RELACIONES NIVEL 3 - COMPONENTES INTEGRATION LAYER
        messageRouterint -> protocolAdapter "Enrutamiento de mensajes [Camel Routes]"
        protocolAdapter -> dataTransformer "Transformación de datos [Camel Exchange]"
        connectionPoolManager -> securityGatewayint "Conexiones seguras [Connection Pool]"
        circuitBreakerManager -> retryPolicyManager "Políticas de fallo [Hystrix]"
        errorHandler -> messageQueue "Manejo de errores [JMS]"
        monitoringCollector -> monitoringService "Métricas de integración [Micrometer]"
        schemaRegistry -> dataTransformer "Versionado de esquemas [Avro/JSON Schema]"
        
        
        
        # RELACIONES NIVEL 3 - COMPONENTES PAYMENT SERVICE
        
        # Flujo de consulta de factura
        requestTransformer -> billQueryHandler "Consulta factura [HTTP]"
        billQueryHandler -> billerIntegrator "Consulta en empresa de servicios [HTTP]"
        billerIntegrator -> integrationLayer "GET /billers/{company}/bill/{reference} [HTTP]"
        integrationLayer -> billerIntegrator "Datos de factura [HTTP]"
        billerIntegrator -> billQueryHandler "Retorna factura [Java]"
        
        # Flujo de pago inmediato
        requestTransformer -> paymentProcessor "Solicitud de pago [HTTP]"
        paymentProcessor -> paymentValidator "Valida datos de pago [Java]"
        
        # Validación de saldo (llamada externa)
        paymentValidator -> accountService "Verifica saldo [gRPC]"
        accountService -> paymentValidator "Saldo disponible: OK [gRPC]"
        
        # Validación de fraude (llamada externa)
        paymentValidator -> fraudService "Valida transacción [gRPC]"
        fraudService -> paymentValidator "Risk score: LOW [gRPC]"
        
        # Procesamiento (Saga Pattern)
        paymentProcessor -> billerIntegrator "Ejecuta pago en empresa [HTTP]"
        billerIntegrator -> integrationLayer "POST /billers/{company}/payment [HTTP]"
        integrationLayer -> billerIntegrator "Confirmación de pago [HTTP]"
        
        # Débito en cuenta
        paymentProcessor -> integrationLayer "Débito en Core Banking [HTTP]"
        integrationLayer -> coreBankingSystem "Ejecuta débito [ISO 20022]"
        
        # Persistencia
        paymentProcessor -> primaryDatabase "INSERT INTO payments [JDBC]"
        paymentProcessor -> paymentHistoryManager "Registra en histórico [Java]"
        paymentHistoryManager -> primaryDatabase "INSERT INTO payment_history [JDBC]"
        
        # Eventos
        paymentProcessor -> eventBus "Publish: PaymentCompleted [Kafka]"
        
        # Flujo de pago programado
        requestTransformer -> scheduledPaymentManager "Crear pago programado [HTTP]"
        scheduledPaymentManager -> primaryDatabase "INSERT INTO scheduled_payments [JDBC]"
        scheduledPaymentManager -> paymentProcessor "Ejecuta en fecha programada [Cron]"
        
        # Reconciliación (proceso batch)
        reconciliationEngine -> primaryDatabase "SELECT payments WHERE status='PENDING' [JDBC]"
        reconciliationEngine -> billerIntegrator "Consulta estado en empresa [HTTP]"
        reconciliationEngine -> primaryDatabase "UPDATE payment status [JDBC]"
        
        
        # RELACIONES NIVEL 3 - COMPONENTES DR SERVICE

        # Flujo de backup automático (scheduled)
        backupOrchestrator -> snapshotManager "Inicia backup programado [Java]"
        snapshotManager -> primaryDatabase "CREATE SNAPSHOT [PostgreSQL]"
        snapshotManager -> auditDatabase "CREATE BACKUP [MongoDB]"
        snapshotManager -> cacheLayer "BGSAVE [Redis]"
        snapshotManager -> backupOrchestrator "Backup completado [Java]"
        
        # Replicación continua
        backupOrchestrator -> replicationManager "Sincroniza con región secundaria [Java]"
        replicationManager -> primaryDatabase "Configura replicación streaming [PostgreSQL]"
        replicationManager -> auditDatabase "Configura replica set [MongoDB]"
        replicationManager -> dataConsistencyValidator "Valida consistencia [Java]"
        dataConsistencyValidator -> primaryDatabase "Checksum datos primarios [SQL]"
        dataConsistencyValidator -> replicationManager "Datos consistentes [Java]"
        
        # Monitoreo de salud (continuo)
        healthChecker -> apiGateway "GET /health [HTTP]"
        healthChecker -> authService "GET /actuator/health [HTTP]"
        healthChecker -> accountService "GET /actuator/health [HTTP]"
        healthChecker -> transferService "GET /actuator/health [HTTP]"
        healthChecker -> primaryDatabase "SELECT 1 [JDBC]"
        
        # Detección de fallo crítico
        healthChecker -> failoverController "Servicio crítico caído [Java]"
        failoverController -> recoveryPlanner "Evalúa necesidad de failover [Java]"
        recoveryPlanner -> failoverController "Ejecutar failover a DR site [Java]"
        
        # Ejecución de failover
        failoverController -> loadBalancer "Redirige tráfico a región DR [Azure API]"
        failoverController -> primaryDatabase "Promote replica to primary [PostgreSQL]"
        failoverController -> eventBus "Publish: FailoverExecuted [Kafka]"
        failoverController -> notificationService "Notifica a operaciones [HTTP]"
        
        # Pruebas de recuperación (periódicas)
        recoveryTestExecutor -> recoveryPlanner "Simula escenario de desastre [Java]"
        recoveryPlanner -> snapshotManager "Restaura snapshot de prueba [Java]"
        snapshotManager -> primaryDatabase "RESTORE DATABASE test_recovery [PostgreSQL]"
        recoveryTestExecutor -> dataConsistencyValidator "Valida datos restaurados [Java]"
        dataConsistencyValidator -> recoveryTestExecutor "RTO: 15min, RPO: 5min - OK [Java]"
        
        # Recuperación ante desastre real
        bankEmployee -> recoveryPlanner "Inicia recuperación manual [HTTP]"
        recoveryPlanner -> snapshotManager "Selecciona punto de recuperación [Java]"
        snapshotManager -> primaryDatabase "RESTORE DATABASE [PostgreSQL]"
        recoveryPlanner -> replicationManager "Re-establece replicación [Java]"
        recoveryPlanner -> healthChecker "Valida servicios restaurados [Java]"
        recoveryPlanner -> eventBus "Publish: RecoveryCompleted [Kafka]"
        
    
    }

    views {
        # VISTA DE CONTEXTO (C1)
        systemContext bpBankingSystem "SystemContext" {
            include *
            animation {
                customer
                bpBankingSystem
                coreBankingSystem complementarySystem
                smsProvider emailProvider interbankingNetwork biometricProvider
                bankEmployee auditor
            }
            autoLayout tb 300 100
            title "BP Banking System - Context Diagram (C1)"
            description "Vista de contexto del sistema de banca por internet, mostrando usuarios y sistemas externos"
        }

        # VISTA DE CONTENEDORES (C2) - ACTUALIZADA CON FIREWALL Y LOAD BALANCER
        container bpBankingSystem "ContainerView" {
            include *
            animation {
                customer webApp mobileApp
                firewall loadBalancer
                apiGateway
                authService accountService customerProfileService paymentService transferService notificationService
                fraudService auditService integrationLayer
                primaryDatabase auditDatabase cacheLayer eventBus
                monitoringService drService
            }
            autoLayout
            title "BP Banking System - Container Diagram (C2)"
            description "Vista de contenedores mostrando aplicaciones y servicios, incluyendo firewall y load balancer"
        }

        # VISTA DE COMPONENTES - API GATEWAY (C3)
        component apiGateway "ApiGatewayComponents" {
            include *
            animation {
                rateLimiter loadBalancerComponent securityGateway
                circuitBreaker requestTransformer responseTransformer
            }
            autoLayout
            title "API Gateway - Component Diagram (C3)"
            description "Componentes internos del API Gateway mostrando el flujo de procesamiento de requests"
        }

        # VISTA DE COMPONENTES - AUTHENTICATION SERVICE (C3)
        component authService "AuthServiceComponents" {
            include *
            animation {
                oauthServer userManager mfaManager
                biometricValidator sessionManager tokenValidator
            }
            autoLayout
            title "Authentication Service - Component Diagram (C3)"
            description "Componentes del servicio de autenticación y autorización OAuth2"
        }

        # VISTA DE COMPONENTES - ACCOUNT SERVICE (C3)
        component accountService "AccountServiceComponents" {
            include *
            animation {
                accountQueryHandler accountValidator balanceCalculator
                movementHistoryManager cacheManager
            }
            autoLayout
            title "Account Service - Component Diagram (C3)"
            description "Componentes del servicio de gestión de cuentas y consulta de movimientos"
        }
        
        # VISTA DE COMPONENTES - CUSTOMER PROFILE SERVICE (C3)
        component customerProfileService "CustomerProfileServiceComponents" {
            include *
            animation {
                profileAggregator cacheStrategyManager dataEnricher profileValidator
            }
            autoLayout
            title "Customer Profile Service - Component Diagram (C3)"
            description "Componentes del servicio de gestión de perfiles de los clientes"
        }

        # VISTA DE COMPONENTES - TRANSFER SERVICE (C3)
        component transferService "TransferServiceComponents" {
            include *
            animation {
                transferProcessor validationEngine sagaOrchestrator
                externalBankIntegrator transactionLogger
            }
            autoLayout
            title "Transfer Service - Component Diagram (C3)"
            description "Componentes del servicio de transferencias con patrón Saga"
        }
        
        # VISTA DE COMPONENTES - PAYMENT SERVICE (C3)
        component paymentService "PaymentServiceComponents" {
            include *
            animation {
                paymentProcessor  billerIntegrator  paymentValidator
                scheduledPaymentManager  billQueryHandler paymentHistoryManager reconciliationEngine
            }
            autoLayout
            title "Payment Service - Component Diagram (C3)"
            description "Componentes del servicio de pagos"
        }

        # VISTA DE COMPONENTES - NOTIFICATION SERVICE (C3)
        component notificationService "NotificationServiceComponents" {
            include *
            animation {
                eventListener messageRouter templateEngine
                channelManager deliveryStatusTracker
            }
            autoLayout
            title "Notification Service - Component Diagram (C3)"
            description "Componentes del servicio de notificaciones multicanal"
        }
        
        # VISTA DE COMPONENTES - FRAUD DETECTION SERVICE (C3)
        component fraudService "FraudServiceComponents" {
            include *
            animation {
                riskEngine ruleEngine anomalyDetector
                blacklistValidator behaviorAnalyzer geoLocationValidator
                deviceFingerprinter scoreCalculator alertManager mlModelManager
            }
            autoLayout
            title "Fraud Detection Service - Component Diagram (C3)"
            description "Componentes del servicio de detección de fraude con ML y análisis de riesgo en tiempo real"
        }

        # VISTA DE COMPONENTES - AUDIT SERVICE (C3)
        component auditService "AuditServiceComponents" {
            include *
            animation {
                eventStore auditLogger complianceReporter
                traceabilityManager dataRetentionManager encryptionManager
                auditQueryEngine regulatoryReporter integrityValidator alertProcessor
            }
            autoLayout
            title "Audit Service - Component Diagram (C3)"
            description "Componentes del servicio de auditoría con event sourcing y compliance regulatorio"
        }

        # VISTA DE COMPONENTES - INTEGRATION LAYER (C3)
        component integrationLayer "IntegrationLayerComponents" {
            include *
            animation {
                messageRouter protocolAdapter dataTransformer
                connectionPoolManager circuitBreakerManager retryPolicyManager
                messageQueue errorHandler securityGateway
                monitoringCollector schemaRegistry
            }
            autoLayout
            title "Integration Layer - Component Diagram (C3)"
            description "Componentes de la capa de integración con patrones EIP y sistemas externos"
        }
        
        # VISTA DE COMPONENTES - DISASTER RECOVERY SERVICE (C3)
        component drService "DisasterRecoveryServiceComponents" {
            include *
            animation {
                backupOrchestrator replicationManager recoveryPlanner
                healthChecker failoverController snapshotManager
                recoveryTestExecutor dataConsistencyValidator
            }
            autoLayout
            title "Disaster Recovery Service - Component Diagram (C3)"
            description "Componentes de la capa de recuperación ante desastres"
        }
        
        #WEB Y MOVIL
        component webApp "WebAppComponents"{
            include *
            animation { 
                uiLayer serviceLayer authAdapter offlineManager storage apiClient 
            }
            autoLayout
            title "Web Application - Component Diagram (C3)"
            description "Componentes internos de la SPA y cómo consumen el API Gateway"
        }
        
        
        component mobileApp "MobileAppComponents" {
            include *
            animation {
                ui networkLayer authAdapterMobile offlineSync biometricIntegration 
            }
            autoLayout
            title "Mobile Application - Component Diagram (C3)"
            description "Componentes de la app móvil (Onboarding con biometría, auth y sincronización offline)"
        }

        # VISTA DE DEPLOYMENT - AZURE CLOUD (ARQUITECTURA GENERAL)
    deployment bpBankingSystem "Production" "AzureDeployment" {
        include *
        autolayout tb
        title "BP Banking System - Azure Production Deployment"
        description "Despliegue en producción en Azure con firewall, load balancer, alta disponibilidad y escalabilidad"
    }
    
        # VISTA DE DEPLOYMENT - NETWORKING (INFRAESTRUCTURA DE RED)
    deployment bpBankingSystem "Network" "NetworkView" {
        include *
        autolayout tb
        title "BP Banking System - Network Architecture"
        description "Vista detallada de la arquitectura de red, subnets, NSGs y routing en Azure"
    }
    
        # VISTA DE DEPLOYMENT - SECURITY (ARQUITECTURA DE SEGURIDAD)
    deployment bpBankingSystem "Security" "SecurityView" {
        include *
        autolayout tb
        title "BP Banking System - Security Architecture"
        description "Vista completa de la arquitectura de seguridad, incluyendo IAM, cifrado, monitoreo y compliance"
    }
    
    #Diagrama de Secuencia: Flujo de Autenticación OAuth2

    dynamic bpBankingSystem "AuthenticationFlow" "Flujo de autenticación OAuth2 con biometría" {
        customer -> webApp "1. Inicia sesión"
        webApp -> firewall "2. Solicita autenticación (Filtro de Seguridad)"
        firewall -> loadBalancer "3. Envia Solicitud a balanceador"
        loadBalancer -> apiGateway "4. Envia solicitud a API Gateway"
        apiGateway -> authService "5. Valida credenciales"
        authService -> biometricProvider "6. Valida biometría (onboarding)"
        biometricProvider -> authService "7. Confirma identidad"
        authService -> primaryDatabase "8. Verifica usuario"
        authService -> cacheLayer "9. Crea sesión"
        authService -> apiGateway "10. Retorna JWT token"
        apiGateway -> loadBalancer "11. Retorna JWT token"
        loadBalancer -> firewall "11. Retorna JWT token"
        firewall -> webApp "12. Token de acceso"
        autoLayout
        title "Flujo de Autenticación OAuth2 con Biometría"
    }
    
    #Diagrama de Secuencia - Proceso de Transferencia con Saga
    dynamic bpBankingSystem "TransferSagaFlow" "Patrón Saga para transferencias distribuidas" {
        webApp -> firewall "1. Solicita transferencia (Filtro de Seguridad)"
        firewall -> loadBalancer "2. Envia Solicitud de transferencia a balanceador"
        loadBalancer -> apiGateway "3. Envia solicitud de transferencia a API Gateway"
        apiGateway -> transferService "4. Inicia transferencia"
        transferService -> fraudService "5. Valida fraude"
        fraudService -> transferService "6. Aprobado/Rechazado"
        transferService -> accountService "7. Verifica saldo"
        accountService -> transferService "8. Saldo disponible"
        transferService -> integrationLayer "9. Procesa en Core Banking"
        integrationLayer -> coreBankingSystem "10. Ejecuta transacción"
        coreBankingSystem -> integrationLayer "11. Confirmación"
        transferService -> eventBus "12. Publica evento"
        notificationService -> eventBus "13. Consume evento"
        notificationService -> smsProvider "14. Envía notificación"
        autoLayout
        title "Proceso de Transferencia con Patrón Saga"
    }
    
    #Diagrama de Secuencia:Onboarding con Reconocimiento Facial
    dynamic bpBankingSystem "OnboardingFlow" "Flujo de registro de nuevo cliente con biometría" {
        customer -> mobileApp "1. Inicia registro"
        mobileApp -> firewall "2. Envia Datos Basicos (Filtro de seguridad)"
        firewall -> loadBalancer "3. Envia los datos basicos al balanceador"
        loadBalancer -> apiGateway "4. Envia datos basicos a api gateway" 
        apiGateway -> authService "5. Validación inicial"
        authService -> biometricProvider "6. Captura facial"
        biometricProvider -> authService "7. Resultado validación"
        authService -> integrationLayer "8. Consulta Core Banking"
        integrationLayer -> coreBankingSystem "9. Verifica identidad"
        authService -> primaryDatabase "10. Crea usuario"
        authService -> apiGateway "11. Onboarding exitoso"
        apiGateway -> loadBalancer "12. Onboarding exitoso"
        loadBalancer -> firewall "13. Onboarding exitoso"
        firewall -> mobileApp "14. Onboarding exitoso"
        autoLayout
        title "Proceso de Onboarding con Reconocimiento Facial"
    }
    
    #FLujo de Seguridad
    dynamic bpBankingSystem "SecurityFlow" "Flujo completo de seguridad en capas" {
        # Capa 1: DDoS Protection
        customer -> ddosProtection "1. Request HTTPS"
        ddosProtection -> ddosProtection "2. Valida rate & patterns"
        
        # Capa 2: WAF
        ddosProtection -> wafService "3. Tráfico legítimo"
        wafService -> wafService "4. Inspecciona OWASP Top 10"
        
        # Capa 3: Firewall
        wafService -> firewall "5. Request sin amenazas"
        
        # Capa 4: Load Balancer
        firewall -> loadBalancer "6. Tráfico autorizado"
        
        # Capa 5: API Gateway
        loadBalancer -> apiGateway "7. Request balanceado"
        apiGateway -> secretsVault "8. Obtiene JWT public key"
        secretsVault -> apiGateway "9. Public key"
        
        # Capa 6: Microservicios
        apiGateway -> transferService "10. Request autenticado"
        transferService -> secretsVault "11. Obtiene DB credentials"
        secretsVault -> transferService "12. Credentials"
        transferService -> primaryDatabase "13. Query con TDE"
        
        # Auditoría
        secretsVault -> auditService "14. Log: Secret accessed"
        wafService -> auditService "15. Log: WAF inspection"
        
        autoLayout
        title "Flujo de Seguridad en Capas - Defense in Depth"
    }
    
    #Vista para patrones de datos
    container bpBankingSystem "DataArchitecture" {
        include accountService
        include customerProfileService
        include transferService
        include primaryDatabase
        include auditDatabase
        include cacheLayer
        include eventBus
        
        autoLayout
        title "Arquitectura de Datos - Cache Aside y Event Sourcing"
        description "Patrones de persistencia: Cache-Aside para clientes frecuentes, Event Sourcing para auditoría"
    }
    
    #Stack de seguridad
    # Vista especial mostrando la stack de seguridad
    container bpBankingSystem "SecurityStack" {
        include customer
        include ddosProtection
        include wafService
        include firewall
        include loadBalancer
        include apiGateway
        include secretsVault
        include authService
        include fraudService
        include auditService
        include monitoringService
        
        autoLayout lr
        title "Security Stack - Defense in Depth Architecture"
        description "Arquitectura de seguridad en capas con DDoS, WAF, Firewall, Secrets Management y Fraud Detection"
    }
    
    
    dynamic bpBankingSystem "SecretsManagement" "Gestión centralizada de secretos" {
        # Inicio de servicio
        apiGateway -> secretsVault "1. Request: TLS certificate"
        secretsVault -> apiGateway "2. Certificate + Private key"
        
        # Autenticación
        authService -> secretsVault "3. Request: JWT signing keys"
        secretsVault -> authService "4. RSA private/public keys"
        
        # Acceso a datos
        accountService -> secretsVault "5. Request: DB connection string"
        secretsVault -> accountService "6. PostgreSQL credentials"
        
        # Integración externa
        integrationLayer -> secretsVault "7. Request: Core Banking API key"
        secretsVault -> integrationLayer "8. Encrypted API key"
        
        # Rotación automática
        secretsVault -> authService "9. Webhook: Keys rotated"
        authService -> secretsVault "10. Request: New keys"
        secretsVault -> authService "11. New JWT keys"
        
        # Auditoría
        secretsVault -> auditService "12. Log: Secret accessed by accountService"
        
        autoLayout
        title "Secrets Management - Centralizado con Azure Key Vault"
        description "Todos los servicios obtienen secretos de manera segura desde Key Vault"
    }
    
    
        

        # ESTILOS PERSONALIZADOS (ACTUALIZADOS)
        styles {
            element "Person" {
        color #ffffff
        fontSize 24
        shape Person
        background #003087  
    }
    element "Customer" {
        background #005B96  
        icon https://static.structurizr.com/themes/microsoft-azure-2021.01.26/User.png
    }
    element "Bank Staff" {
        background #4A4A4A  
        icon https://static.structurizr.com/themes/microsoft-azure-2021.01.26/User.png
    }
    element "Auditor" {
        background #2F4F4F  
        icon https://static.structurizr.com/themes/microsoft-azure-2021.01.26/User.png
    }
    element "Software System" {
        background #0078D4  
        color #ffffff
        shape RoundedBox
    }
    element "External" {
        background #6B7280  
        color #ffffff
        shape Box
        opacity 80
    }
    element "Container" {
        background #1E90FF  
        color #ffffff
        shape RoundedBox
    }
    element "Web Browser" {
        shape WebBrowser
        background #1E90FF
        color #ffffff
    }
    element "Mobile App" {
        shape MobileDevicePortrait
        background #1E90FF
        color #ffffff
    }
    element "Database" {
        shape Cylinder
        background #4682B4  
        color #ffffff
    }
    element "Cache" {
        shape Cylinder
        background #FF4500  
        color #ffffff
    }
    element "Message Broker" {
        shape Pipe
        background #FFA500  
        color #ffffff
    }
    element "Microservice" {
        background #32CD32  
        color #ffffff
        shape Hexagon  
    }
    element "API Gateway" {
        background #FF6347  
        color #ffffff
        shape RoundedBox
    }
    element "Firewall" {
        background #DC143C  
        color #ffffff
        shape RoundedBox
    }
    element "Load Balancer" {
        background #9370DB  
        color #ffffff
        shape RoundedBox
    }
    element "Integration" {
        background #8A2BE2  
        color #ffffff
        shape RoundedBox
    }
    element "Monitoring" {
        background #00CED1  
        color #ffffff
        shape RoundedBox
    }
    element "Component" {
        background #98FB98  
        color #000000
        shape Component
    }
    relationship "Relationship" {
        routing Direct  
        thickness 1
        color #333333  
        fontSize 12
        position 50  
    }
    relationship "Synchronous" {
        dashed false
        color #0000FF  
    }
    relationship "Asynchronous" {
        dashed true
        color #FF0000  
    }
        }

        # TEMAS PERSONALIZADOS
        #themes https://static.structurizr.com/themes/azure-2021.01.26/theme.json
    }

    # CONFIGURACIÓN
    configuration {
        scope softwareSystem
        
    }
}