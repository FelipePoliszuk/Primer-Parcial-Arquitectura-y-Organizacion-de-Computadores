En una máquina de uno de los labos de la facultad, nos encontramos un _pendrive_ con un programa ejecutable de linux adentro.
Investigando un poco vimos que se trata de un programa de prueba interno de una importante compañía de software, que sirve para probar la validez de claves para su sistema operativo.
Si logramos descubrir la clave... bueno, sería interesante...
Para ello llamamos por teléfono a la división de desarrollo en USA, haciéndonos pasar por Susan, la amiga de John (quien averiguamos estuvo en la ECI dando una charla sobre seguridad).
De esa llamada averiguamos:

- El programador que compiló el programa olvidó sacar los símbolos de *debug* en la función que imprime el mensaje de autenticación exitosa/fallida.
  Esta función toma un único parámetro de tipo `int` llamado `miss` que utiliza para definir y imprimir un mensaje de éxito o de falla de autenticación.
- La clave está guardada en una variable local (de tipo `char*`) de alguna función en la cadena de llamados de la función de autenticación.

Se pide:

1. Investigar como ver los símbolos de debug con GDB e identificar funciones que podrían ser las que imprimanel mensaje de autenticación exitosa/fallida.
2. Correr el programa con `gdb` y poner breakpoints en la o las funciones identificadas.
3. Para cada función, imprimir una porción del stack, con un formato adecuado para ver si podemos encontrar la clave.
4. ¿En que función se encuentra la clave? Explicar el mecanismo de como se llega a encontrar la función en la que se calcula la clave.

### Tips de GDB:
- :exclamation: El comando `backtrace` de gdb permite ver el stack de llamados hasta el momento actual de la ejecución del programa, y el comando `frame` permite cambiar al frame determinado. 
  `info frame` permite ver información del frame activo actualmente.
- Los parámetros pasados al comando `run` dentro de gdb se pasan al binario como argumentos, por ejemplo `run clave` iniciará la ejecución del binario cargado en gdb, pasándole un argumento con valor "clave".
- El comando `p {tipo} dirección` permite pasar a `print` cómo se debe interpretar el contenido de la dirección.  
Por ejemplo: `p {char*} 0x12345678` es equivalente a `p *(char**) 0x12345678`.  
  - En el ejemplo mostrado, sabemos que en la dirección `0x12345678` hay un puntero a `char`, por lo que le decimos a `gdb` que interprete el contenido de esa dirección como un puntero a `char`.
- El comando `p ({tipo} dirección)@cantidad` permite imprimir una cantidad de elementos de un tipo determinado a partir de una dirección.
Esto es sumamente práctico cuando conocemos la dirección y el tipo de una variable y queremos ver su contenido.






LA RESPUESTA:
./validate_key clave_192.168.0.157


gdb ./programa
(gdb) info functions
b (funcion)
run "asd"
frame
info frame
disassemble
p (char*) $rax








1)Ver símbolos de debug e identificar funciones relevantes:


En GDB, usar info functions para listar funciones.

Buscar funciones con nombres como print_authentication_message o do_some_stuff, que podrían imprimir mensajes de éxito o error.

2)Correr el programa y poner breakpoints:
gdb ./validate_key
(gdb) break do_some_stuff
(gdb) break print_authentication_message
(gdb) run

3)Imprimir porción del stack para encontrar la clave:

Usar info frame para ver dirección del frame y registros.

Usar x/s <dirección> sobre registros o variables locales para ver cadenas en memoria.

También se puede inspeccionar lo que devuelve asprintf o cadenas formateadas ("clave_%s").


4)Función donde se encuentra la clave y mecanismo:

La clave se calcula en do_some_stuff, donde se forma dinámicamente usando asprintf con el formato "clave_%s" y la IP local de la máquina.

Se llegó a esta función al inspeccionar los símbolos, poner breakpoints y observar que allí se construye la cadena de la clave antes de pasarla a la función que imprime el mensaje de autenticación.
