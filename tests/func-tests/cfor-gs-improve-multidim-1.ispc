#include "test_static.isph"
task void f_fu(uniform float RET[], uniform float aFOO[], uniform float b) {
    float a = aFOO[programIndex]; 
    uniform float udx[programCount+1][programCount+1];
    #pragma ignore warning
    cfor (uniform int i = 0; i < programCount+1; ++i)
        #pragma ignore warning
        cfor (uniform int j = 0; j < programCount+1; ++j)
            udx[i][j] = 100*i+j;

    int x = 1;
    RET[programIndex] = udx[x][programIndex+1];
}

task void result(uniform float RET[]) {
    RET[programIndex] = 101+programIndex;
}
