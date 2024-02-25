# README

**POST localhost:3001/oauth/authorize**

```shell
curl --location 'http://localhost:3001/oauth/token' \
--header 'Content-Type: application/json' \
--data-raw '{
"email":"admin@a.ru",
"password": "admin123",
"grant_type": "password",
"client_id": "JaaKaaBIxM9Dps-5r-77fsqJqfGpZjvlNF1vMxq4LMc",
"client_secret":"_2ovTY7oyJ9Q3Rn1_M82vcvu9Z5Cvt8rwHN_NRp23hg"
}'
```

## Sources

1 [http://railscasts.com/episodes/353-oauth-with-doorkeeper](http://railscasts.com/episodes/353-oauth-with-doorkeeper)