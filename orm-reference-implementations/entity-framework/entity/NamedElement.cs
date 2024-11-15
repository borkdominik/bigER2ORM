using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    public abstract class NamedElement
    {
        public Guid Id { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Name { get; set; }
    }
}