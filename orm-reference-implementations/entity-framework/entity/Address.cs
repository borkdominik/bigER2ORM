using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    [Owned]
    public class Address
    {
        [Column(TypeName = "Varchar(255)")]
        public string? Street { get; set; }


        [Column(TypeName = "Varchar(255)")]
        public string? City { get; set; }

        public int? PostCode { get; set; }


        [Column(TypeName = "Varchar(255)")]
        public string? Country { get; set; }
    }
}