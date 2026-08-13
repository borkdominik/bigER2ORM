package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.PrimaryKeyJoinColumns;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@PrimaryKeyJoinColumns(value = {}, foreignKey = @ForeignKey(name = "fk_graduate_student_card_id"))
public class GraduateStudentCard extends StudentCard {

  @Column(name = "graduation_date")
  private String graduationDate;

  @Column(name = "issue_date", columnDefinition = "timestamp without time zone")
  private LocalDateTime issueDate;

}
