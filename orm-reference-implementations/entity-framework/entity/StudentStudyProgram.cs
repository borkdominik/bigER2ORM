using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("student_study_program")]
    [PrimaryKey(nameof(StudentId), nameof(StudyProgramId))]
    public class StudentStudyProgram
    {
        public Guid StudentId { get; set; }
        public required Student Student { get; set; }

        public Guid StudyProgramId { get; set; }
        public required StudyProgram StudyProgram { get; set; }

        public Boolean? Finished { get; set; }

    }
}
