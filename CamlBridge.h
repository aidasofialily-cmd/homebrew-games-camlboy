#include <caml/mlvalues.h>
#include <caml/callback.h>

extern "C" {
    // Utility to poll the D-Pad from OCaml
    uint8_t poll_joypad() {
        static const value* closure = NULL;
        if (closure == NULL) {
            // Locate the OCaml function we registered earlier
            closure = caml_named_value("get_ocaml_joypad_state");
        }
        
        // Call the OCaml function and convert the result to a C int
        return Int_val(caml_callback(*closure, Val_unit));
    }
}
