import uuid
from entity.certificate import Certificate
from sqlalchemy import ForeignKey, ForeignKeyConstraint, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship


class RecognizedCertificate(Certificate):
    __tablename__ = 'recognized_certificate'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())

    original_certificate_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True),
                                             ForeignKey("certificate.id", name="fk_recognized_certificate_original_certificate_id"))
    original_certificate: Mapped["Certificate"] = relationship(foreign_keys=[original_certificate_id])
    __mapper_args__ = {
        "polymorphic_identity": "recognized_certificate",
        "inherit_condition": (id == Certificate.id)
    }

    __table_args__ = (
        ForeignKeyConstraint([id], [Certificate.id], name="fk_recognized_certificate_id"),
    )
