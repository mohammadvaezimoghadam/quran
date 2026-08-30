#include "qrcode.h"
#include <string.h>
#include <stdlib.h>

static const uint16_t NUM_ERROR_CORRECTION_CODEWORDS[4][40] = {
    { 7, 10, 15, 20, 26 },
    { 10, 16, 26, 36, 48 },
    { 13, 22, 36, 52, 72 },
    { 17, 28, 44, 64, 88 }
};

static const uint8_t NUM_RAW_DATA_MODULES[5] = { 208, 359, 567, 807, 1079 };

uint16_t qrcode_getBufferSize(uint8_t version) {
    return ((version * 4 + 17) * (version * 4 + 17) + 7) / 8;
}

static void setModule(QRCode *qrcode, uint8_t x, uint8_t y, bool on) {
    uint16_t offset = y * qrcode->size + x;
    if (on) {
        qrcode->modules[offset >> 3] |= (1 << (offset & 7));
    } else {
        qrcode->modules[offset >> 3] &= ~(1 << (offset & 7));
    }
}

bool qrcode_getModule(QRCode *qrcode, uint8_t x, uint8_t y) {
    if (x >= qrcode->size || y >= qrcode->size) return false;
    uint16_t offset = y * qrcode->size + x;
    return (qrcode->modules[offset >> 3] & (1 << (offset & 7))) != 0;
}

static void drawFinderPattern(QRCode *qrcode, int x, int y) {
    for (int dy = -3; dy <= 3; dy++) {
        for (int dx = -3; dx <= 3; dx++) {
            int dist = abs(dx) > abs(dy) ? abs(dx) : abs(dy);
            int px = x + dx;
            int py = y + dy;
            if (px >= 0 && px < qrcode->size && py >= 0 && py < qrcode->size) {
                setModule(qrcode, px, py, dist != 2);
            }
        }
    }
}

int8_t qrcode_initText(QRCode *qrcode, uint8_t *modules, uint8_t version, uint8_t ecc, const char *text) {
    if (version < 1 || version > 5) version = 3;
    qrcode->version = version;
    qrcode->size = version * 4 + 17;
    qrcode->ecc = ecc;
    qrcode->modules = modules;

    memset(modules, 0, qrcode_getBufferSize(version));

    // Draw finder patterns
    drawFinderPattern(qrcode, 3, 3);
    drawFinderPattern(qrcode, qrcode->size - 4, 3);
    drawFinderPattern(qrcode, 3, qrcode->size - 4);

    // Draw timing patterns
    for (int i = 0; i < qrcode->size; i++) {
        setModule(qrcode, 6, i, i % 2 == 0);
        setModule(qrcode, i, 6, i % 2 == 0);
    }

    // Simple text data layout simulation for embedded QR rendering
    int len = strlen(text);
    int idx = 0;
    for (int y = 8; y < qrcode->size - 8; y++) {
        for (int x = 8; x < qrcode->size - 8; x++) {
            if (x == 6 || y == 6) continue;
            bool bit = ((text[idx % len] + x + y) % 3 == 0);
            setModule(qrcode, x, y, bit);
            idx++;
        }
    }

    return 0;
}
