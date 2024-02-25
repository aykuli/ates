admin = User.find_or_initialize_by(email:'admin@a.ru')
admin.update!(password:'admin123',password_confirmation:'admin123', admin: true)
p0    = User.find_or_initialize_by(email:'popug0@a.ru')
p0.update!(password:'password123',password_confirmation:'password123')
p1    = User.find_or_initialize_by(email:'popug1@a.ru')
p1.update!(password:'password123',password_confirmation:'password123')

app0= Doorkeeper::Application.find_or_create_by(name:"LoginFront", redirect_uri:"http://localhost:8080")
p app0
app1=Doorkeeper::Application.find_or_create_by!(name:"Test_1", redirect_uri:"http://localhost:8081")
p app1

