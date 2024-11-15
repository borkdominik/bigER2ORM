using System;
using System.Linq;

Console.WriteLine("Hello, World!");

using var db = new SchoolContext();

db.Database.EnsureDeleted();

db.Database.EnsureCreated();

Console.WriteLine("Updated Database!");