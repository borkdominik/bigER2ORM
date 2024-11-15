import uuid
from entity.address import Address
from entity.person import Person
from sqlalchemy import Integer, String, UUID
from sqlalchemy.orm import Mapped, composite, mapped_column, relationship


class Student(Person):
    __tablename__ = 'student'

    # TODO: Currently inheriting all attributes, as inheritance is buggy with ConcreteClasses
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    name: Mapped[str] = mapped_column(String(255), nullable=True)
    address: Mapped[Address] = composite(mapped_column("street", String(255), nullable=True),
            mapped_column("city", String(255), nullable=True),
            mapped_column("post_code", Integer, nullable=True),
            mapped_column("country", String(255), nullable=True))
    studies: Mapped[list["StudentStudyProgram"]] = relationship(back_populates="student")
    certificates: Mapped[list["Certificate"]] = relationship(back_populates="student")

    __mapper_args__ = {"polymorphic_identity": "student", "concrete": True}
