package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class StudentCardId implements Serializable {

  @Column(name = "card_nr")
  private String cardNr;

  @Column(name = "card_version")
  private String cardVersion;

}
