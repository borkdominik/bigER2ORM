package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ManyToMany;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Lecturer extends Person {
  @ManyToMany(mappedBy = "lecturers")
  private List<Course> courses;
}
