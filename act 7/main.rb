# main.rb
# Programa principal: carga las clases, crea los datos de prueba,
# demuestra cada rechazo y maneja el archivo CSV del historial.
require 'csv'
require_relative 'persona'
require_relative 'veterinario'
require_relative 'propietario'
require_relative 'mascota'

ARCHIVO_HISTORIAL = 'historial_veterinaria.csv'

# Guarda una línea por vacuna: mascota,especie,propietario,vacuna
def guardar_historial(propietarios, archivo)
  # Se indica UTF-8 para que las tildes se guarden bien en cualquier equipo
  CSV.open(archivo, 'w', encoding: 'UTF-8') do |csv|
    propietarios.each do |propietario|
      propietario.mascotas.each do |mascota|
        mascota.vacunas.each do |vacuna|
          csv << [mascota.nombre, mascota.especie, propietario.nombre, vacuna]
        end
      end
    end
  end
  puts "Historial guardado en #{archivo}"
end

# Lee el CSV y cuenta cuántas vacunas se aplicaron por especie.
# Si el archivo no existe, se maneja el error con begin/rescue.
def contar_vacunas_por_especie(archivo)
  conteo = Hash.new(0)
  begin
    CSV.foreach(archivo, encoding: 'UTF-8') do |fila|
      conteo[fila[1]] += 1 # la columna 1 es la especie
    end
    puts "Vacunas aplicadas por especie (#{archivo}):"
    conteo.each { |especie, cantidad| puts "  - #{especie}: #{cantidad}" }
  rescue Errno::ENOENT
    puts "  [ERROR] El archivo '#{archivo}' no existe."
  end
end

# Clase hija de prueba que NO sobrescribe identificacion_individuo
class Visitante < Persona
end

puts '=' * 60
puts '1. CREACIÓN DE VETERINARIOS Y PROPIETARIOS'
puts '=' * 60
dolittle = Veterinario.new('John Dolittle', '1001', 'TP-4521', 'Animales exóticos')
ellie    = Veterinario.new('Ellie Sattler', '1002', 'TP-7788', 'Aves y reptiles')
shrek    = Propietario.new('Shrek', '2001', '300-111-2233')
indiana  = Propietario.new('Indiana Jones', '2002', '300-444-5566')
puts dolittle
puts ellie
puts shrek
puts indiana

puts
puts '=' * 60
puts '2. CREACIÓN DE MASCOTAS'
puts '=' * 60
perro   = Mascota.new('Pulgoso Balboa', 'perro', 10)
gato    = Mascota.new('Gatúbela', 'gato', 7)
loro    = Mascota.new('Loro Skywalker', 'ave', 15)
ganso   = Mascota.new('Cuacsparrow', 'ave', 5) # un ganso es un ave
gatito  = Mascota.new('Miauricio', 'gato', 2)

# Shrek tiene 3 mascotas e Indiana Jones tiene 2
[perro, gato, loro].each { |m| shrek.agregar_mascota(m) }
[ganso, gatito].each { |m| indiana.agregar_mascota(m) }
puts "Total de mascotas registradas: #{Mascota.total_registradas}"

puts
puts '=' * 60
puts '3. REGLAS DEL VETERINARIO (rechazos y aceptados)'
puts '=' * 60
puts '-- Agregar propietarios --'
dolittle.agregar_propietario(shrek)
dolittle.agregar_propietario(nil)    # rechazo: nil
dolittle.agregar_propietario(shrek)  # rechazo: duplicado
ellie.agregar_propietario(indiana)

puts '-- Vacunas válidas --'
dolittle.vacunar(perro, shrek, 'Parvovirus')
dolittle.vacunar(perro, shrek, 'Rabia')
dolittle.vacunar(gato, shrek, 'Triple felina')
dolittle.vacunar(loro, shrek, 'Newcastle')
ellie.vacunar(ganso, indiana, 'Newcastle')
ellie.vacunar(gatito, indiana, 'Leucemia felina')

puts '-- Rechazos de vacunación --'
# Rechazo: Dolittle no atiende a Indiana Jones
dolittle.vacunar(ganso, indiana, 'Influenza aviar')
# Rechazo: Miauricio pertenece a Indiana, no a Shrek
dolittle.vacunar(gatito, shrek, 'Leucemia felina')
# Rechazo: Pulgoso Balboa ya recibió la vacuna contra la Rabia
dolittle.vacunar(perro, shrek, 'Rabia')

puts
puts '=' * 60
puts '4. ENCAPSULAMIENTO Y ERRORES ESPERADOS'
puts '=' * 60
# Especie inválida (solo se permite perro, gato o ave) -> ArgumentError
begin
  Mascota.new('Dolly Llama', 'llama', 8)
rescue ArgumentError => e
  puts "  [ArgumentError] #{e.message}"
end
puts "Total de mascotas después del error: #{Mascota.total_registradas} (no aumentó)"

# Persona no se puede instanciar directamente -> NotImplementedError
begin
  Persona.new('Nadie', '000')
rescue NotImplementedError => e
  puts "  [NotImplementedError] #{e.message}"
end

# Hija que no sobrescribe identificacion_individuo -> NotImplementedError
begin
  Visitante.new('Visitante Anónimo', '999').identificacion_individuo
rescue NotImplementedError => e
  puts "  [NotImplementedError] #{e.message}"
end

# El método que agrega vacunas es privado -> NoMethodError
begin
  perro.agregar_vacuna('Vacuna trampa')
rescue NoMethodError => e
  puts "  [NoMethodError] No se puede llamar agregar_vacuna desde afuera: #{e.message}"
end

# Las listas se devuelven congeladas -> FrozenError
begin
  perro.vacunas << 'Vacuna trampa'
rescue FrozenError => e
  puts "  [FrozenError] La lista de vacunas está congelada: #{e.message}"
end

puts
puts '=' * 60
puts '5. COMPARABLE, SORT Y MAX'
puts '=' * 60
shrek.listar_mascotas
indiana.listar_mascotas
todas = shrek.mascotas + indiana.mascotas
puts "Mascota de mayor edad de la clínica: #{todas.max}"

puts
puts '=' * 60
puts '6. POLIMORFISMO'
puts '=' * 60
[dolittle, ellie, shrek, indiana].each do |persona|
  puts persona.identificacion_individuo
end

puts
puts '=' * 60
puts '7. ARCHIVO CSV'
puts '=' * 60
guardar_historial([shrek, indiana], ARCHIVO_HISTORIAL)
contar_vacunas_por_especie(ARCHIVO_HISTORIAL)
puts '-- Intento de leer un archivo que no existe --'
contar_vacunas_por_especie('archivo_inexistente.csv')
