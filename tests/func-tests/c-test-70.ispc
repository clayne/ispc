#include "test_static.isph"
task void f_fu(uniform float RET[], uniform float aFOO[], uniform float b) {
    float a = aFOO[programIndex];
    float i, j;
    if (a >= 4)
        a = 0;
    else {
        for (i = 0; i < b; ++i) {
            if (a == b) 
                a += 10;
            ++a;
            if (a == 2) break;
        }
    }
    RET[programIndex] = a;
}

task void result(uniform float RET[]) {
    RET[programIndex] = 0;
    RET[0] = 2;
    RET[1] = 17;
    RET[2] = 18;
}
