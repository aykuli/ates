# Awesome Task Exchange System (aTES) для UberPopug Inc

Таск-трекер для хороших попугаев и их менеджеров.

## Стек

```
pauth - сервис авторизации по oAuth
  |-- Ruby on Rails
  |-- Postgres

tasks - сервис работы с задачами
  |-- Ruby on Rails
  |-- Postgres
  |-- Karafka
```

## Запуск всех 2-х сервисов

1. В папке `pauth` на порту 3000 будет oAuth хостер:

```shell
rails s -p 3000
```

2. В папке `tasks` на порту 3001 запускаю сервис задач:

```shell
rails s -p 3001
```

3. В папке `tasks` запускаю `karafka`

```
bundle exec karafka server
```

### Хочется запомнить

* В `pauth` в сидах создала приложение. id,secret приложения потом кладу в `settings.yml` сервиса `tasks`.
По колбеку `oAuth` потом отправляет токен приложению задач.
* Стратегию `Ates < OmniAuth::Strategies::OAuth2` надо прописать и в oAuth, и в tasks? Надо проверить.

* В `tasks` стратегию не получилось сделать `autoload`, хоть и прописывала в конфига приложения, чтоб в автолоад добавил папочку `lib`, куда я изначально пыталась положить стратегию, как в примерах. Поэтому стратегия лежит прямо рядом в инициализаторах, где определяется `middleware` приложения с `OmniAuth::Builder`

* `client_id` & `client_secret` скопировала из таблицы `oauth_applications` базы данных `pauth` сервиса.

* Топики кафке приписаны в `karafka.rb` роутами конфига.

----------

```shell
Поддержка: Айнур Шауэрман, i@aykuli.ru
```
