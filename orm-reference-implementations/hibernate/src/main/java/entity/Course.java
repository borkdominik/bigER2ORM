package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
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

  @ManyToMany
  @JoinTable(
      name = "courses_lecturers",
      joinColumns = {
          @JoinColumn(name = "course_id", referencedColumnName = "id"),
      },
      foreignKey = @ForeignKey(name = "fk_courses_lecturers_lecturers"),
      inverseJoinColumns = {
          @JoinColumn(name = "lecturer_id", referencedColumnName = "id"),
      },
      inverseForeignKey = @ForeignKey(name = "fk_courses_lecturers_courses")
  )
  private List<Lecturer> lecturers;

  @OneToMany(mappedBy = "course")
  private List<Certificate> certificates;

}
