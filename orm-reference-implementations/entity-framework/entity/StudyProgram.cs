using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("study_program")]
    public class StudyProgram : NamedElement
    {
        public List<StudentStudyProgram>? Students { get; set; }

        public List<StudentCardStudyProgram>? StudentCards { get; set; }

    }
}
