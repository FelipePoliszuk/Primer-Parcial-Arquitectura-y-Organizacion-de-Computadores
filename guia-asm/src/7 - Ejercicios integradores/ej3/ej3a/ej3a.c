#include "../ejs.h"
#include <stdlib.h>

// Función auxiliar para contar casos por nivel

int contar_casos_por_nivel(caso_t *arreglo_casos, int largo, int nivel) {

  int cantidad = 0;

  if (arreglo_casos) {
    int i = 0;
    while (i < largo) {
      if (arreglo_casos[i].usuario->nivel == nivel) {
        cantidad += 1;
      }
      i += 1;
    }
  }

  return cantidad;
}

segmentacion_t *segmentar_casos(caso_t *arreglo_casos, int largo) {
  int casos0 = contar_casos_por_nivel(arreglo_casos, largo, 0);
  int casos1 = contar_casos_por_nivel(arreglo_casos, largo, 1);
  int casos2 = contar_casos_por_nivel(arreglo_casos, largo, 2);

  segmentacion_t *mallocRes = malloc(sizeof(segmentacion_t));

  // Reservar memoria para cada nivel (NULL si no hay casos)
  mallocRes->casos_nivel_0 =
      casos0 > 0 ? malloc(casos0 * sizeof(caso_t)) : NULL;
  mallocRes->casos_nivel_1 =
      casos1 > 0 ? malloc(casos1 * sizeof(caso_t)) : NULL;
  mallocRes->casos_nivel_2 =
      casos2 > 0 ? malloc(casos2 * sizeof(caso_t)) : NULL;

  // Índices para llenar cada arreglo
  int idx0 = 0, idx1 = 0, idx2 = 0;

  // Recorrer el arreglo original y copiar a los arreglos correspondientes
  for (int i = 0; i < largo; i++) {
    if (arreglo_casos[i].usuario->nivel == 0) {
      mallocRes->casos_nivel_0[idx0++] = arreglo_casos[i];
    } else if (arreglo_casos[i].usuario->nivel == 1) {
      mallocRes->casos_nivel_1[idx1++] = arreglo_casos[i];
    } else if (arreglo_casos[i].usuario->nivel == 2) {
      mallocRes->casos_nivel_2[idx2++] = arreglo_casos[i];
    }
  }

  return mallocRes;
}
