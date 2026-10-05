# Subject Deletion Deadlock Lab

Окремий Spring Boot стенд для моделювання deadlock під час видалення суб'єктів. Тут зібрані FK-зв'язки, порядок `DELETE`, індекси та гарячі місця, які потрібні для дослідження блокувань.

Проект лежить у `D:\home\Learn\gp-diit`.

Потрібна Java 17+. Скрипти автоматично виставляють JAVA_HOME на локальний JDK 17, якщо він встановлений у C:\Java\jdk-17.0.0.1.

## 1. Карта Запусків

У стенда є 7 варіантів запуску:

| N | Варіант | Профіль | Для чого |
| --- | --- | --- | --- |
| 1 | H2 файлова БД | `h2` | швидко перевірити UI/API без Docker |
| 2 | PostgreSQL у Docker | `postgresql` | ізольований PostgreSQL-експеримент |
| 3 | SQL Server у Docker | `mssql` | основний рекомендований сценарій для deadlock |
| 4 | Oracle у Docker | `oracle` | ізольований Oracle-експеримент |
| 5 | PostgreSQL real/test server | `postgresql-real` | перевірка на реальному тестовому PostgreSQL |
| 6 | SQL Server real/test server | `mssql-real` | перевірка на реальному тестовому SQL Server |
| 7 | Oracle real/test server | `oracle-real` | перевірка на реальному тестовому Oracle |

Порядок роботи краще такий:

1. Почати з **SQL Server у Docker**.
2. Перевірити сценарій через Web UI.
3. Повторити на PostgreSQL/Oracle Docker, якщо потрібно порівняти СУБД.
4. Лише після цього переходити до `*-real` профілів.

## 2. Запуск Через `.bat` Без PowerShell

Найпростіший спосіб запуску — подвійний клік по потрібному `.bat` у корені проекту або запуск з `cmd`.

Основні варіанти:

```cmd
run-h2.bat
run-postgresql-docker.bat
run-mssql-docker.bat
run-oracle-docker.bat
run-postgresql-real.bat
run-mssql-real.bat
run-oracle-real.bat
```

Запуск з IDEA через Maven:

1. Відкрити Maven tool window.
2. Увімкнути один із profiles: `run-h2`, `run-postgresql`, `run-mssql`, `run-oracle`, `run-postgresql-real`, `run-mssql-real`, `run-oracle-real`.
3. Запустити goal `spring-boot:run`.

Те саме з командного рядка:

```cmd
mvn -Prun-h2 spring-boot:run
mvn -Prun-mssql spring-boot:run
```

Службові дії:

```cmd
build.bat
reset-h2.bat
bootstrap-real-databases.bat
```

`run-mssql-docker.bat` — рекомендований перший запуск для deadlock-дослідження. Він сам піднімає контейнер SQL Server, створює БД `deadlock_lab`, запускає застосунок; UI буде доступний на:

```text
http://localhost:8080/
```
## 3. Рекомендований Перший Запуск: SQL Server У Docker

Це основний сценарій для дослідження deadlock: БД ізольована, її можна безпечно пересоздавати, ламати індекси й повторювати експерименти.

Запусти через `.bat`:

```cmd
cd /d D:\home\Learn\gp-diit
run-mssql-docker.bat
```

Скрипт робить усе послідовно:

1. Підіймає контейнер `mssql`.
2. Чекає, поки SQL Server готовий приймати підключення.
3. Створює БД `deadlock_lab`, якщо її ще немає.
4. Запускає застосунок з профілем `mssql`.
5. Flyway автоматично створює таблиці та індекси.

Після старту відкрий:

```text
http://localhost:8080/
```

## 4. Робота Через Web UI

На сторінці `http://localhost:8080/` є всі основні дії без Postman:

- створення тестових даних;
- видалення одного суб'єкта;
- паралельне видалення кількох суб'єктів;
- режим `LEGACY` або `DIRECT_LEDGERS`;
- `lock=true/false`;
- пауза після конкретного delete-step;
- статистика по таблицях;
- останній результат операції та помилки.

Типовий ручний сценарій:

1. У блоці `Seed Data` поставити, наприклад, `Subjects = 20`, `Fanout = 20`, `Reset = true`.
   (Fanout тут означає “скільки залежних наборів даних створити для одного клієнта/subject”.)
2. Натиснути `Create Test Data`.
3. Скопійовані `subjectIds` автоматично з'являться в `Parallel Delete`.
4. Встановити `Threads = 5` або більше.
5. Натиснути `Run Parallel Delete`.
6. Дивитися `Last Operation`, `Raw Output` і `Database Snapshot`.

## 5. Усі Варіанти Запуску

### 5.1 H2: Швидка Перевірка Без Docker

H2 не дуже корисний для реального deadlock-дослідження, але швидко перевіряє UI та порядок delete.

```powershell
cd D:\home\Learn\gp-diit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile h2
```

Після старту:

```text
http://localhost:8080/
```

H2 console:

```text
http://localhost:8080/h2-console
```

JDBC URL:

```text
jdbc:h2:file:./data/deadlock-lab;MODE=MSSQLServer;DATABASE_TO_UPPER=false;NON_KEYWORDS=access_keys,org_positions;LOCK_TIMEOUT=10000
```

