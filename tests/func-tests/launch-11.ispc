#include "test_static.isph"
// rule: skip on arch=xe64

typedef task void (*TaskFn)(uniform int i, float i);

static uniform float array[10000];
task void x(uniform int i, float f) {
    uniform int j;
    array[i] = i / 10000.;
    for (j = 0; j < 10000; ++j)
        array[i] = sin(array[i]);
    if (array[i] < .02)
        array[i] = i;
}
task void f_f(uniform float RET[], uniform float fFOO[]) {
    float f = fFOO[programIndex];
    uniform int i;
    uniform TaskFn func = x;
    for (i = 0; i < 10000; ++i)
        launch func(i, f);
    sync;
    RET[programIndex] = array[9999];
}


task void result(uniform float RET[]) {
    RET[programIndex] = 9999.000000;
}
