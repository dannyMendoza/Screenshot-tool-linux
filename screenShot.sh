#!/usr/bin/env bash

# Author: Daniel Alejandro Mendoza Becerra
# Robotics Engineer
# NIX user

# Screnshoot Tool
# a) Fullscreen
# b) Selected Area
# c) Circular Area, click at the center of the image and then in circunference.
# d) Copy to clipboard

# When you take a screnshot there is always a preview.
# Even if you take a selected area or fullscreen screenshot, always remains in the clipboard.

title="DM Screenshot Tool"
save="SaveImage"
fullscreen="FullScreen"
selection="Seleceted Area"
circular="Cicle selection"
cptoclip="Copy to clipboard"

## SAVE THE IMAGE ##

saveImage()
{
	si=$(zenity --entry --text "Save Image" --title "$save" 2>/dev/null)
	imageName=`echo "${si}.png"`
}

## CIRCLE SELECTION ##

# (x – h)^2 + (y – k)^2 = r^2 -> Circle equation

# 1) You have to click twice
# 1.1) One click to provide (h,k), wich are the center of the circle.
# 2) Second click works as the distance of center to the circunference of the circle.

# https://askubuntu.com/questions/1035174/is-it-possible-to-take-a-screenshot-of-a-circular-selected-area
# The circle selection posted in askubuntu works great, I just have made some changes.

circle()
{
	xclip -i /dev/null
	output=~/Pictures/tmp.png
	temp_screenshot=~/Pictures/tmp.png
	STATE1=$(xinput --query-state 10 | grep 'button\[' | sort)
	while true; do
		STATE2=$(xinput --query-state 10 | grep 'button\[' | sort)
		sleep 0.05
		i=$(comm -13 <(echo "$STATE1") <(echo "$STATE2"))
		STATE1=$STATE2
		var=$(echo $i | grep -woi "2")
		if [[ -n $var ]] ; then
			echo $i > $HOME/.clicked
			cat $HOME/.clicked | sed -e 's/^ //g'
			if [[ -s $HOME/.clicked ]] ; then
				eval $(xdotool getmouselocation --shell)
				x_center=$X
				y_center=$Y
				break
			fi
		fi
	done
	rm -f $HOME/.clicked
	unset STATE1 
	unset STATE2
	sleep 0.5
	xclip -i /dev/null
	STATE1=$(xinput --query-state 10 | grep 'button\[' | sort)
	while true; do
		STATE2=$(xinput --query-state 10 | grep 'button\[' | sort)
		sleep 0.05
		i=$(comm -13 <(echo "$STATE1") <(echo "$STATE2"))
		STATE1=$STATE2
		var=$(echo $i | grep -woi "2")
		if [[ -n $var ]] ; then
			echo $i > $HOME/.clicked
		cat $HOME/.clicked | sed -e 's/^ //g'
			if [[ -s $HOME/.clicked ]] ; then
				eval $(xdotool getmouselocation --shell)
				break
			fi
		fi
	done
	rm -f $HOME/.clicked
	maim -u -q $temp_screenshot
	if [[ -s ~/Pictures/tmp.png ]] ; then	
		radius=$(bc <<<"sqrt(($X-$x_center)^2+($Y-$y_center)^2)")
		convert $temp_screenshot -alpha on \( +clone -channel a -evaluate multiply 0 -draw "ellipse $x_center,$y_center $radius,$radius 0,360" \) -compose CopyOpacity -composite -trim "$output"
		xclip -selection clipboard -t image/png -i ~/Pictures/tmp.png
		size=`file ~/Pictures/tmp.png | awk {'print $5"x"$7'} | tr -d \,`
		sxiv -b -s f -g $size $HOME/Pictures/tmp.png &
		psSXIV=`pidof sxiv | awk '{print $1}'`
		saveImage
		if [ -n "$imageName" ]
		then
			mv $HOME/Pictures/tmp.png $HOME/Pictures/"$imageName" > /dev/null 2>&1
		fi
		kill $psSXIV > /dev/null 2>&1
	fi
	screenshot
}

## Fullscreen Selection ##

fullscreen(){
	maim -u -q ~/Pictures/tmp.png 
	xclip -selection clipboard -t image/png -i ~/Pictures/tmp.png
	size=`file ~/Pictures/tmp.png | awk {'print $5"x"$7'} | tr -d \,`
	sxiv -b -s f -g $size $HOME/Pictures/tmp.png 2>/dev/null &
	psSXIV=`pidof sxiv | awk '{print $1}'`
	saveImage
	if [ -n "$imageName" ]
	then
		mv $HOME/Pictures/tmp.png $HOME/Pictures/"$imageName" > /dev/null 2>&1
	fi
	kill $psSXIV > /dev/null 2>&1
	screenshot
}

## Window or Selected Area ##

selection(){
	maim -s -u -b 2 -q -c 0,28,67,0.5 ~/Pictures/tmp.png
	if [[ -s ~/Pictures/tmp.png ]] ; then	
		xclip -selection clipboard -t image/png -i ~/Pictures/tmp.png
		size=`file ~/Pictures/tmp.png | awk {'print $5"x"$7'} | tr -d \,`
		sxiv -b -s f -g $size $HOME/Pictures/tmp.png &
		psSXIV=`pidof sxiv | awk '{print $1}'`
		saveImage
		if [ -n "$imageName" ]
		then
			mv $HOME/Pictures/tmp.png $HOME/Pictures/"$imageName" > /dev/null 2>&1

		kill $psSXIV > /dev/null 2>&1
		fi
	fi
	screenshot
}

## Copy to clipboard ##

clipboard(){
	maim -s -q -u -b 2 -c 0,75,100,0.6 --format png /dev/stdout | xclip -selection clipboard -t image/png
	screenshot
}

## Main Function ##

screenshot(){
	option=$(zenity --list --text "DM SCREENSHOT" --title "$title" --column="" --hide-header "$fullscreen" "$selection" "$circular" "$cptoclip" 2>/dev/null)

	if [[ -d ~/Pictures ]]
	then
		if [[ $option == $fullscreen ]];
		then
			fullscreen
		elif [[ $option == $selection ]];
		then
			selection
		elif [[ $option == $cptoclip ]]
		then
			clipboard
		elif [[ $option == $circular ]]
		then	
			circle
		else
			echo "Option not selected"
		fi
	else
		mkdir -p ~/Pictures
		screenshot
	fi
}
screenshot
