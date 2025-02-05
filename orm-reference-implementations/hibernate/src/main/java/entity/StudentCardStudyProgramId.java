package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.Embedded;
import java.io.Serializable;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class StudentCardStudyProgramId implements Serializable {

  @Embedded
  private StudentCardId studentCardId;

  @Column(name = "study_program_id")
  private UUID studyProgramId;

}
