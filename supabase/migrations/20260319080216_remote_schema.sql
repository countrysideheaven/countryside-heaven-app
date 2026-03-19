
  create table "public"."bookings" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid,
    "fraction_id" uuid,
    "user_id" uuid,
    "start_date" timestamp with time zone not null,
    "end_date" timestamp with time zone not null,
    "type" text not null,
    "is_outside_booking" boolean default false,
    "guest_name" text
      );



  create table "public"."documents" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "file_name" text not null,
    "file_url" text,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."favorites" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "property_id" bigint,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."favorites" enable row level security;


  create table "public"."fractions" (
    "id" uuid not null default gen_random_uuid(),
    "unit_id" uuid,
    "owner_id" uuid,
    "fraction_index" integer not null
      );



  create table "public"."kyc_documents" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "document_name" text not null,
    "status" text default 'Pending Verification'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."kyc_documents" enable row level security;


  create table "public"."portfolio" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "property_id" bigint,
    "fractions_owned" integer not null default 1,
    "purchase_price" numeric not null,
    "purchased_at" timestamp with time zone default now(),
    "room_number" text default 'TBD'::text
      );


alter table "public"."portfolio" enable row level security;


  create table "public"."rental_revenue" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "property_id" bigint,
    "amount" numeric not null,
    "payout_date" date not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."rental_revenue" enable row level security;


  create table "public"."units" (
    "id" uuid not null default gen_random_uuid(),
    "property_id" uuid,
    "name" text not null,
    "fraction_price" numeric not null
      );



  create table "public"."users" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text not null,
    "role" text not null,
    "my_referral_code" text not null,
    "referred_by_code" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."profiles" add column "phone_number" text;

alter table "public"."properties" drop column "image_url";

alter table "public"."properties" drop column "price";

alter table "public"."properties" drop column "status";

alter table "public"."properties" alter column "created_at" set default now();

alter table "public"."properties" alter column "created_at" drop not null;

alter table "public"."properties" alter column "id" set default gen_random_uuid();

alter table "public"."properties" alter column "id" drop identity;

alter table "public"."properties" alter column "id" set data type uuid using "id"::uuid;

CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id);

CREATE UNIQUE INDEX documents_pkey ON public.documents USING btree (id);

CREATE UNIQUE INDEX favorites_pkey ON public.favorites USING btree (id);

CREATE UNIQUE INDEX favorites_user_id_property_id_key ON public.favorites USING btree (user_id, property_id);

CREATE UNIQUE INDEX fractions_pkey ON public.fractions USING btree (id);

CREATE UNIQUE INDEX kyc_documents_pkey ON public.kyc_documents USING btree (id);

CREATE UNIQUE INDEX portfolio_pkey ON public.portfolio USING btree (id);

CREATE UNIQUE INDEX rental_revenue_pkey ON public.rental_revenue USING btree (id);

