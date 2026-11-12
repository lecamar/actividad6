# Sistema escolar en Python: análisis y manuales

Sistema para gestionar docentes, estudiantes y asignaturas de un colegio. Regla principal: un estudiante solo puede tener asignaturas inscritas por su docente director de grupo.

El modelo se trasladó desde el ejemplo clínico visto en clase:

| Modelo clínico | Modelo escolar | Rol |
|---|---|---|
| `Persona` | `Persona` | Clase padre abstracta |
| `Medico` | `Docente` | Hija de `Persona`, gestiona sus estudiantes |
| `Paciente` | `Estudiante` | Hija de `Persona`, recibe asignaturas |
| `Medicamento` | `Asignatura` | Clase fuera de la jerarquía |
| `asignar_paciente()` | `inscribir_estudiante()` | El docente guarda la lista de estudiantes |
| `recetar()` | `asignar_asignatura()` | Valida que el estudiante pertenezca al docente |
| `mostrar_formula()` | `mostrar_horario()` | Lista el contenido académico del estudiante |

## Contenido del repositorio

```
.
├── sistema_escolar.py   # Programa completo con main de demostración
└── README.md            # Análisis, libreto del video y manuales
```

## Cómo ejecutar

Requisitos: Python 3.9 o superior. No se usan librerías externas (solo `abc` de la biblioteca estándar).

```bash
python actividad6.py
```

## 1. Preguntas de análisis

### 1.1 ¿Qué pasaría si la lista de estudiantes fuera atributo de clase y no estuviera en `__init__`?

Se probó con una clase `DocenteConListaDeClase`, que declara `estudiantes = []` en el cuerpo de la clase. La salida del programa fue:

```
Lista de malo1: ['Hermione Granger']
Lista de malo2: ['Hermione Granger']
¿Son la misma lista? True
```

**Explicación:** un atributo de clase se crea una sola vez, cuando Python define la clase, y lo comparten todos los objetos. Al hacer `malo1.estudiantes.append(...)` no se crea una lista nueva para `malo1`: se modifica la única lista de la clase. Por eso `malo2`, que nunca recibió a Hermione, también la "tiene". En un colegio real esto rompe la regla del negocio, porque todos los docentes verían a todos los estudiantes. Al crear la lista dentro de `__init__` con `self._estudiantes = []`, cada docente recibe su propia lista independiente.

### 1.2 ¿Por qué `Estudiante.__init__` debe usar `self.estado = estado` y no `self._estado = estado`?

Porque `self.estado = ...` pasa por el **setter** de la propiedad `estado`, que valida que el valor no sea `None`, vacío ni solo espacios. En cambio, `self._estado = ...` escribe directo en el atributo protegido y se salta la validación. Con `self._estado`, se podría crear un estudiante con estado vacío y el error solo aparecería después, al usar el setter. Usando `self.estado`, la regla se cumple desde el momento en que se crea el objeto.

### 1.3 ¿Por qué el guion bajo de `_agregar_asignatura()` no impide llamarlo desde fuera? ¿Qué mecanismo de Java sí lo impide?

En Python el guion bajo inicial es solo una **convención** entre programadores: avisa "esto es de uso interno", pero el intérprete no lo hace cumplir. En el programa se comprobó llamando `ferris._agregar_asignatura(fisica)` desde `main`, y funcionó (el total de Ferris pasó de 7 a 10 créditos sin pasar por el docente).

En Java el mecanismo que sí lo impide son los **modificadores de acceso**, que el compilador verifica. Con `private`, solo la propia clase puede usar el método y cualquier otro intento da error de compilación ("has private access"). Como en este diseño el método lo debe llamar `Docente` pero no el código externo, en Java se usaría el acceso **de paquete** (sin modificador) con `Docente` y `Estudiante` en el mismo paquete: las clases del paquete pueden llamarlo y el resto no.

## Video

<div align="center">
  <a href="[https://www.youtube.com/watch?v=H7q9dEORVSQ">
    <img src="https://img.shields.io/badge/YouTube-Ver%20Video-red?style=for-the-badge&logo=youtube" alt="Ver video en YouTube">
  </a>
</div>

## 3. Manual de programación

### 3.1 Requisitos y ejecución

- Python 3.9 o superior. No se usan librerías externas, solo `abc` de la biblioteca estándar.
- Ejecución: `python actividad6.py`

### 3.2 Estructura del programa

| Clase | Hereda de | Responsabilidad |
|---|---|---|
| `Persona` | `ABC` | Clase abstracta con `_nombre`, `_documento`, `__str__` e `identificacion_individuo()` abstracto |
| `Asignatura` | (ninguna) | Datos de la materia: nombre, código y créditos (entero positivo) |
| `Docente` | `Persona` | Gestiona su lista de estudiantes, inscribe y asigna asignaturas |
| `Estudiante` | `Persona` | Guarda estado, director de grupo y asignaturas; calcula créditos y muestra el horario |
| `DocenteConListaDeClase` | `Persona` | Clase de ejemplo incorrecto, solo para la pregunta 1 |

### 3.3 Detalle de cada clase

