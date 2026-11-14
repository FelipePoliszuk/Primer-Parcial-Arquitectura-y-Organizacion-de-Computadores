#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "ABI.h"

int main() {
	uint32_t result;
	double result_double;
	// TESTS

	// ALTERNATE SUM 4
	assert(alternate_sum_4_using_c(8, 2, 5, 1) == 10);

	// ALTERNATE SUM 4 USING C ALTERNATIVE
	assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 10);


	// ALTERNATE SUM 8
	assert(alternate_sum_8(1,1,1,1,1,1,1,1) == 0);
	assert(alternate_sum_8(8,8,1,1,2,1,1,2) == 0);

	// PRODUCT 2 F
	product_2_f(&result, 8, 2.0);
	assert(result == 16);  // 8 * 2.0 = 16 (truncado)

	// PRODUCT 9 F
	product_9_f(&result_double, 8, 2.0, 1, 1.0, 1, 1.0, 1, 1.0, 1, 1.0, 1, 1.0, 1, 1.0, 1, 1.0, 1, 1.0);
	assert(result_double == 16);  // 8 * 2.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 * 1 * 1.0 = 16

	return 0;
}
