#!/bin/sh

firefox &
telegram-desktop &
Discord &

pw-link pw_vsink_desktop:output_FL pw_vsource_mixed:input_1
pw-link pw_vsink_desktop:output_FR pw_vsource_mixed:input_2
pw-link pw_vsource_voice:capture_1 pw_vsource_mixed:input_1
pw-link pw_vsource_voice:capture_2 pw_vsource_mixed:input_2
