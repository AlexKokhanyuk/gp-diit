# Subject Deletion Deadlock Lab

Spring Boot стенд для моделювання deadlock під час видалення сутності з великою кількістю пов'язаних таблиць.

Проект створений для дипломної роботи: він відтворює типову проблему видалення "клієнта" з production-системи, але використовує нейтральні назви таблиць і колонок. Основна мета - дослідити, як порядок DELETE, індекси, розмір транзакції та паралельні запити впливають на блокування у різних СУБД.

## Вимоги

- Java 17.
- Maven 3.8+.
- Docker Desktop, якщо запускаються контейнерні PostgreSQL, SQL Server або Oracle.

Після старту застосунок доступний тут:

```text
http://localhost:8080/
```

## Швидкий Запуск

Перейти в каталог проекту:

```bat
cd /d D:\home\Learn\gp-diit
```

Запустити один з готових сценаріїв:

```bat
run-h2.bat
run-mssql-docker.bat
run-postgresql-docker.bat
run-oracle-docker.bat
```

`H2` не потребує Docker. Інші три сценарії піднімають відповідний контейнер, чекають готовності БД і запускають застосунок з потрібним Spring profile. Структуру таблиць створює Flyway.

## Варіанти Запуску

| Сценарій | Команда | База даних | Призначення |
| --- | --- | --- | --- |
| H2 | `run-h2.bat` | локальна файлова H2 | швидка перевірка UI/API |
| SQL Server Docker | `run-mssql-docker.bat` | `localhost:14333`, база `deadlock_lab` | основний стенд для MS SQL deadlock |
| PostgreSQL Docker | `run-postgresql-docker.bat` | `localhost:15432`, база `deadlock_lab` | перевірка PostgreSQL |
| Oracle Docker | `run-oracle-docker.bat` | `localhost:1521/FREEPDB1`, схема `DEADLOCK_LAB` | перевірка Oracle |
| SQL Server real | `run-mssql-real.bat` | зовнішній SQL Server | запуск на підготовленій реальній БД |
| PostgreSQL real | `run-postgresql-real.bat` | зовнішній PostgreSQL | запуск на підготовленій реальній БД |
| Oracle real | `run-oracle-real.bat` | зовнішній Oracle | запуск на підготовленій реальній БД |

Ті самі режими доступні як Maven profiles, тому їх можна запускати з IDE:

```bat
mvn -Prun-h2 spring-boot:run
mvn -Prun-mssql-docker spring-boot:run
mvn -Prun-postgresql-docker spring-boot:run
mvn -Prun-oracle-docker spring-boot:run
mvn -Prun-mssql-real spring-boot:run
mvn -Prun-postgresql-real spring-boot:run
mvn -Prun-oracle-real spring-boot:run
```

## Web UI

Головна сторінка містить кілька робочих блоків.

**Seed Data** створює тестові дані.

- `Subjects` - кількість головних сутностей.
- `Fanout` - кількість пов'язаних записів на одну головну сутність у кожній дочірній групі.
- `Reset` - очистити поточні дані перед заповненням.
- `Deadlock preset` - встановлює параметри для більш щільного набору даних.

**Single Delete** виконує один запит:

```http
DELETE /lab/subjects/{id}
```

**Parallel Delete** приймає список ID і відправляє з браузера окремий DELETE-запит для кожного ID. Поле `Threads` задає кількість одночасних запитів з фронту.

Цей режим потрібен, щоб моделювати реальну ситуацію: користувач вибирає кілька об'єктів, а фронт відправляє кілька незалежних видалень майже одночасно.

**Database Snapshot** показує кількість основних сутностей, загальну кількість рядків і діапазон ID.

**Table Viewer** дозволяє переглянути вміст будь-якої таблиці зі стенду.

**Last Operation** показує результат останнього запуску.

**Raw Output** містить повну JSON-відповідь останньої операції.

## API

Створити тестові дані:

