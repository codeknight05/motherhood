-- ============================================================
-- Migration: Add user role and due_date to profiles
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Add role column to profiles
alter table public.profiles
  add column if not exists role text default 'parent'
    check (role in ('pregnant', 'parent', 'family'));

-- Add due_date for pregnant users
alter table public.profiles
  add column if not exists due_date date;

-- Add pregnancy_week computed helper (optional, for display)
alter table public.profiles
  add column if not exists pregnancy_week integer;

-- Make baby name optional (it already is nullable by default,
-- but let's be explicit)
alter table public.babies
  alter column name set default 'My Baby';
