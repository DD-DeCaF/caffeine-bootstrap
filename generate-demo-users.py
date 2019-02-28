from iam.models import User, db
from iam.app import app, init_app
init_app(app, db)
app.app_context().push()
print("Adding user: demo@demo")
user = User(email="demo@demo")
user.set_password("demo")
db.session.add(user)
for i in range(40):
    print(f"Adding user: demo{i}@demo (password demo)")
    user = User(email=f"demo{i}@demo")
    user.set_password("demo")
    db.session.add(user)
db.session.commit()
