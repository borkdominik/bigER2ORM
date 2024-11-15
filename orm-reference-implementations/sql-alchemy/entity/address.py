from dataclasses import dataclass


@dataclass
class Address(object):
    street: str
    city: str
    post_code: int
    country: str
