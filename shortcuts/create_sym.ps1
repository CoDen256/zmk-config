New-Item -ItemType SymbolicLink -Force -Path "~\AppData\Roaming\JetBrains\IntelliJIdea2024.2\keymaps\keymap.xml" -Target ".\shortcuts\keymap.xml"
New-Item -ItemType SymbolicLink -Force -Path "~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\layout.ahk" -Target ".\shortcuts\layout.ahk"
New-Item -ItemType SymbolicLink -Force -Path "~\.yazi\keymap.toml" -Target ".\shortcuts\keymap.toml"