User.first_or_create!(email:'admin@a.ru',password:'admin123',password_confirmation:'admin123')
User.first_or_create!(email:'p0@a.ru',password:'password',password_confirmation:'password')
User.first_or_create!(email:'p1@a.ru',password:'password',password_confirmation:'password')

Doorkeeper::Application.create!(name:"Test", redirect_uri:"http://localhost:8080")
Doorkeeper::Application.create!(name:"Test_1", redirect_uri:"http://localhost:8081")

