#include "test_static.isph"
// rule: skip on cpu=tgllp
// rule: skip on cpu=dg2
// rule: skip on target=generic.*
// rule: run on OS=!windows
task void f_f(uniform float RET[], uniform float aFOO[]) {
    double a = aFOO[programIndex]; 
    RET[programIndex] = round(a+.49999); 
}

task void result(uniform float RET[]) {
    RET[programIndex] = 1 + (double) programIndex;
}
