[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/4FFwu1Be)
## Основное задание

На основе шаблона приложения необходимо добавить: 

При старте приложения проверять авторизацию, если есть токен открывать экран со список строк, в случае если токена нет открывать экран авторизации.
Авторизацию: получтиь данные из полей ввода и при нажатии на кнопку "войти" отправить данные на сервер, в случае неуспешной авторизации показать попап с ошибкой, в случае успешной сохрнаить токен. 
Получение данных + кэширование: При запуске экрана проверить наличие данных в кэш, если данные есть отобразать их в таблице на экране, если данных нет, загрузить их с сервера, сохранить в кэш и отобразить на экране

## Дополнительное задание

Реализовать валидацию (проверку на корректность данных от пользователя) на форме авторизации.
Реализовать постраничную подгрузку строк при скролле таблицы

## Как работать с сервером

Сервер это приложение на Swift, достаточно просто запустить его в xcode и он начнет работать по адресу http://127.0.0.1:8080.
Доступно два url:

**http://127.0.0.1:8080/auth/login** - авторизация. Для авторизацуии необходимо передать post запрос с json телом:

```json
{
    "email": "johndown@exmample.com",
    "password": "1234567"
}
```

Авторизация доступна только указанным выше данным.

**http://127.0.0.1:8080/rows/1** получение строк для отображения и кэширования. Последняя часть пути это номер запрашиваемой страницы. Каждая страница представляет из себя json вида:

```json
[
    {
        "id": 0,
        "text": "Mollit mollit consequat consequat ut ut ipsum consequat nisi eu exercitation sit ex. Dolore elit quis non velit dolor aute nisi elit ut anim proident. Dolore amet mollit commodo quis. Eiusmod in ad ut quis amet nulla id elit. Deserunt laborum nisi laborum voluptate consectetur minim excepteur."
    },
    {
        "id": 1,
        "text": "Sint quis qui culpa elit aliqua mollit nostrud occaecat enim qui excepteur sunt dolore qui. Incididunt fugiat consectetur consequat quis exercitation. Esse laboris non aute proident magna Lorem dolor. Ut id adipisicing labore velit tempor officia. Ad labore consectetur incididunt velit pariatur do."
    }
]
```

Это массив объектов.

Для доступа к этим данным нужно передавать токен полученный при авторизации в заголовке "authorization".

## Критерии оценки

* Проект запускается;
* Основное задание выполнено частично;
* Основное задание выполнено полностью;
* Дополнительное задание выполнено полностью;
* Отсутствие ошибок и предупреждений в коде;
* Обработаны все негативные сценарии нет сети, нет ответа от сервера и тд, не файла;
* Не используется Unwrap в коде;
* Однородное форматирование кода;
* Понятный нейминг сущностей в коде;
* Выбраны верные хранилища для каждого типа данных;