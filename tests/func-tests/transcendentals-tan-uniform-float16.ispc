#include "test_static.isph"
// rule: skip on arch=x86
// rule: skip on arch=x86-64

uniform bool ok(uniform float16 x, uniform float16 ref) { return (abs(x - ref) < 1e-4) || abs((x-ref)/ref) < 1e-3; }
task void f_fu(uniform float RET[], uniform float aFOO[], uniform float b) {
  for (uniform int i = 0; i != programCount; ++i) {
    uniform float16 arg = aFOO[i] + b;
    uniform float16 ref = tan((float)arg);
    uniform float16 res = tan(arg);
    RET[i] = ok(res, ref) ? 0. : 1.;
  }
}

task void result(uniform float RET[]) {
    RET[programIndex] = 0.0;
}
