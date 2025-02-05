package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
public class Address implements Serializable {

  @Column(name = "street")
  private String street;

  @Column(name = "city")
  private String city;

  @Column(name = "post_code")
  private Integer postCode;

  @Column(name = "country")
  private String country;

}
