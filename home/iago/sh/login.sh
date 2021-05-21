#!/bin/sh

maintain_link() {
    from="$1"
    to="$2"

    while true; do
        pw-link $1 $2
        sleep 1
    done
}

#start_jack 2>&1 > start_jack.log
#pa_virtual_devices
#source $HOME/.config/carla-env
carla Documents/patchbay-pipewire.carxp &
firefox &
telegram-desktop &
Discord &

out="alsa_output.pci-0000_09_00.1.output_hdmi-stereo"
mic="alsa_input.usb-Generalplus_Usb_Audio_Device_13662631792-00.input_mono-fallback"
maintain_link {pa_vsink_desktop:monitor,"$out":playback}_FL &
maintain_link {pa_vsink_desktop:monitor,"$out":playback}_FR &
maintain_link {pa_vsink_call:monitor,"$out":playback}_FL &
maintain_link {pa_vsink_call:monitor,"$out":playback}_FR &
maintain_link "$mic":capture_MONO "Noise Suppressor for Voice (Mono):Input" &
