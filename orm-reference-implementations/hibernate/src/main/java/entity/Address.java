package entity;

import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class Address implements Serializable {

  private String street;

  private String city;

  private Integer postCode;

  private String country;

}