### 5.2 PostgreSQL У Docker

```bat
cd D:\home\Learn\gp-diit
run-postgresql-docker.bat
```

PostgreSQL контейнер сам створює БД `deadlock_lab` і користувача `deadlock_lab/deadlock_lab`. Docker-профіль використовує порт `15432`, щоб не конфліктувати з локальним або реальним PostgreSQL на `5432`, і запускається з `UTC`, щоб PostgreSQL не падав на Windows/JVM timezone `Europe/Kiev`.

### 5.3 SQL Server У Docker

Короткий рекомендований варіант:

```powershell
cd D:\home\Learn\gp-diit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-mssql-docker.ps1
```

Те саме вручну по кроках:

```powershell
cd D:\home\Learn\gp-diit
docker compose up -d mssql
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-docker-databases.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile mssql
```

SQL Server контейнер не створює application database автоматично, тому bootstrap спочатку чекає готовності сервера і створює БД `deadlock_lab`.

### 5.4 Oracle У Docker

Простіше запускати через bat:

```bat
cd D:\home\Learn\gp-diit
run-oracle-docker.bat
```

Docker-варіант використовує Oracle Free 23 (`gvenzl/oracle-free:23-slim`). Для Oracle у проєкті підключений окремий Flyway database module, тому помилки типу `Unsupported Database: Oracle 23.0` бути не повинно.

Oracle image створює користувача `deadlock_lab/deadlock_lab`; підключення йде до service name `FREEPDB1`.

### 5.5 Реальні Тестові Сервери

Цей режим потрібен тільки після Docker-експериментів, коли треба перевірити поведінку на реальних тестових інстансах. Існуючі схеми `dev1`, `tester3`, `ORESCHENKO1` для таблиць стенда не використовуються.

| СУБД | Ізольована область | Профіль |
| --- | --- | --- |
| PostgreSQL `127.0.0.1:5432/ibank` | schema `deadlock_lab` | `postgresql-real` |
| SQL Server `192.168.88.91:1433` | database `deadlock_lab`, schema `lab`, user `deadlock_lab_user` | `mssql-real` |
| Oracle `192.168.88.91:1521/orclpdb` | user/schema `DEADLOCK_LAB` | `oracle-real` |

Спочатку створити окремі області та накотити Flyway:

```powershell
cd D:\home\Learn\gp-diit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-real-databases.ps1 -Target all -Migrate -ConfirmRealServers
```

