// Copyright (c) 2025, Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause

export uniform int width() { return programCount; }

// Macro for rotate functions with different data types
#define ROTATE_FUNC(TYPE)                                                                                              \
    export void rotate_##TYPE(uniform TYPE *uniform input, uniform TYPE *uniform output, uniform int n,                \
                              uniform int offset) {                                                                    \
        foreach (i = 0 ... n) {                                                                                        \
            TYPE value = input[i];                                                                                     \
            TYPE rotated = rotate(value, offset);                                                                      \
            output[i] = rotated;                                                                                       \
        }                                                                                                              \
    }

// Macro for const rotate functions with different data types
#define ROTATE_CONST_FUNC(TYPE)                                                                                        \
    export void rotate_const_##TYPE(uniform TYPE *uniform input, uniform TYPE *uniform output, uniform int n) {        \
        foreach (i = 0 ... n) {                                                                                        \
            TYPE value = input[i];                                                                                     \
            TYPE rotated = rotate(value, -1);                                                                          \
            output[i] = rotated;                                                                                       \
        }                                                                                                              \
    }

// Test rotating different data types
#ifdef HAS_FP16
ROTATE_FUNC(float16)
ROTATE_CONST_FUNC(float16)
#endif

ROTATE_FUNC(float)
ROTATE_CONST_FUNC(float)
ROTATE_FUNC(double)
ROTATE_CONST_FUNC(double)
ROTATE_FUNC(int8)
ROTATE_CONST_FUNC(int8)
ROTATE_FUNC(int16)
ROTATE_CONST_FUNC(int16)
ROTATE_FUNC(int32)
ROTATE_CONST_FUNC(int32)
ROTATE_FUNC(int64)
ROTATE_CONST_FUNC(int64)
