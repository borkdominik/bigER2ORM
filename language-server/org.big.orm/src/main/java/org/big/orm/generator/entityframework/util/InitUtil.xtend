package org.big.orm.generator.entityframework.util

import com.google.inject.Singleton
import org.big.orm.ormModel.OrmModel
import com.google.common.base.CaseFormat

@Singleton
class InitUtil {
	
	def compileCsprojFile(OrmModel model)
	'''
	<Project Sdk="Microsoft.NET.Sdk">
	
	  <PropertyGroup>
	    <OutputType>Exe</OutputType>
	    <TargetFramework>net9.0</TargetFramework>
	    <RootNamespace>«model.name»</RootNamespace>
	    <ImplicitUsings>enable</ImplicitUsings>
	    <Nullable>enable</Nullable>
	  </PropertyGroup>
	
	  <ItemGroup>
	    <PackageReference Include="EFCore.NamingConventions" Version="9.0.0" />
	    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="9.0.2">
	      <PrivateAssets>all</PrivateAssets>
	      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
	    </PackageReference>
	    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="9.0.2">
	      <PrivateAssets>all</PrivateAssets>
	      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
	    </PackageReference>
	    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.0.3" />
	  </ItemGroup>
	
	</Project>
	'''	
	
	def compileProgram(OrmModel model)
	'''
	Console.WriteLine("Hello, World!");
	
	using var db = new «CaseFormat.LOWER_CAMEL.to(CaseFormat.UPPER_CAMEL, model.name)»Context();
	
	db.Database.EnsureDeleted();
	
	db.Database.EnsureCreated();
	
	Console.WriteLine("Updated Database!");
	'''	
}