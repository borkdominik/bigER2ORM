import uuid
from base import Base
from entity.address import Address
from sqlalchemy import Integer, String, UUID
from sqlalchemy.ext.declarative import ConcreteBase
from sqlalchemy.orm import Mapped, composite, mapped_column


class Person(ConcreteBase, Base):
    __tablename__ = 'person'

    # TODO: Currently inheriting all attributes, as inheritance is buggy with ConcreteClasses
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    name: Mapped[str] = mapped_column(String(255), nullable=True)

    address: Mapped[Address] = composite(
            mapped_column("street", String(255), nullable=True),
            mapped_column("city", String(255), nullable=True),
            mapped_column("post_code", Integer, nullable=True),
            mapped_column("country", String(255), nullable=True)
    )

    __mapper_args__ = {
        "polymorphic_identity": "person",
    }
