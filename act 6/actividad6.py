"""
Sistema de gestión escolar (Docentes, Estudiantes y Asignaturas).

Modelo trasladado desde el ejemplo clínico visto en clase:
    Persona    -> Persona     (clase padre abstracta)
    Medico     -> Docente     (hija de Persona, gestiona sus estudiantes)
    Paciente   -> Estudiante  (hija de Persona, recibe asignaturas)
    Medicamento-> Asignatura  (clase fuera de la jerarquía)

"""

from abc import ABC, abstractmethod


# ---------------------------------------------------------------
# Clase abstracta Persona
# ---------------------------------------------------------------
class Persona(ABC):
    """Clase padre abstracta: no se puede instanciar directamente."""

    def __init__(self, nombre, documento):
        # Atributos protegidos (convención: guion bajo al inicio)
        self._nombre = nombre
        self._documento = documento

    # Propiedades de solo lectura (no tienen setter)
    @property
    def nombre(self):
        return self._nombre

    @property
    def documento(self):
        return self._documento

    def __str__(self):
        return f"{self._nombre} (documento: {self._documento})"

    @abstractmethod
    def identificacion_individuo(self):
        """Cada clase hija debe decir cómo se identifica."""
        pass


# ---------------------------------------------------------------
# Clase Asignatura (no hereda de Persona)
# ---------------------------------------------------------------
class Asignatura:
    """Materia que cursa un estudiante."""

    def __init__(self, nombre, codigo, creditos):
        self._nombre = nombre
        self._codigo = codigo
        self.creditos = creditos  # pasa por el setter para validar el entero

    @property
    def nombre(self):
        return self._nombre

    @property
    def codigo(self):
        return self._codigo

    @property
    def creditos(self):
        return self._creditos

    @creditos.setter
    def creditos(self, valor):
        # Los créditos deben ser un entero positivo
        if not isinstance(valor, int) or valor <= 0:
            raise ValueError("Los créditos deben ser un entero positivo.")
        self._creditos = valor

    def __str__(self):
        # Formato pedido: MAT101 - Cálculo I (4 créditos)
        return f"{self._codigo} - {self._nombre} ({self._creditos} créditos)"


# ---------------------------------------------------------------
# Clase Estudiante (hereda de Persona)
# ---------------------------------------------------------------
class Estudiante(Persona):
    """Estudiante matriculado. Recibe asignaturas desde su docente."""

    def __init__(self, nombre, documento, estado):
        super().__init__(nombre, documento)
        # Se usa self.estado (y no self._estado) para que pase por el
        # setter y se valide desde el momento de crear el objeto.
        self.estado = estado
        self._director_grupo = None
        self._asignaturas = []  # lista propia de cada estudiante

    @property
    def estado(self):
        return self._estado

    @estado.setter
    def estado(self, valor):
        # Rechaza None, vacío o solo espacios
        if valor is None or not str(valor).strip():
            raise ValueError("El estado no puede estar vacío.")
        self._estado = str(valor).strip()

    @property
    def director_grupo(self):
        return self._director_grupo

    @property
    def asignaturas(self):
        # Se devuelve una copia para proteger la lista interna
        return list(self._asignaturas)

    # --- Métodos de uso interno (solo los llama el Docente) ---
    def _set_director_grupo(self, docente):
        self._director_grupo = docente

    def _agregar_asignatura(self, asignatura):
        self._asignaturas.append(asignatura)

    # --- Métodos públicos ---
    def total_creditos(self):
        # Suma los créditos de todas sus asignaturas
        return sum(a.creditos for a in self._asignaturas)

    def mostrar_horario(self):
        print(f"--- Horario de {self._nombre} ---")
        if not self._asignaturas:
            print("  (sin asignaturas inscritas)")
        for asignatura in self._asignaturas:
            print(f"  {asignatura}")
        print(f"  Total de créditos: {self.total_creditos()}")

    def identificacion_individuo(self):
        return (f"Estudiante {self._nombre} - doc. {self._documento} "
                f"- estado: {self._estado}")


# ---------------------------------------------------------------
# Clase Docente (hereda de Persona)
# ---------------------------------------------------------------
class Docente(Persona):
    """Docente director de grupo: gestiona a sus estudiantes."""

    def __init__(self, nombre, documento, area, escalafon):
        super().__init__(nombre, documento)
        self._area = area
        self._escalafon = escalafon
        # La lista se crea DENTRO del __init__ para que cada docente
        # tenga su propia lista (no compartida entre objetos).
        self._estudiantes = []

    @property
    def area(self):
        return self._area

    @property
    def escalafon(self):
        return self._escalafon

    @property
    def estudiantes(self):
        # Devuelve una copia: modificarla no afecta la lista interna
        return list(self._estudiantes)

    def inscribir_estudiante(self, estudiante):
        # Rechaza None
        if estudiante is None:
            print("RECHAZADO: no se puede inscribir un estudiante None.")
            return False
        # Rechaza duplicados
        if estudiante in self._estudiantes:
            print(f"RECHAZADO: {estudiante.nombre} ya está inscrito "
                  f"con {self._nombre}.")
            return False
        self._estudiantes.append(estudiante)
        # Al inscribirlo, este docente queda como su director de grupo
        estudiante._set_director_grupo(self)
        print(f"OK: {estudiante.nombre} inscrito. "
              f"Director de grupo: {self._nombre}.")
        return True

    def asignar_asignatura(self, estudiante, asignatura):
        # Valida que el estudiante pertenezca a la lista del docente
        if estudiante not in self._estudiantes:
            print(f"RECHAZADO: {self._nombre} no es director de grupo de "
                  f"{estudiante.nombre if estudiante else 'None'}.")
            return False
        if asignatura is None:
            print("RECHAZADO: la asignatura no puede ser None.")
            return False
        if asignatura in estudiante.asignaturas:
            print(f"RECHAZADO: {estudiante.nombre} ya tiene {asignatura.codigo}.")
            return False
        estudiante._agregar_asignatura(asignatura)
        print(f"OK: {asignatura.codigo} asignada a {estudiante.nombre}.")
        return True

    def identificacion_individuo(self):
        return (f"Docente {self._nombre} - doc. {self._documento} "
                f"- área: {self._area} - escalafón: {self._escalafon}")


