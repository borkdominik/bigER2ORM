import uuid
from entity.course import Course
from sqlalchemy import ForeignKeyConstraint, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class CourseWithExercise(Course):
    __tablename__ = Course.__tablename__

    tutor_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=True)
    tutor: Mapped["Student"] = relationship(foreign_keys=[tutor_id])

    __mapper_args__ = {
        "polymorphic_identity": "course_with_exercise",
    }

    __table_args__ = (
        ForeignKeyConstraint([tutor_id], ["student.id"], name="fk_course_with_exercise_tutor"),
        {'extend_existing': True},
    )
