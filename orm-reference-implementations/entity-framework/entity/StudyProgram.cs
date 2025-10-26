using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("study_program")]
    public class StudyProgram : NamedElement
    {
        [Column(TypeName = "Varchar(255)")]
        public StudyProgramType? StudyProgramType { get; set; }

        public List<StudentStudyProgram>? Students { get; set; }

        public List<StudentCardStudyProgram>? StudentCards { get; set; }

    }
}
