package entity;

import entity.util.AbstractEnumConverter;

public enum StudyProgramType {
  BACHELOR,
  MASTER,
  DOCTOR;

  @jakarta.persistence.Converter
  public static class Converter extends AbstractEnumConverter<StudyProgramType> {
    public Converter() { super(StudyProgramType.class); }
  }
}
