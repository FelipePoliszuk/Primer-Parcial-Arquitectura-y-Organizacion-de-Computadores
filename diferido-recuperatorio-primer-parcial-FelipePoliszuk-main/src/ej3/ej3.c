#include <stdint.h>

#include "../ejs.h"
#include "../ejs_aux.h"

backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t)) {

    backpack_t *mochila = malloc(sizeof(backpack_t));

    mochila->item_count = 0;
    mochila->max_weight = 255;
    mochila->items = malloc((sizeof(item_t))*7);

    event_t *actual = itinerary->first;

    while (actual){
        for (size_t i = 0; i < actual->destination->requirements_size; i++){
            item_kind_t item = actual->destination->requirements[i];
            
            if (!backpackContainsItem(mochila,item)){
                // mochila->items[mochila->item_count].kind = item;
                mochila->items[mochila->item_count].weight = getItemWeight(item);
                mochila->item_count ++;
            }
        }
        actual = actual->next;
    }

    return mochila;
}
