# propietario.rb
require_relative 'persona'

# Propietario hereda de Persona: agrega teléfono y su lista de mascotas
class Propietario < Persona
  attr_reader :telefono

  def initialize(nombre, documento, telefono)
    super(nombre, documento) # reutilizamos el initialize de Persona
    @telefono = telefono
    @mascotas = []
  end

  # Devuelve una copia congelada de la lista de mascotas
  def mascotas
    @mascotas.dup.freeze
  end

  # Agrega una mascota a la lista del propietario (ignora nil)
  def agregar_mascota(mascota)
    if mascota.nil?
      puts "  [RECHAZADO] No se puede agregar una mascota nula a #{nombre}."
      return false
    end

    @mascotas << mascota
    true
  end

  # Lista las mascotas de la menor a la mayor edad usando sort
  # (sort funciona porque Mascota define <=> con Comparable)
  def listar_mascotas
    puts "Mascotas de #{nombre} (de menor a mayor edad):"
    @mascotas.sort.each { |mascota| puts "  - #{mascota}" }
  end

  # Polimorfismo: misma firma que en Persona, pero con su propio comportamiento
  def identificacion_individuo
    "Propietario #{nombre} - Documento: #{documento} - Teléfono: #{telefono}"
  end
end
