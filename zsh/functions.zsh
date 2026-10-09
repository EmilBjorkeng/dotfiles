rasm() {
    local name=${1%.asm}
    local exe=$name
    [[ $exe == */* ]] || exe="./$exe"
    [[ -f "$name.asm" ]] || { print -u2 "rasm: $name.asm not found"; return 1; }
    nasm -f elf64 -o "$name.o" "$name.asm" &&
        ld -o "$name" "$name.o" &&
        rm -f "$name.o" &&
        "$exe" "${@:2}"
}

dasm() {
    local name=${1%.asm}
    [[ -f "$name.asm" ]] || { print -u2 "dasm: $name.asm not found"; return 1; }
    local tmp ret
    tmp=$(mktemp -d) || return 1
    nasm -f elf64 -g -F dwarf -o "$tmp/prog.o" "$name.asm" &&
        ld -o "$tmp/prog" "$tmp/prog.o" &&
        gdb --silent --args "$tmp/prog" "${@:2}"
    ret=$?
    rm -rf "$tmp"
    return $ret
}
