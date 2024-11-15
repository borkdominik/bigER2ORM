using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace csharp_example.entity
{
    public class StudentStudyProgram
    {
        public Guid StudentId { get; set; }
        public Student? Student { get; set; }

        public Guid StudyProgramId { get; set; }
        public StudyProgram? StudyProgram { get; set; }
        
        public Boolean? Finished { get; set; }
    }
}