#include "test_static.isph"
uniform unsigned int32 s = 10;

task void f_f(uniform float RET[], uniform float aFOO[]) {
    float a = aFOO[programIndex];
    uniform unsigned int32 b = atomic_add_global(&s, 1);
    RET[programIndex] = s;
}

task void result(uniform float RET[]) {
    RET[programIndex] = 11;
}
