package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class StudentCardStudyProgramData implements Serializable {

  @Column(name = "data_one")
  private String dataOne;

  @Column(name = "data_two")
  private Integer dataTwo;

}
