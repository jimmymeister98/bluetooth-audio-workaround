#!/bin/bash



#rootcheck because this script needs elevated permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo -n "This setup will deactivate PulseAudio and use PipeWire instead"
echo -n "Choose between (r)ollback, (i)nstallation, (c)ancel"
read -p "Enter (r/i/c): " userInput

# Check if string is empty using -z. For more 'help test'    
if [[ -z "$userInput" ]]; then
   printf '%s\n' "No input entered"
   exit 1

elif [["$userInput" = "r" ]]; then
    systemctl --user unmask pulseaudio
    systemctl --user --now enable pulseaudio.service pulseaudio.socket
 
elif [["$userInput" = "i"]]; then
   # If userInput is not empty show what the user typed in and run ls -l
    printf "Installing..."
    echo "Installing dependencies"
    sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream -y
    sudo apt update -y
    sudo apt install libspa-0.2-bluetooth,pipewire-audio-client-libraries
    echo "reloading the daemon"
    systemctl --user daemon-reload
    echo "Disabling PulseAudio"
    systemctl --user --now disable pulseaudio.service pulseaudio.socket
    echo "Masking PulseAudio in order to be compatible with Ubuntu 20.04"
    systemctl --user mask pulseaudio
    echo "Enabling PipeWire"
    systemctl --user --now enable pipewire-media-session.service
    echo "Done!"
    echo "If you dont see your different audio profiles in settings, its highly recommended to restart your device!"
else
    echo "Invalid input, exiting..."
fi

