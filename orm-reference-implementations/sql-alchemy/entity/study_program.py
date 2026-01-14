from base import Base
from entity.named_element import NamedElement
from entity.study_program_type import StudyProgramType
from sqlalchemy import Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship


class StudyProgram(Base, NamedElement):
    __tablename__ = 'study_program'

    study_program_type: Mapped[StudyProgramType] = mapped_column(Enum(native_enum=False, length=255), nullable=True)
    students: Mapped[list["StudentStudyProgram"]] = relationship(back_populates="study_program")
    student_cards: Mapped[list["StudentCardStudyProgram"]] = relationship(back_populates="study_program")
