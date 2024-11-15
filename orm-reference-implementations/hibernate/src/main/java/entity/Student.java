package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Student extends Person {

  @OneToMany(mappedBy = "student")
  private List<Certificate> certificates;

  @OneToMany(mappedBy = "student")
  private List<StudentStudyProgram> studies;

}
