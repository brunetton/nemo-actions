# Some [more or less custom] Nemo actions

![](screenshots/mp3_convert.png) ![](screenshots/sound_extract.png)


  * **extract_sound** : use ffmpeg to extract sound from video, and create a sound file in the same dir (with corresponding extension)
  * **convert_to_mp3-*** : use lame to convert file to mp3, and create a sound file in the same dir (with corresponding extension). No check is done on the file format (must be wav)

## TODO

  * catch errors and use Zenity to pass error messages to user
