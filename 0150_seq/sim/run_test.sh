# amsenv a1
# source /tools/.ius142isr17rc

set result_name = tb

cat > ${result_name}_dump.tcl <<!
database ${result_name}.shm
probe \
 -create tb -shm -depth all \
 -all -tasks -functions -uvm -packed 4k -unpacked 16k -ports \
 -memories -waveform -database ${result_name}.shm
run
!

irun \
 -input ${result_name}_dump.tcl \
 +access+r \
 tb_clk_gen.v \
 tb.v \
 ../rtl/synth.v \
 ../rtl/seq.v \
 ../rtl/cnt_down.v
