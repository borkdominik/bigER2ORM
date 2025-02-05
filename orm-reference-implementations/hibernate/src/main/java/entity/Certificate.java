package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.ManyToOne;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Inheritance(strategy = InheritanceType.JOINED)
public class Certificate {

  @Id
  @GeneratedValue(strategy = GenerationType.UUID)
  @Column(name = "id")
  private UUID id;

  @Column(name = "grade")
  private Integer grade;

  @ManyToOne
  @JoinColumns(value = {
    @JoinColumn(name = "student_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_certificate_student"))
  private Student student;

  @ManyToOne
  @JoinColumns(value = {
    @JoinColumn(name = "course_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_certificate_course"))
  private Course course;

}
