# magick -list font
# SVG requires for potrace
# apt-get install potrace

# banner.jpg (500x300, blue)
magick -size 500x300 xc:"#3498db" -gravity center -pointsize 36 -fill white -font DejaVu-Sans -annotate +0+0 "banner.jpg" banner.jpg

# icon.svg (350x350, purple)
# magick -size 350x350 xc:"#9b59b6" -gravity center -pointsize 28 -fill white -font DejaVu-Sans -annotate +0+0 "icon.svg" icon.svg

# logo.png (400x400, green)
magick -size 400x400 xc:"#2ecc71" -gravity center -pointsize 32 -fill white -font DejaVu-Sans -annotate +0+0 "logo.png" logo.png

# test1.jpg (450x600, orange)
magick -size 450x600 xc:"#e67e22" -gravity center -pointsize 34 -fill white -font DejaVu-Sans -annotate +0+0 "test1.jpg" test1.jpg

# test2.jpeg (550x700, red)
magick -size 550x700 xc:"#e74c3c" -gravity center -pointsize 38 -fill white -font DejaVu-Sans -annotate +0+0 "test2.jpeg" test2.jpeg

# test3.png (300x400, turquoise)
magick -size 300x400 xc:"#1abc9c" -gravity center -pointsize 26 -fill white -font DejaVu-Sans -annotate +0+0 "test3.png" test3.png

# test4.gif (480x650, dark blue)
magick -size 480x650 xc:"#2c3e50" -gravity center -pointsize 36 -fill white -font DejaVu-Sans -annotate +0+0 "test4.gif" test4.gif

# test5.svg (420x520, pink)
# magick -size 420x520 xc:"#e91e63" -gravity center -pointsize 32 -fill white -font DejaVu-Sans -annotate +0+0 "test5.svg" test5.svg

# test6.webp (600x800, purple-blue)
magick -size 600x800 xc:"#673ab7" -gravity center -pointsize 42 -fill white -font DejaVu-Sans -annotate +0+0 "test6.webp" test6.webp
