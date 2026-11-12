# mascota.rb
# Mascota NO hereda de Persona. Incluye el módulo Comparable
# para poder comparar mascotas por edad (<, >, sort, max, etc.).
class Mascota
  include Comparable

  # Especies permitidas según el enunciado: solo perro, gato o ave
  ESPECIES_VALIDAS = %w[perro gato ave].freeze

  # Variable de clase: es compartida por todas las mascotas y cuenta cuántas se han creado
  @@total_registradas = 0

  attr_reader :nombre, :especie, :edad

  # Método de clase: se llama como Mascota.total_registradas
  def self.total_registradas
    @@total_registradas
  end

  def initialize(nombre, especie, edad)
    # Validamos la especie antes de crear la mascota
    unless ESPECIES_VALIDAS.include?(especie.to_s.downcase)
      raise ArgumentError, "Especie '#{especie}' no válida. Solo se permite: #{ESPECIES_VALIDAS.join(', ')}"
    end

    @nombre = nombre
    @especie = especie.to_s.downcase
    @edad = edad
    @vacunas = [] # lista interna de vacunas aplicadas

    # Solo se suma si la mascota se creó correctamente (no hubo error arriba)
    @@total_registradas += 1
  end

  # Devuelve una COPIA congelada: así nadie modifica la lista original desde afuera
  def vacunas
    @vacunas.dup.freeze
  end

  # Pregunta si la mascota ya recibió esa vacuna
  def ya_tiene_vacuna?(vacuna)
    @vacunas.include?(vacuna)
  end

  # Método requerido por Comparable: compara las mascotas por edad
  def <=>(otra)
    edad <=> otra.edad
  end

  def to_s
    "#{@nombre} (#{@especie}, #{@edad} años)"
  end

  private

  # Es privado: no se puede llamar como mascota.agregar_vacuna desde afuera.
  # Solo el Veterinario lo usa (mediante send) cuando aprueba todas las reglas.
  def agregar_vacuna(vacuna)
    @vacunas << vacuna
  end
end
