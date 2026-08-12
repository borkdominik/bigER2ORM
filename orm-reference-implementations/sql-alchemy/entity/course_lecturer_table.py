from base import Base
from sqlalchemy import Column, ForeignKeyConstraint, Table


course_lecturer = Table(
    "course_lecturer",
    Base.metadata,
    Column("course_id", nullable=False),
    Column("lecturer_id", nullable=False),
    ForeignKeyConstraint(["course_id"], ["course.id"], name="fk_course_lecturer_lecturers"),
    ForeignKeyConstraint(["lecturer_id"], ["lecturer.id"], name="fk_course_lecturer_courses")
)
