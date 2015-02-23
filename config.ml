open Mirage

let main =
  foreign "Unikernel.Main" (console @-> network @-> entropy @-> kv_ro @-> job)

let secrets_dir = "demo_keys"

let platform =
  match get_mode () with
  | `Xen -> "xen"
  | _ -> "unix"

let disk =
  match get_mode () with
  | `Xen  -> crunch secrets_dir
  | _ -> direct_kv_ro secrets_dir

let () =
  add_to_ocamlfind_libraries [
    "cstruct"; "cstruct.syntax"; "re"; "re.str"; "tcpip.ethif"; "tcpip.tcp";
    "tcpip.udp"; "tcpip.stack-direct"; "mirage-clock-" ^ platform;
    "mirage-nat"; "tcpip.channel";
  ];
  add_to_opam_packages [
    "cstruct"; "tcpip"; "re"; "mirage-clock-" ^ platform; "mirage-nat";
    "mirage-net-xen.1.2.0"; "io-page.1.2.0";
  ];
  register "unikernel" [
    main $ default_console $ tap0 $ default_entropy $ disk
  ]
