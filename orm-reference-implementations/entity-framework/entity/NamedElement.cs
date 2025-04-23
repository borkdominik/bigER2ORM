using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [PrimaryKey(nameof(Id))]
    public abstract class NamedElement
    {
        public Guid Id { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Name { get; set; }

    }
}
