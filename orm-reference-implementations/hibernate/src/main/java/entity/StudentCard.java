package entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Inheritance(strategy = InheritanceType.JOINED)
public class StudentCard {

  @EmbeddedId
  private StudentCardId id;

  @Column(name = "printed_name", nullable = false)
  private String printedName;

  @OneToOne(mappedBy = "studentCard")
  private Student student;

  @OneToMany(mappedBy = "studentCard")
  private List<StudentCardStudyProgram> studyPrograms;

}
