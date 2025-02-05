import uuid
from base import Base
from sqlalchemy import ForeignKeyConstraint, Integer, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class Certificate(Base):
    __tablename__ = 'certificate'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    grade: Mapped[int] = mapped_column(Integer, nullable=True)

    student_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=True)
    student: Mapped["Student"] = relationship(foreign_keys=[student_id], back_populates="certificates")

    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=True)
    course: Mapped["Course"] = relationship(foreign_keys=[course_id], back_populates="certificates")

    __table_args__ = (
        ForeignKeyConstraint([student_id], ["student.id"], name="fk_certificate_student"),
        ForeignKeyConstraint([course_id], ["course.id"], name="fk_certificate_course"),
    )
