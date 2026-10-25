# Infraestructura como Código (IaC) — Flota de Servidores y Entornos de Desarrollo

Plataforma declarativa de **Infraestructura como Código (IaC)**, **Gestión de Configuración** y **GitOps** para el aprovisionamiento, hardening y despliegue de cargas de trabajo tanto en entornos corporativos (producción, staging y local para desarrolladores) como en proyectos personales.

El sistema implementa el estándar de la industria desacoplando responsabilidades:
* **Aprovisionamiento IaaS:** OpenTofu (código HCL declarativo, redes privadas y cómputo).
* **Gestión de Configuración y Hardening:** Ansible (automatización *agentless* vía SSH con soporte multi-bóveda).
* **Gestión de Cargas de Trabajo:** Docker Compose bajo el principio del *Host Inmaculado*.
* **Tráfico Perimetral y Terminación TLS:** Traefik v3 con auto-renovación de certificados Let's Encrypt.
* **Pila Local para Desarrolladores:** Entorno autocontenido (PostgreSQL 16, Redis 7, RabbitMQ, MinIO, Mailpit).

---

## 1. Requisitos Previos y Compatibilidad de Entorno

* **Sistema Operativo:** Linux (Debian/Ubuntu, Arch, Fedora) o macOS / Windows con WSL2.
* **Herramientas de Operación Local:**
  * Git >= 2.40
  * Docker Engine >= 26.0 y Docker Compose Plugin >= 2.27
  * Make (para comandos rápidos de desarrollo)
* **Herramientas para Gestión de Servidores Remotos (DevOps / SysAdmin):**
  * OpenTofu >= 1.8.0 (o Terraform >= 1.8.0)
  * Ansible Core >= 2.15 (con Python >= 3.10)
  * Cliente OpenSSH con soporte para llaves `Ed25519`

---

## 2. Inicio Rápido (Quickstart en 3 Pasos)

### Paso A: Clonar el repositorio
```bash
git clone git@github.com:JorgeDoicela/infraestructura.git
cd infraestructura
```

### Paso B: Levantar la pila de desarrollo local (Para Desarrolladores)
Si tu objetivo es programar y necesitas bases de datos y colas locales:
```bash
cd workloads/work/local
make dev-up
```
Los servicios estarán disponibles de inmediato en `localhost` (`5432` para Postgres, `6379` para Redis, `15672` para RabbitMQ UI).

### Paso C: Aprovisionar o Configurar Servidores Remotos (Para DevOps)
Si tu objetivo es administrar servidores en la nube:
```bash
# 1. Aprovisionar infraestructura con OpenTofu (ejemplo: personal/prod)
cd tofu/environments/personal/prod
export TF_VAR_hcloud_token="tu-token-hetzner"
tofu init && tofu apply

# 2. Endurecer el sistema operativo e instalar Docker con Ansible
cd ../../../ansible
ansible-playbook -i inventories/personal/prod/hosts.yaml playbooks/site.yaml \
  --vault-id personal@~/.vault-personal
```

---

## 3. Comandos Principales y Ciclo de Vida del Software

| Área / Contexto | Comando | Descripción Técnica |
|---|---|---|
| **Local (Devs)** | `cd workloads/work/local && make dev-up` | Inicia Postgres, Redis, RabbitMQ, MinIO y Mailpit en segundo plano. |
| **Local (Devs)** | `cd workloads/work/local && make dev-down` | Detiene los contenedores locales sin perder datos persistidos. |
| **Local (Devs)** | `cd workloads/work/local && make dev-clean` | Detiene y elimina contenedores y volúmenes locales a estado cero. |
| **Local (Devs)** | `cd workloads/work/local && make dev-logs` | Muestra los registros combinados en tiempo real. |
| **IaaS (Tofu)** | `tofu fmt -check -recursive tofu/` | Verifica el formato estricto de todos los archivos HCL. |
| **IaaS (Tofu)** | `tofu plan -out=tfplan` | Calcula la diferencia entre el estado actual y el código declarado. |
| **IaaS (Tofu)** | `tofu apply tfplan` | Aplica los cambios aprobados contra la API del proveedor de nube. |
| **SO (Ansible)** | `ansible -i <inventario> all -m ping` | Verifica la conectividad SSH y el intérprete Python en los servidores. |
| **SO (Ansible)** | `ansible-playbook -i <inventario> playbooks/site.yaml` | Ejecuta roles de swap, hardening SSH, UFW, Docker y Traefik. |

