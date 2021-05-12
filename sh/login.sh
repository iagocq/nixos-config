#!/bin/sh

to_upper() {
    printf '%s%s' `echo -n ${1:0:1} | tr '[:lower:]' '[:upper:]'` "${1:1}"
}

list_pa_alsa_modules() {
   pacmd list-cards |
       grep --no-group-separator -A1 "driver: <module-alsa-card.c>" |
       sed -n 2~2p |
       sed 's/owner module://'   
}

start_jack() {
    until pacmd info > /dev/null; do sleep 1; done
    pacmd suspend true
    for module in $(list_pa_alsa_modules); do
        pacmd unload-module $module
    done
    #jack_control start
    #jack_control ds alsa
    #jack_control dps playback hw:NVidia,3
    #jack_control dps capture hw:Generic,0
    #jack_control dps rate 44100
    #jack_control dps nperiods 2
    #jack_control dps period 64
    jackd -v -r -P 99 -dalsa -Phw:NVidia,3 -Chw:Generic,0 -r48000 -n 2 -p 2048 &
    jack_wait -w
    alsa_in -j cloop -dcloop &
    alsa_out -j ploop -dploop &
    alsa_out -j line_out -dhw:Generic,0 &
    alsa_in -j line_in -dhw:Generic,2 &
    while [ "`jack_lsp cloop`" == "" ] || [ "`jack_lsp ploop`" == "" ]; do sleep 1; done
    #jack_connect cloop:capture_1 system:playback_1
    #jack_connect cloop:capture_2 system:playback_2
    #jack_connect system:capture_1 ploop:playback_1
    #jack_connect system:capture_2 ploop:playback_2
    for pasink in voice desktop extra; do
        pactl load-module module-jack-sink \
            sink_name="jack_sink_$pasink" \
            client_name="pa-sink-$pasink" \
            channels=2 \
            connect=no
        cmd="update-sink-proplist jack_sink_$pasink"
        pacmd "update-sink-proplist jack_sink_$pasink device.description="\""`to_upper $pasink` (Jack sink)"\"
    done
    for pasource in voice mixed extra; do
        pactl load-module module-jack-source \
            source_name="jack_source_$pasource" \
            client_name="pa-source-$pasource" \
            channels=2 \
            connect=no
        pacmd "update-source-proplist jack_source_$pasource device.description="\""`to_upper $pasource` (Jack source)"\"
    done
    pacmd set-default-sink "jack_sink_desktop"
    pacmd set-default-source "jack_source_voice"
}

pa_virtual_devices() {
    for pasink in call desktop; do
        pactl load-module module-null-sink \
            sink_name="pa_vsink_$pasink" \
            channels=2 \
            object.linger=1 \
            media.class=Audio/Sink \
            device.description=\""`to_upper $pasink` (PA Virt Sink)"\"
    done
    for pasource in mic mixed; do
        pactl load-module module-null-sink \
            sink_name="pa_vsource_$pasource" \
            channels=2 \
            object.linger=1 \
            media.class=Audio/Source/Virtual \
            device.description=\""`to_upper $pasource` (PA Virt Source)"\"
    done
    pactl set-default-sink "pa_vsink_desktop"
    pactl set-default-source "pa_vsource_voice"
}

maintain_link() {
    from="$1"
    to="$2"

    while true; do
        pw-link $from $to
        sleep 1
    done
}

#start_jack 2>&1 > start_jack.log
#pa_virtual_devices
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