```http
POST /lab/seed?subjects=10&fanout=5&reset=true
```

Видалити одну сутність:

```http
DELETE /lab/subjects/{subjectId}
```

Отримати статистику:

```http
GET /lab/stats
```

Переглянути таблицю:

```http
GET /lab/table/{tableName}?limit=50
```

Отримати опис зв'язків:

```http
GET /lab/relationships
```

Технічний endpoint для серверного паралельного запуску також залишений у проекті:

```http
POST /lab/delete-parallel
```

У звичайному UI-сценарії він не використовується: фронт відправляє окремі DELETE-запити самостійно.

## Модель Даних

Головна таблиця:

```text
subjects
```

Основні групи залежностей:

- прямі дочірні таблиці головної сутності;
- користувачі та їхні дочірні записи;
- ключі та історія ключів;
- рахунки, ліміти, операції та журнали;
- документи та супутні таблиці;
- таблиці з підзапитами, які спеціально залишені для моделювання складних DELETE.

Назви таблиць нейтральні. Вони описують роль у моделі, а не копіюють production-схему.

## Міграції

Flyway-міграції розділені за СУБД:

```text
src/main/resources/db/migration/h2
src/main/resources/db/migration/mssql
src/main/resources/db/migration/oracle
src/main/resources/db/migration/postgresql
```

На старті застосунок сам застосовує міграції для активного profile.

## Docker-Бази

Контейнери описані в:

```text
docker-compose.yml
```

Порти:

| СУБД | Порт на хості | Користувач | База/схема |
| --- | ---: | --- | --- |
| PostgreSQL | `15432` | `deadlock_lab` | `deadlock_lab` |
| SQL Server | `14333` | `sa` | `deadlock_lab` |
| Oracle | `1521` | `DEADLOCK_LAB` | `DEADLOCK_LAB` |

PostgreSQL використовує порт `15432`, щоб не конфліктувати з локальним PostgreSQL на стандартному `5432`.

## Реальні Бази

Для запуску на зовнішніх БД використовуються профілі:

```text
mssql-real
postgresql-real
oracle-real
```

Параметри підключення лежать у відповідних `application-*.yml`. Перед запуском на реальній БД потрібно мати окрему тестову базу або схему для цього стенду. Production-схеми використовувати не потрібно.

## Корисні Команди

Зібрати проект:

```bat
build.bat
```

Скинути локальну H2-базу:

```bat
reset-h2.bat
```

Запустити без `.bat`:

```bat
mvn -Prun-h2 spring-boot:run
```

## Структура Коду

Основні класи:

```text
src/main/java/edu/diploma/deadlocklab/web/SubjectDeleteController.java
src/main/java/edu/diploma/deadlocklab/delete/SubjectDeleteService.java
src/main/java/edu/diploma/deadlocklab/seed/SeedService.java
src/main/java/edu/diploma/deadlocklab/stats/StatsService.java
src/main/java/edu/diploma/deadlocklab/bootstrap/DockerDatabaseBootstrap.java
```

Фронт:

```text
src/main/resources/static/index.html
```

Конфігурації:

```text
src/main/resources/application.yml
src/main/resources/application-h2.yml
src/main/resources/application-mssql.yml
src/main/resources/application-postgresql.yml
src/main/resources/application-oracle.yml
```

## Призначення Стенду

Стенд дозволяє перевіряти:

- які таблиці створюють найбільший ризик блокувань;
- як впливають відсутні або неправильні індекси;
- як змінюється поведінка при паралельному видаленні;
- чим відрізняються H2, PostgreSQL, SQL Server і Oracle;
- чи зменшує проблему впорядкування DELETE-запитів;
- чи потрібна черга, окремий endpoint або інша стратегія серіалізації видалень.

H2 підходить для швидкої функціональної перевірки. Для реального дослідження deadlock потрібно запускати SQL Server, PostgreSQL або Oracle.
