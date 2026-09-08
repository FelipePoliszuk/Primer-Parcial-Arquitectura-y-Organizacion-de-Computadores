#include "../ejs.h"

// Función auxiliar para contar casos por nivel
int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel){

    int contador = 0;

    for (size_t i = 0; i < largo; i++){
        caso_t caso = arreglo_casos[i];

        if (caso.usuario->nivel == nivel){
            contador ++;
        }
    }
    return contador;
}

// por referencia

segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {

    int largo0 = contar_casos_por_nivel(arreglo_casos, largo, 0);
    int largo1 = contar_casos_por_nivel(arreglo_casos, largo, 1);
    int largo2 = contar_casos_por_nivel(arreglo_casos, largo, 2);

    segmentacion_t *resultado = malloc((sizeof(segmentacion_t)));

    if (largo0 == 0){
        resultado->casos_nivel_0 = NULL;
    } else {
        resultado->casos_nivel_0 = malloc((sizeof(caso_t))*largo0);
    }

    if (largo1 == 0){
        resultado->casos_nivel_1 = NULL;
    } else {
        resultado->casos_nivel_1 = malloc((sizeof(caso_t))*largo1);
    }
    
    if (largo2 == 0){
        resultado->casos_nivel_2 = NULL;
    } else {
        resultado->casos_nivel_2 = malloc((sizeof(caso_t))*largo2);
    } 

    int j = 0;
    int k = 0;
    int l = 0;

    for (int i = 0; i < largo; i++){

        caso_t *caso = &arreglo_casos[i];
        uint32_t nivel = caso->usuario->nivel;

        if (nivel == 0){
            resultado->casos_nivel_0[j] = *caso;
            j++;
        }

        if (nivel == 1){
            resultado->casos_nivel_1[k] = *caso;
            k++;
        }
        
        if (nivel == 2){
            resultado->casos_nivel_2[l] = *caso;
            l++;
        }        
        
    }
    
    return resultado;

}


// chequear si esta version tiene sentido en ASM o descartarla completamente

// por copia

// segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {

//     int largo0 = contar_casos_por_nivel(arreglo_casos, largo, 0);
//     int largo1 = contar_casos_por_nivel(arreglo_casos, largo, 1);
//     int largo2 = contar_casos_por_nivel(arreglo_casos, largo, 2);

//     segmentacion_t *resultado = malloc((sizeof(segmentacion_t)));

//     if (largo0 == 0){
//         resultado->casos_nivel_0 = NULL;
//     } else {
//         resultado->casos_nivel_0 = malloc((sizeof(caso_t))*largo0);
//     }

//     if (largo1 == 0){
//         resultado->casos_nivel_1 = NULL;
//     } else {
//         resultado->casos_nivel_1 = malloc((sizeof(caso_t))*largo1);
//     }
    
//     if (largo2 == 0){
//         resultado->casos_nivel_2 = NULL;
//     } else {
//         resultado->casos_nivel_2 = malloc((sizeof(caso_t))*largo2);
//     } 

//     int j = 0;
//     int k = 0;
//     int l = 0;

//     for (int i = 0; i < largo; i++){

//         caso_t caso = arreglo_casos[i];
//         uint32_t nivel = caso.usuario->nivel;

//         if (nivel == 0){
//             resultado->casos_nivel_0[j] = caso;
//             j++;
//         }

//         if (nivel == 1){
//             resultado->casos_nivel_1[k] = caso;
//             k++;
//         }
        
//         if (nivel == 2){
//             resultado->casos_nivel_2[l] = caso;
//             l++;
//         }        
        
//     }
    
//     return resultado;

// }











// segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {

//     int largo0 = contar_casos_por_nivel(arreglo_casos, largo, 0);

//     segmentacion_t *resultado = malloc((sizeof(segmentacion_t)));

//     if (largo0 == 0){
//         resultado->casos_nivel_0 = NULL;
//     } else {
//         resultado->casos_nivel_0 = malloc((sizeof(caso_t))*largo0);
//     }

//     int j = 0;

//     for (int i = 0; i < largo; i++){

//         caso_t caso = arreglo_casos[i];
//         uint32_t nivel = caso.usuario->nivel;

//         if (nivel == 0){
//             resultado->casos_nivel_0[j] = caso;
//             j++;
//         }
        
//     }
    
//     return resultado;

// }