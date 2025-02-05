package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Student extends Person {

  @OneToMany(mappedBy = "student")
  private List<StudentStudyProgram> studies;

  // Unique constraint name can't be set: https://hibernate.atlassian.net/browse/HHH-19006
  // Once finished refactor creation to be equivalent
  @OneToOne
  @JoinColumns(value = {
    @JoinColumn(name = "student_card_card_nr", referencedColumnName = "card_nr"),
    @JoinColumn(name = "student_card_card_version", referencedColumnName = "card_version"),
  }, foreignKey = @ForeignKey(name = "fk_student_student_card"))
  private StudentCard studentCard;

  @OneToMany(mappedBy = "student")
  private List<Certificate> certificates;

}
