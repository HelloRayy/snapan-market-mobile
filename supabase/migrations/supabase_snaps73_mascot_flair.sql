-- Migration: Add mascot_flair support for public.profiles and public.market_posts (SNAPS-13)
-- Allows users to persist their chosen mascot flair avatar badge.

-- 1. Add mascot_flair column to profiles table if not exists
alter table public.profiles 
  add column if not exists mascot_flair jsonb default null;

-- 2. Add mascot_flair column to market_posts table if not exists
alter table public.market_posts 
  add column if not exists mascot_flair jsonb default null;

-- 3. Comments for documentation
comment on column public.profiles.mascot_flair is 'Stores user active mascot flair bundle and emotion: {"bundle": "koala", "emotion": "delighted"}';
comment on column public.market_posts.mascot_flair is 'Stores post-specific mascot flair snapshot';
