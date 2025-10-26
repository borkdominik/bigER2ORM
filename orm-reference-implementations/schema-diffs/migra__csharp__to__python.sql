alter table "public"."certificate" drop constraint "PK_certificate";

alter table "public"."course" drop constraint "pk_course";

alter table "public"."graduate_student_card" drop constraint "PK_graduate_student_card";

alter table "public"."lecturer" drop constraint "PK_lecturer";

alter table "public"."person" drop constraint "PK_person";

alter table "public"."recognized_certificate" drop constraint "PK_recognized_certificate";

alter table "public"."student" drop constraint "PK_student";

alter table "public"."student_card" drop constraint "PK_student_card";

alter table "public"."student_card_study_program" drop constraint "pk_student_card_study_program";

alter table "public"."student_study_program" drop constraint "pk_student_study_program";

alter table "public"."study_program" drop constraint "pk_study_program";

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

CREATE UNIQUE INDEX certificate_pkey ON public.certificate USING btree (id);

CREATE UNIQUE INDEX course_pkey ON public.course USING btree (id);

CREATE UNIQUE INDEX graduate_student_card_pkey ON public.graduate_student_card USING btree (card_nr, card_version);

CREATE UNIQUE INDEX lecturer_pkey ON public.lecturer USING btree (id);

CREATE UNIQUE INDEX person_pkey ON public.person USING btree (id);

CREATE UNIQUE INDEX recognized_certificate_pkey ON public.recognized_certificate USING btree (id);

CREATE UNIQUE INDEX student_card_pkey ON public.student_card USING btree (card_nr, card_version);

CREATE UNIQUE INDEX student_card_study_program_pkey ON public.student_card_study_program USING btree (study_program_id, student_card_card_nr, student_card_card_version);

CREATE UNIQUE INDEX student_pkey ON public.student USING btree (id);

CREATE UNIQUE INDEX student_student_card_card_nr_student_card_card_version_key ON public.student USING btree (student_card_card_nr, student_card_card_version);

CREATE UNIQUE INDEX student_study_program_pkey ON public.student_study_program USING btree (student_id, study_program_id);

CREATE UNIQUE INDEX study_program_pkey ON public.study_program USING btree (id);

alter table "public"."certificate" add constraint "certificate_pkey" PRIMARY KEY using index "certificate_pkey";

alter table "public"."course" add constraint "course_pkey" PRIMARY KEY using index "course_pkey";

alter table "public"."graduate_student_card" add constraint "graduate_student_card_pkey" PRIMARY KEY using index "graduate_student_card_pkey";

alter table "public"."lecturer" add constraint "lecturer_pkey" PRIMARY KEY using index "lecturer_pkey";

alter table "public"."person" add constraint "person_pkey" PRIMARY KEY using index "person_pkey";

alter table "public"."recognized_certificate" add constraint "recognized_certificate_pkey" PRIMARY KEY using index "recognized_certificate_pkey";

alter table "public"."student" add constraint "student_pkey" PRIMARY KEY using index "student_pkey";

alter table "public"."student_card" add constraint "student_card_pkey" PRIMARY KEY using index "student_card_pkey";

alter table "public"."student_card_study_program" add constraint "student_card_study_program_pkey" PRIMARY KEY using index "student_card_study_program_pkey";

alter table "public"."student_study_program" add constraint "student_study_program_pkey" PRIMARY KEY using index "student_study_program_pkey";

alter table "public"."study_program" add constraint "study_program_pkey" PRIMARY KEY using index "study_program_pkey";

alter table "public"."student" add constraint "student_student_card_card_nr_student_card_card_version_key" UNIQUE using index "student_student_card_card_nr_student_card_card_version_key";


