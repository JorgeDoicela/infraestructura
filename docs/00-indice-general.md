# Catálogo Maestro de Documentación Técnica — Infraestructura como Código (IaC)

Este documento centraliza y cataloga la biblioteca documental técnica del repositorio `infraestructura`. La documentación está estructurada bajo la metodología **Docs-as-Code** y organizada mediante **taxonomía jerárquica numérica** para garantizar un recorrido secuencial y modular de toda la plataforma.

[Volver al README Principal](../README.md)

---

## 1. Mapa General de Módulos Técnicos

| Índice | Módulo / Archivo | Dominio Técnico | Alcance y Propósito |
|---|---|---|---|
| **01** | [01 — Arquitectura General y Multi-Contexto](01-arquitectura-general.md) | Arquitectura y Diseño | Visión global, topología multi-contexto (Personal vs. Trabajo), ambientes (`prod`, `staging`, `local`), principio del Host Inmaculado y separación estricta de responsabilidades. |
| **02** | [02 — Aprovisionamiento de Infraestructura con OpenTofu](02-aprovisionamiento-tofu.md) | IaaS / Cómputo y Redes | Módulos reutilizables (`compute`, `network`), ambientes declarativos, variables tipadas, salidas y gestión de estado remoto en buckets S3/R2 con bloqueo distribuido. |
| **03** | [03 — Gestión de Configuración y Hardening con Ansible](03-gestion-configuracion-ansible.md) | Config Management / SO | Automatización agentless vía SSH, optimización con multiplexación, roles modulares (`swap`, `base_hardening`, `docker`, `traefik_bootstrap`) y soporte multi-bóveda con Vault IDs. |
| **04** | [04 — Entorno de Desarrollo Local para Equipos](04-entorno-local-desarrolladores.md) | Developer Experience | Pila local estandarizada en Docker para desarrolladores (`docker-compose.local.yml`), automatización con Makefile, catálogo de puertos y variables de conexión a servicios de datos. |
| **05** | [05 — Cargas de Trabajo y Enrutamiento Perimetral Edge](05-cargas-de-trabajo-y-edge.md) | Workloads / Reverse Proxy | Despliegue de aplicaciones vía Docker Compose, proxy perimetral Traefik v3, red `web_gateway`, enrutamiento L7 basado en etiquetas y certificados SSL automáticos con Let's Encrypt. |
| **06** | [06 — Seguridad, Políticas de Secretos y Cumplimiento](06-seguridad-y-politica-de-secretos.md) | Seguridad / SecOps | Políticas contra fugas de credenciales, cifrado AES-256 de secretos con Ansible Vault, endurecimiento de SSH, cortafuegos UFW, auditoría de `.gitignore` y flujos de CI/CD. |

---

## 2. Rutas de Lectura Sugeridas según el Rol

### A. Desarrolladores de Aplicaciones y Nuevas Incorporaciones (Onboarding)
1. Comenzar por el [README Principal](../README.md) para comprender el propósito general del repositorio.
2. Leer el documento [04 — Entorno de Desarrollo Local para Equipos](04-entorno-local-desarrolladores.md) para levantar la base de datos PostgreSQL, Redis, RabbitMQ y MinIO en su máquina local con `make dev-up`.
3. Consultar [05 — Cargas de Trabajo y Enrutamiento Perimetral Edge](05-cargas-de-trabajo-y-edge.md) si requiere configurar etiquetas de Traefik para exponer una nueva API en staging o producción.

### B. Ingenieros DevOps, SysAdmins y Responsables de Infraestructura
1. Leer [01 — Arquitectura General y Multi-Contexto](01-arquitectura-general.md) para entender la división de ambientes y responsabilidades.
2. Consultar [02 — Aprovisionamiento de Infraestructura con OpenTofu](02-aprovisionamiento-tofu.md) para la creación de máquinas virtuales y subredes privadas.
3. Consultar [03 — Gestión de Configuración y Hardening con Ansible](03-gestion-configuracion-ansible.md) para ejecutar tareas de aprovisionamiento de sistema operativo y gestión de roles.
4. Auditar [06 — Seguridad, Políticas de Secretos y Cumplimiento](06-seguridad-y-politica-de-secretos.md) antes de gestionar credenciales o desplegar cambios a producción.
