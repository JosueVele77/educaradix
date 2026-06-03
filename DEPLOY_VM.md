# Despliegue en VM

Este proyecto genera el archivo `educaradix.war` y se conecta por defecto a:

```text
jdbc:postgresql://172.17.42.121:5432/DB_educa
usuario: postgres
clave: 1234
```

## Requisitos

- JDK 11 o superior.
- Tomcat 9 o un servidor compatible con Java EE 8 / `javax.servlet`.
- Acceso desde la VM al servidor PostgreSQL `172.17.42.121:5432`.

> Importante: Tomcat 10 usa `jakarta.servlet` y este proyecto usa `javax.servlet`, por eso debe desplegarse en Tomcat 9.

## Compilar el WAR

En la carpeta del proyecto:

```bash
./mvnw clean package
```

En Windows:

```bat
mvnw.cmd clean package
```

El archivo queda en:

```text
target/educaradix.war
```

## Desplegar en Tomcat

Copiar el WAR a la carpeta `webapps` de Tomcat:

```bash
cp target/educaradix.war /opt/tomcat/webapps/
```

Reiniciar Tomcat si no despliega automaticamente:

```bash
sudo systemctl restart tomcat
```

La aplicacion queda disponible en:

```text
http://IP_DE_LA_VM:8080/educaradix/
```

## Cambiar credenciales sin recompilar

Si se necesita apuntar a otra base, configurar estas variables antes de iniciar Tomcat:

```bash
export EDUCARADIX_DB_URL="jdbc:postgresql://172.17.42.121:5432/DB_educa"
export EDUCARADIX_DB_USER="postgres"
export EDUCARADIX_DB_PASSWORD="1234"
```

## Si no conecta a PostgreSQL

Verificar en el servidor de base de datos:

- PostgreSQL escucha en la red, no solo en `localhost`.
- El puerto `5432` esta abierto en firewall.
- `pg_hba.conf` permite conexiones desde la IP de la VM.
- La base `DB_educa` tiene las tablas `usuarios`, `bitacora` y `actividades_estudiante`.
