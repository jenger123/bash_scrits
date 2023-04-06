#! /bin/bash
srcDir=$1
outfile=$2
Hp=$3
echo "№;Path;FileSize;Mdata;K;H" > $outfile
num=0
for file in `find $srcDir -type f -name "*"`
do
echo $file
#if [[ -s $file &&  "$file" != ^. ]] # Раскомментировать если не хочется видеть скрытые файлы
if [[ -s $file ]]
then
filesize=$(stat -c%s $file)
Mdata=$(date -r $file)
declare -A bytes
while read offset hex char 
do
if [ ${bytes[$hex]+_} ]
    then
        bytes[$hex]=$((${bytes[$hex]}+1))
    else
        bytes+=( [$hex]=1 )
fi
done < <(xxd -c 1 $file)
H=0
uniq_bytes=0
for i in ${!bytes[@]}
do
((uniq_bytes++))
pi=$(echo "${bytes[$i]}/$filesize" | bc -l)
H=$(echo "$H+$pi*l($pi)" | bc -l)
done
H=$(echo "-1*$H" | bc -l )
if (( $(echo "$H > $Hp" | bc -l) ))
then
((num++))
echo "$num;$file;$filesize;$Mdata;$uniq_bytes;$H" >> $outfile
fi
fi
done