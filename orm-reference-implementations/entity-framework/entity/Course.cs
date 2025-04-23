using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("course")]
    public class Course : NamedElement
    {
        public List<Lecturer>? Lecturers { get; set; }

        public List<Certificate>? Certificates { get; set; }

    }
}
