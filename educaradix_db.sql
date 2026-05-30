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

CREATE TABLE IF NOT EXISTS bitacora (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NULL REFERENCES usuarios(id) ON DELETE SET NULL,
    usuario_nombre VARCHAR(120) NOT NULL,
    accion VARCHAR(60) NOT NULL,
    detalle TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT NOW()
);

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

CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_actividades_usuario ON actividades_estudiante(usuario_id);
CREATE INDEX IF NOT EXISTS idx_actividades_revision ON actividades_estudiante(revisado);
CREATE INDEX IF NOT EXISTS idx_bitacora_fecha ON bitacora(fecha DESC);

INSERT INTO usuarios (nombre, correo, clave, rol, bloqueado)
VALUES
    ('Administrador EducaRadix', 'admin@educaradix.edu', '60fe74406e7f353ed979f350f2fbb6a2e8690a5fa7d1b0c32983d1d8b3f95f67', 'ADMIN', FALSE),
    ('Estudiante Demo', 'estudiante@educaradix.edu', '3b7d577e2e841153c1b6f71ec437e03ea134b219c9bd8375feb8d827808b9eea', 'ESTUDIANTE', FALSE)
ON CONFLICT (correo) DO NOTHING;

INSERT INTO bitacora (usuario_nombre, accion, detalle)
VALUES ('Sistema', 'INSTALACION_BD', 'Estructura inicial de EducaRadix creada.')
ON CONFLICT DO NOTHING;

SELECT *FROM usuarios;
