package entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrimaryKeyJoinColumns;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@PrimaryKeyJoinColumns(value = {}, foreignKey = @ForeignKey(name = "fk_recognized_certificate_id"))
public class RecognizedCertificate extends Certificate {

  @ManyToOne(optional = false)
  @JoinColumns(value = {
    @JoinColumn(name = "original_certificate_id", referencedColumnName = "id"),
  }, foreignKey = @ForeignKey(name = "fk_recognized_certificate_original_certificate"))
  private Certificate originalCertificate;

}
