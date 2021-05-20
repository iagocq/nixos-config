#!/bin/sh

f="$HOME/Pictures/screenshots/`date +%Y-%m-%d-%H%M%S.png`"

scr_full() {
	$maim $f
	s=$?
}

scr_window() {
	$maim -i `$xdotool getactivewindow` $f
	s=$?
}

scr_region() {
	$maim -m 1 | $feh -F - &
	FEH=$!
	$maim -s $f
	s=$?
	kill $FEH
}

copy_to_clipboard() {
	$xclip -selection clipboard -t image/png $f
}

case $1 in
	full)
		scr_full
		;;
	window)
		scr_window
		;;
	*)
		scr_region
		;;
esac

[ $s -eq 0 ] && copy_to_clipboard

