# /bin/bash
FILENAME=""
lineCount=0
current=0
analyze=1;
reset=0;
#check if the playlist file exists
if [ "$1" != "" ] && [ -f "$1" ] && [ -s "$1" ]; then
	FILENAME=$1
	#first we must analyze the playlist
	while read -r -a line
	do
		lineCount=$[lineCount + 1]
		case "$line" in \#\#*) continue ;; esac
		case "$line" in \#*) continue ;; esac
		if [ $analyze == 1 ]; then
			case "$line" in *) current=$lineCount; analyze=0 ;; esac
		fi
	done < "$FILENAME"
	if [ $analyze == 1 ]; then
		current=$lineCount
		analyze=0
	fi
	#now handle the options
	if [ "$2" == "next" ]; then
		count=0
		while read line
		do
			if [ $count == $[current - 1] ] && [ $count != $[lineCount - 1] ] ; then
				echo \#$line
			else
				echo $line
			fi
			count=$[count + 1]
		done < "$FILENAME" > /tmp/playlist.ypl.t
		mv /tmp/playlist.ypl.t "$FILENAME"
		if [ $[current - 1] -ge $[lineCount - 1 ] ]; then
			echo END
		fi
	elif [ "$2" == "back" ]; then
		count=0
		while read line
		do
			if [ $count == $[current - 2] ] && [ $count != 0 ] ; then
				echo ${line//#/}
			else
				echo $line
			fi
			count=$[count + 1]
		done < "$FILENAME" > /tmp/playlist.ypl.t
		mv /tmp/playlist.ypl.t "$FILENAME"
		if [ $[current - 2] -le 1 ]; then
			echo TOP
		fi
		
	elif [ "$2" == "reset" ]; then
		reset=1
	else 
		#echo current
		count=0
		while read -r -a line
		do
			if [ $count == $[current - 1] ]; then
				echo $line
				break;
			fi
			count=$[count + 1]
		done < "$FILENAME"
	fi
	if [ $reset == 1 ]; then
		while read line
		do 
			case "$line" in \#\#*) echo $line; continue ;; esac
			echo ${line//#/}
		done < "$FILENAME" > /tmp/playlist.ypl.t
		mv /tmp/playlist.ypl.t "$FILENAME"
		#sed -i -e 's/#//g' $FILENAME 
	fi
else
	echo $1: Playlist does not exist.
fi
