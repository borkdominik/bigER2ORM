using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    [Table("recognized_certificate")]
    public class RecognizedCertificate : Certificate
    {
        public Guid OriginalCertificateId { get; set; }
        public Certificate OriginalCertificate { get; set; }
    }
}