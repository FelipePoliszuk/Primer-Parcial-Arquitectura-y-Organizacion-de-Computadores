#include "../ejs.h"
#include "../ejs_aux.h"

bool canItemFitInBackpack(backpack_t *backpack, item_t *item) {

    int peso = 0;

    for (uint32_t i = 0; i < backpack->item_count; i++){
        peso += backpack->items[i].weight;
    }

    if (peso + item->weight > backpack->max_weight){
        return false;
    }
    
    return true;
}