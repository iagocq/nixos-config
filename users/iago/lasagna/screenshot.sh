#!/bin/sh

f="$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H%M%S.png)"

maim=${maim:-@maim@/bin/maim}
xdotool=${xdotool:-@xdotool@/bin/xdotool}
feh=${feh:-@feh@/bin/feh}
xclip=${xclip:-@xclip@/bin/xclip}

scr_full() {
    $maim "$f"
    s=$?
}

scr_window() {
    $maim --window $($xdotool getactivewindow) --capturebackground "$f"
    s=$?
}

scr_region() {
    $maim --format bmp | $feh -F - &
    FEH=$!
    $maim --select --hidecursor "$f"
    s=$?
    kill -9 $FEH
}

copy_image_to_clipboard() {
    $xclip -selection clipboard -t image/png "$f"
}

copy_path_to_selection() {
    echo -n "$f" | $xclip -selection primary
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

[ $s -eq 0 ] && copy_image_to_clipboard && copy_path_to_selection
