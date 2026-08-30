#include "../ejs.h"
#include "../ejs_aux.h"

bool canItemFitInBackpack(backpack_t *backpack, item_t *item) {

    uint8_t pesoMochila = 0;

    for (size_t i = 0; i < backpack->item_count; i++){
        pesoMochila += backpack->items[i].weight;
    }

    if ((pesoMochila + item->weight) > backpack->max_weight){
        return false;
    }

    return true;
}












































// bool canItemFitInBackpack(backpack_t *backpack, item_t *item) {

//   uint8_t peso_acumulado = 0;

//   for (size_t i = 0; i < backpack->item_count; i++){
//     peso_acumulado += backpack->items[i].weight;
//   }

//   if ((item->weight + peso_acumulado) > backpack->max_weight){
//     return false;
//   }
  
//   return true;
// }
