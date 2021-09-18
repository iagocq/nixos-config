#!/bin/sh

maintain_link() {
    while true; do
        pw-link "$1" "$2"
        sleep 1
    done
}

#start_jack 2>&1 > start_jack.log
#pa_virtual_devices
#source $HOME/.config/carla-env
firefox &
telegram-desktop &
Discord &

out="alsa_output.pci-0000_09_00.1.hdmi-stereo"
mic="alsa_input.usb-Generalplus_Usb_Audio_Device_13662631792-00.mono-fallback"
maintain_link pa_vsink_desktop:output_FL pa_vsource_mixed:input_1 &
maintain_link pa_vsink_desktop:output_FR pa_vsource_mixed:input_2 &
maintain_link pa_vsource_voice:capture_1 pa_vsource_mixed:input_1 &
maintain_link pa_vsource_voice:capture_2 pa_vsource_mixed:input_2 &
