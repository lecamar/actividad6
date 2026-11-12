# veterinario.rb
require_relative 'persona'

# Veterinario hereda de Persona: agrega tarjeta profesional, especialidad
# y la lista de propietarios que atiende
class Veterinario < Persona
  attr_reader :tarjeta_profesional, :especialidad

  def initialize(nombre, documento, tarjeta_profesional, especialidad)
    super(nombre, documento) # reutilizamos el initialize de Persona
    @tarjeta_profesional = tarjeta_profesional
    @especialidad = especialidad
    @propietarios = []
  end

  # Copia congelada de la lista interna
  def propietarios
    @propietarios.dup.freeze
  end

  # Agrega un propietario a la lista. Rechaza nil y duplicados (por documento)
  def agregar_propietario(propietario)
    if propietario.nil?
      puts "  [RECHAZADO] #{nombre}: no se puede agregar un propietario nulo."
      return false
    end

    if @propietarios.any? { |p| p.documento == propietario.documento }
      puts "  [RECHAZADO] #{nombre}: el propietario #{propietario.nombre} ya está en su lista."
      return false
    end

    @propietarios << propietario
    puts "  [OK] #{nombre} ahora atiende a #{propietario.nombre}."
    true
  end

  # Aplica una vacuna a una mascota, verificando todas las reglas de negocio.
  # Devuelve true si se aplicó y false si fue rechazada.
  def vacunar(mascota, propietario, vacuna)
    # Regla 1: el propietario debe ser cliente de este veterinario
    unless @propietarios.include?(propietario)
      puts "  [RECHAZADO] #{nombre} no atiende a ese propietario; no puede vacunar a #{mascota&.nombre || 'la mascota'}."
      return false
    end

    # Regla 2: la mascota debe pertenecer realmente a ese propietario
    unless propietario.mascotas.include?(mascota)
      puts "  [RECHAZADO] #{mascota&.nombre || 'La mascota'} no pertenece a #{propietario.nombre}."
      return false
    end

    # Regla 3: no repetir la misma vacuna
    if mascota.ya_tiene_vacuna?(vacuna)
      puts "  [RECHAZADO] #{mascota.nombre} ya recibió la vacuna '#{vacuna}'."
      return false
    end

    # Todo está bien: se llama al método privado de Mascota con send.
    # Así la vacuna solo se registra a través del veterinario.
    mascota.send(:agregar_vacuna, vacuna)
    puts "  [OK] #{nombre} aplicó '#{vacuna}' a #{mascota.nombre}."
    true
  end

  # Polimorfismo: misma firma que en Persona, pero con su propio comportamiento
  def identificacion_individuo
    "Veterinario #{nombre} - Tarjeta profesional: #{tarjeta_profesional} - Especialidad: #{especialidad}"
  end
end
