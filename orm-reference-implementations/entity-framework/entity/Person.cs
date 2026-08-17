using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("person")]
    public class Person : NamedElement
    {
        // LIMITATION: Owned types cannot be used in Table-per-Class inheritance hierarchies, embeddables must be mapped as flattened properties: https://github.com/dotnet/efcore/issues/32028
        [Column(TypeName = "Varchar(255)")]
        public string? Street { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? City { get; set; }

        public int? PostCode { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Country { get; set; }

    }
}
