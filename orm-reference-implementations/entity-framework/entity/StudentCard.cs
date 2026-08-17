using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("student_card")]
    [PrimaryKey(nameof(CardNr), nameof(CardVersion))]
    public class StudentCard
    {
        // LIMITATION: Owned types cannot be used in Table-per-Class inheritance hierarchies, embeddables must be mapped as flattened properties: https://github.com/dotnet/efcore/issues/32028
        [Column(TypeName = "Varchar(255)")]
        public string CardNr { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string CardVersion { get; set; }

        [Column(TypeName = "Varchar(100)")]
        public required string PrintedName { get; set; }

        public Student? Student { get; set; }

        public List<StudentCardStudyProgram>? StudyPrograms { get; set; }

    }
}
