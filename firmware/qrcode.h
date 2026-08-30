/**
 * The MIT License (MIT)
 * Copyright (c) 2017 Richard Moore
 *
 * Tiny QR Code Generator for Embedded Systems (C/C++)
 */

#ifndef __QRCODE_H__
#define __QRCODE_H__

#include <stdint.h>
#include <stdbool.h>

#define ECC_LOW 0
#define ECC_MEDIUM 1
#define ECC_QUARTILE 2
#define ECC_HIGH 3

typedef struct {
    uint8_t version;
    uint8_t size;
    uint8_t ecc;
    uint8_t mode;
    uint8_t *modules;
} QRCode;

#ifdef __cplusplus
extern "C" {
#endif

uint16_t qrcode_getBufferSize(uint8_t version);
int8_t qrcode_initText(QRCode *qrcode, uint8_t *modules, uint8_t version, uint8_t ecc, const char *text);
bool qrcode_getModule(QRCode *qrcode, uint8_t x, uint8_t y);

#ifdef __cplusplus
}
#endif

#endif
