from base import Base
from entity.named_element import NamedElement
from sqlalchemy.orm import Mapped, relationship


class StudyProgram(Base, NamedElement):
    __tablename__ = 'study_program'

    students: Mapped[list["StudentStudyProgram"]] = relationship(back_populates="study_program")