Після цього запускати потрібний профіль:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile postgresql-real
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile mssql-real
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile oracle-real
```

`-ConfirmRealServers` навмисно обов'язковий, щоб випадково не підключитися до shared-серверів.

## 6. API Якщо Все Ж Таки Потрібен HTTP

UI викликає ці endpoint-и. Блок `Table Viewer` показує перші рядки вибраної таблиці з whitelist-списку статистики; `limit` обмежено до 500 рядків.

```http
POST /lab/seed?subjects=10&fanout=5&reset=true
GET /lab/stats
GET /lab/relationships
GET /lab/table/{table}?limit=50
DELETE /lab/subjects/{subjectId}?mode=LEGACY
POST /lab/delete-parallel    # допоміжний backend endpoint, UI для масового видалення його не використовує
```

Масове видалення у Web UI навмисно реалізоване як багато окремих HTTP-запитів:

```http
DELETE /lab/subjects/1001?mode=LEGACY
DELETE /lab/subjects/1002?mode=LEGACY
DELETE /lab/subjects/1003?mode=LEGACY
```

Поле `Threads` у UI обмежує, скільки таких одиночних запитів браузер тримає одночасно. Це ближче до реальної проблеми: бекенд отримує незалежні одиночні delete-запити, а не один batch-виклик.

Допоміжний backend endpoint `/lab/delete-parallel` залишений для технічних експериментів, але основний UI його не викликає.

Режими:

- `LEGACY` — ближче до старого коду, включно з self-subquery для `ledger_accounts`;
- `DIRECT_LEDGERS` — фінальний delete з `ledger_accounts` напряму по `subject_id`.

Додаткові параметри delete:

```http
pauseAfterStep=ledger_accounts:user_ledgers&pauseMs=5000&lock=true
```

Цікаві кроки для пауз:

- `ledger_accounts:user_ledgers`
- `user_accounts:user_ledgers`
- `user_accounts:key_events`
- `deleteLoans:loan_contracts`
- `subjectTable:subjects`

### 6.1 MSSQL Stress-Сценарій

Якщо паралельне видалення проходить без deadlock, найчастіше причина проста: мало рядків, транзакції завершуються занадто швидко і майже не перетинаються.

У Web UI є кнопка `MS deadlock preset`. Вона виставляє такі параметри:

- seed: `subjects=24`, `fanout=120`, `reset=true`;
- parallel delete: `threads=12`;
- mode: `LEGACY`;
- lock: `false`;
- pause: `pauseAfterStep=ledger_accounts:user_ledgers`, `pauseMs=3000`.

Порядок перевірки:

1. Натиснути `MS deadlock preset`.
2. Натиснути `Create Test Data`.
3. Натиснути `Run Parallel Delete`.
4. Якщо deadlock не з'явився, збільшити `fanout` до `200` або `threads` до `16`.

Якщо навіть на великому fanout deadlock не відтворюється, це теж важливий результат: індекси та однаковий порядок видалення можуть прибрати головну причину взаємних блокувань. Для дипломної роботи це можна показати як порівняння: малий набір, великий набір, великий набір з паузою, великий набір із серіалізацією через lock.

## 7. Що Змодельовано

Коренева таблиця:

- `subjects`

Основні групи залежностей:

- agents: `partner_agents`, `agent_cards`;
- users/keys: `user_accounts`, `access_keys`, `key_events`, `key_profiles`, `permission_events`, `mobile_links`, `user_login_attempts`, `key_requests`, `hardware_tokens`;
- ledgers/cards: `ledger_accounts`, `primary_ledgers`, `ledger_operations`, `ledger_snapshots`, `user_ledgers`, `payment_plastics`, `plastic_limits`, `plastic_snapshots`, `plastic_operations`, `plastic_ledgers`;
- loans: `loan_contracts`, `loan_schedules`, `loan_debt_snapshots`, `loan_operations`, `loan_rate_events`, `loan_segments`;
- savings: `savings_contracts`, `savings_ledgers`, `savings_operations`, `savings_rate_events`;
- documents: `inbox_messages`, `payroll_batches`, `payroll_slips`, `savings_open_requests`, `card_open_requests`, `payment_rule_create_requests`, `payment_rule_stop_requests`, `transfer_requests`, `currency_payment_requests`, `delivery_rejects`, `card_funding_deliveries`, `document_events`, `document_recipients`, `savings_documents`;
- final subject tables: `merchant_sites`, `subject_operation_links`, `network_rules`, `admin_subject_links`, `document_watchers`, `session_windows`, `org_positions`, `budget_items`, `payment_recipients`, `approved_recipients`, `beneficiary_profiles`, `message_links`, `subject_properties`, `corporate_recipients`, `mobile_recipients`, `trusted_payment_caps`, `currency_agents`.

FK зроблені без `ON DELETE CASCADE`, щоб сервіс видаляв усе вручну.

## 8. Індекси

Основні індекси лежать у `V2__indexes.sql` для кожної БД.

Hotspot-індекси:

- `user_ledgers(user_id)`;
- `key_events(key_id)`;
- `ledger_accounts(subject_id)`;
- `loan_contracts(subject_id)`;
- `agent_cards(agent_id)`;
- document tables by `subject_id`;
- ledger child tables by `ledger_id`.

Для експерименту з відсутніми індексами є файл:

```text
docs/drop_hotspot_indexes.sql
```

Запускати його тільки на лабораторній БД.

## 9. Типові Проблеми

### SQL Server 2022 І Flyway

SQL Server 2022 визначається JDBC як `Microsoft SQL Server 16.0`. Старий Flyway 8.5.13 зі Spring Boot 2.7.x його не підтримує і падає з помилкою:

```text
Unsupported Database: Microsoft SQL Server 16.0
```

У `pom.xml` зафіксовано `java.version=17` і `flyway.version=9.22.3`, щоб Flyway підтримував SQL Server 2022. Для SQL Server також підключено окремий модуль `org.flywaydb:flyway-sqlserver`; без нього навіть Flyway 9.x може впасти з `Unsupported Database: Microsoft SQL Server 16.0`.


### Windows Блокує `.ps1`

Якщо бачиш `выполнение сценариев отключено`, запускай скрипти так:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-mssql-docker.ps1
```

Це не змінює системну політику Windows.

### JVM Не Стартує Через Брак Пам'яті

Помилка виглядає так:

```text
There is insufficient memory for the Java Runtime Environment to continue.
Native memory allocation failed
```

Використовуй low-memory скрипти:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-low-memory.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-jar-low-memory.ps1
```

Вони запускають JVM з параметрами:

```text
-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC
```

### H2 Не Стартує Через Flyway Checksum

Помилка виглядає так:

```text
FlywayValidateException: Migration checksum mismatch
Applied to database : ...
Resolved locally    : ...
```

Це означає, що `data/deadlock-lab.mv.db` створена старою версією міграцій. Для локального стенда пересоздай H2:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\reset-local-h2.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-local-low-memory.ps1 -Profile h2
```

Скрипт не видаляє стару БД назавжди, а переносить її у backup `*.bak`.

### MSSQL: Cannot Open Database `deadlock_lab`

Помилка:

```text
Cannot open database "deadlock_lab" requested by the login
```

Причина: застосунок стартував до створення БД або bootstrap не виконався. Найпростіше рішення:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-mssql-docker.ps1
```

## 10. Де Дивитись Код

- `SubjectDeleteService` — порядок видалення і SQL.
- `SeedService` — генерація тестового графа даних.
- `SubjectDeleteController` — HTTP API для UI та експериментів.
- `src/main/resources/static/index.html` — простий фронт.
- `src/main/resources/db/migration/*` — DDL та індекси для кожної БД.