CREATE UNIQUE INDEX units_pkey ON public.units USING btree (id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_my_referral_code_key ON public.users USING btree (my_referral_code);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY using index "bookings_pkey";

alter table "public"."documents" add constraint "documents_pkey" PRIMARY KEY using index "documents_pkey";

alter table "public"."favorites" add constraint "favorites_pkey" PRIMARY KEY using index "favorites_pkey";

alter table "public"."fractions" add constraint "fractions_pkey" PRIMARY KEY using index "fractions_pkey";

alter table "public"."kyc_documents" add constraint "kyc_documents_pkey" PRIMARY KEY using index "kyc_documents_pkey";

alter table "public"."portfolio" add constraint "portfolio_pkey" PRIMARY KEY using index "portfolio_pkey";

alter table "public"."rental_revenue" add constraint "rental_revenue_pkey" PRIMARY KEY using index "rental_revenue_pkey";

alter table "public"."units" add constraint "units_pkey" PRIMARY KEY using index "units_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."bookings" add constraint "bookings_fraction_id_fkey" FOREIGN KEY (fraction_id) REFERENCES public.fractions(id) ON DELETE CASCADE not valid;

alter table "public"."bookings" validate constraint "bookings_fraction_id_fkey";

alter table "public"."bookings" add constraint "bookings_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE not valid;

alter table "public"."bookings" validate constraint "bookings_unit_id_fkey";

alter table "public"."bookings" add constraint "bookings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_user_id_fkey";

alter table "public"."documents" add constraint "documents_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."documents" validate constraint "documents_user_id_fkey";

alter table "public"."favorites" add constraint "favorites_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."favorites" validate constraint "favorites_user_id_fkey";

alter table "public"."favorites" add constraint "favorites_user_id_property_id_key" UNIQUE using index "favorites_user_id_property_id_key";

alter table "public"."fractions" add constraint "fractions_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."fractions" validate constraint "fractions_owner_id_fkey";

alter table "public"."fractions" add constraint "fractions_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE not valid;

alter table "public"."fractions" validate constraint "fractions_unit_id_fkey";

alter table "public"."kyc_documents" add constraint "kyc_documents_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."kyc_documents" validate constraint "kyc_documents_user_id_fkey";

alter table "public"."portfolio" add constraint "portfolio_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."portfolio" validate constraint "portfolio_user_id_fkey";

alter table "public"."rental_revenue" add constraint "rental_revenue_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."rental_revenue" validate constraint "rental_revenue_user_id_fkey";

alter table "public"."units" add constraint "units_property_id_fkey" FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE not valid;

alter table "public"."units" validate constraint "units_property_id_fkey";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_my_referral_code_key" UNIQUE using index "users_my_referral_code_key";

grant delete on table "public"."bookings" to "anon";

grant insert on table "public"."bookings" to "anon";

grant references on table "public"."bookings" to "anon";

grant select on table "public"."bookings" to "anon";

grant trigger on table "public"."bookings" to "anon";

grant truncate on table "public"."bookings" to "anon";

grant update on table "public"."bookings" to "anon";

grant delete on table "public"."bookings" to "authenticated";

grant insert on table "public"."bookings" to "authenticated";

grant references on table "public"."bookings" to "authenticated";

grant select on table "public"."bookings" to "authenticated";

grant trigger on table "public"."bookings" to "authenticated";

grant truncate on table "public"."bookings" to "authenticated";

grant update on table "public"."bookings" to "authenticated";

grant delete on table "public"."bookings" to "service_role";

grant insert on table "public"."bookings" to "service_role";

grant references on table "public"."bookings" to "service_role";

grant select on table "public"."bookings" to "service_role";

grant trigger on table "public"."bookings" to "service_role";

grant truncate on table "public"."bookings" to "service_role";

grant update on table "public"."bookings" to "service_role";

grant delete on table "public"."documents" to "anon";

grant insert on table "public"."documents" to "anon";

grant references on table "public"."documents" to "anon";

grant select on table "public"."documents" to "anon";

grant trigger on table "public"."documents" to "anon";

grant truncate on table "public"."documents" to "anon";

grant update on table "public"."documents" to "anon";

grant delete on table "public"."documents" to "authenticated";

grant insert on table "public"."documents" to "authenticated";

grant references on table "public"."documents" to "authenticated";

grant select on table "public"."documents" to "authenticated";

grant trigger on table "public"."documents" to "authenticated";

grant truncate on table "public"."documents" to "authenticated";

grant update on table "public"."documents" to "authenticated";

grant delete on table "public"."documents" to "service_role";

grant insert on table "public"."documents" to "service_role";

grant references on table "public"."documents" to "service_role";

grant select on table "public"."documents" to "service_role";

grant trigger on table "public"."documents" to "service_role";

grant truncate on table "public"."documents" to "service_role";

grant update on table "public"."documents" to "service_role";

grant delete on table "public"."favorites" to "anon";

grant insert on table "public"."favorites" to "anon";

grant references on table "public"."favorites" to "anon";

grant select on table "public"."favorites" to "anon";

grant trigger on table "public"."favorites" to "anon";

grant truncate on table "public"."favorites" to "anon";

grant update on table "public"."favorites" to "anon";

grant delete on table "public"."favorites" to "authenticated";

grant insert on table "public"."favorites" to "authenticated";

grant references on table "public"."favorites" to "authenticated";

grant select on table "public"."favorites" to "authenticated";

grant trigger on table "public"."favorites" to "authenticated";

grant truncate on table "public"."favorites" to "authenticated";

grant update on table "public"."favorites" to "authenticated";

grant delete on table "public"."favorites" to "service_role";

grant insert on table "public"."favorites" to "service_role";

grant references on table "public"."favorites" to "service_role";

grant select on table "public"."favorites" to "service_role";

grant trigger on table "public"."favorites" to "service_role";

grant truncate on table "public"."favorites" to "service_role";

grant update on table "public"."favorites" to "service_role";

grant delete on table "public"."fractions" to "anon";

grant insert on table "public"."fractions" to "anon";

grant references on table "public"."fractions" to "anon";

grant select on table "public"."fractions" to "anon";

grant trigger on table "public"."fractions" to "anon";

grant truncate on table "public"."fractions" to "anon";

grant update on table "public"."fractions" to "anon";

grant delete on table "public"."fractions" to "authenticated";

grant insert on table "public"."fractions" to "authenticated";

grant references on table "public"."fractions" to "authenticated";

grant select on table "public"."fractions" to "authenticated";

grant trigger on table "public"."fractions" to "authenticated";

grant truncate on table "public"."fractions" to "authenticated";

grant update on table "public"."fractions" to "authenticated";

grant delete on table "public"."fractions" to "service_role";

grant insert on table "public"."fractions" to "service_role";

grant references on table "public"."fractions" to "service_role";

grant select on table "public"."fractions" to "service_role";

grant trigger on table "public"."fractions" to "service_role";

grant truncate on table "public"."fractions" to "service_role";

grant update on table "public"."fractions" to "service_role";

grant delete on table "public"."kyc_documents" to "anon";

grant insert on table "public"."kyc_documents" to "anon";

grant references on table "public"."kyc_documents" to "anon";

grant select on table "public"."kyc_documents" to "anon";

grant trigger on table "public"."kyc_documents" to "anon";

grant truncate on table "public"."kyc_documents" to "anon";

grant update on table "public"."kyc_documents" to "anon";

grant delete on table "public"."kyc_documents" to "authenticated";

grant insert on table "public"."kyc_documents" to "authenticated";

grant references on table "public"."kyc_documents" to "authenticated";

grant select on table "public"."kyc_documents" to "authenticated";

grant trigger on table "public"."kyc_documents" to "authenticated";

grant truncate on table "public"."kyc_documents" to "authenticated";

grant update on table "public"."kyc_documents" to "authenticated";

grant delete on table "public"."kyc_documents" to "service_role";

grant insert on table "public"."kyc_documents" to "service_role";

grant references on table "public"."kyc_documents" to "service_role";

grant select on table "public"."kyc_documents" to "service_role";

grant trigger on table "public"."kyc_documents" to "service_role";

grant truncate on table "public"."kyc_documents" to "service_role";

grant update on table "public"."kyc_documents" to "service_role";

grant delete on table "public"."portfolio" to "anon";

grant insert on table "public"."portfolio" to "anon";

grant references on table "public"."portfolio" to "anon";

grant select on table "public"."portfolio" to "anon";

grant trigger on table "public"."portfolio" to "anon";

grant truncate on table "public"."portfolio" to "anon";

grant update on table "public"."portfolio" to "anon";

grant delete on table "public"."portfolio" to "authenticated";

grant insert on table "public"."portfolio" to "authenticated";

grant references on table "public"."portfolio" to "authenticated";

grant select on table "public"."portfolio" to "authenticated";

grant trigger on table "public"."portfolio" to "authenticated";

grant truncate on table "public"."portfolio" to "authenticated";

grant update on table "public"."portfolio" to "authenticated";

grant delete on table "public"."portfolio" to "service_role";

grant insert on table "public"."portfolio" to "service_role";

grant references on table "public"."portfolio" to "service_role";

grant select on table "public"."portfolio" to "service_role";

grant trigger on table "public"."portfolio" to "service_role";

grant truncate on table "public"."portfolio" to "service_role";

grant update on table "public"."portfolio" to "service_role";

grant delete on table "public"."rental_revenue" to "anon";

grant insert on table "public"."rental_revenue" to "anon";

grant references on table "public"."rental_revenue" to "anon";

grant select on table "public"."rental_revenue" to "anon";

grant trigger on table "public"."rental_revenue" to "anon";

grant truncate on table "public"."rental_revenue" to "anon";

grant update on table "public"."rental_revenue" to "anon";

grant delete on table "public"."rental_revenue" to "authenticated";

grant insert on table "public"."rental_revenue" to "authenticated";

grant references on table "public"."rental_revenue" to "authenticated";

grant select on table "public"."rental_revenue" to "authenticated";

grant trigger on table "public"."rental_revenue" to "authenticated";

grant truncate on table "public"."rental_revenue" to "authenticated";

grant update on table "public"."rental_revenue" to "authenticated";

grant delete on table "public"."rental_revenue" to "service_role";

grant insert on table "public"."rental_revenue" to "service_role";

grant references on table "public"."rental_revenue" to "service_role";

grant select on table "public"."rental_revenue" to "service_role";

grant trigger on table "public"."rental_revenue" to "service_role";

grant truncate on table "public"."rental_revenue" to "service_role";

grant update on table "public"."rental_revenue" to "service_role";

grant delete on table "public"."units" to "anon";

grant insert on table "public"."units" to "anon";

grant references on table "public"."units" to "anon";

grant select on table "public"."units" to "anon";

grant trigger on table "public"."units" to "anon";

grant truncate on table "public"."units" to "anon";

grant update on table "public"."units" to "anon";

grant delete on table "public"."units" to "authenticated";

grant insert on table "public"."units" to "authenticated";

grant references on table "public"."units" to "authenticated";

grant select on table "public"."units" to "authenticated";

grant trigger on table "public"."units" to "authenticated";

grant truncate on table "public"."units" to "authenticated";

grant update on table "public"."units" to "authenticated";

grant delete on table "public"."units" to "service_role";

grant insert on table "public"."units" to "service_role";

grant references on table "public"."units" to "service_role";

grant select on table "public"."units" to "service_role";

grant trigger on table "public"."units" to "service_role";

grant truncate on table "public"."units" to "service_role";

grant update on table "public"."units" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


  create policy "Users can manage their own favorites"
  on "public"."favorites"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));



  create policy "Users manage own KYC"
  on "public"."kyc_documents"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));



  create policy "Users can manage their own portfolio"
  on "public"."portfolio"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));



  create policy "Allow authenticated users to read profiles"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Users see own revenue"
  on "public"."rental_revenue"
  as permissive
  for all
  to public
using ((auth.uid() = user_id));



