import sqlalchemy

from base import Base, db, Session
from entity import *

# Clean reset without noisy "doesn't exist" errors:
Base.metadata.drop_all(bind=db, checkfirst=True)
Base.metadata.create_all(bind=db, checkfirst=True)

session = Session()

with Session() as session:
    session.commit()
