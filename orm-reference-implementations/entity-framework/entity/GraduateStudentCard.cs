using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("graduate_student_card")]
    public class GraduateStudentCard : StudentCard
    {
        [Column(TypeName = "Varchar(255)")]
        public string? GraduationDate { get; set; }
    }
}
