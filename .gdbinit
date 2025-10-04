source /usr/share/gdb-dashboard/.gdbinit

# Use Intel syntax for disassembly
set disassembly-flavor intel

# Pretty print complex data structures
set print pretty on

# Disable paging in output (No --More--)
set pagination off

# equivalent to b main, r . Relies on existence of main
# start 



define cls
shell clear
dashboard
end


# ================= Commands to put memory in the watch ==================
define mem_watch
    dashboard memory watch $arg0 $arg1
	# dashboard memory watch $rsp $arg0
end


define stack_watch
    dashboard memory unwatch $rbp-$arg0
    # Watch from RBP down to include the stack frame
    dashboard memory watch $rbp-$arg0 $arg0
end


define stack_unwatch
    dashboard memory unwatch $rbp-$arg0
end


define stack_watch_both
    dashboard memory unwatch $rbp-$arg0
    # Watch from RBP down to include the stack frame
    dashboard memory watch $rbp-$arg0 $arg0+$arg0
end



## ================== Dashboardless versions. Useful because dashboard can't change endianness or display formats. =============
# Pure GDB memory inspection commands (no dashboard)
define int_watch
    printf "32-bit integers at 0x%lx (%d bytes):\n", $arg0, $arg1
    set $count = $arg1 / 4
    x/$count[1]wx $arg0
end

define stack_ints
    printf "Stack (RSP=0x%lx) as 32-bit integers:\n", $rsp
    set $count = $arg0 / 4
    x/$count[1]wx $rsp
end

define mem_analyze
    printf "Memory analysis at 0x%lx:\n", $arg0
    printf "Raw bytes:    "
    x/16xb $arg0
    printf "32-bit ints:  "
    x/4xw $arg0  
    printf "64-bit ints:  "
    x/2gx $arg0
    printf "32-bit floats:"
    x/4fw $arg0
    printf "ASCII:        "
    x/16c $arg0
end

# DWORD (32-bit) watch
define dword_watch
    printf "32-bit DWORDs at 0x%lx (%d bytes):\n", $arg0, $arg1
    set $count = $arg1 / 4
    x/$count[1]wx $arg0
end

# WORD (16-bit) watch  
define word_watch
    printf "16-bit WORDs at 0x%lx (%d bytes):\n", $arg0, $arg1
    set $count = $arg1 / 2
    x/$count[1]hx $arg0
end

# BYTE (8-bit) watch
define byte_watch
    printf "8-bit BYTEs at 0x%lx (%d bytes):\n", $arg0, $arg1
    x/$arg1[1]xb $arg0
end

# Complete type-specific watches
define type_watch
    printf "Memory at 0x%lx as different types (%d bytes):\n", $arg0, $arg1
    printf "BYTEs (8-bit):  "
    x/$arg1[1]xb $arg0
    printf "WORDs (16-bit): "
    x/$(($arg1/2))[1]hx $arg0
    printf "DWORDs (32-bit):"
    x/$(($arg1/4))[1]wx $arg0
    printf "QWORDs (64-bit):"
    x/$(($arg1/8))[1]gx $arg0
end

# Signed integer watches
define sdword_watch
    printf "Signed 32-bit integers at 0x%lx:\n", $arg0
    set $count = $arg1 / 4
    x/$count[1]wd $arg0
end

define sword_watch
    printf "Signed 16-bit integers at 0x%lx:\n", $arg0
    set $count = $arg1 / 2
    x/$count[1]hd $arg0
end

define sbyte_watch
    printf "Signed 8-bit integers at 0x%lx:\n", $arg0
    x/$arg1[1]db $arg0
end

define qword_watch
    printf "64-bit integers at 0x%lx:\n", $arg0
    set $count = $arg1 / 8
    x/$count[1]gx $arg0
end

define float_watch
    printf "32-bit floats at 0x%lx:\n", $arg0
    set $count = $arg1 / 4
    x/$count[1]fw $arg0
end

define double_watch
    printf "64-bit doubles at 0x%lx:\n", $arg0
    set $count = $arg1 / 8
    x/$count[1]fd $arg0
end

# Quick formatted memory dump
define mem_dump
    if $argc == 0
        set $addr = $rsp
        set $bytes = 64
    else
        set $addr = $arg0
        if $argc > 1
            set $bytes = $arg1
        else
            set $bytes = 64
        end
    end
    printf "Memory dump at 0x%lx (%d bytes):\n", $addr, $bytes
    x/$bytes[1]xb $addr
    printf "As 32-bit: "
    x/$(($bytes/4))[1]wx $addr
end

# Register-focused memory inspection
define reg_mem
    printf "Memory at %s (0x%lx):\n", $arg0, $arg1
    x/8xb $arg1
    x/2xw $arg1
    x/1gx $arg1
end

# Compare memory regions
define mem_cmp
    printf "Comparing 0x%lx vs 0x%lx (%d bytes):\n", $arg0, $arg1, $arg2
    printf "Address A:\n"
    x/$arg2[1]xb $arg0
    printf "Address B:\n"
    x/$arg2[1]xb $arg1
end

# Smart stack inspection
define stack_inspect
    set $bytes = 128
    if $argc > 0
        set $bytes = $arg0
    end
    printf "Stack inspection (RSP=0x%lx, RBP=0x%lx):\n", $rsp, $rbp
    printf "Stack frame size: %d bytes\n", ($rbp - $rsp)
    printf "Current stack (%d bytes):\n", $bytes
    x/$(($bytes/8))[1]gx $rsp
end

# Watch memory with periodic updates
define mem_trace
    printf "Tracing memory at 0x%lx (auto-update on stop):\n", $arg0
    display/8xb $arg0
    display/2xw $arg0
    display/1gx $arg0
end