# ---------------------------------------------------------------
# Clase solo para demostrar la Pregunta 1 (lista como atributo de clase)
# ---------------------------------------------------------------
class DocenteConListaDeClase(Persona):
    """Versión INCORRECTA: la lista es atributo de clase."""

    estudiantes = []  # compartida por TODOS los docentes

    def __init__(self, nombre, documento):
        super().__init__(nombre, documento)

    def identificacion_individuo(self):
        return f"DocenteMalo {self._nombre}"


def titulo(texto):
    """Imprime un título para separar las partes de la demostración."""
    print("\n" + "=" * 60)
    print(texto)
    print("=" * 60)


# ---------------------------------------------------------------
# Programa principal
# ---------------------------------------------------------------
def main():
    # Objetos 
    keating = Docente("John Keating", "1001", "Literatura", "Grado 14")
    mcgonagall = Docente("Minerva McGonagall", "1002", "Matemáticas", "Grado 12")

    hermione = Estudiante("Hermione Granger", "2001", "Activo")
    ferris = Estudiante("Ferris Bueller", "2002", "Activo")

    calculo = Asignatura("Cálculo I", "MAT101", 4)
    fisica = Asignatura("Física Mecánica", "FIS201", 3)
    poo = Asignatura("Programación Orientada a Objetos", "PRO301", 3)

    # 1. Inscripciones y duplicado
    titulo("1. Inscripción de estudiantes y duplicado")
    mcgonagall.inscribir_estudiante(hermione)
    keating.inscribir_estudiante(ferris)
    mcgonagall.inscribir_estudiante(hermione)   # duplicado -> rechazado
    mcgonagall.inscribir_estudiante(None)       # None -> rechazado

    # 2. Rechazo al asignar asignatura
    titulo("2. Rechazo: Keating no es director de Hermione")
    keating.asignar_asignatura(hermione, calculo)

    # Asignaciones válidas
    titulo("Asignaciones válidas")
    mcgonagall.asignar_asignatura(hermione, calculo)
    mcgonagall.asignar_asignatura(hermione, fisica)
    keating.asignar_asignatura(ferris, poo)
    keating.asignar_asignatura(ferris, calculo)

    # 3. Horarios
    titulo("3. Horarios de cada estudiante")
    hermione.mostrar_horario()
    ferris.mostrar_horario()

    # 4. Polimorfismo
    titulo("4. Recorrido polimórfico de list[Persona]")
    personas: list[Persona] = [keating, mcgonagall, hermione, ferris]
    for persona in personas:
        print(persona)                          # usa __str__
        print("   ->", persona.identificacion_individuo())

    # 5. Error del setter
    titulo("5. Error provocado por el setter de estado")
    try:
        hermione.estado = "   "
    except ValueError as error:
        print("ValueError capturado:", error)

    # 6. Instanciar la clase abstracta
    titulo("6. Error al instanciar Persona directamente")
    try:
        Persona("Nadie", "0000")
    except TypeError as error:
        print("TypeError capturado:", error)

    # 7. Copia de la lista
    titulo("7. Vaciar la copia no afecta la lista interna")
    copia = mcgonagall.estudiantes
    print("Estudiantes de McGonagall (copia):", len(copia))
    copia.clear()
    print("Copia después de clear():", len(copia))
    print("Lista interna después de clear():", len(mcgonagall.estudiantes))

    # Pregunta 1: lista como atributo de clase
    titulo("Pregunta 1: lista declarada como atributo de clase")
    malo1 = DocenteConListaDeClase("Docente Uno", "9001")
    malo2 = DocenteConListaDeClase("Docente Dos", "9002")
    malo1.estudiantes.append(hermione)
    print("Lista de malo1:", [e.nombre for e in malo1.estudiantes])
    print("Lista de malo2:", [e.nombre for e in malo2.estudiantes])
    print("¿Son la misma lista?", malo1.estudiantes is malo2.estudiantes)

    # Pregunta 3: el guion bajo no impide el acceso en Python
    titulo("Pregunta 3: llamar _agregar_asignatura desde fuera")
    ferris._agregar_asignatura(fisica)  # Python lo permite (solo es convención)
    ferris.mostrar_horario()


if __name__ == "__main__":
    main()