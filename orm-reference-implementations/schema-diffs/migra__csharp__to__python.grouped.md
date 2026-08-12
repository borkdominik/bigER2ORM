## public.certificate

```sql
alter table "public"."certificate" drop constraint "PK_certificate";

CREATE UNIQUE INDEX certificate_pkey ON public.certificate USING btree (id);

alter table "public"."certificate" add constraint "certificate_pkey" PRIMARY KEY using index "certificate_pkey";
```

## public.course

```sql
alter table "public"."course" drop constraint "pk_course";

CREATE UNIQUE INDEX course_pkey ON public.course USING btree (id);

alter table "public"."course" add constraint "course_pkey" PRIMARY KEY using index "course_pkey";
```

## public.graduate_student_card

```sql
alter table "public"."graduate_student_card" drop constraint "PK_graduate_student_card";

CREATE UNIQUE INDEX graduate_student_card_pkey ON public.graduate_student_card USING btree (card_nr, card_version);

alter table "public"."graduate_student_card" add constraint "graduate_student_card_pkey" PRIMARY KEY using index "graduate_student_card_pkey";
```

## public.lecturer

```sql
alter table "public"."lecturer" drop constraint "PK_lecturer";

CREATE UNIQUE INDEX lecturer_pkey ON public.lecturer USING btree (id);

alter table "public"."lecturer" add constraint "lecturer_pkey" PRIMARY KEY using index "lecturer_pkey";
```

## public.person

```sql
alter table "public"."person" drop constraint "PK_person";

CREATE UNIQUE INDEX person_pkey ON public.person USING btree (id);

alter table "public"."person" add constraint "person_pkey" PRIMARY KEY using index "person_pkey";
```

## public.recognized_certificate

```sql
alter table "public"."recognized_certificate" drop constraint "PK_recognized_certificate";

CREATE UNIQUE INDEX recognized_certificate_pkey ON public.recognized_certificate USING btree (id);

alter table "public"."recognized_certificate" add constraint "recognized_certificate_pkey" PRIMARY KEY using index "recognized_certificate_pkey";
```

## public.student

```sql
alter table "public"."student" drop constraint "PK_student";

CREATE UNIQUE INDEX student_pkey ON public.student USING btree (id);

CREATE UNIQUE INDEX student_student_card_card_nr_student_card_card_version_key ON public.student USING btree (student_card_card_nr, student_card_card_version);

alter table "public"."student" add constraint "student_pkey" PRIMARY KEY using index "student_pkey";

alter table "public"."student" add constraint "student_student_card_card_nr_student_card_card_version_key" UNIQUE using index "student_student_card_card_nr_student_card_card_version_key";
```

## public.student_card

```sql
alter table "public"."student_card" drop constraint "PK_student_card";

CREATE UNIQUE INDEX student_card_pkey ON public.student_card USING btree (card_nr, card_version);

alter table "public"."student_card" add constraint "student_card_pkey" PRIMARY KEY using index "student_card_pkey";
```

## public.student_card_study_program

```sql
alter table "public"."student_card_study_program" drop constraint "pk_student_card_study_program";

CREATE UNIQUE INDEX student_card_study_program_pkey ON public.student_card_study_program USING btree (study_program_id, student_card_card_nr, student_card_card_version);

alter table "public"."student_card_study_program" add constraint "student_card_study_program_pkey" PRIMARY KEY using index "student_card_study_program_pkey";
```

## public.student_study_program

```sql
alter table "public"."student_study_program" drop constraint "pk_student_study_program";

CREATE UNIQUE INDEX student_study_program_pkey ON public.student_study_program USING btree (student_id, study_program_id);

alter table "public"."student_study_program" add constraint "student_study_program_pkey" PRIMARY KEY using index "student_study_program_pkey";
```

## public.study_program

```sql
alter table "public"."study_program" drop constraint "pk_study_program";

CREATE UNIQUE INDEX study_program_pkey ON public.study_program USING btree (id);

alter table "public"."study_program" add constraint "study_program_pkey" PRIMARY KEY using index "study_program_pkey";
```

## (other)

```sql
drop index if exists "public"."PK_certificate";

drop index if exists "public"."PK_graduate_student_card";

drop index if exists "public"."PK_lecturer";

drop index if exists "public"."PK_person";

drop index if exists "public"."PK_recognized_certificate";

drop index if exists "public"."PK_student";

drop index if exists "public"."PK_student_card";

drop index if exists "public"."pk_course";

drop index if exists "public"."pk_student_card_study_program";

drop index if exists "public"."pk_student_study_program";

drop index if exists "public"."pk_study_program";
```
