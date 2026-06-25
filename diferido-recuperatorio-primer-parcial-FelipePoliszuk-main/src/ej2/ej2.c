#include "../ejs.h"
#include "../ejs_aux.h"

bool meetsRequirements(backpack_t *backpack, destination_t *dest);

// void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack) {

//     event_t *actual = itinerary->first;
//     event_t *anterior = NULL;

//     while (actual){
//         event_t *proximo = actual->next;
//         if (!meetsRequirements(backpack, actual->destination)){
            
//             if (anterior == NULL){
//                 itinerary->first = actual->next;
//             } else{
//                 anterior->next = actual->next;
//             }
//             free_event2(actual);
//         } else {
//             anterior = actual;
//         }
        
//         actual = proximo;
//     }
    
// }

void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack) {
    
    // "indirecto" apunta a la flecha que apunta al nodo actual
    event_t **indirecto = &itinerary->first;

    while (*indirecto != NULL) {
        
        event_t *actual = *indirecto; // Desreferenciamos para ver el nodo

        if (!meetsRequirements(backpack, actual->destination)) {
            // Lo salteamos directamente cambiando a dónde apunta la flecha original
            *indirecto = actual->next; 
            free_event2(actual);
        } else {
            // Si no lo borramos, avanzamos nuestra flecha al "next" del nodo actual
            indirecto = &actual->next;
        }
    }
}


// Funcion Auxiliar
bool meetsRequirements(backpack_t *backpack, destination_t *dest) {

    for (size_t i = 0; i < dest->requirements_size; i++){
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


















// void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack) {

//     event_t *actual = itinerary->first;
//     event_t *prev =  NULL;

//     while (actual != NULL){

//         event_t *proximo = actual->next;

//         if (!meetsRequirements(backpack, actual->destination)){
            
//             if (prev == NULL){
//                 itinerary->first = proximo;
//             } else{
//                 prev->next = proximo;
//             }
            
//             free_event(actual);
            
//         } else{
//             prev = actual;
//         }
        
//         actual = proximo;
        
//     }
// }


// bool meetsRequirements(backpack_t *backpack, destination_t *dest) {
    
//     for (uint32_t i = 0; i < dest->requirements_size; i++){
        
//         if (!backpackContainsItem(backpack, dest->requirements[i])){
//             return false;
//         }    
//     }
//     return true;    
// }


// // void free_destination(destination_t *destination) {
// //   free(destination->requirements);
// //   free(destination);
// // }

// // void free_event(event_t *event) {
// //   free_destination(event->destination);
// //   free(event);
// // }




// void free_event(event_t *event) {
//   free(event->destination->requirements);
//   free(event->destination);
//   free(event);
// }