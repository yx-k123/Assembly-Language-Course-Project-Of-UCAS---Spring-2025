#include <stdio.h>

typedef struct {
    int a;
    float b;
    double c;
    int d;
    float e;
    double f;
    int g;
    float h;
    double i;
    int j;
} ComplexStruct;

ComplexStruct processStruct(ComplexStruct s) {
    s.a += 1;
    s.b += 1.0f;
    s.c += 1.0;
    s.d += 1;
    s.e += 1.0f;
    s.f += 1.0;
    s.g += 1;
    s.h += 1.0f;
    s.i += 1.0;
    s.j += 1;
    return s;
}

int main() {
    ComplexStruct cs = {
        .a = 1, .b = 1.0f, .c = 1.0,
        .d = 2, .e = 2.0f, .f = 2.0,
        .g = 3, .h = 3.0f, .i = 3.0,
        .j = 4
    };
    ComplexStruct result = processStruct(cs);
    return 0;
}