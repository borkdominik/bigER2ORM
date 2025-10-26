from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

db_string = "postgresql://postgres:postgres@postgres:5432/python"

db = create_engine(db_string)
Base = declarative_base()

Session = sessionmaker(db)
