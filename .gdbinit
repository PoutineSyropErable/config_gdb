# source /usr/share/gdb-dashboard/.gdbinit

# I trust my own project, allow running the local gdb init

# add-auto-load-safe-path /home/francois/Documents/zzz__PersonalProjects/MapleKernel/
# add-auto-load-safe-path /home/francois/Documents/zzz__PersonalProjects/MapleKernel/src
add-auto-load-safe-path /home/francois/Documents/zzz__PersonalProjects/MapleKernel/src/.gdbinit


define rk32
	target remote :1234 
end


define rk64
	set architecture i386:x86-64
	target remote :1234 
end




define activate_dashboard 
	source /usr/share/gdb-dashboard/.gdbinit
end

# Use Intel syntax for disassembly
set disassembly-flavor intel

# Pretty print complex data structures
set print pretty on

# Disable paging in output (No --More--)
set pagination off

# equivalent to b main, r . Relies on existence of main
# start 

# Useful commands, that we wouldn't run here
define never_run_fr
	#enable backward steps
	target record-full
# we dont call it right here, but later

end


define cls
	shell clear
	dashboard
end

define di 
	disassemble 
end

define atnt
	set disassembly-flavor att
end 


define intel
	set disassembly-flavor intel
end 




# ================= Commands to put memory in the watch ==================
define aset
	dashboard assembly -style height $arg0
end 


define ascroll 
	 dashboard assembly scroll $arg0
end



# ==== Local var only ====  Exactly the current stack
define stack_watch
    # Unwatch any previous watches in the same range
    dashboard memory unwatch $rsp $rbp-$rsp
    # Watch from RSP for length RBP-RSP
    dashboard memory watch $rsp $rbp-$rsp
end

define stack_unwatch
    dashboard memory unwatch $rsp $rbp-$rsp
end


define mem_watch
    dashboard memory watch $arg0 $arg1
	# dashboard memory watch $rsp $arg0
	# arg0 is the location, and arg1 is the size. 
	# Watch arg1 byte starting at arg0
end



define mem_unwatch
    dashboard memory unwatch $arg0
	# dashboard memory watch $rsp $arg0
	# arg0 is the location, and arg1 is the size. 
	# Watch arg1 byte starting at arg0
end


define stack_watch_n
    dashboard memory unwatch $rbp-$arg0
    # Watch from RBP down to include the stack frame
    dashboard memory watch $rbp-$arg0 $arg0
end


define stack_unwatch_n
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




# ====== Reset ===== 

define config_dashboard

	# Use Intel syntax for disassembly
	set disassembly-flavor intel

	# Pretty print complex data structures
	set print pretty on

	# Disable paging in output (No --More--)
	set pagination off

	aset 20 
	ascroll 5 
	stack_watch
end

define simple_view 

	display/10i $rip
	display/x $rbp
	display/x $rsp
	display/x $rax
	display/x $rbx
	display/x $rcx
	display/x $rdx
	display/x $rdi
	display/x $rsi
	display/x $r8
	display/x $r9
	display/x $r12
	display/x $r13
	display/x $r14
	display/10gx $rsp
	start
end


define mainb 
	set $call_add16 = 0xB070
	set $add1616 = 0xB040
	set $resume32 = 0xB0A8
	b kernel_main 
	b before
	b *$call_add16 	
	b *$add1616
	b *$resume32
end

define real_stack_check 
	/2hx ($ss*16+$sp)
	/4x ($ss*16+$sp)
end

define bm 
	b call_real_mode_function_with_argc
	# b *0x204d62
	b *204d50
	b *b060
	b *b0b0
	b *b0cc
end



define b2 
	# call_add16
	b before 
	c 
	b *0xB070 
	set $call_add16 = 0xB040
	set $add1616 = 0xB080
	set $resume32 = 0xB0b0

	info address args16_start
	info address stack16_start
	info address stack16_end


	# call_add16
	b *0xB040 

	b *0xb054 
	
	# before jump
	b *0xb06d 

	# add1616
	b *0xB080 

	# resume32
	b *0xB0b0
end



define remote_kernel
    # Connect to QEMU remote
    target remote localhost:1234

    # Set common breakpoints
	mainb
	continue


end



define pk 
	printf "Breakpoints set:\n"
	printf " call_add16   = 0x%x\n", $call_add16
	printf " protected16  = 0x%x\n", $protected16
	printf " add1616      = 0x%x\n", $add1616
	printf " add16        = 0x%x\n", $add16
	printf " resume32     = 0x%x\n", $resume32
