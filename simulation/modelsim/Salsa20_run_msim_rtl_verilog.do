transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Adam/Desktop/Salsa20 {C:/Users/Adam/Desktop/Salsa20/quarter_round.v}

