using university.entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;

public class UniversityContext : DbContext
{
    public DbSet<Certificate> Certificate { get; set; }
    public DbSet<Course> Course { get; set; }
    public DbSet<CourseWithExercise> CourseWithExercise { get; set; }
    public DbSet<GraduateStudentCard> GraduateStudentCard { get; set; }
    public DbSet<Lecturer> Lecturer { get; set; }
    public DbSet<Person> Person { get; set; }
    public DbSet<RecognizedCertificate> RecognizedCertificate { get; set; }
    public DbSet<Student> Student { get; set; }
    public DbSet<StudentCard> StudentCard { get; set; }
    public DbSet<StudyProgram> StudyProgram { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options
            .UseNpgsql("Host=localhost;Database=csharp;Username=postgres;Password=postgres")
            .UseSnakeCaseNamingConvention();

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder.Conventions.Remove(typeof(ForeignKeyIndexConvention));
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {

        // INHERTIANCE

        // Table-per-Type doesn't support renaming primary keys: https://github.com/dotnet/efcore/issues/19970
        modelBuilder.Entity<StudentCard>().UseTptMappingStrategy();

        modelBuilder.Entity<GraduateStudentCard>()
            .HasOne<StudentCard>()
            .WithOne()
            .HasForeignKey<GraduateStudentCard>(e => new { e.CardNr, e.CardVersion })
            .HasPrincipalKey<StudentCard>(e => new { e.CardNr, e.CardVersion })
            .HasConstraintName("fk_graduate_student_card_id")
            .OnDelete(DeleteBehavior.NoAction);

        // Table-per-Type doesn't support renaming primary keys: https://github.com/dotnet/efcore/issues/19970
        modelBuilder.Entity<Certificate>().UseTptMappingStrategy();

        modelBuilder.Entity<RecognizedCertificate>()
            .HasOne<Certificate>()
            .WithOne()
            .HasForeignKey<RecognizedCertificate>(e => new { e.Id })
            .HasPrincipalKey<Certificate>(e => new { e.Id })
            .HasConstraintName("fk_recognized_certificate_id")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Course>()
            .HasDiscriminator<string>("dtype")
            .HasValue<Course>("Course")
            .HasValue<CourseWithExercise>("CourseWithExercise");

        modelBuilder.Entity<Course>()
            .Property("dtype")
            .HasMaxLength(31);

        modelBuilder.Entity<Person>().UseTpcMappingStrategy();

        // END INHERITANCE

        // RELATIONSHIPS

        modelBuilder.Entity<Certificate>()
            .HasOne(e => e.Student)
            .WithMany(e => e.Certificates)
            .HasForeignKey(e => new { e.StudentId })
            .HasConstraintName("fk_certificate_student")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Certificate>()
            .HasOne(e => e.Course)
            .WithMany(e => e.Certificates)
            .HasForeignKey(e => new { e.CourseId })
            .HasConstraintName("fk_certificate_course")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Course>()
            .HasMany(e => e.Lecturers)
            .WithMany(e => e.Courses)
            .UsingEntity<Dictionary<string, object>>(
                "courses_lecturers",
                e => e
                    .HasOne<Lecturer>()
                    .WithMany()
                    .HasForeignKey(["lecturer_id"])
                    .HasConstraintName("fk_courses_lecturers_courses")
                    .OnDelete(DeleteBehavior.NoAction),
                e => e
                    .HasOne<Course>()
                    .WithMany()
                    .HasForeignKey(["course_id"])
                    .HasConstraintName("fk_courses_lecturers_lecturers")
                    .OnDelete(DeleteBehavior.NoAction)
            )
            .HasNoKey();

        modelBuilder.Entity<StudentStudyProgram>()
            .HasOne(e => e.Student)
            .WithMany(e => e.Studies)
            .HasForeignKey(e => new { e.StudentId })
            .HasConstraintName("fk_student_study_program_student")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<StudentStudyProgram>()
            .HasOne(e => e.StudyProgram)
            .WithMany(e => e.Students)
            .HasForeignKey(e => new { e.StudyProgramId })
            .HasConstraintName("fk_student_study_program_study_program")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<CourseWithExercise>()
            .HasOne(e => e.Tutor)
            .WithMany()
            .HasForeignKey(e => new { e.TutorId })
            .HasConstraintName("fk_course_with_exercise_tutor")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<RecognizedCertificate>()
            .HasOne(e => e.OriginalCertificate)
            .WithMany()
            .HasForeignKey(e => new { e.OriginalCertificateId })
            .HasConstraintName("fk_recognized_certificate_original_certificate")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Student>()
            .HasOne(e => e.StudentCard)
            .WithOne(e => e.Student)
            .HasForeignKey<Student>(e => new { e.StudentCardCardNr, e.StudentCardCardVersion })
            .HasConstraintName("fk_student_student_card")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<StudentCardStudyProgram>()
            .HasOne(e => e.StudentCard)
            .WithMany(e => e.StudyPrograms)
            .HasForeignKey(e => new { e.StudentCardCardNr, e.StudentCardCardVersion })
            .HasConstraintName("fk_student_card_study_program_student_card")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<StudentCardStudyProgram>()
            .HasOne(e => e.StudyProgram)
            .WithMany(e => e.StudentCards)
            .HasForeignKey(e => new { e.StudyProgramId })
            .HasConstraintName("fk_student_card_study_program_study_program")
            .OnDelete(DeleteBehavior.NoAction);

        // END RELATIONSHIPS
    }
}
