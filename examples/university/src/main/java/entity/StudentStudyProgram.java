package entity;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class StudentStudyProgram {

	@EmbeddedId
	private StudentStudyProgramId id;

	@ManyToOne
	@MapsId("studentId")
	@JoinColumn(name = "student_id", foreignKey = @ForeignKey(name = "FK_STUDENT"))
	private Student student;

	@ManyToOne
	@MapsId("studyProgramId")
	@JoinColumn(name = "study_program_id", foreignKey = @ForeignKey(name = "FK_STUDY_PROGRAM"))
	private StudyProgram studyProgram;

	private Boolean finished;
	
}
