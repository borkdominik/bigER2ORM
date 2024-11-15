package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.PrimaryKeyJoinColumns;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@PrimaryKeyJoinColumns(value = {}, foreignKey = @ForeignKey(name = "fk_student_card"))
public class GraduateStudentCard extends StudentCard {
	
	private String graduationDate;
	
}