---

## 4. Estructura Macro del Directorio

```text
infraestructura/
├── README.md                           # Documentacion principal y guia rapida (este archivo)
├── .gitignore                          # Exclusiones criticas de seguridad (.tfstate, secretos, llaves)
├── docs/                               # Biblioteca documental tecnica Docs-as-Code
│   ├── 00-indice-general.md           # Catalogo maestro de la documentacion
│   ├── 01-arquitectura-general.md     # Vision global, multi-contexto y Host Inmaculado
│   ├── 02-aprovisionamiento-tofu.md   # Modulos de red/computo y ambientes OpenTofu
│   ├── 03-gestion-configuracion-ansible.md # Hardening, roles modulares y Vault IDs
│   ├── 04-entorno-local-desarrolladores.md # Guia de onboarding y pila local en Docker
│   ├── 05-cargas-de-trabajo-y-edge.md # Traefik v3, red web_gateway y Docker Compose
│   └── 06-seguridad-y-politica-de-secretos.md # Cifrado AES-256 y defensa perimetral
│
├── tofu/                               # Aprovisionamiento de infraestructura (IaaS)
│   ├── modules/                        # Modulos reutilizables agnosticos (network, compute)
│   └── environments/                   # Ambientes organizados por contexto
│       ├── personal/prod/              # Servidores para proyectos propios
│       └── work/                       # Entornos corporativos
│           ├── staging/                # Pre-produccion de la empresa
│           └── prod/                   # Produccion corporativa
│
├── ansible/                            # Configuracion de SO y Hardening (Agentless)
│   ├── ansible.cfg                     # Optimizacion SSH multiplexing y tuberias
│   ├── playbooks/                      # Playbooks maestros (site.yaml, deploy-apps.yaml)
│   ├── roles/                          # Roles modulares (swap, base_hardening, docker, traefik_bootstrap)
│   └── inventories/                    # Inventarios y variables aisladas por contexto
│       ├── personal/prod/              # Inventario y variables de proyectos propios
│       └── work/                       # Inventarios de la empresa
│           ├── staging/                # Inventario staging
│           └── prod/                   # Inventario produccion
│
├── workloads/                          # Cargas de trabajo en contenedores (Docker Compose)
│   ├── personal/                       # Servicios propios (edge proxy Traefik y aplicaciones)
│   └── work/                           # Servicios corporativos
│       ├── edge/                       # Traefik v3 perimetral con TLS automatico
│       ├── staging/                    # Compose stacks para staging
│       ├── prod/                       # Compose stacks para produccion
│       └── local/                      # Pila local para el equipo (Postgres, Redis, Rabbit, MinIO)
│
└── .github/
    └── workflows/
        └── ci.yaml                     # Pipeline de integracion continua (yamllint, tofu fmt)
```

---

## 5. Puntero a la Documentación Técnica Detallada (Docs-as-Code)

Para profundizar en el diseño arquitectónico, contratos de red, parámetros de entrada de módulos y runbooks operacionales, consultar el catálogo técnico centralizado:

👉 **[Documentación Técnica Completa](docs/00-indice-general.md)**

Módulos cubiertos en `docs/`:
1. `01-arquitectura-general.md`: Topología multi-contexto y separación de responsabilidades.
2. `02-aprovisionamiento-tofu.md`: Especificación de módulos HCL y gestión de estado remoto.
3. `03-gestion-configuracion-ansible.md`: Automatización de sistema operativo y multi-vault.
4. `04-entorno-local-desarrolladores.md`: Guía de onboarding para desarrolladores y puertos locales.
5. `05-cargas-de-trabajo-y-edge.md`: Enrutamiento perimetral L7 y certificados automáticos.
6. `06-seguridad-y-politica-de-secretos.md`: Cero secretos en Git y auditoría de seguridad.

---

## 6. Seguridad de Secretos y Licencia

* **Cero Secretos en Repositorio:** Toda variable sensible debe residir cifrada con Ansible Vault (`--vault-id`) o ser inyectada mediante variables de entorno en el pipeline de despliegue.
* **Archivos de Estado:** Los archivos `.tfstate` están estrictamente excluidos por el archivo `.gitignore` y deben residir en un bucket S3 remoto con cifrado habilitado.
* **Licencia:** Este proyecto se distribuye bajo términos de código abierto para fines formativos y de estandarización técnica.
