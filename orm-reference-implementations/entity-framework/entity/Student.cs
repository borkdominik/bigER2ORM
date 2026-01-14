using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("student")]
    public class Student : Person
    {
        [Column(TypeName = "Varchar(255)")]
        public string? StudentCardCardNr { get; set; }
        [Column(TypeName = "Varchar(255)")]
        public string? StudentCardCardVersion { get; set; }
        public StudentCard? StudentCard { get; set; }

        public List<Certificate>? Certificates { get; set; }

        public List<StudentStudyProgram>? Studies { get; set; }

    }
}
