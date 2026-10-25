# 03 — Gestión de Configuración y Hardening con Ansible

[Volver al Índice General](00-indice-general.md) | [Anterior: Aprovisionamiento con OpenTofu](02-aprovisionamiento-tofu.md) | [Siguiente: Entorno Local para Equipos](04-entorno-local-desarrolladores.md)

---

## 1. Filosofía Operativa de Ansible

Ansible opera como el motor de configuración del sistema operativo bajo una arquitectura estrictamente **agentless**:
* No requiere la instalación de agentes ni demonios residentes en el servidor de destino que consuman memoria RAM.
* La comunicación se realiza exclusivamente a través de **SSH seguro** sobre el puerto configurado (puerto 22 por defecto).
* Todas las tareas implementadas son **idempotentes**: ejecutar el playbook una o cien veces produce con exactitud el mismo estado final en el servidor.

---

## 2. Optimización de Conexión SSH (`ansible.cfg`)

Para acelerar las ejecuciones y evitar latencias por aperturas repetitivas de conexiones SSH, [`ansible/ansible.cfg`](../ansible/ansible.cfg) implementa:
* **Pipelining:** Transfiere módulos Python directamente por la tubería SSH en lugar de copiarlos a disco en el host remoto.
* **ControlMaster y ControlPersist:** Mantiene un socket SSH abierto en segundo plano durante 60 segundos para reutilizar el túnel en tareas consecutivas.

---

## 3. Soporte Multi-Bóveda con Vault IDs

Para garantizar el aislamiento de secretos entre contextos corporativos y personales, la configuración soporta **Vault IDs** nativos. 

> [!IMPORTANT]
> Prohibido utilizar una única clave de cifrado compartida. Cada contexto utiliza su propia identidad:
> * **Identidad Corporativa:** `work`
> * **Identidad Personal:** `personal`

### Cifrado de Cadenas Individuales
```bash
# Para secretos personales:
ansible-vault encrypt_string 'mi_secreto' --name 'db_password' --vault-id personal@~/.vault-personal

# Para secretos corporativos:
ansible-vault encrypt_string 'mi_secreto_empresa' --name 'api_key' --vault-id work@~/.vault-work
```

---

## 4. Catálogo de Roles Modulares Reutilizables

Los roles residen en `ansible/roles/` y están diseñados de forma desacoplada para ser consumidos por cualquier inventario mediante inyección de variables:

### A. Rol `swap`
Asegura que el servidor cuente con memoria virtual de intercambio para proteger los procesos ante picos de carga:
1. Verifica si el archivo de swap ya existe con `stat`.
2. Asigna espacio contiguo en disco mediante `fallocate -l {{ swap_size_gb }}G {{ swap_file_path }}`.
3. Aplica permisos estrictos `0600` (solo lectura y escritura para root).
4. Inicializa con `mkswap` y activa con `swapon`.
5. Registra la entrada correspondiente en `/etc/fstab` con opciones `sw` para persistencia tras reinicios.

### B. Rol `base_hardening`
Endurece la seguridad perimetral y el acceso administrativo del servidor:
1. Actualiza el índice APT e instala paquetes de auditoría y defensa: `ufw`, `fail2ban`, `curl`, `htop`, `ca-certificates`.
2. Modifica `/etc/ssh/sshd_config` validando sintaxis antes de reiniciar el daemon:
   * `PermitRootLogin no` (bloquea acceso directo del superusuario).
   * `PasswordAuthentication no` (obliga al uso exclusivo de llaves SSH criptográficas).
   * `X11Forwarding no` (reduce superficie de ataque).
3. Configura el cortafuegos `ufw`:
   * Política por defecto entrante: `deny` (bloqueo total).
   * Política por defecto saliente: `allow`.
   * Reglas de límite de tasa (*rate limit*) para puerto SSH (`22/tcp`), `80/tcp` y `443/tcp`.
   * Habilitación persistente del cortafuegos.

### C. Rol `docker`
Instala y configura el motor de contenedores oficial:
1. Descarga e instala la clave GPG oficial de Docker en `/etc/apt/keyrings/docker.asc`.
2. Registra el repositorio APT oficial de Docker para la versión de Debian en ejecución.
3. Instala `docker-ce`, `docker-ce-cli`, `containerd.io` y el plugin `docker-compose-plugin`.
4. Escribe `/etc/docker/daemon.json` aplicando rotación obligatoria de registros:
   * `"log-driver": "json-file"`
   * `"max-size": "{{ docker_log_max_size }}"` (por defecto 50 MB / 100 MB en producción).
   * `"max-file": "{{ docker_log_max_file }}"` (3 a 5 rotaciones archivadas).
5. Habilita e inicia el servicio `systemd` de Docker.

### D. Rol `traefik_bootstrap`
Prepara el entorno para el proxy perimetral:
1. Crea la estructura de directorios `/opt/traefik/data`.
2. Genera el archivo `/opt/traefik/data/acme.json` con permisos de seguridad `0600`.
3. Crea la red Docker externa `web_gateway` tipo *bridge* donde se interconectarán todas las aplicaciones.

---

## 5. Estructura de Inventarios y Variables

```text
ansible/inventories/
├── personal/
│   └── prod/
│       ├── hosts.yaml              # Servidor personal (personal-srv-prod-01)
│       └── group_vars/all.yaml     # Variables personales (swap: 4 GB, traefik_acme_email)
└── work/
    ├── staging/
    │   ├── hosts.yaml              # Servidor staging (work-srv-staging-01)
    │   └── group_vars/all.yaml     # Variables staging
    └── prod/
        ├── hosts.yaml              # Servidor produccion (work-srv-prod-01)
        └── group_vars/all.yaml     # Variables prod (swap: 8 GB, logs: 100m x 5)
```

---

## 6. Procedimiento Operativo de Ejecución

### Comprobación de Conectividad (Ping SSH)
```bash
# Probar servidores personales:
ansible -i inventories/personal/prod/hosts.yaml all -m ping

# Probar servidores de produccion corporativa:
ansible -i inventories/work/prod/hosts.yaml all -m ping
```

### Ejecución del Playbook Maestro de Aprovisionamiento
```bash
# Para proyectos personales:
ansible-playbook -i inventories/personal/prod/hosts.yaml playbooks/site.yaml \
  --vault-id personal@~/.vault-personal

# Para staging corporativo:
ansible-playbook -i inventories/work/staging/hosts.yaml playbooks/site.yaml \
  --vault-id work@~/.vault-work

# Para produccion corporativa:
ansible-playbook -i inventories/work/prod/hosts.yaml playbooks/site.yaml \
  --vault-id work@~/.vault-work
```
