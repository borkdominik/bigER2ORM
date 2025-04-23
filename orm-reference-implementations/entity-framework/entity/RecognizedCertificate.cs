using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("recognized_certificate")]
    public class RecognizedCertificate : Certificate
    {
        public Guid OriginalCertificateId { get; set; }
        public required Certificate OriginalCertificate { get; set; }

    }
}
