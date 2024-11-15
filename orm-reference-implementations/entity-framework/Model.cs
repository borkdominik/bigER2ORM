using csharp_example.entity;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Metadata;

public class SchoolContext : DbContext
{
    public DbSet<Student> Student { get; set; }
    public DbSet<Course> Course { get; set; }
    public DbSet<Certificate> Certificate { get; set; }
    public DbSet<RecognizedCertificate> RecognizedCertificate { get; set; }
    public DbSet<Lecturer> Lecturer { get; set; }
    public DbSet<StudyProgram> StudyProgram { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options
            .UseNpgsql("Host=localhost;Database=csharp;Username=postgres;Password=postgres")
            .UseSnakeCaseNamingConvention();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Student>()
            .HasKey(s => s.Id)
            .HasName("student_pkey");

        modelBuilder.Entity<Course>()
            .HasKey(s => s.Id)
            .HasName("course_pkey");

        // TODO: PKEY cant be set due to bug, EF does not support this on Tpt
        modelBuilder.Entity<Certificate>().UseTptMappingStrategy();

        modelBuilder.Entity<Lecturer>()
            .HasKey(s => s.Id)
            .HasName("lecturer_pkey");

        modelBuilder.Entity<StudyProgram>()
            .HasKey(s => s.Id)
            .HasName("study_program_pkey");

        modelBuilder.Entity<Certificate>()
            .HasOne(certificate => certificate.Course)
            .WithMany(course => course.Certificates)
            .HasForeignKey(certificate => certificate.CourseId)
            .HasConstraintName("fk_course");

        modelBuilder.Entity<Certificate>()
            .HasOne(certificate => certificate.Student)
            .WithMany(student => student.Certificates)
            .HasForeignKey(certificate => certificate.StudentId)
            .HasConstraintName("fk_student");

        modelBuilder.Entity<Course>()
            .HasMany(course => course.Lecturers)
            .WithMany(lecturer => lecturer.Courses)
            .UsingEntity<Dictionary<string, object>>(
                "courses_lecturers",
                j => j
                    .HasOne<Lecturer>()
                    .WithMany()
                    .HasForeignKey("lecturer_id")
                    .HasConstraintName("fk_lecturer")
                    .OnDelete(DeleteBehavior.NoAction),
                j => j
                    .HasOne<Course>()
                    .WithMany()
                    .HasForeignKey("course_id")
                    .HasConstraintName("fk_course")
                    .OnDelete(DeleteBehavior.NoAction)
            )
            .HasNoKey();

        modelBuilder.Entity<StudentStudyProgram>()
            .HasKey(s => new { s.StudentId, s.StudyProgramId })
            .HasName("student_study_program_pkey");

        modelBuilder.Entity<StudentStudyProgram>()
            .HasOne(s => s.Student)
            .WithMany(s => s.Studies)
            .HasForeignKey(s => s.StudentId)
            .HasConstraintName("fk_student")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<StudentStudyProgram>()
            .HasOne(s => s.StudyProgram)
            .WithMany(s => s.Students)
            .HasForeignKey(s => s.StudyProgramId)
            .HasConstraintName("fk_study_program")
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Student>()
            .OwnsOne(
                s => s.Address,
                a => {
                    a.Property(s => s.Street).HasColumnName("street");
                    a.Property(s => s.City).HasColumnName("city");
                    a.Property(s => s.PostCode).HasColumnName("post_code");
                    a.Property(s => s.Country).HasColumnName("country");
                }
            );

        modelBuilder.Entity<RecognizedCertificate>()
            .HasOne(s => s.OriginalCertificate)
            .WithMany()
            .HasForeignKey(s => s.OriginalCertificateId)
            .HasConstraintName("fk_original_certificate")
            .OnDelete(DeleteBehavior.NoAction);

    }
}
