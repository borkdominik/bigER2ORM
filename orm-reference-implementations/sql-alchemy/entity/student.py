import uuid
from entity.address import Address
from entity.person import Person
from sqlalchemy import ForeignKeyConstraint, Integer, String, UUID, UniqueConstraint
from sqlalchemy.orm import Mapped, composite, mapped_column, relationship


class Student(Person):
    __tablename__ = 'student'

    # TODO: Currently inheriting all attributes, as inheritance is buggy with ConcreteClasses
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    name: Mapped[str] = mapped_column(String(255), nullable=True)
    address: Mapped[Address] = composite(
            mapped_column("street", String(255), nullable=True),
            mapped_column("city", String(255), nullable=True),
            mapped_column("post_code", Integer, nullable=True),
            mapped_column("country", String(255), nullable=True)
    )

    student_card_card_nr: Mapped[str] = mapped_column(String(255), nullable=True)
    student_card_card_version: Mapped[str] = mapped_column(String(255), nullable=True)
    student_card: Mapped["StudentCard"] = relationship(foreign_keys=[student_card_card_nr, student_card_card_version], back_populates="student")
    certificates: Mapped[list["Certificate"]] = relationship(back_populates="student")
    studies: Mapped[list["StudentStudyProgram"]] = relationship(back_populates="student")

    __mapper_args__ = {
        "polymorphic_identity": "student", "concrete": True,
    }

    __table_args__ = (
        ForeignKeyConstraint([student_card_card_nr, student_card_card_version], ["student_card.card_nr", "student_card.card_version"], name="fk_student_student_card"),
        UniqueConstraint(student_card_card_nr, student_card_card_version, name="student_student_card_card_nr_student_card_card_version_key"),
    )
