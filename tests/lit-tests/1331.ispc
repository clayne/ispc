// RUN: not %{ispc} --target=host --nowrap --nostdlib %s -o - 2>&1 | FileCheck %s

// CHECK: Unable to find any matching overload for call to function "func".

enum Enum111{
    One,
    Two
};

void func(void* x) {
    return;
}

void func1(Enum111 Foo1111) {
    func(Foo1111);
}
