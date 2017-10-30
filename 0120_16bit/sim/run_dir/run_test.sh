# amsenv a1
# source /tools/.ius142isr17rc

cat > intermediate/$1_dump.tcl <<!
database result/$1.shm
probe \
 -create tb -shm -depth all \
 -all -tasks -functions -uvm -packed 4k -unpacked 16k -ports \
 -memories -waveform -database result/$1.shm
run
!

irun \
 -input intermediate/$1_dump.tcl \
 +access+r \
 -f files.f \
 ../scenario/$1.v
