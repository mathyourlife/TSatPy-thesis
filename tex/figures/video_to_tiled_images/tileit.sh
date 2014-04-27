#!/bin/bash


VIDEO="p-controller-2.avi"
ffmpeg -i $VIDEO -f image2 image-%03d.jpg

# gimp -f -i -b '(batch-tileimages "'$fileout'" '$n' '$m' '$padding'
#   '$gimpfilltype' '$roundedcornerradius' '$featherselectionradius'
#   '$drawbox' '$drawgrid' '$gridlinewidth' '$dpi' '$jpgqual'
#   "'$fileglobpattern'")' -b '(gimp-quit 0)'
gimp -i -b '(batch-tileimages "new.jpg" 4 5 4 1 10 10 0 1 1 600 0.98 "image*.jpg")' -b '(gimp-quit 0)'

