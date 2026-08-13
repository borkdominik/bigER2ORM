using System.ComponentModel.DataAnnotations.Schema;

namespace university.entity
{
    [Table("course")]
    public class Course : NamedElement
    {
        public List<Lecturer>? Lecturers { get; set; }

        public List<Course>? Prerequisites { get; set; }

        public Guid? ParentCourseId { get; set; }
        public Course? ParentCourse { get; set; }

        public List<Certificate>? Certificates { get; set; }

        public List<Course>? PrerequisiteFor { get; set; }

        public List<Course>? ChildCourses { get; set; }

    }
}
