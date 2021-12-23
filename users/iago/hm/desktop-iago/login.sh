#!/bin/sh

firefox &
telegram-desktop &
Discord &

sleep 10
pw-link pw_vsink_desktop:output_FL pw_vsource_mixed:input_FL
pw-link pw_vsink_desktop:output_FR pw_vsource_mixed:input_FR
pw-link pw_vsource_voice:capture_FL pw_vsource_mixed:input_FL
pw-link pw_vsource_voice:capture_FR pw_vsource_mixed:input_FR
