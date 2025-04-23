using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("person")]
    public class Person : NamedElement
    {
        //can't use ComplexType in Inheritance, need to manually inherit all attributes
        [Column(TypeName = "Varchar(255)")]
        public string? Street { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? City { get; set; }

        public int? PostCode { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Country { get; set; }
    }
}
