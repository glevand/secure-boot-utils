#include <stdio.h>
#include <stdint.h>

static void _hex_dmp(const char *func, int line, const char *msg,
	const void *data, unsigned int data_len)
{
	unsigned int i;

	printf("%s:%d: %s (%u bytes)", func, line, msg, data_len);

	for (i = 0; i < data_len; i++) {
		printf("%02x", ((uint8_t *)data)[i]);
	}

	printf("\n");
}

#define hex_dmp(_msg, _data, _data_len) do {_hex_dmp(__func__, __LINE__, _msg, _data, _data_len);} while(0)

int main(void)
{
	uint8_t rotpk_data[] = "12345678901234567890123456789012";

	hex_dmp("rotpk:    ", rotpk_data, sizeof(rotpk_data) - 1);

	return 0;
}
