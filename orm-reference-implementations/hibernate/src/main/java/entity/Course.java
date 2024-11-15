package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
public class Course extends NamedElement {

  @OneToMany(mappedBy = "course")
  private List<Certificate> certificates;

  @ManyToMany
  @JoinTable(
      name = "courses_lecturers",
      joinColumns = @JoinColumn(name = "course_id", foreignKey = @ForeignKey(name = "FK_COURSE")),
      inverseJoinColumns = @JoinColumn(name = "lecturer_id", foreignKey = @ForeignKey(name = "FK_LECTURER")))
  private List<Lecturer> lecturers;
}
