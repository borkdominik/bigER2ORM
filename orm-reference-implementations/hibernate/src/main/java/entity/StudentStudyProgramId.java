package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class StudentStudyProgramId implements Serializable {

  @Column(name = "student_id")
  private UUID studentId;

  @Column(name = "study_program_id")
  private UUID studyProgramId;

}
