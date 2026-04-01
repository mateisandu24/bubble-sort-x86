# Advanced Bubble Sort in Assembly (x86 - MASM/TASM)

This repository contains an advanced implementation of the **Bubble Sort** algorithm written in **x86 Assembly Language** (MASM/TASM syntax). It was developed as part of a project for the **Information Technology Basics (BTI)** course, taken in the **1st year, 1st semester** of the **Economic Informatics** specialization, Faculty of Cybernetics, Statistics and Economic Informatics (CSIE).

##  About the Project

Unlike basic Assembly implementations, this program handles real-world data constraints by converting user-inputted strings into mathematical values and vice versa. It allows the user to:
1. Enter the size of an array (anywhere between **2 and 16,000** elements).
2. Enter multi-digit, **signed 16-bit integers** (handling negative and positive numbers from **-32,768 to +32,767**).
3. View the correctly sorted result using an optimized Bubble Sort algorithm.

##  Features

- **Custom String-to-Integer Conversion:** Parses buffered ASCII input (`INT 21h, AH=0Ah`) into signed 16-bit registers, correctly handling the `-` and `+` characters.
- **Custom Integer-to-String Conversion:** Uses successive division and the stack to convert sorted values back into ASCII strings for console output.
- **Optimized Bubble Sort:** Implements an early-exit flag (`di`) that stops the sorting process immediately if a full pass occurs with zero swaps, saving CPU cycles.
- **Clean Code Architecture:** Written with a strict indentation hierarchy (Level 0 for definitions, Level 1 for main flow, Level 2 for loops) to make the low-level logic highly readable.
- **Robust Validation:** Prevents out-of-bounds array sizes and gracefully re-prompts the user.

##  Technologies Used

- **Language:** Assembly Language (MASM/TASM compatible)
- **Architecture:** x86 (16-bit real mode DOS)
- **Environments:** DOSBox, EMU8086, or VS Code with MASM/TASM extensions

##  How to Run

1. Use an x86-compatible emulator (like DOSBox) or a VS Code extension.
2. Assemble and link the code using TASM or MASM.

```bash
tasm bubblesort.asm
tlink bubblesort.obj
bubblesort.exe
