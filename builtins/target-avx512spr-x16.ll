;;  Copyright (c) 2016-2024, Intel Corporation
;;
;;  SPDX-License-Identifier: BSD-3-Clause

define(`WIDTH',`16')
define(`ISA',`AVX512SKX')

include(`target-avx512-common-16.ll')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shuffles

declare <16 x i8> @llvm.x86.avx512.mask.permvar.qi.128(<16 x i8>, <16 x i8>, <16 x i8>, i16)
define <16 x i8> @__shuffle_i8(<16 x i8>, <16 x i32>) nounwind readnone alwaysinline {
  %ind = trunc <WIDTH x i32> %1 to <WIDTH x i8>
  %res = call <16 x i8> @llvm.x86.avx512.mask.permvar.qi.128(<16 x i8> %0, <16 x i8> %ind, <16 x i8> zeroinitializer, i16 -1)
  ret <16 x i8> %res
}

declare <WIDTH x i8> @llvm.x86.avx512.vpermi2var.qi.128(<WIDTH x i8>, <WIDTH x i8>, <WIDTH x i8>)
define <WIDTH x i8> @__shuffle2_i8(<WIDTH x i8>, <WIDTH x i8>, <WIDTH x i32>) nounwind readnone alwaysinline {
  %isc = call i1 @__is_compile_time_constant_varying_int32(<WIDTH x i32> %2)
  br i1 %isc, label %is_const, label %not_const

is_const:
  %res_const = tail call <WIDTH x i8> @__shuffle2_const_i8(<WIDTH x i8> %0, <WIDTH x i8> %1, <WIDTH x i32> %2)
  ret <WIDTH x i8> %res_const

not_const:
  %ind = trunc <WIDTH x i32> %2 to <WIDTH x i8>
  %res = call <WIDTH x i8> @llvm.x86.avx512.vpermi2var.qi.128(<WIDTH x i8> %0, <WIDTH x i8> %ind, <WIDTH x i8> %1)
  ret <WIDTH x i8> %res
}

declare <WIDTH x i16> @llvm.x86.avx512.mask.permvar.hi.256(<WIDTH x i16>, <WIDTH x i16>, <WIDTH x i16>, i16)
define <WIDTH x i16> @__shuffle_i16(<WIDTH x i16>, <WIDTH x i32>) nounwind readnone alwaysinline {
  %ind = trunc <WIDTH x i32> %1 to <WIDTH x i16>
  %res = call <WIDTH x i16> @llvm.x86.avx512.mask.permvar.hi.256(<WIDTH x i16> %0, <WIDTH x i16> %ind, <WIDTH x i16> zeroinitializer, i16 -1)
  ret <WIDTH x i16> %res
}

declare <WIDTH x i16> @llvm.x86.avx512.vpermi2var.hi.256(<WIDTH x i16>, <WIDTH x i16>, <WIDTH x i16>)
define <WIDTH x i16> @__shuffle2_i16(<WIDTH x i16>, <WIDTH x i16>, <WIDTH x i32>) nounwind readnone alwaysinline {
  %isc = call i1 @__is_compile_time_constant_varying_int32(<WIDTH x i32> %2)
  br i1 %isc, label %is_const, label %not_const

is_const:
  %res_const = tail call <WIDTH x i16> @__shuffle2_const_i16(<WIDTH x i16> %0, <WIDTH x i16> %1, <WIDTH x i32> %2)
  ret <WIDTH x i16> %res_const

not_const:
  %ind = trunc <WIDTH x i32> %2 to <WIDTH x i16>
  %res = call <WIDTH x i16> @llvm.x86.avx512.vpermi2var.hi.256(<WIDTH x i16> %0, <WIDTH x i16> %ind, <WIDTH x i16> %1)
  ret <WIDTH x i16> %res
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; svml

include(`svml.m4')
svml(ISA)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rcp, rsqrt

rcp14_uniform()
;; rcp float
declare <16 x float> @llvm.x86.avx512.rcp14.ps.512(<16 x float>, <16 x float>, i16) nounwind readnone
define <16 x float> @__rcp_fast_varying_float(<16 x float>) nounwind readonly alwaysinline {
  %ret = call <16 x float> @llvm.x86.avx512.rcp14.ps.512(<16 x float> %0, <16 x float> undef, i16 -1)
  ret <16 x float> %ret
}
define <16 x float> @__rcp_varying_float(<16 x float>) nounwind readonly alwaysinline {
  %call = call <16 x float> @__rcp_fast_varying_float(<16 x float> %0)
  ;; do one Newton-Raphson iteration to improve precision
  ;;  float iv = __rcp_v(v);
  ;;  return iv * (2. - v * iv);
  %v_iv = fmul <16 x float> %0, %call
  %two_minus = fsub <16 x float> <float 2., float 2., float 2., float 2.,
                                  float 2., float 2., float 2., float 2.,
                                  float 2., float 2., float 2., float 2.,
                                  float 2., float 2., float 2., float 2.>, %v_iv
  %iv_mul = fmul <16 x float> %call,  %two_minus
  ret <16 x float> %iv_mul
}

;; rcp double
declare <8 x double> @llvm.x86.avx512.rcp14.pd.512(<8 x double>, <8 x double>, i8) nounwind readnone
define <16 x double> @__rcp_fast_varying_double(<16 x double> %val) nounwind readonly alwaysinline {
  %val_lo = shufflevector <16 x double> %val, <16 x double> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %val_hi = shufflevector <16 x double> %val, <16 x double> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %res_lo = call <8 x double> @llvm.x86.avx512.rcp14.pd.512(<8 x double> %val_lo, <8 x double> undef, i8 -1)
  %res_hi = call <8 x double> @llvm.x86.avx512.rcp14.pd.512(<8 x double> %val_hi, <8 x double> undef, i8 -1)
  %res = shufflevector <8 x double> %res_lo, <8 x double> %res_hi, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x double> %res
}
define <16 x double> @__rcp_varying_double(<16 x double>) nounwind readonly alwaysinline {
  %call = call <16 x double> @__rcp_fast_varying_double(<16 x double> %0)
  ;; do one Newton-Raphson iteration to improve precision
  ;;  double iv = __rcp_v(v);
  ;;  return iv * (2. - v * iv);
  %v_iv = fmul <16 x double> %0, %call
  %two_minus = fsub <16 x double> <double 2., double 2., double 2., double 2.,
                                   double 2., double 2., double 2., double 2.,
                                   double 2., double 2., double 2., double 2.,
                                   double 2., double 2., double 2., double 2.>, %v_iv
  %iv_mul = fmul <16 x double> %call,  %two_minus
  ret <16 x double> %iv_mul
}

rsqrt14_uniform()
;; rsqrt float
declare <16 x float> @llvm.x86.avx512.rsqrt14.ps.512(<16 x float>,  <16 x float>,  i16) nounwind readnone
define <16 x float> @__rsqrt_fast_varying_float(<16 x float> %v) nounwind readonly alwaysinline {
  %ret = call <16 x float> @llvm.x86.avx512.rsqrt14.ps.512(<16 x float> %v,  <16 x float> undef,  i16 -1)
  ret <16 x float> %ret
}
define <16 x float> @__rsqrt_varying_float(<16 x float> %v) nounwind readonly alwaysinline {
  %is = call <16 x float> @__rsqrt_fast_varying_float(<16 x float> %v)
  ; Newton-Raphson iteration to improve precision
  ;  float is = __rsqrt_v(v);
  ;  return 0.5 * is * (3. - (v * is) * is);
  %v_is = fmul <16 x float> %v,  %is
  %v_is_is = fmul <16 x float> %v_is,  %is
  %three_sub = fsub <16 x float> <float 3., float 3., float 3., float 3.,
                                  float 3., float 3., float 3., float 3.,
                                  float 3., float 3., float 3., float 3.,
                                  float 3., float 3., float 3., float 3.>, %v_is_is
  %is_mul = fmul <16 x float> %is,  %three_sub
  %half_scale = fmul <16 x float> <float 0.5, float 0.5, float 0.5, float 0.5,
                                   float 0.5, float 0.5, float 0.5, float 0.5,
                                   float 0.5, float 0.5, float 0.5, float 0.5,
                                   float 0.5, float 0.5, float 0.5, float 0.5>, %is_mul
  ret <16 x float> %half_scale
}

;; rsqrt double
declare <8 x double> @llvm.x86.avx512.rsqrt14.pd.512(<8 x double>,  <8 x double>,  i8) nounwind readnone
define <16 x double> @__rsqrt_fast_varying_double(<16 x double> %val) nounwind readonly alwaysinline {
  %val_lo = shufflevector <16 x double> %val, <16 x double> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %val_hi = shufflevector <16 x double> %val, <16 x double> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %res_lo = call <8 x double> @llvm.x86.avx512.rsqrt14.pd.512(<8 x double> %val_lo, <8 x double> undef, i8 -1)
  %res_hi = call <8 x double> @llvm.x86.avx512.rsqrt14.pd.512(<8 x double> %val_hi, <8 x double> undef, i8 -1)
  %res = shufflevector <8 x double> %res_lo, <8 x double> %res_hi, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x double> %res
}
declare <8 x i1> @llvm.x86.avx512.fpclass.pd.512(<8 x double>, i32)
define <16 x double> @__rsqrt_varying_double(<16 x double> %v) nounwind readonly alwaysinline {
  ; detect +/-0 and +inf to deal with them differently.
  %val_lo = shufflevector <16 x double> %v, <16 x double> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %val_hi = shufflevector <16 x double> %v, <16 x double> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %corner_cases_lo = call <8 x i1> @llvm.x86.avx512.fpclass.pd.512(<8 x double> %val_lo, i32 14)
  %corner_cases_hi = call <8 x i1> @llvm.x86.avx512.fpclass.pd.512(<8 x double> %val_hi, i32 14)
  %corner_cases = shufflevector <8 x i1> %corner_cases_lo, <8 x i1> %corner_cases_hi, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %is = call <16 x double> @__rsqrt_fast_varying_double(<16 x double> %v)

  ; Precision refinement sequence based on minimax approximation.
  ; This sequence is a little slower than Newton-Raphson, but has much better precision
  ; Relative error is around 3 ULPs.
  ; t1 = 1.0 - (v * is) * is
  ; t2 = 0.37500000407453632 + t1 * 0.31250000550062401
  ; t3 = 0.5 + t1 * t2
  ; t4 = is + (t1*is) * t3
  %v_is = fmul <16 x double> %v,  %is
  %v_is_is = fmul <16 x double> %v_is,  %is
  %t1 = fsub <16 x double> <double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1., double 1.>, %v_is_is
  %t1_03125 = fmul <16 x double> <double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401, double 0.31250000550062401>, %t1
  %t2 = fadd <16 x double> <double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632, double 0.37500000407453632>, %t1_03125
  %t1_t2 = fmul <16 x double> %t1, %t2
  %t3 = fadd <16 x double> <double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5, double 0.5>, %t1_t2
  %t1_is = fmul <16 x double> %t1, %is
  %t1_is_t3 = fmul <16 x double> %t1_is, %t3
  %t4 = fadd <16 x double> %is, %t1_is_t3
  %ret = select <16 x i1> %corner_cases, <16 x double> %is, <16 x double> %t4
  ret <16 x double> %ret
}

;;saturation_arithmetic_novec()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; half precision rcp and rsqrt using native SPR instriuctions
;; they will be invoked only when hardware support is available.

declare <8 x half> @llvm.x86.avx512fp16.mask.rcp.sh(<8 x half>, <8 x half>, <8 x half>, i8)
define half @__rcp_uniform_half(half) nounwind readonly alwaysinline {
  %vec = insertelement <8 x half> undef, half %0, i32 0
  %rcp = tail call <8 x half> @llvm.x86.avx512fp16.mask.rcp.sh(<8 x half> %vec, <8 x half> %vec, <8 x half> undef, i8 -1)
  %ret = extractelement <8 x half> %rcp, i32 0
  ret half %ret
}

declare <16 x half> @llvm.x86.avx512fp16.mask.rcp.ph.256(<16 x half>, <16 x half>, i16)
define <16 x half> @__rcp_varying_half(<16 x half>) nounwind readonly alwaysinline {
  %ret = tail call <16 x half> @llvm.x86.avx512fp16.mask.rcp.ph.256(<16 x half> %0, <16 x half> undef, i16 -1)
  ret <16 x half> %ret
}

declare <8 x half> @llvm.x86.avx512fp16.mask.rsqrt.sh(<8 x half>, <8 x half>, <8 x half>, i8)
define half @__rsqrt_uniform_half(half) nounwind readnone alwaysinline {
  %vec = insertelement <8 x half> undef, half %0, i32 0
  %rsqrt = tail call <8 x half> @llvm.x86.avx512fp16.mask.rsqrt.sh(<8 x half> %vec, <8 x half> %vec, <8 x half> undef, i8 -1)
  %ret = extractelement <8 x half> %rsqrt, i32 0
  ret half %ret
}

declare <16 x half> @llvm.x86.avx512fp16.mask.rsqrt.ph.256(<16 x half>, <16 x half>, i16)
define <16 x half> @__rsqrt_varying_half(<16 x half>) nounwind readnone alwaysinline {
  %ret = tail call <16 x half> @llvm.x86.avx512fp16.mask.rsqrt.ph.256(<16 x half> %0, <16 x half> undef, i16 -1)
  ret <16 x half> %ret
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dot product
declare <16 x i32> @llvm.x86.avx512.vpdpbusd.512(<16 x i32>, <16 x i32>, <16 x i32>) nounwind readnone
define <16 x i32> @__dot4add_u8i8packed(<16 x i32> %a, <16 x i32> %b, <16 x i32> %acc) nounwind readnone alwaysinline {
  %ret = call <16 x i32> @llvm.x86.avx512.vpdpbusd.512(<16 x i32> %acc, <16 x i32> %a, <16 x i32> %b)
  ret <16 x i32> %ret
}
declare <16 x i32> @llvm.x86.avx512.vpdpbusds.512(<16 x i32>, <16 x i32>, <16 x i32>) nounwind readnone
define <16 x i32> @__dot4add_u8i8packed_sat(<16 x i32> %a, <16 x i32> %b, <16 x i32> %acc) nounwind readnone alwaysinline {
  %ret = call <16 x i32> @llvm.x86.avx512.vpdpbusds.512(<16 x i32> %acc, <16 x i32> %a, <16 x i32> %b)
  ret <16 x i32> %ret
}

declare <16 x i32> @llvm.x86.avx512.vpdpwssd.512(<16 x i32>, <16 x i32>, <16 x i32>) nounwind readnone
define <16 x i32> @__dot2add_i16packed(<16 x i32> %a, <16 x i32> %b, <16 x i32> %acc) nounwind readnone alwaysinline {
  %ret = call <16 x i32> @llvm.x86.avx512.vpdpwssd.512(<16 x i32> %acc, <16 x i32> %a, <16 x i32> %b)
  ret <16 x i32> %ret
}
declare <16 x i32> @llvm.x86.avx512.vpdpwssds.512(<16 x i32>, <16 x i32>, <16 x i32>) nounwind readnone
define <16 x i32> @__dot2add_i16packed_sat(<16 x i32> %a, <16 x i32> %b, <16 x i32> %acc) nounwind readnone alwaysinline {
  %ret = call <16 x i32> @llvm.x86.avx512.vpdpwssds.512(<16 x i32> %acc, <16 x i32> %a, <16 x i32> %b)
  ret <16 x i32> %ret
}
