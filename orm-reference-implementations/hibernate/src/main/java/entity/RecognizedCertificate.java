package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrimaryKeyJoinColumns;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@PrimaryKeyJoinColumns(value = {}, foreignKey = @ForeignKey(name = "fk_certificate"))
public class RecognizedCertificate extends Certificate {

  @ManyToOne(optional = false)
  @JoinColumn(name = "original_certificate_id", foreignKey = @ForeignKey(name = "FK_ORIGINAL_CERTIFICATE"))
  private Certificate originalCertificate;
}
