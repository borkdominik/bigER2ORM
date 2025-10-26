package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class StudyProgram extends NamedElement {

  @Convert(converter = StudyProgramType.Converter.class)
  @Column(name = "study_program_type")
  private StudyProgramType studyProgramType;

  @OneToMany(mappedBy = "studyProgram")
  private List<StudentStudyProgram> students;

  @OneToMany(mappedBy = "studyProgram")
  private List<StudentCardStudyProgram> studentCards;

}
