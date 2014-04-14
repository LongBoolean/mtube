mtube
=====

A simple Bash script for playing Youtube videos using mplayer or vlc.

Place "mtube.sh" and "ytube_playlist.sh" in your bin/ in your home directory to run the script from anywhere.

Example Input:

    mtube.sh loop 	//play multiple videos one after another

    mtube.sh best playlist example_playlist.ypl		//play a user created playlist with the best availible quality

    mtube.sh update	//update youtube-dl

Update: Having issues with mplayer and youtube-dl now using vlc by default. To change this back modify the line ' useVLC="true" ' to read ' useVLC="false" '. For now mplayer and youtube-dl are still required for the script to run without errors.


Required packages:
    
    youtube-dl
    
    mplayer

    vlc
    
    curl

Note:
    youtube-dl will periodically require updating for video playback to function. Be sure to read youtube-dl documentation for more details (man youtube-dl)
    Be aware that since original development of this script changes made to youtube-dl and/or mplayer could result in the script not working properly.  
