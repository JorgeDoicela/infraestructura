-- Script de inicializacion ejecutado automaticamente por Postgres al primer arranque
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Esquema base de pruebas
CREATE SCHEMA IF NOT EXISTS core;

-- Mensaje de confirmacion en log
DO $$
BEGIN
    RAISE NOTICE 'Base de datos de desarrollo inicializada correctamente con extensiones UUID y PGCRYPTO.';
END $$;
