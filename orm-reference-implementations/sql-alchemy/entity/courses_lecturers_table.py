from base import Base
from sqlalchemy import Column, ForeignKeyConstraint, Table


courses_lecturers = Table(
    "courses_lecturers",
    Base.metadata,
    Column("course_id", nullable=False),
    Column("lecturer_id", nullable=False),
    ForeignKeyConstraint(["course_id"], ["course.id"], name="fk_courses_lecturers_lecturers"),
    ForeignKeyConstraint(["lecturer_id"], ["lecturer.id"], name="fk_courses_lecturers_courses")
)
