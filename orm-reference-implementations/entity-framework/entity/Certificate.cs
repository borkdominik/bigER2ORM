using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    [Table("certificate")]
    public class Certificate
    {
        public Guid Id { get; set; }

        public Guid? StudentId { get; set; }
        public Student? Student { get; set; }

        public Guid? CourseId { get; set; }
        public Course? Course { get; set; }

        public int? Grade { get; set; }
    }
}