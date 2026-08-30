#include "../ejs.h"
#include <stdlib.h>
#include <string.h>

estadisticas_t *calcular_estadisticas(caso_t *arreglo_casos, int largo,
                                      uint32_t usuario_id) {

  estadisticas_t *resultado = malloc(sizeof(estadisticas_t));

  resultado->cantidad_CLT = 0;
  resultado->cantidad_estado_0 = 0;
  resultado->cantidad_estado_1 = 0;
  resultado->cantidad_estado_2 = 0;
  resultado->cantidad_KDT = 0;
  resultado->cantidad_KSC = 0;
  resultado->cantidad_RBO = 0;

  if (usuario_id != 0) {
    for (int i = 0; i < largo; i++) {
      if (arreglo_casos[i].usuario->id == usuario_id) {
        if (strcmp(arreglo_casos[i].categoria, "CLT") == 0) {
          resultado->cantidad_CLT += 1;
        }
        if (strcmp(arreglo_casos[i].categoria, "RBO") == 0) {
          resultado->cantidad_RBO += 1;
        }
        if (strcmp(arreglo_casos[i].categoria, "KSC") == 0) {
          resultado->cantidad_KSC += 1;
        }
        if (strcmp(arreglo_casos[i].categoria, "KDT") == 0) {
          resultado->cantidad_KDT += 1;
        }
        if (arreglo_casos[i].estado == 0) {
          resultado->cantidad_estado_0 += 1;
        }
        if (arreglo_casos[i].estado == 1) {
          resultado->cantidad_estado_1 += 1;
        }
        if (arreglo_casos[i].estado == 2) {
          resultado->cantidad_estado_2 += 1;
        }
      }
    }
  } else {
    for (int i = 0; i < largo; i++) {
      if (strcmp(arreglo_casos[i].categoria, "CLT") == 0) {
        resultado->cantidad_CLT += 1;
      }
      if (strcmp(arreglo_casos[i].categoria, "RBO") == 0) {
        resultado->cantidad_RBO += 1;
      }
      if (strcmp(arreglo_casos[i].categoria, "KSC") == 0) {
        resultado->cantidad_KSC += 1;
      }
      if (strcmp(arreglo_casos[i].categoria, "KDT") == 0) {
        resultado->cantidad_KDT += 1;
      }
      if (arreglo_casos[i].estado == 0) {
        resultado->cantidad_estado_0 += 1;
      }
      if (arreglo_casos[i].estado == 1) {
        resultado->cantidad_estado_1 += 1;
      }
      if (arreglo_casos[i].estado == 2) {
        resultado->cantidad_estado_2 += 1;
      }
    }
  }

  return resultado;
}
