#include "test_static.isph"
task void f_fu(uniform float RET[], uniform float aFOO[], uniform float b) {
    float a = aFOO[programIndex]; 
    a = -a;
    if (a > 0)
        // This shoudln't hit, given the if test above
        assert(a > 0);
    assert(b == 5.);
    RET[programIndex] = -a; 
}

task void result(uniform float RET[]) {
    RET[programIndex] = 1 + programIndex;
}
