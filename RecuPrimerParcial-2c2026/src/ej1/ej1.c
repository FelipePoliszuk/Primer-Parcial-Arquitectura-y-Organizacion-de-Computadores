#include "../ejs.h"
#include "../utils.h"

bool suscribirDisciplina(
    usuario_t *usuario,
    disciplina_t *candidata,
    bool (*son_unificables)(const disciplina_t *, const disciplina_t *)
) {
    (void)usuario;
    (void)candidata;
    (void)son_unificables;
    return false;
}
