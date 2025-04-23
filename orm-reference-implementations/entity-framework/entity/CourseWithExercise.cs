namespace university.entity
{
    public class CourseWithExercise : Course
    {
        public Guid? TutorId { get; set; }
        public Student? Tutor { get; set; }

    }
}
