using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("lecturer")]
    public class Lecturer : Person
    {
        public List<Course>? Courses { get; set; }

    }
}
