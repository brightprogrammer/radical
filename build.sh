#!/bin/zsh
echo "building -- bootloader.asm ..."
nasm -f bin bootloader.asm -o bootloader.bin
echo "building -- bootloader.asm ... done"