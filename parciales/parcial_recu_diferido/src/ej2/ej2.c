#include "../ejs.h"
#include "../ejs_aux.h"

bool meetsRequirements(backpack_t *backpack, destination_t *dest);


void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack) {

    event_t **indirecto = &(itinerary->first);

    while (*indirecto){

        event_t *actual = *indirecto;

        if (!meetsRequirements(backpack,actual->destination)){
            
            *indirecto = actual->next;
            free_event2(actual);

        } else {
            indirecto = &(actual->next);
        }
    }
}

// Funcion Auxiliar
bool meetsRequirements(backpack_t *backpack, destination_t *dest) {

    for (uint32_t i = 0; i < dest->requirements_size; i++){

        if (!backpackContainsItem(backpack,dest->requirements[i])){
            return false;
        }

    }

    return true;
}

// Funcion Auxiliar
void free_event2(event_t *event) {

    free(event->destination->requirements);
    free(event->destination);
    free(event);

}

// // versión con *anterior
// void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack) {

//     event_t *actual = itinerary->first;
//     event_t *anterior = NULL;

//     while (actual){
//         event_t *proximo = actual->next;
//         if (!meetsRequirements(backpack, actual->destination)){
            
//             if (anterior == NULL){          // caso primer nodo de la lista 
//                 itinerary->first = proximo;
//             } else{

//                 anterior->next = proximo;
//             }
//             free_event2(actual);
            
//         } else {

//             anterior = actual;
//         }
//         actual = proximo;
//     }
    
// }