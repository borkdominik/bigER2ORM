Console.WriteLine("Hello, World!");

using var db = new UniversityContext();

db.Database.EnsureDeleted();

db.Database.EnsureCreated();

Console.WriteLine("Updated Database!");