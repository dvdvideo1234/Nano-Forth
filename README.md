# Nano-Forth

### Description

It's a cross-platform forth-based envirionment

### Base features
1. Compile/decompile
2. Truely minimalistic
3. Only 16 primitives

### Virtual forth mashine with minimal instructions 
```
CALL : (EVEN address): Pushes the current instruction pointer onto a return stack, then sets it to the new address.
PUSH : moves the top element from the data stack TO the return stack
POP  : moves the top element from the return stack TO the data stack
DUP  : Duplicates the top element of the data stack.
J    : Duplicates the SECOND element of the RETURN stack.
@R+  : Pushes the value stored at a memory address at R onto the stack and increments cell size R.
!R+  : Pops a value from the data stack and stores it in a memory address at R and increments cell size R.
XR   : Swaps the top elements OF the DATA AND RETUN stacks.
XA   : Swaps the top OF THE RETURN STACK AND REGISTER A.
;    : Pops an address from the return stack and sets the instruction pointer to that address.
if   : (address): JUMP IF FALSE(address): Pops a value from the DATA stack. JUMP If ZERO TO address.
if-  : (address): JUMP IF POSITIVE(address): Decrements TOP OF the DATA stack. JUMP If POSITIVE TO address.
jmp  : (address): Unconditionally sets the instruction pointer to a new address.
NAND : Pops two bitwise values, performs a bitwise NAND, and pushes the result.
+2/  : Pops two values, performs a bitwise ADD, pushes the result, and pushes the SHIFTRIGHT (CARRY: result).
+*   : IF ODD(NXT) THEN TOP := TOP + A; SHIFTRIGHT(CARRY:TOP:NXT)
-/   : SHIFTLEFT (TOP:NXT); IF TOP >= A THEN BEGIN TOP := TOP - A; NXT := NXT + 1; END;

```

### Forth language main loop

```asm
  GoForth
  DW _INTMODE
@mainloop  _GETLINE,_EVAL,_CR,_BR,@mainloop

XT OPERATION, @_WARY
  DW _NUM,_EXEC,_NUMC,_COMMA

XT EVAL,@EVAL
@_EVAL  DW _BLWORD,_DC@,_ZBR,@DROPX
  DW _FOUND,_OPERATION,_PERFORM,_BR,@_EVAL	

```