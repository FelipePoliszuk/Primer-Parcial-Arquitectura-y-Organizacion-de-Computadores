#include "../ejs.h"

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){
 
    estadisticas_t* estadisticas = malloc(sizeof(estadisticas_t));

    estadisticas->cantidad_CLT = 0;
    estadisticas->cantidad_RBO = 0;
    estadisticas->cantidad_KSC = 0;
    estadisticas->cantidad_KDT = 0;
    
    estadisticas->cantidad_estado_0 = 0;
    estadisticas->cantidad_estado_1 = 0;
    estadisticas->cantidad_estado_2 = 0;

    if (usuario_id != 0){
            
        for (size_t i = 0; i < largo; i++){
            caso_t *caso = &arreglo_casos[i];

            if (caso->usuario->id == usuario_id){


                if ((strcmp("CLT",caso->categoria)) == 0){
                    estadisticas->cantidad_CLT ++;
                }

                if ((strcmp("RBO",caso->categoria)) == 0){
                    estadisticas->cantidad_RBO ++;
                }
                
                if ((strcmp("KSC",caso->categoria)) == 0){
                    estadisticas->cantidad_KSC ++;
                }      

                if ((strcmp("KDT",caso->categoria)) == 0){
                    estadisticas->cantidad_KDT ++;
                }                      

                if (caso->estado == 0){
                    estadisticas->cantidad_estado_0 ++;
                }            
                
                if (caso->estado == 1){
                    estadisticas->cantidad_estado_1 ++;
                }   
                
                if (caso->estado == 2){
                    estadisticas->cantidad_estado_2 ++;
                }    
            }
            
        }
    }

    if (usuario_id == 0){
            
        for (size_t i = 0; i < largo; i++){
            caso_t *caso = &arreglo_casos[i];

            if ((strcmp("CLT",caso->categoria)) == 0){
                estadisticas->cantidad_CLT ++;
            }

            if ((strcmp("RBO",caso->categoria)) == 0){
                estadisticas->cantidad_RBO ++;
            }
            
            if ((strcmp("KSC",caso->categoria)) == 0){
                estadisticas->cantidad_KSC ++;
            }           

            if ((strcmp("KDT",caso->categoria)) == 0){
                estadisticas->cantidad_KDT ++;
            }               

            if (caso->estado == 0){
                estadisticas->cantidad_estado_0 ++;
            }            
            
            if (caso->estado == 1){
                estadisticas->cantidad_estado_1 ++;
            }   
            
            if (caso->estado == 2){
                estadisticas->cantidad_estado_2 ++;
            }               
            
        }
    }

    return estadisticas;
}   