end




define rk1
	b before 



	# Set the variables
	set $call_add16 = 0xB060
	set $protected16 = 0xB0A0
	set $add1616 = 0xb0bc 
	set $add16 = 0xB100
	set $resume32 = 0xb110

	
	# Print them nicely
	# printf "Breakpoints set:\n"
	printf " call_add16   = 0x%x\n", $call_add16
	printf " protected16  = 0x%x\n", $protected16
	printf " add1616      = 0x%x\n", $add1616
	printf " add16        = 0x%x\n", $add16
	printf " resume32     = 0x%x\n", $resume32


	printf "\n Do Continue, then Go press Enter on grub \n\n"

end



define rk2 
	# Set breakpoints
	b *$call_add16
	b *$protected16 
	b *$add1616
	b *$add16 
	b *$resume32 
end

define a161_address
	info address args16_start	
end


define a16_type
	ptype args16_start
end

define a16_value 
	print args16_start
end

define a16_offset
	print_args16_offsets
end

define a16_break 
	b print_args16_more 
end


define a16a 
	info address args16_start	
	ptype args16_start
	print args16_start
	x/24xh &args16_start

	b print_args16_more
	 

	print_to_args16_offsets

	p /x args16_start.esp

end 

define print_args16_offsets
    printf "gdt_root     -> %d bytes\n", (char *)&args16_start.gdt_root - (char *)&args16_start
    printf "esp          -> %d bytes\n", (char *)&args16_start.esp - (char *)&args16_start
    printf "ret1         -> %d bytes\n", (char *)&args16_start.ret1 - (char *)&args16_start
    printf "ret2         -> %d bytes\n", (char *)&args16_start.ret2 - (char *)&args16_start
    printf "func         -> %d bytes\n", (char *)&args16_start.func - (char *)&args16_start
    printf "func_cs      -> %d bytes\n", (char *)&args16_start.func_cs - (char *)&args16_start
    printf "argc         -> %d bytes\n", (char *)&args16_start.argc - (char *)&args16_start
    printf "func_args[0] -> %d bytes\n", (char *)&args16_start.func_args[0] - (char *)&args16_start
    printf "func_args[1] -> %d bytes\n", (char *)&args16_start.func_args[1] - (char *)&args16_start
    printf "func_args[2] -> %d bytes\n", (char *)&args16_start.func_args[2] - (char *)&args16_start
    printf "func_args[3] -> %d bytes\n", (char *)&args16_start.func_args[3] - (char *)&args16_start
    printf "func_args[4] -> %d bytes\n", (char *)&args16_start.func_args[4] - (char *)&args16_start
    printf "func_args[5] -> %d bytes\n", (char *)&args16_start.func_args[5] - (char *)&args16_start
    printf "func_args[6] -> %d bytes\n", (char *)&args16_start.func_args[6] - (char *)&args16_start
    printf "func_args[7] -> %d bytes\n", (char *)&args16_start.func_args[7] - (char *)&args16_start
    printf "func_args[8] -> %d bytes\n", (char *)&args16_start.func_args[8] - (char *)&args16_start
    printf "func_args[9] -> %d bytes\n", (char *)&args16_start.func_args[9] - (char *)&args16_start
    printf "func_args[10] -> %d bytes\n", (char *)&args16_start.func_args[10] - (char *)&args16_start
    printf "func_args[11] -> %d bytes\n", (char *)&args16_start.func_args[11] - (char *)&args16_start
end




python
import gdb
import os

class CdSrc(gdb.Command):
    def __init__(self):
        super().__init__("cd-src", gdb.COMMAND_SUPPORT)
    
    def invoke(self, arg, from_tty):
        # Try different relative paths
        paths_to_try = [
            "src",           # src in current dir
            "../src",        # src one level up
            "../../src",     # src two levels up
            "../../../src",  # src three levels up
            "../../../../src" # src four levels up
        ]
        
        for path in paths_to_try:
            try:
                # Check if exists
                if os.path.exists(path) and os.path.isdir(path):
                    gdb.execute(f"cd {path}")
                    print(f"✓ Changed to {path}")
                    gdb.execute("pwd")
                    return
            except:
                pass
        
        print("✗ Couldn't find src directory nearby")
        print("  Try: cd .. and then cd-src again")

CdSrc()
end
