package entity;

import entity.util.AbstractEnumConverter;

public enum Status {
  VALID,
  INVALID;

  @jakarta.persistence.Converter
  public static class Converter extends AbstractEnumConverter<Status> {
    public Converter() { super(Status.class); }
  }
}
