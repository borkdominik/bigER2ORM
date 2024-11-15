import sqlalchemy

from base import Base, db, Session
from entity import *

insp = sqlalchemy.inspect(db)
for table_entry in reversed(insp.get_sorted_table_and_fkc_names()):
    table_name = table_entry[0]
    if table_name:
        with db.begin() as conn:
            conn.execute(sqlalchemy.text(f'DROP TABLE "{table_name}" CASCADE'))
Base.metadata.drop_all(db)
Base.metadata.create_all(db)

session = Session()


student: Student = Student()
student.name = "Student"
session.add(student)

session.commit()

session.close()
