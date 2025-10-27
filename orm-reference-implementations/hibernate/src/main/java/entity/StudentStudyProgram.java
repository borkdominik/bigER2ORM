package entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class StudentStudyProgram {

  @EmbeddedId
  private StudentStudyProgramId id;

  @Column(name = "finished")
  private Boolean finished;

  @MapsId("studentId")
  @ManyToOne(optional = false)
  @JoinColumns(value = {
    @JoinColumn(name = "student_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_student_study_program_student"))
  private Student student;

  @MapsId("studyProgramId")
  @ManyToOne(optional = false)
  @JoinColumns(value = {
    @JoinColumn(name = "study_program_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_student_study_program_study_program"))
  private StudyProgram studyProgram;

}
