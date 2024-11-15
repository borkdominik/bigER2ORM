from base import Base
from entity.courses_lecturers_table import courses_lecturers
from entity.named_element import NamedElement
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship


class Course(Base, NamedElement):
    __tablename__ = 'course'

    lecturers: Mapped[list["Lecturer"]] = relationship("Lecturer", secondary=courses_lecturers,
                                             back_populates="courses")
    certificates: Mapped[list["Certificate"]] = relationship(back_populates="course")
    dtype: Mapped[str] = mapped_column(String(31), nullable=False)

    __mapper_args__ = {
        "polymorphic_identity": "course",
        "polymorphic_on": dtype,
    }
