# 02 — Aprovisionamiento de Infraestructura con OpenTofu

[Volver al Índice General](00-indice-general.md) | [Anterior: Arquitectura General](01-arquitectura-general.md) | [Siguiente: Configuración con Ansible](03-gestion-configuracion-ansible.md)

---

## 1. Rol de OpenTofu en la Arquitectura

OpenTofu cumple la función exclusiva de **Infraestructura como Código (IaaS)**. Su responsabilidad inicia y termina en la API del proveedor de nube (por defecto Hetzner Cloud):
* Creación de redes privadas virtuales (VPC) y subredes internas.
* Aprovisionamiento de instancias de cómputo con sistemas base Debian 12 Minimal.
* Registro de llaves públicas SSH autorizadas.
* Exportación de direcciones IP públicas y privadas hacia las salidas del sistema (*outputs*).

> [!IMPORTANT]
> OpenTofu **nunca ejecuta aprovisionamiento de software interno** ni comandos de shell sobre los servidores creados. La configuración interna del sistema operativo es responsabilidad delegada a Ansible.

---

## 2. Catálogo de Módulos Reutilizables (`tofu/modules/`)

Para mantener el principio DRY (*Don't Repeat Yourself*), la infraestructura se abstrae en dos módulos reutilizables:

### A. Módulo de Red (`tofu/modules/network`)
Crea la red privada interna del contexto y asigna un rango CIDR para subredes dedicadas.

| Variable de Entrada | Tipo | Valor por Defecto | Descripción |
|---|---|---|---|
| `network_name` | `string` | *(Obligatorio)* | Nombre asignado a la red privada |
| `ip_range` | `string` | `"10.0.0.0/16"` | Rango CIDR global para la red |
| `network_zone` | `string` | `"eu-central"` | Zona geográfica del centro de datos |
| `subnet_ip_range` | `string` | `"10.0.1.0/24"` | Rango CIDR para la subred de cómputo |
| `labels` | `map(string)` | `{}` | Etiquetas de contexto y metadatos |

**Salidas del Módulo (`outputs`):**
* `network_id`: Identificador único de la red privada para asociación de interfaces.
* `network_name`: Nombre de la red registrada.
* `subnet_ip_range`: Rango CIDR de la subred creada.

### B. Módulo de Cómputo (`tofu/modules/compute`)
Aprovisiona instancias virtuales enlazadas a la red privada y asigna llaves SSH autorizadas.

| Variable de Entrada | Tipo | Valor por Defecto | Descripción |
|---|---|---|---|
| `server_name` | `string` | *(Obligatorio)* | Hostname del servidor |
| `server_type` | `string` | `"cpx11"` | Tamaño de cómputo (vCPU / RAM) |
| `image` | `string` | `"debian-12"` | Imagen base del sistema operativo |
| `location` | `string` | `"fsn1"` | Región o centro de datos |
| `ssh_public_key` | `string` | *(Obligatorio)* | Contenido de la llave pública SSH autorizada |
| `network_id` | `string` | *(Obligatorio)* | Identificador de red privada provisto por el módulo de red |
| `private_ip` | `string` | *(Obligatorio)* | Dirección IPv4 estática dentro de la subred interna |
| `environment` | `string` | *(Obligatorio)* | Etiqueta de ambiente (`prod`, `staging`) |
| `labels` | `map(string)` | `{}` | Etiquetas adicionales de auditoría |

**Salidas del Módulo (`outputs`):**
* `server_id`: Identificador numérico de la instancia.
* `server_name`: Hostname registrado en la plataforma.
* `public_ipv4`: Dirección IPv4 pública asignada para tráfico web y SSH.
* `private_ipv4`: Dirección IPv4 en la red privada interna.
* `status`: Estado de ejecución de la instancia.

---

## 3. Ambientes Implementados (`tofu/environments/`)

```text
tofu/environments/
├── personal/
│   └── prod/               # Servidor personal (10.10.1.10 en personal-net-prod)
└── work/
    ├── staging/            # Servidor staging (10.20.1.10 en work-net-staging)
    └── prod/               # Servidor produccion (10.30.1.10 en work-net-prod)
```

Cada entorno contiene su archivo `main.tf` instanciando los módulos reutilizables con los parámetros correspondientes, su archivo `variables.tf` para parametrización y `outputs.tf` para reportar las IPs generadas.

---

## 4. Gestión de Estado Remoto (`tfstate`)

El archivo de estado contiene el mapeo exacto entre el código declarativo y los recursos reales en la nube. Puede contener direcciones IP internas y metadatos sensibles.

> [!CAUTION]
> El estado de OpenTofu **nunca debe comitearse a Git**. Está estrictamente bloqueado en el archivo `.gitignore`.

### Configuración de Backend Remoto en Producción
Para entornos multi-usuario y pipelines de CI/CD, cada ambiente dispone de un bloque `backend "s3"` listo para descomentar en `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket                      = "work-infra-tfstate"
    key                         = "prod/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
```

Este esquema es compatible con Cloudflare R2, AWS S3, MinIO o Hetzner Object Storage, y garantiza cifrado en reposo y bloqueo de concurrencia distribuido (*state locking*).

---

## 5. Procedimiento Operativo de Despliegue

Para desplegar un ambiente específico (ejemplo con `personal/prod`):

```bash
# 1. Navegar al entorno objetivo
cd tofu/environments/personal/prod

# 2. Exportar el token de autenticacion del proveedor
export TF_VAR_hcloud_token="tu_token_aqui"

# 3. Inicializar modulos y proveedores
tofu init

# 4. Generar y revisar el plan de ejecucion
tofu plan -out=tfplan

# 5. Aplicar los cambios planificados
tofu apply tfplan
```
