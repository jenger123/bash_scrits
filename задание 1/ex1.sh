#! /bin/bash

#Зайти в папку, содержащую данный скрипт из консоли: cd /home/task1
# Запуск: bash ./test.sh <размер шингла> <путь к файлу, который нужно разбить на шинглы> <имя рабочего файла> <имя файла отчета> <имя файла- словаря исключений>
# Пример запуска(если все файлы в одной папке):   bash ex1.sh 3 input.txt workfile.txt report.txt exclusion.txt
shingle_size=$1  # Передаем первым аргументом размер шингла
input_text=$2   # исходный файл, который нужно разбить на шинглы
work_file=$3    # рабочий файл
out_file=$4     # файл отчет
file_exclusion=$5   # файл-словарь исключений
declare exclusions  #
echo > $out_file    #очищаем и создаем(если нужно) файлы отчета и рабочего файла
echo > $work_file   #
echo "Переменные созданы"
echo "Заполняем словарь исключений из файла"
while read y  # Читаем файл словарь построчно добавляя в массив строки
do
y=${y//\'}
exclusions+=("$y")
done < $file_exclusion
echo "Очищаем текст от ненужных символов и конструкций..."
while read str1 # Читаем исходный файл построчно
do
    str1=${str1,,} # приводим считанную строку к нижнему регистру
    for (( i=0;i<${#exclusions[@]};i++ )) # для каждого исключения из массива исключений
        do
            str1=${str1//${exclusions[$i]}} # убираем все вхождения запрещенных символов
        done
    if [ ${#str1} -ne 0 ] # если обработанная строка не пустая
    then echo -n $str1 >> $work_file # Добавляем в рабочий файл обработанную строку (-n чтобы между вставляемыми строками не было символа переноса строки \n)
    fi
done < $input_text
echo -e '\n'
echo "Делим рабочий файл на шинглы..."

declare -A shingles # инициализируем словарь с шинглами
while read -N $shingle_size str2 # читаем из рабочего файла количество символов, которое указано в переменной $single_size
do
            if [ ${shingles[$str2]+_} ] # проверяем есть ли такой шингл в словаре
            then
            shingles[$str2]=$((${shingles[$str2]}+1)) # Если есть - добавляем единицу к значению по ключу
            else
            shingles+=( [$str2]=1 ) # если нет - добавляем ключ к словарю
            fi
        
done < $work_file

# Записываем результат в файл-отчет

num=1
for i in ${!shingles[@]} # с помощью цикла for проходим все пары ключ - значение в словаре и записываем в файл отчет
do
    echo "$num;$i;${shingles[$i]}" >> $out_file
let 'num+=1'
done
echo -e "Готово!!! \nРабочий файл и файл-отчет заполнены!"
