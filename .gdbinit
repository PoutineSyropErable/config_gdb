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

