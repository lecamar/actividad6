# persona.rb
# Clase base de la jerarquía. En Ruby no existen las clases abstractas,
# así que la "simulamos" lanzando NotImplementedError.
class Persona
  # Solo lectura: desde afuera se puede consultar pero no cambiar
  attr_reader :nombre, :documento

  def initialize(nombre, documento)
    # Si alguien intenta hacer Persona.new directamente, lo rechazamos.
    # instance_of? es true solo cuando el objeto es exactamente de la clase Persona,
    # por eso las clases hijas sí pueden crearse sin problema.
    if instance_of?(Persona)
      raise NotImplementedError, "Persona es una clase abstracta: no se puede instanciar directamente"
    end

    @nombre = nombre
    @documento = documento
  end

  # Representación en texto del objeto
  def to_s
    "#{@nombre} (documento: #{@documento})"
  end

  # Método "abstracto": cada clase hija debe sobrescribirlo.
  # Si no lo hace, se lanza NotImplementedError.
  def identificacion_individuo
    raise NotImplementedError, "#{self.class} debe sobrescribir el método identificacion_individuo"
  end
end
