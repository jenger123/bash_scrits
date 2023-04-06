#! /bin/bash
#Пример: bash ex16.sh infile.txt mask.txt outfile
#обратное преобразование: bash ex16.sh outfile mask outfile1
#Проверить результат: cat infile и cat outfile1
infile=$1 # Присваиваем переменным значения аргументов
filemask=$2 #
outfile=$3 #
filesize=$(stat -c%s $infile) #Узнаем длину файла маски и входного файла
masksize=$(stat -c%s $filemask) #

zeros='' # 
if [ $filesize -gt $masksize ] # Сравниваем длину файлов дополняем нулями меньший из них
then 
diff=$(($filesize-$masksize)) # Разница в размерах файлов
for (( i=0;i<$diff;i++ )) #
do
zeros+='0' # Добавляем в пустую строку нули, пока их не наберется достаточное количество
done
echo "$(cat $filemask)$zeros" > $filemask # соединяем содержимое короткого файла и строку нулей
else
diff=$(($masksize-$filesize)) # В ветке else вариант когда маска больше файла 
for (( i=0;i<$diff;i++ ))
do
zeros+='0'
done
echo "$(cat $infile)$zeros" > $infile
fi
exec 5< <(xxd -c 1 $infile) # Помещаем в файловые дискрипторы результат команды xxd -c 1 (-с 1 означает 1 байт в колонку)
exec 6< <(xxd -c 1 $filemask) #
rm $outfile # чтобы файлы были одинаковой длины удаляем outfile
while read offset1 hex1 char1 <&5 && read  offset2 hex2 char2  <&6 # читаем два файла одновременно
do
byte3=$(echo "obase=16; $(( $((16#$hex1)) ^ $((16#$hex2)) ))" | bc ) #$((16#$hex1)) - перевод из 16 в 10 систему счисления;  $((16#$hex1)) ^ $((16#$hex2)) )) - XOR - преобразование; $(echo "obase=16; $(( $((16#$hex1)) ^ $((16#$hex2)) ))" | bc ) - перевод в 16-ричную систему
echo -n -e "\x$byte3" >> $outfile # собираем outfile по байту 
done
