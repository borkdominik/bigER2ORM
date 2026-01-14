package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Embedded;
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
public class StudentCardStudyProgram {

  @EmbeddedId
  private StudentCardStudyProgramId id;

  @Column(name = "finished")
  private Boolean finished;

  @Convert(converter = Status.Converter.class)
  @Column(name = "card_status")
  private Status cardStatus;

  @Embedded
  private StudentCardStudyProgramData additionalData;

  @MapsId("studentCardId")
  @ManyToOne(optional = false)
  @JoinColumns(value = {
    @JoinColumn(name = "student_card_card_nr", referencedColumnName = "card_nr"),
    @JoinColumn(name = "student_card_card_version", referencedColumnName = "card_version"),
  }, foreignKey = @ForeignKey(name = "fk_student_card_study_program_student_card"))
  private StudentCard studentCard;

  @MapsId("studyProgramId")
  @ManyToOne(optional = false)
  @JoinColumns(value = {
    @JoinColumn(name = "study_program_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_student_card_study_program_study_program"))
  private StudyProgram studyProgram;

}
