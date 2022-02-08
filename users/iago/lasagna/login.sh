#!/bin/sh

firefox=${firefox:-@firefox@/bin/firefox}
tdesktop=${tdesktop:-@tdesktop@/bin/telegram-desktop}
discord=${discord:-@discord@/bin/discord}
pipewire=${pipewire:-@pipewire@}
pw_link=$pipewire/bin/pw-link

$firefox &
$tdesktop &
$discord &

sleep 10
$pw_link pw_vsink_desktop:output_FL pw_vsource_mixed:input_FL
$pw_link pw_vsink_desktop:output_FR pw_vsource_mixed:input_FR
$pw_link pw_vsource_voice:capture_FL pw_vsource_mixed:input_FL
$pw_link pw_vsource_voice:capture_FR pw_vsource_mixed:input_FR
