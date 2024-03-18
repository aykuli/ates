# frozen_string_literal: true

# uuid generated in seeds for dev purpose to use them in other services
admin = User.find_or_initialize_by(email: 'admin@a.ru', public_uid: 'b973d192-5085-4a4f-86a8-3ab15e8db223')
admin.update!(password: 'admin123', password_confirmation: 'admin123', admin: true)
p0 = User.find_or_initialize_by(email: 'popug0@a.ru',   public_uid: 'd5a21894-854b-4b76-bf67-e633919c18cd')
p0.update!(password: 'password123', password_confirmation: 'password123')
p1 = User.find_or_initialize_by(email: 'popug1@a.ru',   public_uid: '6cca3aec-c6f5-4276-9d60-3776b05f9766')
p1.update!(password: 'password123', password_confirmation: 'password123')
p2 = User.find_or_initialize_by(email: 'popug2@a.ru', public_uid:  '58f98c1f-8508-48bc-a44b-aacf06d3a79b')
p2.update!(password: 'password123', password_confirmation: 'password123')
p3 = User.find_or_initialize_by(email: 'popug3@a.ru', public_uid:  '3f0d15bb-ee13-4974-b614-b34c023f00e1')
p3.update!(password: 'password123', password_confirmation: 'password123')
p4 = User.find_or_initialize_by(email: 'popug4@a.ru', public_uid:  '42b5f842-3775-474f-96a0-1c4c445aa370')
p4.update!(password: 'password123', password_confirmation: 'password123')

Doorkeeper::Application.find_or_create_by!(name: 'Tasks',   redirect_uri: 'http://localhost:3001/auth/ates/callback')
Doorkeeper::Application.find_or_create_by!(name: 'Billing', redirect_uri: 'http://localhost:3002/auth/ates/callback')
Doorkeeper::Application.find_or_create_by!(name: 'Analytics', redirect_uri: 'http://localhost:3003/auth/ates/callback')
