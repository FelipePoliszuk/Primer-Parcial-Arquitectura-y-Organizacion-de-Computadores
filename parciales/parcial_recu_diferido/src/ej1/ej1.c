#include "../ejs.h"
#include "../ejs_aux.h"

bool canItemFitInBackpack(backpack_t *backpack, item_t *item) {

    uint8_t pesoMochila = 0;

    for (uint32_t i = 0; i < backpack->item_count; i++){
        pesoMochila += backpack->items[i].weight;
    }

    if (pesoMochila + item->weight <= backpack->max_weight){
        return true;
    }
    
    return false;
}