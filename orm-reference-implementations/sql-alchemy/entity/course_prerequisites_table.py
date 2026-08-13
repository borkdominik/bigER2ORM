from base import Base
from sqlalchemy import Column, ForeignKeyConstraint, Table


course_prerequisites = Table(
    "course_prerequisites",
    Base.metadata,
    Column("course_prerequisites_id", nullable=False),
    Column("course_prerequisite_for_id", nullable=False),
    ForeignKeyConstraint(["course_prerequisites_id"], ["course.id"], name="fk_course_prerequisites_prerequisites"),
    ForeignKeyConstraint(["course_prerequisite_for_id"], ["course.id"], name="fk_course_prerequisites_prerequisite_for")
)
