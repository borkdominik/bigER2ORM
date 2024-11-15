package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class StudyProgram extends NamedElement {

  @OneToMany(mappedBy = "studyProgram")
  private List<StudentStudyProgram> students;
}
