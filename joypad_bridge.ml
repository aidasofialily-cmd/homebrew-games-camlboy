(* This function returns the current state of the Joypad as an integer *)
let get_joypad_state joypad =
  (* Assuming joypad.state returns an 8-bit integer *)
  Joypad.get_state joypad 

let () =
  (* Registering the function so C++ can "find" it by string name *)
  Callback.register "get_ocaml_joypad_state" get_joypad_state
