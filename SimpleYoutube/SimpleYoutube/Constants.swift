//
//  Constants.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/30.
//

import Foundation

let channelID = "UC0C-w0YjGpqDXGB8IHb662A"
let playListID = "UU0C-w0YjGpqDXGB8IHb662A"
let apiKey = "請填入Youtube API Key"

var htmlString = """
<!DOCTYPE html>
<html>
  <body>
    <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
    <div id=\"player\"></div>

    <script>
      // 2. This code loads the IFrame Player API code asynchronously.
      var tag = document.createElement('script');

      tag.src = \"https://www.youtube.com/iframe_api\";
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

      // 3. This function creates an <iframe> (and YouTube player)
      //    after the API code downloads.
      var player;
      function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
          height: '%d',
          width: '%d',
          videoId: '%@',
          events: {
            'onReady': onPlayerReady
          }
        });
      }

      // 4. The API will call this function when the video player is ready.
      function onPlayerReady(event) {
        event.target.playVideo();
      }
    </script>
  </body>
</html>
"""
