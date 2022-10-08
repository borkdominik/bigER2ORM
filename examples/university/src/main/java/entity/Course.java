package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import java.util.List;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Course {
	
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;
	
	private String name;
	
	@OneToMany(mappedBy = "course")
	private List<Certificate> certificates;
	
	@ManyToMany
	@JoinTable(
		name = "courses_lecturers",
		joinColumns = @JoinColumn(name = "course_id", foreignKey = @ForeignKey(name = "FK_COURSE")),
		inverseJoinColumns = @JoinColumn(name = "lecturer_id", foreignKey = @ForeignKey(name = "FK_LECTURER")))
	private List<Lecturer> lecturers;
	
}
