-- ============================================================
-- EducaRadix - Script de base de datos PostgreSQL
-- ============================================================
-- Uso recomendado:
-- 1. Abrir una terminal en esta carpeta.
-- 2. Ejecutar:
--      psql -U postgres -f educaradix_db.sql
-- 3. El script crea la base BD_educa si no existe, se conecta y
--    prepara tablas, indices y usuarios iniciales.
--
-- Credenciales esperadas por la aplicacion:
--   Base de datos: BD_educa
--   Usuario: postgres
--   Clave: 1234
--
-- Si usas otro usuario o clave, cambia esos datos con las variables:
-- EDUCARADIX_DB_URL, EDUCARADIX_DB_USER y EDUCARADIX_DB_PASSWORD
-- ============================================================

-- Crea la base de datos solo si falta. Esta instruccion usa comandos de psql.
SELECT 'CREATE DATABASE "BD_educa"'
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_database
    WHERE datname = 'BD_educa'
)\gexec

-- A partir de aqui todo se ejecuta dentro de la base usada por la aplicacion.
\connect "BD_educa"

-- Usuarios del sistema: administradores y estudiantes.
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(160) NOT NULL UNIQUE,
    clave VARCHAR(64) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('ADMIN', 'ESTUDIANTE')),
    bloqueado BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_url VARCHAR(260),
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW(),
    ultima_actualizacion TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Bitacora de eventos: inicios de sesion, registros, cambios y acciones administrativas.
CREATE TABLE IF NOT EXISTS bitacora (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NULL REFERENCES usuarios(id) ON DELETE SET NULL,
    usuario_nombre VARCHAR(120) NOT NULL,
    accion VARCHAR(60) NOT NULL,
    detalle TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Actividades completadas por estudiantes.
-- Cada registro guarda una mision/juego resuelto y permite calcular progreso.
CREATE TABLE IF NOT EXISTS actividades_estudiante (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    categoria VARCHAR(40) NOT NULL,
    respuesta TEXT NOT NULL,
    puntaje INTEGER NOT NULL DEFAULT 0 CHECK (puntaje BETWEEN 0 AND 100),
    revisado BOOLEAN NOT NULL DEFAULT FALSE,
    aprobado BOOLEAN NOT NULL DEFAULT FALSE,
    comentario_admin TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indices para busquedas frecuentes.
CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_actividades_usuario ON actividades_estudiante(usuario_id);
CREATE INDEX IF NOT EXISTS idx_actividades_revision ON actividades_estudiante(revisado);
CREATE INDEX IF NOT EXISTS idx_actividades_usuario_categoria ON actividades_estudiante(usuario_id, LOWER(TRIM(categoria)));
CREATE INDEX IF NOT EXISTS idx_bitacora_fecha ON bitacora(fecha DESC);

-- Usuarios iniciales.
-- Admin inicial: admin@educaradix.edu / Admin1234
-- Estudiante demo: estudiante@educaradix.edu / Estudiante123
INSERT INTO usuarios (nombre, correo, clave, rol, bloqueado)
VALUES
    ('Administrador EducaRadix', 'admin@educaradix.edu', '60fe74406e7f353ed979f350f2fbb6a2e8690a5fa7d1b0c32983d1d8b3f95f67', 'ADMIN', FALSE),
    ('Estudiante Demo', 'estudiante@educaradix.edu', '3b7d577e2e841153c1b6f71ec437e03ea134b219c9bd8375feb8d827808b9eea', 'ESTUDIANTE', FALSE)
ON CONFLICT (correo) DO NOTHING;

-- Marca de instalacion. Evita repetir el mismo evento al correr el script varias veces.
INSERT INTO bitacora (usuario_nombre, accion, detalle)
SELECT 'Sistema', 'INSTALACION_BD', 'Estructura inicial de EducaRadix creada.'
WHERE NOT EXISTS (
    SELECT 1
    FROM bitacora
    WHERE usuario_nombre = 'Sistema'
      AND accion = 'INSTALACION_BD'
      AND detalle = 'Estructura inicial de EducaRadix creada.'
);

-- Consulta final de verificacion.
SELECT id, nombre, correo, rol, bloqueado, fecha_registro
FROM usuarios
ORDER BY id;
