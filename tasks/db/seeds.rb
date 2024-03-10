# Like all users already signed up with oauth at least once
# For dev use
# public_uid is the same as public_uid in oauth service for dev purpose
User.create!(email: 'admin@a.ru',  public_uid: 'b973d192-5085-4a4f-86a8-3ab15e8db223', admin: true)
User.create!(email: 'popug0@a.ru', public_uid: 'd5a21894-854b-4b76-bf67-e633919c18cd')
User.create!(email: 'popug1@a.ru',  public_uid: '6cca3aec-c6f5-4276-9d60-3776b05f9766')
User.create!(email: 'popug2@a.ru',  public_uid: '58f98c1f-8508-48bc-a44b-aacf06d3a79b')
User.create!(email: 'popug3@a.ru',  public_uid: '3f0d15bb-ee13-4974-b614-b34c023f00e1')
User.create!(email: 'popug4@a.ru',  public_uid: '42b5f842-3775-474f-96a0-1c4c445aa370')
