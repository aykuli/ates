# Tasks service

Run service

``
rails s -p 3001

bundle exec karafka server
``

## Внедрение новой версии вида события о задаче

1. Добавляю в сервисе задач в таблицу `tasks` столбец `jira_id` (nullable)
2. Добавила в отправляемый объект новое поле `jira_id`
3. Напишу новую схему для событий `task.assigned`
4. В консьюмере (billing service) делаю миграцию, что бсохранять новое нужное? поле из события
5. В консьюмере (billing service) в классе TasksConsumer пишу вариант приема для второй версии событии
6. В продюсере (tasks service) меняю код на отправку второй версии `task.assigned`
7. В консьюмере меняю код на получение второй версии `task.assigned` с сохранением `jira_id`
Если все хорошо, то чистим:
8. В продюсере (tasks service) 1-ую версию `task.assigned`
9. В консьюемере (billing service) 1-ую версию `task.assigned`
