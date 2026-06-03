-- ═══════════════════════════════════════════════════════════════════════════
-- Push Notification Database Triggers & Automation
-- Run this script in the Supabase SQL Editor.
-- ═══════════════════════════════════════════════════════════════════════════

-- Ensure the pg_net extension is enabled (for making HTTP requests from SQL)
create extension if not exists pg_net;

-- ── 1. Generic Push Notification Helper ──────────────────────────────────────
-- Call this function from any SQL code to send a push notification.
create or replace function public.send_push_notification(
    title text,
    body text,
    user_ids uuid[] default null,
    send_to_all boolean default false,
    custom_data jsonb default '{}'
)
returns void as $$
declare
    payload jsonb;
    project_ref text;
    supabase_url text;
    anon_key text;
begin
    -- 1. Construct the notification payload
    payload := jsonb_build_object(
        'title', title,
        'body', body,
        'data', custom_data
    );

    if send_to_all then
        payload := payload || jsonb_build_object('sendToAll', true);
    elsif user_ids is not null then
        payload := payload || jsonb_build_object('userIds', user_ids);
    end if;

    -- 2. Extract current project URL & keys from settings
    -- In Supabase, the active project URL can be constructed or obtained from configuration
    supabase_url := current_setting('request.headers', true)::jsonb->>'origin';
    
    -- Fallback: Replace <your-project-ref> with your actual Supabase project reference if needed
    -- E.g., 'https://yourprojectref.functions.supabase.co/send-push-notification'
    -- If executing inside a request context, it automatically resolves. Otherwise we use a fallback config.
    project_ref := 'wadscjqpqidtmxnjmxea'; -- UPDATE THIS with your Supabase Project Ref

    -- 3. Trigger HTTP POST via pg_net (asynchronous, non-blocking)
    -- It calls our edge function `send-push-notification`
    perform net.http_post(
        url := 'https://' || project_ref || '.functions.supabase.co/send-push-notification',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            -- Uses service role to bypass auth, or uses anon key
            'Authorization', 'Bearer ' || current_setting('request.jwt.claim.role', true)
        ),
        body := payload::text
    );
end;
$$ language plpgsql security definer;


-- ── 2. Automatic Community Post Notification Trigger ──────────────────────────
-- Automatically notifies all members of a community when a new post is added.
create or replace function public.on_new_community_post_trigger()
returns trigger as $$
declare
    community_name text;
    post_author_name text;
    member_ids uuid[];
    truncated_content text;
    project_ref text := 'wadscjqpqidtmxnjmxea'; -- UPDATE THIS with your Supabase Project Ref
    payload jsonb;
begin
    -- 1. Fetch community name
    select name into community_name 
    from public.communities 
    where id = NEW.community_id;

    -- 2. Fetch author's name
    select coalesce(display_name, 'A user') into post_author_name 
    from public.profiles 
    where id = NEW.user_id;

    -- 3. Fetch all other members of this community (excluding the author)
    select array_agg(user_id) into member_ids
    from public.community_members
    where community_id = NEW.community_id 
      and user_id != NEW.user_id;

    -- 4. Truncate post content for notification body
    truncated_content := substring(NEW.content from 1 for 100);
    if length(NEW.content) > 100 then
        truncated_content := truncated_content || '...';
    end if;

    -- 5. Only proceed if there are other members to notify
    if member_ids is not null and array_length(member_ids, 1) > 0 then
        payload := jsonb_build_object(
            'title', post_author_name || ' posted in ' || community_name,
            'body', truncated_content,
            'userIds', member_ids,
            'data', jsonb_build_object(
                'click_action', 'FLUTTER_NOTIFICATION_CLICK',
                'route', '/community/' || NEW.community_id,
                'post_id', NEW.id::text
            )
        );

        -- Send HTTP POST to FCM Edge Function via pg_net
        perform net.http_post(
            url := 'https://' || project_ref || '.functions.supabase.co/send-push-notification',
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                -- Use your service role key in production webhooks
                'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhZHNjanFwcWlkdG14bmpteGVhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3ODY1ODg4OCwiZXhwIjoyMDk0MjM0ODg4fQ.gZnEDdW7BMCs4iIeCvHU2CmouPDlYVNTneTsMfQ3aAI'
            ),
            body := payload::text
        );
    end if;

    return NEW;
end;
$$ language plpgsql security definer;

-- Create the trigger on the community_posts table
drop trigger if exists trigger_new_community_post on public.community_posts;
create trigger trigger_new_community_post
    after insert on public.community_posts
    for each row execute function public.on_new_community_post_trigger();
