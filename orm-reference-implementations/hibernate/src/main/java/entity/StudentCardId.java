package entity;

import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class StudentCardId implements Serializable {

	private String cardNr;

	private String cardVersion;
	
}
