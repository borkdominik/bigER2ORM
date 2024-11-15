from dataclasses import dataclass


@dataclass
class StudentCardId(object):
    card_nr: str
    card_version: str
