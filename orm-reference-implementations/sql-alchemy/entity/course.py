import uuid
from base import Base
from entity.course_lecturer_table import course_lecturer
from entity.course_prerequisites_table import course_prerequisites
from entity.named_element import NamedElement
from sqlalchemy import ForeignKeyConstraint, String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class Course(Base, NamedElement):
    __tablename__ = 'course'

    lecturers: Mapped[list["Lecturer"]] = relationship("Lecturer", secondary=course_lecturer,
                                             back_populates="courses")
    prerequisites: Mapped[list["Course"]] = relationship("Course", secondary=course_prerequisites,
                                             back_populates="prerequisite_for")

    parent_course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=True)
    parent_course: Mapped["Course"] = relationship(foreign_keys=[parent_course_id], back_populates="child_courses")
    certificates: Mapped[list["Certificate"]] = relationship(back_populates="course")
    prerequisite_for: Mapped[list["Course"]] = relationship("Course", secondary=course_prerequisites,
                                             back_populates="prerequisites")
    child_courses: Mapped[list["Course"]] = relationship(back_populates="parent_course")
    dtype: Mapped[str] = mapped_column(String(31), nullable=False)

    __mapper_args__ = {
        "polymorphic_identity": "course",
        "polymorphic_on": dtype,
    }

    __table_args__ = (
        ForeignKeyConstraint([parent_course_id], ["course.id"], name="fk_course_parent_course"),
    )
