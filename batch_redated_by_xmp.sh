#!/bin/bash
IFS='
'
echo "" > log.txt
find . -type d -mindepth 1| while IFS= read -r dir
do
  echo "start processing $dir"
  find "$dir" -type f -maxdepth 1 -name "*.xmp" | while read -r fullXMPPath
  do
    fullNoExt=${fullXMPPath%.*}
    filenameNoExt=${fullNoExt##*/}

    while IFS= read -r line
    do
      title=$(perl -ne 'print and last if s/.*<photoshop:DateCreated>(.*)<\/photoshop:DateCreated>.*/\1/;' <<<  "$line")
      if [[ "$title" == "" ]]
      then
        continue
      else
        ymd=$(echo "$title"| awk '{ print substr($0,1,4)substr($0,6,2)substr($0,9,2)substr($0,12,2)substr($0,15,2) }')
        find "$dir" -type f -not -name "$filenameNoExt.xmp" -name "$filenameNoExt.*" -maxdepth 1 | while read -r fullImgPath
        do
          if test -f "$fullImgPath"
          then
            echo "touch -t $ymd $fullImgPath" >> log.txt
            touch -t $ymd "$fullImgPath"
          else
            let "fileNotExistCnt=$fileNotExistCnt+1"
            echo "$fullImgPath does not exist" >> log.txt
          fi
        done
      fi
    done < "$fullXMPPath"
  done
  echo "==== Done === "
  sleep 30
done

echo "Number of file not exist errors: $fileNotExistCnt"
echo "Number of file not exist errors: $fileNotExistCnt" >> log.txt
