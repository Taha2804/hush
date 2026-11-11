-- Word descriptions for players who get the real word. Safe to re-run.
-- The seed file fills private.word_bank.description.
begin;

alter table private.word_bank add column if not exists description text;

create or replace function public.get_my_assignment(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_record public.private_player_assignments;
    v_description text;
begin
    select * into v_record from public.private_player_assignments
    where session_id = p_session_id and player_id = auth.uid();
    if not found then raise exception 'You are not in this game.'; end if;

    -- Only the crew sees what the word means; it would hand the imposter the answer.
    if not v_record.is_imposter then
        select w.description into v_description
        from private.session_words sw join private.word_bank w on w.id = sw.word_id
        where sw.session_id = p_session_id;
    end if;

    return jsonb_build_object(
        'is_imposter', v_record.is_imposter,
        'word', v_record.secret_word,
        'hint', v_record.hint,
        'fake_word', v_record.fake_word,
        'description', v_description,
        'teammates', v_record.teammates
    );
end;
$$;

revoke execute on function public.get_my_assignment(uuid) from public, anon;
grant execute on function public.get_my_assignment(uuid) to authenticated;

notify pgrst, 'reload schema';
commit;
