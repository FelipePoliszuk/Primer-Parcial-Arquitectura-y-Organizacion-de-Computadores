# Recuperatorio 1 - Arquitectura y Organización del Computador
### 2do Cuatrimestre 2026

- [Recuperatorio 1 - Arquitectura y Organización del Computador](#recuperatorio-1---arquitectura-y-organización-del-computador)
    - [2do Cuatrimestre 2026](#2do-cuatrimestre-2026)
- [Normas generales y modalidad de entrega](#normas-generales-y-modalidad-de-entrega)
  - [Régimen de Aprobación](#régimen-de-aprobación)
  - [Conocimientos a evaluar](#conocimientos-a-evaluar)
  - [Compilación y Testeo](#compilación-y-testeo)
- [Enunciado](#enunciado)
  - [Estructuras Principales](#estructuras-principales)
  - [Ejercicio 1 — Suscripción y unificación de disciplinas](#ejercicio-1--suscripción-y-unificación-de-disciplinas)
  - [Ejercicio 2 — Armado de combos de rutinas](#ejercicio-2--armado-de-combos-de-rutinas)
  - [Ejercicio 3 — Depuración de solicitudes y reserva de cancha](#ejercicio-3--depuración-de-solicitudes-y-reserva-de-cancha)



# Normas generales y modalidad de entrega

- El parcial es **INDIVIDUAL**
- Una vez terminada la evaluación se deberán subir los archivos `.asm` de cada ejercicio al campus de la materia.

## Régimen de Aprobación

- El parcial es en los laboratorios, usando las compus de los labos o sus propias compus.
- Es a libro abierto, pueden tener todo lo que se les ocurra a disposición. Esta totalmente prohibido el uso del celular, internet y chatbots.
- El internet de los laboratorios está limitado a la página del campus de la materia. 
- Quienes rindan con su computadora personal deberán conectarse al internet del labo mediante cable ethernet.
- **Sólo se evalúa programación en Assembly**, **C no se corrije** pero recomendamos que primero planteen una solución en C y después pasarla a Assembly cuando tengan en claro cómo estructurar la solución.
- Para aprobar el parcial deben implementar 2 de los 3 puntos del enunciado y que corran con éxito los tests funcionales, de abi y de memoria (valgrind).
- Vamos a usar herramientas de detección de plagio para asegurarnos de que su entrega sea original.

> [!NOTE]
> El comando `./tester.sh` corre los mismos tests que nosotros al corregir. Pueden usarlo para revisar que su parcial vaya a pasar los tests en dicho entorno.

> [!NOTE]
> Durante el parcial estaremos disponibles para resolver consultas de enunciado y para destrabarles si están dando vueltas mucho tiempo en algo que no forma parte de lo evaluado. NO responderemos preguntas teóricas.


## Conocimientos a evaluar 
- Uso de memoria dinámica.
- Navegación de punteros.
- Representación binaria de los tipos de datos.
- Manejo de pila.
- Manejo de structs.
- Convención C, ABI, uso de registros.
- Uso del debugger GDB.

## Compilación y Testeo

Para compilar y ejecutar los tests cada ejercicio dispone de un archivo
`Makefile` para cada uno, con los siguientes *targets*:

| Comando             | Descripción                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `make test_c`       | Genera el ejecutable usando la implementación en C del ejercicio.   |
| `make test_asm`     | Genera el ejecutable usando la implementación en ASM del ejercicio. |
| `make test_abi`     | Genera usando la implementación en ASM del ejercicio + archivos necesarios para ABI enforcer |
| `make run_c`        | Corre los tests usando la implementación en C.                      |
| `make run_asm`      | Corre los tests usando la implementación en ASM.                    |
| `make run_abi`      | Corre los tests usando la implementación en ASM + ABI enforcer.     |
| `make valgrind_c`   | Corre los tests en valgrind usando la implementación en C.          |
| `make valgrind_asm` | Corre los tests en valgrind usando la implementación en ASM.        |
| `make valgrind_abi` | Corre los tests en valgrind usando la implementación en ASM + ABI enforcer        |
| `make check_offsets` | Corre el chequeo de offsets                                         |
| `make run_main_c`        | Corre main usando la implementación en C.                      |
| `make run_main_asm`      | Corre main usando la implementación en ASM (no corre ABI enforcer).                    |
| `make clean`        | Borra todo archivo generado por el `Makefile`.                      |


> [!CAUTION]
> Para considerar un ejercicio aprobado, debe pasar los tests **con el comando** `make valgrind_abi`

# Enunciado

Se acercan las vacaciones y nos quedamos sin excusas para no tocar pasto, tomar sol y hacer un poco de ejercicio físico. El campo de deportes de la facultad advierte que se agotan los cupos para toda la oferta de clases, pero no quiere que nadie se quede afuera. Por eso nos encargaron el desarrollo de una aplicación que permita a las y los entrenadores de cada disciplina publicar rutinas de ejercicios que cada quien pueda realizar por su cuenta en caso de no conseguir lugar en las clases. Previendo que la demanda de uso va a ser alta, decidimos implementar algunas funciones críticas en Assembly x86-64 para asegurarnos de que la ejecución sea eficiente.

La aplicación contará con rutinas de calentamiento, entrenamiento y estiramiento para cada disciplina (básquet, vóley, judo, etc.), y permitirá a las personas usuarias:
1. Suscribirse a disciplinas compatibles (o unificables) según sus días de entrenamiento.
2. Elegir rutinas del catálogo completo para armar su propio combo de entrenamiento.
3. Coordinar con otras personas suscritas a una misma disciplina para reservar una cancha e ir a practicar en grupo.

## Estructuras Principales

Las estructuras completas y sus anotaciones para el chequeo de *offsets* se encuentran en `src/ejs.h`.

### Representación de días (bitmask)

En `disciplina_t`, `solicitud_t` y `cancha_t`, los días de la semana se codifican en un `uint8_t` usando los **7 bits menos significativos**:

* Bit `0` (`0x01`): Lunes
* Bit `1` (`0x02`): Martes
* Bit `2` (`0x04`): Miércoles
* Bit `3` (`0x08`): Jueves
* Bit `4` (`0x10`): Viernes
* Bit `5` (`0x20`): Sábado
* Bit `6` (`0x40`): Domingo

Por ejemplo, una disciplina que se entrena lunes y miércoles tiene `dias = 0x01 | 0x04 = 0x05`. Dos disciplinas **comparten al menos un día** si el AND entre sus máscaras es distinto de cero:
 
```
  0x05  = 0000 0101   (Lunes, Miércoles)
& 0x14  = 0001 0100   (Miércoles, Viernes)
  ------------------
  0x04  = 0000 0100   → comparten el Miércoles
```

> [!TIP] (Opcional)
> Cuidado con la precedencia en C: `a & b != 0` se evalúa como `a & (b != 0)`.

### Estructuras compartidas (Disciplinas, Suscripciones y Usuarios)

```C
typedef struct {
    uint8_t dias;                // Bitmask de días de la semana
    char nombre[19];
    uint32_t id;
    uint8_t nivel_requerido;
} disciplina_t;

typedef struct {
    bool activa;
    disciplina_t *disciplina;
    uint16_t semanas_restantes;
} suscripcion_t;

typedef struct {
    uint32_t id;
    suscripcion_t *suscripciones; // Array prealocado de tamaño max_suscripciones
    uint32_t cant_suscripciones;  // Cantidad actual de elementos válidos
    uint32_t max_suscripciones;   // Capacidad máxima del array
} usuario_t;
```
**Personas usuarias y suscripciones**

Cada persona usuaria se representa con un `usuario_t`. Además de su `id`, guarda un arreglo `suscripciones`: cada elemento es una `suscripcion_t` que indica una disciplina (deporte) a la que la persona se anotó.

Cada usuario **puede suscribirse como máximo a `max_suscripciones` disciplinas**. Por eso el arreglo ya viene reservado en memoria con lugar para `max_suscripciones` elementos, pero **solo las primeras `cant_suscripciones` posiciones tienen datos válidos**. El resto es espacio libre.

## Ejercicio 1 — Suscripción y unificación de disciplinas

Cuando una persona quiere anotarse a una disciplina nueva (la `candidata`), antes de registrarla hay que revisar si cuadra con sus otras suscripciones:

* **No puede anotarse dos veces a lo mismo.** Si ya tiene una suscripción a una disciplina con el mismo `id`, se rechaza.
* **Si la candidata comparte días con alguna de sus disciplinas, hay que revisar si son unificables.** Por ejemplo, si los lunes ya hace *Pilates* y quiere sumar *Yoga* también los lunes, al ser disciplinas parecidas quizás sus rutinas de entrenamiento se pueden fusionar. 
    * Si se pueden combinar, **se combinan sí o sí**: no se agrega una suscripción nueva, sino que se reemplaza la disciplina de la suscripción existente por la versión unificada (ver función `unificar` más abajo).
    * Si no se puede combinar con ninguna pero hay espacio en el array, **se suscribe igual.** Que dos disciplinas caigan el mismo día no es motivo de rechazo: así como el SIU Guaraní te deja inscribirte en dos materias que se superponen, asumimos que la persona sabe lo que hace (y verá cómo se organiza). En este caso, igual que cuando no choca con nada, es una suscripción nueva común y corriente: se agrega con estado activa y con 4 semanas restantes.

Se pide implementar esta lógica en la función encargada de suscribir un `usuario` a una `disciplina` candidata:

```C
bool suscribirDisciplina(
    usuario_t *usuario,
    disciplina_t *candidata,
    bool (*son_unificables)(const disciplina_t *, const disciplina_t *)
);
```

Además, cuentan con la siguiente función auxiliar ya implementada en C:

```C
disciplina_t *unificar(disciplina_t *A, disciplina_t *B);
```

### Comportamiento esperado

1. La función debe recorrer en orden las suscripciones actuales del usuario y comparar sus disciplinas contra la candidata:
   * **Duplicado:** Si la suscripción apunta a una disciplina con el mismo `id` que `candidata->id`, la suscripción debe rechazarse devolviendo `false` sin modificar al usuario.
   * **Solapamiento de días y unificación:** Si la disciplina de la suscripción `i` comparte al menos un día con `candidata` (`(actual->dias & candidata->dias) != 0`), se debe consultar `son_unificables(actual, candidata)`:
     * Si devuelve `true`, se debe llamar inmediatamente a `unificar(actual, candidata)`, reemplazar la disciplina de esa suscripción con el puntero devuelto y devolver `true`.
       * **No** se debe liberar la memoria de la disciplina original ni de la `candidata`.
       * `cant_suscripciones` **no** se ve afectada en este caso.
     * Si devuelve `false`, se continúa recorriendo el resto de las suscripciones.
2. Si se finaliza el recorrido sin encontrar duplicados ni una suscripción unificable:
   * Si no se alcanzó el máximo de suscripciones (`cant_suscripciones < max_suscripciones`):
     * Agregar la nueva suscripción al final con `activa = true`, `disciplina = candidata` y `semanas_restantes = 4`.
     * Incrementar `cant_suscripciones` en 1.
     * Devolver `true`.
   * Si se alcanzó el máximo de suscripciones:
     * Devolver `false`.

> **ℹ️ Aclaraciones**
> - Se asume que todos los punteros recibidos por parámetro (`usuario`, `candidata`, `son_unificables` y `usuario->suscripciones` cuando `max_suscripciones > 0`) son válidos y no `NULL`.
> - Si hay más de una disciplina unificable con la candidata, se unifica únicamente la **primera** que aparezca en el arreglo.


## Ejercicio 2 — Armado de combos de rutinas

Si alguien prefiere armar sus propios entrenamientos, puede armar combos con las rutinas creadas por las y los entreandores, disponibles en un catálogo unificado.
Cada rutina es un bloque de ejercicios (no representados) con las siguientes características:

* pertenece a una **fase**: calentamiento, entrenamiento o estiramiento,
* dura una cierta cantidad de **minutos**,
* tiene un **ajuste de intensidad** que la vuelve más exigente (si es positivo) o más liviana (si es negativo).

Los combos agrupan varias rutinas y obtienen un puntaje de intensidad total a partir de ellas. Como queremos que los usuarios siempre vean la última versión de una rutina, el combo almacenará referencias a cada una.

Las rutinas del catálogo y los combos armados por los usuarios se representan con las siguientes estructuras:

```C
typedef enum {
    FASE_CALENTAMIENTO = 1,
    FASE_ESTIRAMIENTO  = 2,
    FASE_ENTRENAMIENTO = 3
} fase_t;

typedef struct {
    uint8_t fase;                // Valores de fase_t (1, 2 o 3)
    uint32_t id;
    int8_t ajuste_intensidad;    // Entero con signo (puede ser negativo)
    uint16_t duracion_min;
    char nombre[21];
    uint16_t calorias_base;
} rutina_t;

typedef struct {
    rutina_t **rutinas;          // Array de punteros a las rutinas del catálogo
    uint32_t cant_rutinas;
    int32_t puntaje_intensidad;  // Métrica que habrá que calcular, cuidado con su valor inicial
} combo_t;
```

Se pide implementar:

```C
combo_t *armarCombo(
    const rutina_t *catalogo,
    uint32_t cant_catalogo,
    const uint32_t *ids_elegidos, //Corresponden a los ids de las rutinas dentro del catálogo
    uint32_t cant_elegidos
);
```

### Comportamiento esperado

1. La función debe crear un combo con las rutinas elegidas (la copia de las rutinas es **superficial**: cada posición apunta directamente a la `rutina_t` correspondiente dentro de `catalogo`).
    * Si alguno de los IDs elegidos no existe en el catálogo, la función debe retornar `NULL` y **liberar la memoria** que se haya pedido hasta ese momento.
2. Se debe calcular la intensidad del combo de acuerdo a la siguiente fórmula:
   * `puntaje_intensidad` = $\sum \left(\text{fase} \cdot \text{duracion\_min} + (\text{int32\_t})\text{ajuste\_intensidad} \cdot 10\right)$.

> **ℹ️ Aclaraciones y sugerencias**
> - Se asume que `catalogo`, `ids_elegidos` son siempre punteros válidos, que `cant_catalogo` y `cant_elegidos` reflejan correctamente sus respectivos tamaños, y que `cant_elegidos >= 2`.
> - Prestar especial atención a los tipos de las variables a la hora de calcular la intensidad.
> - Sugerimos implementar la función auxiliar `rutina_t *obtenerRutinaDeCatalogo(uint32_t id_rutina, rutina_t *catalogo, uint32_t cant_catalogo)`

## Ejercicio 3 — Depuración de solicitudes y reserva de cancha

Los usuarios pueden solicitar reservar una cancha para practicar su disciplina presencialmente. La reserva se confirma recién cuando haya solicitudes suficientes para satisfacer el mínimo de jugadores requerido por la cancha para un día determinado.

Para confirmar una reserva, revisaremos la lista de solicitudes (representada como una lista enlazada) contando la cantidad de solicitudes validas y eliminando aquellas que no lo sean.

Una solicitud se considera inválida si su disciplina no coincide con la de la cancha o ninguno de sus días disponibles coincide con el día de reserva.

Para coordinar reservas grupales de canchas se utilizan las siguientes estructuras:

```C
typedef struct solicitud_t {
    uint8_t dias_disponibles;    // Bitmask de días disponibles del usuario
    uint32_t disciplina_id;      // ID de la disciplina solicitada
    struct solicitud_t *next;
    usuario_t *usuario;
} solicitud_t;

typedef struct {
    solicitud_t *first;
} lista_solicitudes_t;

typedef struct {
    uint32_t disciplina_id;              // ID de la disciplina habilitada
    uint16_t min_jugadores;
    uint16_t max_cupos;
} cancha_t;

typedef struct {
    uint32_t cant_participantes;
    uint8_t dia_bitmask;
    cancha_t *cancha;
} reserva_t;
```

Se pide implementar:

```C
reserva_t *confirmarReserva(
    lista_solicitudes_t *lista,
    cancha_t *cancha,
    uint8_t dia_bitmask                  // Bitmask del día de la reserva (un único día)
);
```

### Comportamiento esperado

1. La función debe recorrer la lista de solicitudes para reconocer y quitar las inválidas. Una solicitud es **válida** si y solo si cumple ambas condiciones:
   * `(solicitud->dias_disponibles & dia_bitmask) != 0` (alguno de sus días disponibles coincide con el día de la reserva).
   * `solicitud->disciplina_id == cancha->disciplina_id`.
2. Toda solicitud **inválida** debe quitarse de la lista y su memoria debe ser liberada. Procurar liberar únicamente el nodo `solicitud_t`, **no** liberar `usuario_t`, y **dejar la lista en un estado consistente**.
3. Si la cantidad de solicitudes válidas es menor a `cancha->min_jugadores`, devolver `NULL` (dejando la lista limpia de solicitudes inválidas).
4. Si la cantidad de solicitudes válidas es mayor o igual a `cancha->min_jugadores`:
   * Sea `cupo = min(cant_validas, cancha->max_cupos)`.
   * Crear una `reserva_t` y cargar `cancha`, `dia_bitmask` y `cant_participantes = cupo`.
   * Devolver el puntero a la `reserva_t` creada.

> **ℹ️ Aclaraciones**
> - Se asume que `lista` y `cancha` son parámetros válidos (no `NULL`), que `dia_bitmask` marca exactamente un único día (un solo bit en 1 entre los bits `0..6`), que `cancha->max_cupos > 0`, y que la cantidad de solicitudes válidas en la lista es representable en 2 bytes (`uint16_t`).