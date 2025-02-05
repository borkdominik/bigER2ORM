from base import Base
from entity.student_card_id import StudentCardId
from sqlalchemy import String
from sqlalchemy.orm import Mapped, composite, mapped_column, relationship


class StudentCard(Base):
    __tablename__ = 'student_card'

    printed_name: Mapped[str] = mapped_column(String(255))

    card_nr: Mapped[str] = mapped_column("card_nr", String(255), primary_key=True)
    card_version: Mapped[str] = mapped_column("card_version", String(255), primary_key=True)
    id: Mapped[StudentCardId] = composite("card_nr", "card_version")
    study_programs: Mapped[list["StudentCardStudyProgram"]] = relationship(back_populates="student_card")
    student: Mapped["Student"] = relationship(back_populates="student_card")
