(* This function returns the current state of the Joypad as an integer *)
let get_joypad_state joypad =
  (* Assuming joypad.state returns an 8-bit integer *)
  Joypad.get_state joypad 

let () =
  (* Registering the function so C++ can "find" it by string name *)
  Callback.register "get_ocaml_joypad_state" get_joypad_state

  let dump_vram bus filename =
  let out = open_out_bin filename in
  for addr = 0x8000 to 0x97FF do
    output_byte out (Bus.read_byte bus addr)
  done;
  close_out out
