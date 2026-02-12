open Alcotest
open Camlboy_lib

let test_timing_rom () =
  let cpu = CPU.create () in
  let bus = Bus.create ~rom:"roms/games/test_cpu_timing.gb" in
  
  (* Run for a fixed number of cycles *)
  for i = 0 to 100000 do
    CPU.step cpu bus
  done;

  (* Check the Serial Output register for the 'P' (Pass) character *)
  let result = Bus.read_byte bus 0xFF01 in
  check int "CPU Timing Pass" (int_of_char 'P') result

let () =
  run "Emulator Tests" [
    "ROM-Tests", [test_case "Instruction Timing" `Quick test_timing_rom]
  ]
