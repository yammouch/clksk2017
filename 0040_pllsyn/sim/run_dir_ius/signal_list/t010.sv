# SimVision Command Script (Thu Sep 21 04:32:52 AM CEST 2017)
#
# Version 14.20.s017
#
# You can restore this configuration with:
#
#     simvision -input /fstkdata/ux_user/tyam/projects/clksk2017.git/trunk/0040_pllsyn/sim/run_dir_ius/signal_list/t010.sv
#  or simvision -input /fstkdata/ux_user/tyam/projects/clksk2017.git/trunk/0040_pllsyn/sim/run_dir_ius/signal_list/t010.sv database1 database2 ...
#


#
# Preferences
#
preferences set toolbar-Standard-WatchWindow {
  usual
  shown 0
}
preferences set plugin-enable-svdatabrowser-new 1
preferences set toolbar-SimControl-WaveWindow {
  usual
  position -pos 2
}
preferences set toolbar-CursorControl-WaveWindow {
  usual
  position -row 1 -pos 2 -anchor e
}
preferences set toolbar-Windows-WatchWindow {
  usual
  shown 0
}
preferences set toolbar-sendToIndago-WaveWindow {
  usual
  position -pos 1
}
preferences set toolbar-TimeSearch-WaveWindow {
  usual
  position -pos 0 -anchor e
}
preferences set toolbar-Standard-Console {
  usual
  position -pos 1
}
preferences set toolbar-Windows-SchematicWindow {
  usual
  position -pos 2
}
preferences set toolbar-OperatingMode-WaveWindow {
  usual
  position -pos 4
  name OperatingMode
}
preferences set toolbar-Search-Console {
  usual
  position -pos 3
}
preferences set plugin-enable-svdatabrowser 0
preferences set toolbar-NavSignalList-WaveWindow {
  usual
  position -pos 1 -anchor e
}
preferences set toolbar-txe_waveform_toggle-WaveWindow {
  usual
  position -pos 0
}
preferences set toolbar-Standard-WaveWindow {
  usual
  position -pos 5
}
preferences set plugin-enable-groupscope 0
preferences set sb-display-values 1
preferences set plugin-enable-interleaveandcompare 0
preferences set plugin-enable-waveformfrequencyplot 0
preferences set toolbar-SimControl-WatchWindow {
  usual
  shown 0
}
preferences set toolbar-Windows-WaveWindow {
  usual
  position -pos 2
}
preferences set toolbar-WaveZoom-WaveWindow {
  usual
  position -row 0 -pos 3 -anchor w
}
preferences set whats-new-dont-show-at-startup 1
preferences set toolbar-TimeSearch-WatchWindow {
  usual
  shown 0
}

#
# Databases
#
array set dbNames ""
set dbNames(realName1) [ database require t010 -hints {
	file ./result/t010.shm/t010.trn
	file /fstkdata/ux_user/tyam/projects/clksk2017.git/trunk/0040_pllsyn/sim/run_dir_ius/result/t010.shm/t010.trn
}]
if {$dbNames(realName1) == ""} {
    set dbNames(realName1) t010
}

#
# Mnemonic Maps
#
mmap new -reuse -name {Boolean as Logic} -radix %b -contents {{%c=FALSE -edgepriority 1 -shape low}
{%c=TRUE -edgepriority 1 -shape high}}
mmap new -reuse -name {Example Map} -radix %x -contents {{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}}

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1748x751+64+83}] != ""} {
    window geometry "Waveform 1" 1748x751+64+83
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar select designbrowser
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
waveform baseline set -time 0

set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.DIGIT0[7:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.DIGIT1[7:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.DIGIT2[7:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.DIGIT3[7:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.cnt_0[5:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.cnt_1[1:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.DIGIT[7:0]}]}
	} ]]
waveform format $id -radix %b
waveform hierarchy expand $id
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.i_blink_7seg.DIGIT_SEL[3:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {tb.dut.DIGIT_SEL[3:0]}]}
	} ]]
waveform format $id -radix %b
waveform hierarchy expand $id

waveform xview limits 18865962.789ns 18929038.532ns

#
# Waveform Window Links
#

#
# Source Browser windows
#
if {[catch {window new SrcBrowser -name "Source Browser 1" -geometry 700x525+0+25}] != ""} {
    window geometry "Source Browser 1" 700x525+0+25
}
window target "Source Browser 1" on
srcbrowser using {Source Browser 1}
srcbrowser set \
    -primarycursor TimeA \
    -units ns \
    -radix default \
    -showstrength 0 \
    -showcallstack 0 \
    -displayvalues 1

srcbrowser show -scope tb.dut -file /user/tyam/projects/clksk2017.git/trunk/0040_pllsyn/rtl/pll_test.v -line 48

srcbrowser sidebar visibility partial

#
# Layout selection
#

