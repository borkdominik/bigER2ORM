from base import Base
from sqlalchemy import Column, ForeignKey, Table


courses_lecturers = Table(
    "courses_lecturers",
    Base.metadata,
    Column("course_id", ForeignKey("course.id", name="fk_courses_lecturers_course_id"), nullable=False),
    Column("lecturer_id", ForeignKey("lecturer.id", name="fk_courses_lecturers_lecturer_id"), nullable=False)
)
