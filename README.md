# Lines
Это простая игра, написанная в PascalABC.net с использованием GraphABC. 
# Правила игры
Игра проходит на квадратном поле, где генерируюся несклько фишек разного цвета. Игрок может переставлять их двумя кликами ЛКМ. 
Собрав линию из 5 или более фишек одного цвета вдоль осей или по диагонали, игрок получает очки, а фишки исчезают. При каждом ходе на поле появляются ещё 3 фишки. 
Места их появления подсвечиваются полупозрачными кружками. При полном замощении поля фишками игра заканчивается. Цель - набрать как можно больше очков.

# Подключение и использование
Чтобы запустить приложение, скачайте архив [Release.zip](https://github.com/KIrillPal/Lines/blob/main/Release.zip) из корня проекта и запустить в нём файл Lines.exe. 
Открывшееся окно содержит 3 кнопки: уменьшить размер поля, увеличить и запустить игру. 

Управление интуитивно понятно. Если попытаться переместить существующую фишку в место предполагаемого появления новой, то новая фишка появится в любом другом случайном месте. 
По достижении игроком 20% от прошлого рекорда появляется сравнение очков с предыдущим рекордом.
Чем меньше поле, тем сложнее игра. По её окончании появляется окно с результатом игрока. Там отображается процент, на который побит рекорд, или процент от рекорда. В зависимости от этого процента можно получить одно из званий:
### 1. Игрок [0%, 33%)
![nocorrect](https://github.com/KIrillPal/Lines/blob/main/images/nocorrect.png)
### 2. Студент [33%, 67%)
![fewcorrect](https://github.com/KIrillPal/Lines/blob/main/images/fewcorrect.png)
### 3. Талант [67%, 100%)
![oncorrect](https://github.com/KIrillPal/Lines/blob/main/images/oncorrect.png)
### 4. Отличник (>=100%)
![allcorrect](https://github.com/KIrillPal/Lines/blob/main/images/allcorrect.png)

Звания ни на что не влияют, но приятно пробовать разные варианты и сразиться сам с собой.
# Структура проекта.
Проект состоит из главного файла Lines.pas. Прокт получает картинки из папки images, а невероятные звуки из папки sounds.
# Замечания
Окно не растягивается. Рекорд не запоминается после закрытия программы. 
# Особенности проекта
Это была, вероятно, последняяя моя работа на паскале. Несмотря на простоту, Lines - моя любимая игрушка из представленных в списке моих игровых проектов.
