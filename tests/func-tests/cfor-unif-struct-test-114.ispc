#include "test_static.isph"
struct Foo {
    uniform float x;
    uniform float f;
};
task void f_fi(uniform float RET[], uniform float a[], uniform int bFOO[]) {
    int b = bFOO[programIndex];
    uniform struct Foo myFoo[programCount+1];
    uniform int i;
    #pragma ignore warning
    cfor (i = 0; i < programCount+1; ++i) {
        myFoo[i].x = i;
        myFoo[i].f = 2*i;
    }
    #pragma ignore warning(perf)
    RET[programIndex] = myFoo[b/2].f;
}


task void result(uniform float RET[]) {
    RET[programIndex] = 2 + 2 * programIndex;
}