**Persona.** Define `_nombre` y `_documento` como atributos protegidos con propiedades sin setter. Sobrescribe `__str__` y declara `identificacion_individuo()` con `@abstractmethod`.

**Asignatura.** Atributos `nombre`, `codigo` y `creditos`. El setter de `creditos` lanza `ValueError` si no es un entero positivo. `__str__` devuelve el formato `MAT101 - Cálculo I (4 créditos)`.

**Docente.** Agrega `area`, `escalafon` y la lista `_estudiantes`, creada dentro de `__init__`.

- `inscribir_estudiante(estudiante)`: rechaza `None` y duplicados; si lo acepta, lo agrega y llama `estudiante._set_director_grupo(self)`.
- `asignar_asignatura(estudiante, asignatura)`: imprime `RECHAZADO` si el estudiante no está en su lista; también rechaza asignaturas `None` o repetidas.
- Propiedad `estudiantes`: devuelve `list(self._estudiantes)`, una copia.

**Estudiante.** Agrega `estado` (con setter validado), `director_grupo` y la lista `_asignaturas`.

- `_set_director_grupo()` y `_agregar_asignatura()`: de uso interno, solo los llama el docente.
- `total_creditos()`: suma los créditos de sus asignaturas.
- `mostrar_horario()`: imprime cada asignatura y el total de créditos.

### 3.4 Decisiones de diseño

- **Copias defensivas:** las propiedades `estudiantes` y `asignaturas` devuelven copias para que el código externo no altere el estado interno.
- **Listas dentro de `__init__`:** evita compartir datos entre objetos (ver pregunta 1.1).
- **Validación en el setter:** centraliza la regla del estado en un solo lugar.
- **Regla del director de grupo:** la comprobación está en `Docente.asignar_asignatura`, que es quien tiene la lista de sus estudiantes.

### 3.5 Conceptos aplicados

Abstracción (`ABC` y método abstracto), herencia (`Docente` y `Estudiante` heredan de `Persona`), encapsulamiento (atributos protegidos, propiedades y copias), polimorfismo (`identificacion_individuo()` sobre `list[Persona]`) y asociación entre objetos (docente con estudiantes, estudiante con asignaturas).

## 4. Manual de pruebas funcionales

Todas las pruebas se ejecutaron con `python actividad6.py` y el resultado obtenido es la salida real del programa.

| N.º | Prueba | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|
| 1 | Inscribir a Hermione con McGonagall | Se inscribe y McGonagall queda como directora de grupo | `OK: Hermione Granger inscrito. Director de grupo: Minerva McGonagall.` | Aprobada |
| 2 | Inscribir a Hermione de nuevo (duplicado) | Rechazo | `RECHAZADO: Hermione Granger ya está inscrito con Minerva McGonagall.` | Aprobada |
| 3 | Inscribir `None` | Rechazo | `RECHAZADO: no se puede inscribir un estudiante None.` | Aprobada |
| 4 | Keating asigna MAT101 a Hermione (no es su estudiante) | Rechazo | `RECHAZADO: John Keating no es director de grupo de Hermione Granger.` | Aprobada |
| 5 | McGonagall asigna MAT101 y FIS201 a Hermione | Se asignan | `OK: MAT101 asignada...` y `OK: FIS201 asignada...` | Aprobada |
| 6 | Horario de Hermione | MAT101 (4) + FIS201 (3) = 7 créditos | `Total de créditos: 7` | Aprobada |
| 7 | Horario de Ferris | PRO301 (3) + MAT101 (4) = 7 créditos | `Total de créditos: 7` | Aprobada |
| 8 | Recorrido polimórfico de `list[Persona]` | Cada objeto muestra su propia identificación | Dos líneas de "Docente..." y dos de "Estudiante..." | Aprobada |
| 9 | `hermione.estado = "   "` | `ValueError` | `ValueError capturado: El estado no puede estar vacío.` | Aprobada |
| 10 | `Persona("Nadie", "0000")` | `TypeError` | `TypeError capturado: Can't instantiate abstract class Persona without an implementation for abstract method 'identificacion_individuo'` | Aprobada |
| 11 | Vaciar la copia de `estudiantes` | La lista interna no cambia | Copia: 1 a 0; lista interna: 1 | Aprobada |
| 12 | Lista como atributo de clase (pregunta 1) | Las listas se comparten | `¿Son la misma lista? True` | Aprobada (demuestra el problema) |
| 13 | Llamar `_agregar_asignatura` desde fuera (pregunta 3) | Python lo permite | Ferris pasó de 7 a 10 créditos | Aprobada (demuestra la convención) |

### Evidencia

<img width="1920" height="1032" alt="Screenshot 2026-11-11 174022" src="https://github.com/user-attachments/assets/42164eeb-b4d5-4f7e-a326-977d1450ce4b" />
<img width="1920" height="1032" alt="Screenshot 2026-11-11 174017" src="https://github.com/user-attachments/assets/37cdc737-a533-4069-b7f9-8437aad3e8b0" />
<img width="1920" height="1032" alt="Screenshot 2026-11-11 173958" src="https://github.com/user-attachments/assets/b14cd96c-9dba-4fc0-a336-65753110cce6" />
