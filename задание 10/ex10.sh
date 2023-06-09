#! /bin/bash
#Пример запуска: bash ex10.sh ip.txt ipFile.csv macFile.csv domFile.csv
InFile=$1 # Присваиваем переменным значения входных аргументов (аргумент - $1 в примере выше это ip.txt)
ipFile=$2  # В примере выше это ipFile.csv
macFile=$3 #аналогично два других элемента
domFile=$4 #

echo "№;IP-Address;Count" > $ipFile # Вставляем названия столбцов в файлы
echo "№;Mac-Address;Count" > $macFile #
echo "№;Domain name;Count" > $domFile #

declare -A ip # Объявляем словарь
while read str #Читаем файл построчно, за одну итерацию цикла считывается 1 строка и помещается в переменную str
do
# считанные строки содержат ip-адреса, чтобы посчитать количество одинаковых найденных адресов мы используем словарь. словарь содержит пары [ключ]=значение Ключом делаем ip-адрес, а значением - количество вхождений именно этого адреса в файле 
if [ ${ip[$str]+_} ] # этой строкой мы проверяем есть ли в словаре текущий адрес
then 
ip[$str]=$((${ip[$str]}+1)) # Если есть мы увеличиваем значение соотвествующего адреса
else 
ip+=( [$str]=1 ) #если такого нет - добавляем в словарь запись (например [192.168.1.0]=1)
fi
done < <(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $InFile) # эта строка завершает чтение файла (в моем случае ip.txt). конструкция < <(grep....) указывает на то, что строки будут считываться из результата выполнения команды grep... Команда grep -оЕ находит все совпадения по регулярному выражению(что такое регулярное выражение лучше загуглить)
num=0 #эта переменная счетчик с ее помощью мы выводим в файл-отчет по ip-адресам порядковый номер записи
for i in ${!ip[@]} # в цикле мы проходим все ключи словаря (то есть в нашем случае в переменную i записываются адреса); ${!ip[@]}: ! - указывает что обращаемся к ключам, @ - означает что нас интересуют все записи словаря
do
((num++)) #на каждой записи значение счетчика увыеличивается на единицу
echo "$num;$i;${ip[$i]}" >> $ipFile #с помощью этой команды мы записываем порядковый номер адрес и число его вхождений в файл отчет 
done
#  та же самая процедура для мак-адресов и доменных имен, только разные регулярные выражения
declare -A mac #
while read str
do
str=${str,,} # Числа в 16-ричной системе счисления могут быть заглавными или строчными буквами, поэтому переводим все в нижний регистр, чтобы проще было считать число найденных адресов
if [ ${mac[$str]+_} ]
then 
mac[$str]=$((${mac[$str]}+1))
else
mac+=( [$str]=1 )
fi
done < <(grep -oE '[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}' $InFile) #дословно эта регулярка говорит следующее: найди 2 символа которые могут быть цифрой от 0 до 9, буквой от A до F либо в верхнем либо в нижнем регистре. После этих двух символов двоекточие и всё по новой 
num=0
for i in ${!mac[@]}
do
((num++))
echo "$num;$i;${mac[$i]}" >> $macFile # Запись в файл отчет по мак адресам
done

declare -A dom #
while read str
do
str=${str,,}
if [ ${dom[$str]+_} ]
then 
dom[$str]=$((${dom[$str]}+1))
else
dom+=( [$str]=1 )
fi
done < <(grep -oE '[A-Za-z]{1,61}\.[A-Za-z]{1,126}\.[A-Za-z]{1,63}' $InFile) # тут ищем от 1 до 61 буквы в любом регистре потом точку и так далее. цифры взяты из гугла - это ограничения длины доменного имени
num=0
for i in ${!dom[@]}
do
((num++))
echo "$num;$i;${dom[$i]}" >> $domFile #Запись в отчет по доменным именам
done
