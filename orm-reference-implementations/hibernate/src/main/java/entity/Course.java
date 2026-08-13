package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
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
      name = "course_lecturer",
      joinColumns = {
          @JoinColumn(name = "course_lecturers_id", referencedColumnName = "id"),
      },
      foreignKey = @ForeignKey(name = "fk_course_lecturer_lecturers"),
      inverseJoinColumns = {
          @JoinColumn(name = "lecturer_courses_id", referencedColumnName = "id"),
      },
      inverseForeignKey = @ForeignKey(name = "fk_course_lecturer_courses")
  )
  private List<Lecturer> lecturers;

  @ManyToMany
  @JoinTable(
      name = "course_prerequisites",
      joinColumns = {
          @JoinColumn(name = "course_prerequisites_id", referencedColumnName = "id"),
      },
      foreignKey = @ForeignKey(name = "fk_course_prerequisites_prerequisites"),
      inverseJoinColumns = {
          @JoinColumn(name = "course_prerequisite_for_id", referencedColumnName = "id"),
      },
      inverseForeignKey = @ForeignKey(name = "fk_course_prerequisites_prerequisite_for")
  )
  private List<Course> prerequisites;

  @ManyToOne
  @JoinColumns(value = {
    @JoinColumn(name = "parent_course_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_course_parent_course"))
  private Course parentCourse;

  @OneToMany(mappedBy = "course")
  private List<Certificate> certificates;

  @ManyToMany(mappedBy = "prerequisites")
  private List<Course> prerequisiteFor;

  @OneToMany(mappedBy = "parentCourse")
  private List<Course> childCourses;

}
