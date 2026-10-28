#include <stdio.h>
#include <string.h>
#include <stdint.h>
void __coro_shadow_register(void *f);
void __coro_shadow_verify_resume(void *f);

static void real_resume(void *f)  { (void)f; }
static void evil_fn(void *f)      { (void)f; puts("EVIL CALLED"); }

static struct {
    void (*resume_fn)(void*); void (*destroy_fn)(void*);
    uint32_t type_id; uint32_t _pad; char rest[48];
} frame = { real_resume, real_resume, 1, 0, {0} };

int main(void) {
    __coro_shadow_register(&frame);
    // Simulate the attack: overwrite resume_fn
    frame.resume_fn = evil_fn;
    puts("Calling verify_resume after tampering (should abort):");
    __coro_shadow_verify_resume(&frame);
    puts("ERROR: should not reach here");
    return 1;
}
