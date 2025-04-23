using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("student_card")]
    [PrimaryKey(nameof(CardNr), nameof(CardVersion))]
    public class StudentCard
    {
        [Column(TypeName = "Varchar(255)")]
        public string CardNr { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string CardVersion { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public required string PrintedName { get; set; }

        public List<StudentCardStudyProgram>? StudyPrograms { get; set; }

        public Student? Student { get; set; }

    }
}
