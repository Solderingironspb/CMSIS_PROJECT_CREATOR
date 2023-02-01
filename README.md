# CMSIS_PROJECT_CREATOR
## Скрипты для создания нового проекта под CMSIS без CubeMX
![Снимок](https://user-images.githubusercontent.com/68805120/215838136-b42ab71d-347e-44ae-a406-ae4ceee3a98c.PNG)
### *Для тех, кому надоело каждый раз собирать новый проект под CMSIS при помощи CubeMX.*

Пока удалишь все ненужные файлы, соберешь драйвера CMSIS в одну папку, очистишь main.c и main.h, пропишешь путь к папкам, уберешь флаг USE_HAL_DRIVER.

Согласитесь, это пустая трата времени.

Можно создать один раз чистый проект, настроить его, а потом просто копировать, меняя имя проекта.

Это я и сделал, только кроме изменения названия папки, нужно еще заменять название проекта в файлах, а также изменить название одного файла с расширением .ioc на название нового проекта.

На скорую руку были написаны скрипты (спасибо коллеге сисадмину, т.к. я в Windows Powersheell не особо волоку). 

Кому понравится и идею поймет - может и подредактировать/оптимизировать под себя. 

### Как пользоваться(пример на stm32f103C6T6): 

1) На диске C:\\ создаем папку CMSIS. В ней будут папки с названием микроконтроллеров. В папку с нужным МК закидываем проект, сделанный под себя. Имя проекта "Clean_project"

![Снимок2](https://user-images.githubusercontent.com/68805120/215849187-ca2f7b47-125a-4b5b-9533-0b20988c51be.PNG)

2) Здесь у нас будут лежать 2 скрипта. Открываем .bat файл с именем stm32f103C6T6_new_project.bat от имени администратора. В появившемся окне вводим название нового проекта и жмем Enter

![Снимок5](https://user-images.githubusercontent.com/68805120/215848881-fba6bdd6-925f-458c-99ac-f54f4eec6e4d.PNG)


3) Скрипт начнет собирать новый проект с введенным именем.

![Снимок6](https://user-images.githubusercontent.com/68805120/215848988-2d458c5c-7c62-4dcf-b800-9986187f90b9.PNG)

4) Появится папка с новым проектом.

![Снимок7](https://user-images.githubusercontent.com/68805120/215849390-39326916-002b-4d24-b68d-a9ef9fa4840e.PNG)

![Снимок8](https://user-images.githubusercontent.com/68805120/215849428-44f9ee26-3358-4171-84bd-30c37697529c.PNG)

P.S. В скриптах гвоздями прибиты путь и названия файлов, поэтому при создании новых папок, нужно скрипт править.

# Как я создаю читый проект(на примере STM32F407VGTx):
1) Открываю CubeMX. Выбираю нужный мне МК.

![1](https://user-images.githubusercontent.com/68805120/216049265-3b4b8bdc-6c5f-4bcb-b387-8cc1555bb355.PNG)

2) Ничего там не настраиваю. Топаю сразу же в Project Manager. Там пишу название "Clean_project". Размер стека и кучи можете поправить, можете оставить по-умлочанию. Тулчейн CubeIDE(для универсальности).

![2](https://user-images.githubusercontent.com/68805120/216049846-a4e0bafb-39ce-416e-b4f2-43174749b66c.PNG)

3) Генерируем и открываем папку.

![3](https://user-images.githubusercontent.com/68805120/216050276-7851e296-54d1-4c31-ae19-32b7dd64e572.PNG)

4) Заходим в Clean_project\Drivers. Удаляем папку "STM32F4xx_HAL_Driver". А в папке CMSIS все файлы соберем в корень этой папки.

![4](https://user-images.githubusercontent.com/68805120/216050983-0da56e92-483d-4831-9652-5b57556f9240.PNG)

5) Теперь в Clean_project\Core\Inc. Удалим все лишнее. Оставив только main.h, с нужными нам строками под CMSIS

![5](https://user-images.githubusercontent.com/68805120/216051817-cfe86001-d37e-459f-aee9-77a94447d9a7.PNG)

6) Настала очередь Clean_project\Core\Src. Удаляем файлы, связанные с HAL, а main.c опять правим под CMSIS.

![6](https://user-images.githubusercontent.com/68805120/216052655-5f1a688b-88ae-477e-b774-9b23cc07383e.PNG)

7)Теперь откроем проект через CubeIDE, открыв файл Clean_project\.project . В свойствах проекта сделаем некоторые изменения и сохраним проект.

![7](https://user-images.githubusercontent.com/68805120/216053505-292fea1e-d2c6-49d6-a115-554863bb8ab1.PNG)

![8](https://user-images.githubusercontent.com/68805120/216053855-115812a8-5bda-430b-9385-4f76c1fd3063.PNG)

![9](https://user-images.githubusercontent.com/68805120/216054607-f02317f4-2173-4602-9acb-c308ba1adf81.PNG)

Если все сделали правильно, никаких ошибок быть не должно. Теперь закрываем CubeIDE.

8) Переходим в папку с проектом и удаляем создавшуюся папку .settings
![10](https://user-images.githubusercontent.com/68805120/216055007-621e08fc-eced-4d58-93ae-3e0700c4fb7f.PNG)

9)Шаблон чистого проекта готов. Теперь можете его загрузить в папку C:\CMSIS\stm32f407VGT6 . 

![11](https://user-images.githubusercontent.com/68805120/216055805-11b1fadf-2b39-4e04-aed1-953aafd2cacd.PNG)

10)Теперь просто копируете 2 файлика скрипта и правите их под себя.

![12](https://user-images.githubusercontent.com/68805120/216056532-ebc3b89c-fd55-42ac-9764-99d0ffb9dc7c.PNG)

![13](https://user-images.githubusercontent.com/68805120/216056958-92910a0b-2bc1-45df-8073-76eaabbe7ba0.PNG)

![14](https://user-images.githubusercontent.com/68805120/216057458-45f9d3b6-239f-497e-b97b-4cd4a26be38d.PNG)

11)Все. Запускаете stm32f407VGT6_new_project.bat от имени администратора и создаете копию проекта, но с новым именем. Можете еще ярлык создать, а в нем сделать команду, чтоб от имени администратора всегда открывал файлик.

![15](https://user-images.githubusercontent.com/68805120/216058233-29b0ef22-b435-473e-bb60-26c34b5cd15a.PNG)

Вот и все)

![16](https://user-images.githubusercontent.com/68805120/216058766-e8880808-ff1a-404c-95f9-6db5dadd5949.PNG)

![17](https://user-images.githubusercontent.com/68805120/216058805-152a25ff-667a-4d19-94c4-54eabf2135fa.PNG)

![18](https://user-images.githubusercontent.com/68805120/216058840-040129d9-54d1-4715-a8ba-39c519744447.PNG)


