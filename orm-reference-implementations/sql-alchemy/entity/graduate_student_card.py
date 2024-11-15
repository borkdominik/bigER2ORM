from entity.student_card import StudentCard
from entity.student_card_id import StudentCardId
from sqlalchemy import ForeignKeyConstraint, String
from sqlalchemy.orm import Mapped, composite, mapped_column


class GraduateStudentCard(StudentCard):
    __tablename__ = 'graduate_student_card'

    card_nr: Mapped[str] = mapped_column("card_nr", String(255), primary_key=True)
    card_version: Mapped[str] = mapped_column("card_version", String(255), primary_key=True)
    id: Mapped[StudentCardId] = composite("card_nr", "card_version")
    graduation_date: Mapped[str] = mapped_column(String(255), nullable=True)
    __mapper_args__ = {
        "polymorphic_identity": "graduate_student_card",
        "inherit_condition": (card_nr == StudentCard.card_nr) and (card_version == StudentCard.card_version)
    }

    __table_args__ = (
        ForeignKeyConstraint([card_nr, card_version], [StudentCard.card_nr, StudentCard.card_version], name="fk_graduate_student_card_id"),
    )
