#include "../ejs.h"

// strcmp

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){

    // int j = 0;

    for (size_t i = 0; i < largo; i++){

        caso_t *caso = &arreglo_casos[i];
        uint32_t nivel = caso->usuario->nivel;

        if (nivel == 1 || nivel == 2){
            uint16_t funcionCierraCasos = funcion(caso); 
            if (funcionCierraCasos == 1){
                caso->estado = 1;
            } 

            if (funcionCierraCasos == 0){
                if (((strncmp(caso->categoria, "CLT",4) == 0) || (strncmp(caso->categoria, "RBO",4) == 0))){
                    caso->estado = 2;
                } else {
                    // casos_a_revisar[j] = *caso;
                    // j++;
                }
            }  
        }
        
        // if (nivel == 0){
        //     casos_a_revisar[j] = *caso;
        //     j++;
        // }        
     
    }

}


// versión desreferenciando despues sobre la funcion  


// void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){

//     int j = 0;

//     for (size_t i = 0; i < largo; i++){

//         caso_t caso = arreglo_casos[i];
//         uint32_t nivel = caso.usuario->nivel;

//         if (nivel == 1 || nivel == 2){
//             uint16_t funcionCierraCasos = funcion(&caso); 
//             if (funcionCierraCasos == 1){
//                 arreglo_casos[i].estado = 1;
//             } 

//             if (funcionCierraCasos == 0){
//                 if (((strncmp(caso.categoria, "CLT",4) == 0) || (strncmp(caso.categoria, "RBO",4) == 0))){
//                     arreglo_casos[i].estado = 2;
//                 } else {
//                     casos_a_revisar[j] = caso;
//                     j++;
//                 }
//             }  
//         }
        
//         if (nivel == 0){
//             casos_a_revisar[j] = caso;
//             j++;
//         }        
     
//     }

// }