using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    public class StudyProgram
    {
        public Guid Id { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? Name { get; set; }

        public List<StudentStudyProgram>? Students { get; set; }
    }
}