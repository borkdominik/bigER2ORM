using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("student_card_study_program")]
    [PrimaryKey(nameof(StudentCardCardNr), nameof(StudentCardCardVersion), nameof(StudyProgramId))]
    public class StudentCardStudyProgram
    {
        [Column(TypeName = "Varchar(255)")]
        public string StudentCardCardNr { get; set; }
        [Column(TypeName = "Varchar(255)")]
        public string StudentCardCardVersion { get; set; }
        public required StudentCard StudentCard { get; set; }

        public Guid StudyProgramId { get; set; }
        public required StudyProgram StudyProgram { get; set; }

        public Boolean? Finished { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public string? DataOne { get; set; }

        public int? DataTwo { get; set; }

        [Column(TypeName = "Varchar(255)")]
        public Status? CardStatus { get; set; }

    }
}
