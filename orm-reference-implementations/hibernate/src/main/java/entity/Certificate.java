package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.JoinColumn;
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
  private UUID id;

  private Integer grade;
  
  @ManyToOne
  @JoinColumn(name = "student_id", foreignKey = @ForeignKey(name = "FK_STUDENT"))
  private Student student;

  @ManyToOne
  @JoinColumn(name = "course_id", foreignKey = @ForeignKey(name = "FK_COURSE"))
  private Course course;

}
