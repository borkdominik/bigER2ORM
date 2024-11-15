using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    public class Course
    {
        public Guid Id { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Name { get; set; }

        public List<Certificate>? Certificates { get; set; }

        public List<Lecturer>? Lecturers { get; set; }
    }
}