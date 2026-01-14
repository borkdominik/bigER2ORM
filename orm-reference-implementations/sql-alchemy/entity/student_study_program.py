import uuid
from base import Base
from sqlalchemy import Boolean, ForeignKeyConstraint, PrimaryKeyConstraint, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class StudentStudyProgram(Base):
    __tablename__ = 'student_study_program'

    finished: Mapped[bool] = mapped_column(Boolean, nullable=True)

    student_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    student: Mapped["Student"] = relationship(foreign_keys=[student_id], back_populates="studies")

    study_program_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    study_program: Mapped["StudyProgram"] = relationship(foreign_keys=[study_program_id], back_populates="students")

    __table_args__ = (
        PrimaryKeyConstraint("student_id", "study_program_id"),
        ForeignKeyConstraint([student_id], ["student.id"], name="fk_student_study_program_student"),
        ForeignKeyConstraint([study_program_id], ["study_program.id"], name="fk_student_study_program_study_program"),
    )
