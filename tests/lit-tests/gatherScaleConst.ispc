// This test ensures that the macro to convert scale to constant for gather has been inlined and
// optimised as expected and no extra gather calls or switch statement is remaining after the optimisation.

// RUN: %{ispc} %s --target=avx2-i64x4 --emit-llvm-text -o - 2>&1 | FileCheck %s -check-prefix=CHECK_AVX2_I64X4 --implicit-check-not "switch"
// RUN: %{ispc} %s --target=avx2-i32x8 --emit-llvm-text -o - 2>&1 | FileCheck %s -check-prefix=CHECK_AVX2_I32X8 --implicit-check-not "switch"
// RUN: %{ispc} %s --target=avx2-i32x16 --emit-llvm-text -o - 2>&1 | FileCheck %s -check-prefix=CHECK_AVX2_I32X16 --implicit-check-not "switch"
// RUN: %{ispc} %s --target=avx512skx-x16 --emit-llvm-text -o - 2>&1 | FileCheck %s -check-prefix=CHECK_AVX512SKX_X16 --implicit-check-not "switch"

// REQUIRES: X86_ENABLED

//; CHECK_AVX2_I64X4: llvm.x86.avx2.gather.d.ps

//; CHECK_AVX2_I32X8: llvm.x86.avx2.gather.d.ps.256

//; CHECK_AVX2_I32X16: llvm.x86.avx2.gather.d.ps.256

//; CHECK_AVX512SKX_X16: llvm.x86.avx512.mask.gather.dps.512
struct Foo {
    uniform float x[programCount + 1];
};
void f_fu(uniform float RET[], uniform float aFOO[]) {
    float a = aFOO[programIndex];
    uniform Foo foo;
    uniform int i;
    for (i = 0; i < programCount + 1; ++i)
        foo.x[i] = i;

//; CHECK_AVX2_I64X4: llvm.x86.avx2.gather.d.ps
//; CHECK_AVX2_I64X4: llvm.x86.avx2.gather.d.ps
//; CHECK_AVX2_I64X4-NOT: llvm.x86.avx2.gather.d.ps

//; CHECK_AVX2_I32X8: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X8: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X8-NOT: llvm.x86.avx2.gather.d.ps.256

//; CHECK_AVX2_I32X16: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X16: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X16: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X16: llvm.x86.avx2.gather.d.ps.256
//; CHECK_AVX2_I32X16-NOT: llvm.x86.avx2.gather.d.ps.256

//; CHECK_AVX512SKX_X16: llvm.x86.avx512.mask.gather.dps.512
//; CHECK_AVX512SKX_X16-NOT: llvm.x86.avx512.mask.gather.dps.512
    if ((int)a & 1) {
#pragma ignore warning(perf)
        RET[programIndex] = foo.x[a - 1];
        return;
    }
}
