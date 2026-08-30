#include <assert.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../test-utils.h"
#include "Memoria.h"

int stringLen(char *palabra) {

  int cantidad = 0;

  // char *palabraActual = palabra;

  while (*palabra != '\0') {

    palabra++;
    cantidad += 1;
  }

  return cantidad;
}

int strCmp2(char *a, char *b) {
  while (*a != '\0' && *b != '\0') {
    if (*a < *b)
      return 1; // a es menor
    if (*a > *b)
      return -1; // a es mayor
    a++;
    b++;
  }

  // Si llegamos acá, una de las dos terminó
  if (*a == '\0' && *b == '\0')
    return 0; // iguales
  if (*a == '\0')
    return 1; // a terminó primero → menor
  return -1;  // b terminó primero → a es mayor
}

char *strClone2(char *a) {
  int longitud = strLen(a);

  char *copy = (char *)malloc(longitud + 1); // reservar memoria (+1 para '\0')
  if (!copy)
    return NULL; // manejo de error

  for (int i = 0; i <= longitud; i++) { // copiar incluyendo '\0'
    copy[i] = a[i];
  }

  return copy;
}

int main() {
  // TESTS

  // strLen

  char *palabra = "Felipe";
  int result = stringLen(palabra);

  printf("La longitud de '%s' es %d\n", palabra, result);

  strLen(palabra);
  assert(result == 6);

  // strDelete (usando memoria dinámica)
  char *palabra2 = malloc(7);
  strcpy(palabra2, "Felipe");
  strDelete(palabra2);
  // no acceder a palabra2 después de free; solo verificamos que no crashee

  // strComp
  char *palabra3 = "felipe";
  char *palabra4 = "FELIPE";

  printf("%d\n", strCmp2(palabra4, palabra3));

  // strClone
  char *palabra5 = "felipe";
  char *palabra6 = strClone2(palabra5);
  printf("%s\n", palabra6);
  strDelete(palabra6);

  char *texto = "Violetta\n";
  strPrint(texto, stdout); // imprime en pantalla

  return 0;
}