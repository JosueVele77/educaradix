package io.github.josuevele77.educaradix.models;

public class Categoria {
    private final String codigo;
    private final String nombre;
    private final String descripcion;
    private final String pregunta;
    private final String pista;

    public Categoria(String codigo, String nombre, String descripcion, String pregunta, String pista) {
        this.codigo = codigo;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.pregunta = pregunta;
        this.pista = pista;
    }

    public String getCodigo() {
        return codigo;
    }

    public String getNombre() {
        return nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public String getPregunta() {
        return pregunta;
    }

    public String getPista() {
        return pista;
    }
}
