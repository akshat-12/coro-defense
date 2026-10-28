#include <stdio.h>
#include <string.h>
#include <stdint.h>
// Declare the runtime API
void __coro_shadow_register(void *frame);
void __coro_shadow_verify_resume(void *frame);
void __coro_shadow_verify_and_remove_destroy(void *frame);

// Minimal fake frame: { void(*resume)(void*), void(*destroy)(void*), uint32_t typeid }
static void fake_resume(void *f)  { (void)f; puts("resume OK"); }
static void fake_destroy(void *f) { (void)f; puts("destroy OK"); }

static struct {
    void (*resume_fn)(void*);
    void (*destroy_fn)(void*);
    uint32_t type_id;
    uint32_t _pad;
    char rest[48];
} frame = { fake_resume, fake_destroy, 42, 0, {0} };

int main(void) {
    puts("=== Registering frame ===");
    __coro_shadow_register(&frame);

    puts("=== Verify resume (should pass) ===");
    __coro_shadow_verify_resume(&frame);

    puts("=== Verify and remove destroy (should pass) ===");
    __coro_shadow_verify_and_remove_destroy(&frame);

    puts("=== ALL PASS ===");
    return 0;
}
