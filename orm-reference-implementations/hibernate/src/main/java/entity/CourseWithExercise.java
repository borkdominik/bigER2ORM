package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class CourseWithExercise extends Course {
  @ManyToOne
  @JoinColumn(name = "tutor_id", foreignKey = @ForeignKey(name = "FK_TUTOR"))
  private Student tutor;
}
