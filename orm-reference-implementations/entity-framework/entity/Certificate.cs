using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("certificate")]
    [PrimaryKey(nameof(Id))]
    public class Certificate
    {
        public Guid Id { get; set; }

        public int? Grade { get; set; }

        public Guid? StudentId { get; set; }
        public Student? Student { get; set; }

        public Guid? CourseId { get; set; }
        public Course? Course { get; set; }

    }
}
