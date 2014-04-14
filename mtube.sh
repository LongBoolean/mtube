#! /bin/bash
useVLC="true"
function playVideo {
	echo Preparing to play the video....
	#but first we need to check that the link is valid
	if [ "$(curl -s --head $1 | head -n 1 | grep "HTTP/1.[01] [23]..")" == "" ]; then
		echo ERROR: Invalid Link
	else
		link_loc="$(youtube-dl -i $qual -g --cookies /tmp/cookie.txt "$1")"
		if [ "$link_loc" == "" ]; then
			echo mtube: The link you entered must be incorrect.
		elif [ "$useVLC" == "false" ]; then
			mplayer $other -cache $cache -cache-min $mincache -cookies -cookies-file /tmp/cookie.txt $link_loc 
		else
			vlc $1
		fi
	fi
}

finished="false"
if [ "$1" == "" ]; then
	echo "Either give the quality of the video(480, 720, 1080) followed by a link to a youtube video, enter update to update youtube-dl, or enter 'loop' to play videos one after another."
	finished="true"
elif [ "$1" == "update" ]; then
	echo Updating youtube-dl...
	sudo youtube-dl -U
	finished="true"
fi
#set the quality of the video
qual="-f 18"
other=""
cache=8192
mincache=30
if [ "$1" == "480" ]; then
	qual="-f 18"
elif [ "$1" == "720" ]; then
	qual="-f 22"
	cache=16384
	mincache=50
elif [ "$1" == "1080" ]; then
	qual="-f 37"
	cache=32768
	mincache=50
elif [ "$1" == "best" ]; then
	qual=""
	cache=32768
	mincache=50
elif [ "$1" == "worst" ]; then
	qual="-f worst"
	cache=8192
	mincache=20
elif [ "$1" == "term" ]; then 
	qual="-f 18"
elif [ "$1" == "pl_download" ]; then
	finished="true"
	echo Preparing to download the videos from the playlist.
	plState=""
	plState=$(./ytube_playlist.sh $2 reset)
	while true
	do
		#get url from playlist
		vid_url="$(./ytube_playlist.sh $2)"
		#but first we need to check that the url is valid
		if [ "$(curl -s --head $vid_url | head -n 1 | grep "HTTP/1.[01] [23]..")" == "" ]; then
			echo ERROR: Invalid Link
		else
			youtube-dl -cit "$vid_url"
		fi
		plState=$(./ytube_playlist.sh $2 next)

		if [ "$plState" == "END" ]; then
			break;
		fi
	done

other="-quiet"
elif [ "$1" == "loop" ]; then
	qual=""
	cache=32768
	mincache=50
	finished="true"
	oldurl=""
	vidurl=""
	while true
	do
		echo Please enter a youtube link, 
		echo \'l\' to play the last url entered,
		echo or \'q\' to leave the script.
		echo -n "Input: "
		read input
		echo $'\n'
		if [ "$input" == "q" ]; then
			break;
		fi
		if [ "$input" == "l" ]; then
			vidurl="$oldurl"
		else
			vidurl="$input"
		fi
		playVideo "$vidurl"
		oldurl="$vidurl"
	done

fi
#download and play the video
if [ "$2" == "tut" ]; then
	echo Running Tutorial Video
	mplayer -fs -cookies -cookies-file /tmp/cookie.txt $(youtube-dl -i $qual -g --cookies /tmp/cookie.txt "http://www.youtube.com/watch?v=QCuq0_nY3Xk")
elif [ "$2" == "playlist" ]; then
	echo Preparing to play the videos from the playlist.
	plState=""
	while true
	do
       		 #get url from playlist
                vid_url="$(ytube_playlist.sh $3)"
		playVideo $vid_url
		echo Playlist Controls:  \(please enter one of the following\) 
		echo c$'\t'play the current video
		echo n$'\t'play the next video
		echo b$'\t'play the previous video
		echo r$'\t'reset the playlist
		echo q$'\t'exit without icrementing the playlist
		echo w$'\t'exit and increment the playlist 
		echo -n Choice: 
		read choice
		echo $'\n'
		if [ "$choice" == "c" ]; then
			echo Play current video.
		elif [ "$choice" == "n" ]; then
			echo Play next video.
			plState=$(./ytube_playlist.sh $3 next)
		elif [ "$choice" == "b" ]; then
			echo Play previous video.
			plState=$(./ytube_playlist.sh $3 back)
		elif [ "$choice" == "r" ]; then
			echo Reset the playlist and play the first video.
			plState=$(./ytube_playlist.sh $3 reset)
		elif [ "$choice" == "q" ]; then
			echo Quiting on current video.
			break;
		elif [ "$choice" == "w" ]; then
			echo Quiting on next video.
			plState=$(./ytube_playlist.sh $3 next)
			break;
		else
			echo Invalid input: playing current video...
		fi
		if [ "$plState" == "END" ]; then
			echo End of playlist.
			sleep 2
		elif [ "$plState" == "TOP" ]; then
			echo Begining of playlist.
			sleep 2
		fi
	done
elif [ "$finished" != "true" ]; then
	playVideo $2
fi
