using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    public class Lecturer
    {
        public Guid Id { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Name { get; set; }

        public List<Course>? Courses { get; set; }
    }
}