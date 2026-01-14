package entity.util;

import jakarta.persistence.AttributeConverter;

public abstract class AbstractEnumConverter<E extends Enum<E>> implements AttributeConverter<E, String> {

  private final Class<E> enumClass;

  protected AbstractEnumConverter(Class<E> enumClass) {
    this.enumClass = enumClass;
  }

  @Override public String convertToDatabaseColumn(E attribute) {
    return attribute == null ? null : attribute.name();
  }

  @Override public E convertToEntityAttribute(String dbData) {
    return dbData == null ? null : Enum.valueOf(enumClass, dbData);
  }
}
