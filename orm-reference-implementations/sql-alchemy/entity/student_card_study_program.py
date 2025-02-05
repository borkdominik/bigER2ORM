import uuid
from base import Base
from sqlalchemy import Boolean, ForeignKeyConstraint, PrimaryKeyConstraint, String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class StudentCardStudyProgram(Base):
    __tablename__ = "student_card_study_program"

    student_card_card_nr: Mapped[str] = mapped_column(String(255))
    student_card_card_version: Mapped[str] = mapped_column(String(255))
    student_card: Mapped["StudentCard"] = relationship(foreign_keys=[student_card_card_nr, student_card_card_version], back_populates="study_programs")

    study_program_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    study_program: Mapped["StudyProgram"] = relationship(foreign_keys=[study_program_id], back_populates="student_cards")

    finished: Mapped[bool] = mapped_column(Boolean, nullable=True)

    __table_args__ = (
        PrimaryKeyConstraint("study_program_id", "student_card_card_nr", "student_card_card_version"),
        ForeignKeyConstraint([student_card_card_nr, student_card_card_version], ["student_card.card_nr", "student_card.card_version"], name="fk_student_card_study_program_student_card"),
        ForeignKeyConstraint([study_program_id], ["study_program.id"], name="fk_student_card_study_program_study_program"),
    )
