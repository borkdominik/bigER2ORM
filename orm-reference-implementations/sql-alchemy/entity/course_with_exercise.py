import uuid
from entity.course import Course
from sqlalchemy import ForeignKey, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class CourseWithExercise(Course):

    tutor_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True),
                                             ForeignKey("student.id", name="fk_course_with_exercise_tutor_id"),
                                             nullable=True)
    tutor: Mapped["Student"] = relationship(foreign_keys=[tutor_id])

    __mapper_args__ = {
        "polymorphic_identity": "course_with_exercise"
    }
