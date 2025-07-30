restartshell() {
    source ~/.zshrc
}

rasm() {
    nasm -f elf64 -o $1.o $1.asm && ld -o $1 $1.o && ./$1 "${@:2}"
}

dasm() {
    nasm -f elf64 -g -o debug.o $1.asm && ld -o debug debug.o &&
    gdb --silent --args debug "${@:2}" && rm debug.o && rm debug
}
