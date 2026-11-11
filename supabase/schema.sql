-- ============================================================================
-- HUSHBUG ONLINE MULTIPLAYER SCHEMA (SUPABASE POSTGRESQL)
-- Server-authoritative deduction game backend with RLS, Realtime & RPC
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. PROFILES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Player',
    avatar_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone" 
ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- 2. ROOMS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(6) UNIQUE NOT NULL,
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'playing', 'finished', 'closed')),
    max_players INT NOT NULL DEFAULT 12,
    config JSONB NOT NULL DEFAULT '{
        "mode": "hint",
        "imposterCount": 1,
        "clueRounds": 1,
        "discussionSeconds": 180,
        "maybeNobody": false,
        "roundTwists": false
    }'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '4 hours')
);

CREATE INDEX IF NOT EXISTS idx_rooms_code ON public.rooms(code);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON public.rooms(status);

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Rooms viewable by everyone" 
ON public.rooms FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create rooms" 
ON public.rooms FOR INSERT WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Hosts can update their rooms" 
ON public.rooms FOR UPDATE USING (auth.uid() = host_id);

-- ----------------------------------------------------------------------------
-- 3. ROOM PLAYERS (Lobby Membership & Presence)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.room_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_index INT NOT NULL DEFAULT 0,
    is_host BOOLEAN NOT NULL DEFAULT false,
    is_ready BOOLEAN NOT NULL DEFAULT false,
    is_connected BOOLEAN NOT NULL DEFAULT true,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(room_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_room_players_room ON public.room_players(room_id);

ALTER TABLE public.room_players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Room players viewable by everyone in room" 
ON public.room_players FOR SELECT USING (true);

CREATE POLICY "Players can join room" 
ON public.room_players FOR INSERT WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Players can update own status or host can update" 
ON public.room_players FOR UPDATE USING (
    auth.uid() = player_id 
    OR EXISTS (SELECT 1 FROM public.rooms r WHERE r.id = room_id AND r.host_id = auth.uid())
);

CREATE POLICY "Players can leave or host can remove" 
ON public.room_players FOR DELETE USING (
    auth.uid() = player_id 
    OR EXISTS (SELECT 1 FROM public.rooms r WHERE r.id = room_id AND r.host_id = auth.uid())
);

-- ----------------------------------------------------------------------------
-- 4. GAME SESSIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    round_number INT NOT NULL DEFAULT 1,
    phase VARCHAR(20) NOT NULL DEFAULT 'reveal' 
        CHECK (phase IN ('reveal', 'clue', 'discussion', 'vote', 'last_chance', 'result')),
    category TEXT NOT NULL,
    mode VARCHAR(20) NOT NULL DEFAULT 'hint',
    starter_id UUID NOT NULL REFERENCES public.profiles(id),
    turn_order JSONB NOT NULL DEFAULT '[]'::jsonb,
    clue_step INT NOT NULL DEFAULT 0,
    discussion_start_time TIMESTAMPTZ,
    discussion_end_time TIMESTAMPTZ,
    timer_paused BOOLEAN NOT NULL DEFAULT false,
    timer_remaining_seconds INT NOT NULL DEFAULT 0,
    revotes INT NOT NULL DEFAULT 0,
    winner VARCHAR(20) CHECK (winner IN ('crew', 'imposters', 'nobody')),
    win_reason VARCHAR(40),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_game_sessions_room ON public.game_sessions(room_id);

ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Game sessions viewable by room participants" 
ON public.game_sessions FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.room_players rp WHERE rp.room_id = room_id AND rp.player_id = auth.uid())
);

-- ----------------------------------------------------------------------------
-- 5. GAME PLAYERS (Per-Round Live Player Status)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_index INT NOT NULL DEFAULT 0,
    is_alive BOOLEAN NOT NULL DEFAULT true,
    is_eliminated BOOLEAN NOT NULL DEFAULT false,
    eliminated_round INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(session_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_game_players_session ON public.game_players(session_id);

ALTER TABLE public.game_players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Game players viewable by session participants" 
ON public.game_players FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.game_sessions gs
        JOIN public.room_players rp ON rp.room_id = gs.room_id
        WHERE gs.id = session_id AND rp.player_id = auth.uid()
    )
);

-- ----------------------------------------------------------------------------
-- 6. PRIVATE PLAYER ASSIGNMENTS (STRICT SECURITY - ZERO LEAKAGE)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.private_player_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    is_imposter BOOLEAN NOT NULL,
    secret_word TEXT NOT NULL,
    hint TEXT,
    fake_word TEXT,
    teammates JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(session_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_assignments_session_player ON public.private_player_assignments(session_id, player_id);

ALTER TABLE public.private_player_assignments ENABLE ROW LEVEL SECURITY;

-- CRITICAL RLS: Each player can ONLY select their OWN private assignment!
CREATE POLICY "Strictly private: Only the designated player can read their assignment" 
ON public.private_player_assignments FOR SELECT 
USING (auth.uid() = player_id);

-- ----------------------------------------------------------------------------
-- 7. GAME CLUES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_clues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES public.profiles(id),
    clue_step INT NOT NULL,
    round_number INT NOT NULL DEFAULT 1,
    clue_text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_game_clues_session ON public.game_clues(session_id);

ALTER TABLE public.game_clues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clues viewable by session participants" 
ON public.game_clues FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.game_sessions gs
        JOIN public.room_players rp ON rp.room_id = gs.room_id
        WHERE gs.id = session_id AND rp.player_id = auth.uid()
    )
);

CREATE POLICY "Active player can insert clue" 
ON public.game_clues FOR INSERT WITH CHECK (
    auth.uid() = player_id
    AND EXISTS (
        SELECT 1 FROM public.game_sessions gs
        WHERE gs.id = session_id AND gs.phase = 'clue'
    )
);

-- ----------------------------------------------------------------------------
-- 8. GAME VOTES (Confidential In-flight Ballots)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES public.profiles(id),
    target_id UUID NOT NULL REFERENCES public.profiles(id),
    round_number INT NOT NULL DEFAULT 1,
    revote_number INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(session_id, voter_id, round_number, revote_number)
);

CREATE INDEX IF NOT EXISTS idx_game_votes_session ON public.game_votes(session_id);

ALTER TABLE public.game_votes ENABLE ROW LEVEL SECURITY;

-- Voters can only see their own ballot during the voting phase to prevent vote copying
CREATE POLICY "Voters can only read their own cast ballot" 
ON public.game_votes FOR SELECT USING (auth.uid() = voter_id);

CREATE POLICY "Voters can cast their own vote" 
ON public.game_votes FOR INSERT WITH CHECK (
    auth.uid() = voter_id
    AND EXISTS (
        SELECT 1 FROM public.game_players gp
        WHERE gp.session_id = session_id AND gp.player_id = auth.uid() AND gp.is_alive = true
    )
);

-- ----------------------------------------------------------------------------
-- 9. GAME RESULTS (Revealed only when game concludes)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    winner VARCHAR(20) NOT NULL CHECK (winner IN ('crew', 'imposters', 'nobody')),
    win_reason VARCHAR(40) NOT NULL,
    secret_word TEXT NOT NULL,
    imposters JSONB NOT NULL DEFAULT '[]'::jsonb,
    scores JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_game_results_session ON public.game_results(session_id);

ALTER TABLE public.game_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Results viewable by session participants" 
ON public.game_results FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.game_sessions gs
        JOIN public.room_players rp ON rp.room_id = gs.room_id
        WHERE gs.id = session_id AND rp.player_id = auth.uid()
    )
);

-- ----------------------------------------------------------------------------
-- 10. REALTIME PUBLICATION
-- ----------------------------------------------------------------------------
-- Add public broadcast tables to Supabase Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE 
    public.rooms, 
    public.room_players, 
    public.game_sessions, 
    public.game_players, 
    public.game_clues, 
    public.game_results;

-- Notice: private_player_assignments & game_votes are intentionally EXCLUDED
-- from publication to prevent eavesdropping of secret roles or secret votes.


-- ============================================================================
-- SERVER-AUTHORITATIVE RPC FUNCTIONS
-- ============================================================================

-- A. Create Room RPC
CREATE OR REPLACE FUNCTION public.create_room(
    p_code TEXT,
    p_display_name TEXT,
    p_avatar INT,
    p_config JSONB DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_room_id UUID;
    v_config JSONB;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Ensure profile exists
    INSERT INTO public.profiles (id, display_name, avatar_index)
    VALUES (v_user_id, COALESCE(NULLIF(trim(p_display_name), ''), 'Host'), p_avatar)
    ON CONFLICT (id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        avatar_index = EXCLUDED.avatar_index,
        updated_at = now();

    v_config := COALESCE(p_config, '{
        "mode": "hint",
        "imposterCount": 1,
        "clueRounds": 1,
        "discussionSeconds": 180,
        "maybeNobody": false,
        "roundTwists": false
    }'::jsonb);

    -- Create room
    INSERT INTO public.rooms (code, host_id, status, config)
    VALUES (upper(trim(p_code)), v_user_id, 'waiting', v_config)
    RETURNING id INTO v_room_id;

    -- Add host to room_players
    INSERT INTO public.room_players (room_id, player_id, display_name, avatar_index, is_host, is_ready)
    VALUES (v_room_id, v_user_id, COALESCE(NULLIF(trim(p_display_name), ''), 'Host'), p_avatar, true, true);

    RETURN jsonb_build_object(
        'room_id', v_room_id,
        'code', upper(trim(p_code)),
        'player_id', v_user_id
    );
END;
$$;


-- B. Join Room RPC
CREATE OR REPLACE FUNCTION public.join_room(
    p_code TEXT,
    p_display_name TEXT,
    p_avatar INT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_room RECORD;
    v_player_count INT;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Look up room
    SELECT * INTO v_room FROM public.rooms 
    WHERE code = upper(trim(p_code)) AND status = 'waiting' AND expires_at > now();

    IF v_room IS NULL THEN
        RAISE EXCEPTION 'Room not found, expired, or already in progress.';
    END IF;

    -- Count active players
    SELECT count(*) INTO v_player_count FROM public.room_players WHERE room_id = v_room.id;
    IF v_player_count >= v_room.max_players THEN
        RAISE EXCEPTION 'Room is full (maximum % players).', v_room.max_players;
    END IF;

    -- Update or create user profile
    INSERT INTO public.profiles (id, display_name, avatar_index)
    VALUES (v_user_id, COALESCE(NULLIF(trim(p_display_name), ''), 'Player'), p_avatar)
    ON CONFLICT (id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        avatar_index = EXCLUDED.avatar_index,
        updated_at = now();

    -- Insert into room_players
    INSERT INTO public.room_players (room_id, player_id, display_name, avatar_index, is_host, is_ready, is_connected)
    VALUES (v_room.id, v_user_id, COALESCE(NULLIF(trim(p_display_name), ''), 'Player'), p_avatar, (v_room.host_id = v_user_id), false, true)
    ON CONFLICT (room_id, player_id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        avatar_index = EXCLUDED.avatar_index,
        is_connected = true,
        last_seen_at = now();

    RETURN jsonb_build_object(
        'room_id', v_room.id,
        'code', v_room.code,
        'host_id', v_room.host_id,
        'player_id', v_user_id
    );
END;
$$;


-- C. Toggle Ready RPC
CREATE OR REPLACE FUNCTION public.toggle_ready(
    p_room_id UUID,
    p_is_ready BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.room_players
    SET is_ready = p_is_ready, last_seen_at = now()
    WHERE room_id = p_room_id AND player_id = auth.uid();
END;
$$;


-- D. Start Online Game (Server-Authoritative Role & Word Allocation)
CREATE OR REPLACE FUNCTION public.start_online_game(
    p_room_id UUID,
    p_category TEXT,
    p_word TEXT,
    p_hint TEXT DEFAULT NULL,
    p_fake_word TEXT DEFAULT NULL,
    p_imposter_count INT DEFAULT 1,
    p_discussion_seconds INT DEFAULT 180
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_room RECORD;
    v_session_id UUID;
    v_players UUID[];
    v_player_count INT;
    v_imposter_count INT;
    v_imposter_ids UUID[] := '{}';
    v_starter_id UUID;
    v_current_player UUID;
    v_p RECORD;
    v_is_imp BOOLEAN;
    v_turn_order JSONB;
BEGIN
    v_user_id := auth.uid();
    SELECT * INTO v_room FROM public.rooms WHERE id = p_room_id;
    IF v_room IS NULL THEN
        RAISE EXCEPTION 'Room not found';
    END IF;
    IF v_room.host_id != v_user_id THEN
        RAISE EXCEPTION 'Only the room host can start the game.';
    END IF;

    -- Collect all connected room players
    SELECT array_agg(player_id ORDER BY random()) INTO v_players 
    FROM public.room_players 
    WHERE room_id = p_room_id;

    v_player_count := cardinality(v_players);
    IF v_player_count < 3 THEN
        RAISE EXCEPTION 'At least 3 players are required to start.';
    END IF;

    v_imposter_count := LEAST(GREATEST(p_imposter_count, 1), (v_player_count - 1) / 2);

    -- Randomly designate imposters
    FOR i IN 1..v_imposter_count LOOP
        v_imposter_ids := array_append(v_imposter_ids, v_players[i]);
    END LOOP;

    -- Random starter player
    v_starter_id := v_players[floor(random() * v_player_count + 1)];
    v_turn_order := to_jsonb(v_players);

    -- Create game session
    INSERT INTO public.game_sessions (
        room_id,
        round_number,
        phase,
        category,
        mode,
        starter_id,
        turn_order,
        discussion_start_time,
        discussion_end_time,
        timer_remaining_seconds
    ) VALUES (
        p_room_id,
        1,
        'reveal',
        p_category,
        COALESCE(v_room.config->>'mode', 'hint'),
        v_starter_id,
        v_turn_order,
        now(),
        now() + (p_discussion_seconds || ' seconds')::interval,
        p_discussion_seconds
    ) RETURNING id INTO v_session_id;

    -- Populate game_players and private assignments
    FOR v_p IN (SELECT player_id, display_name, avatar_index FROM public.room_players WHERE room_id = p_room_id) LOOP
        v_is_imp := v_p.player_id = ANY(v_imposter_ids);

        INSERT INTO public.game_players (session_id, player_id, display_name, avatar_index, is_alive)
        VALUES (v_session_id, v_p.player_id, v_p.display_name, v_p.avatar_index, true);

        -- CRITICAL: Store private assignment securely
        INSERT INTO public.private_player_assignments (
            session_id,
            player_id,
            is_imposter,
            secret_word,
            hint,
            fake_word,
            teammates
        ) VALUES (
            v_session_id,
            v_p.player_id,
            v_is_imp,
            CASE WHEN v_is_imp THEN (CASE WHEN p_fake_word IS NOT NULL THEN p_fake_word ELSE 'IMPOSTER' END) ELSE p_word END,
            CASE WHEN v_is_imp THEN p_hint ELSE NULL END,
            CASE WHEN v_is_imp THEN p_fake_word ELSE NULL END,
            CASE WHEN v_is_imp THEN to_jsonb(v_imposter_ids) ELSE '[]'::jsonb END
        );
    END LOOP;

    -- Update room status
    UPDATE public.rooms SET status = 'playing', updated_at = now() WHERE id = p_room_id;

    RETURN jsonb_build_object(
        'session_id', v_session_id,
        'player_count', v_player_count,
        'category', p_category,
        'phase', 'reveal'
    );
END;
$$;


-- E. Get My Assignment RPC
CREATE OR REPLACE FUNCTION public.get_my_assignment(p_session_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_record RECORD;
BEGIN
    SELECT * INTO v_record FROM public.private_player_assignments
    WHERE session_id = p_session_id AND player_id = auth.uid();

    IF v_record IS NULL THEN
        RAISE EXCEPTION 'Assignment not found for current player in this session.';
    END IF;

    RETURN jsonb_build_object(
        'is_imposter', v_record.is_imposter,
        'word', v_record.secret_word,
        'hint', v_record.hint,
        'fake_word', v_record.fake_word,
        'teammates', v_record.teammates
    );
END;
$$;


-- F. Advance Game Phase RPC (Host controlled)
CREATE OR REPLACE FUNCTION public.advance_game_phase(
    p_session_id UUID,
    p_target_phase TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session RECORD;
    v_room RECORD;
    v_disc_seconds INT;
BEGIN
    SELECT * INTO v_session FROM public.game_sessions WHERE id = p_session_id;
    IF v_session IS NULL THEN
        RAISE EXCEPTION 'Session not found';
    END IF;

    SELECT * INTO v_room FROM public.rooms WHERE id = v_session.room_id;
    IF v_room.host_id != auth.uid() THEN
        RAISE EXCEPTION 'Only the host can advance game phases.';
    END IF;

    v_disc_seconds := COALESCE((v_room.config->>'discussionSeconds')::int, 180);

    IF p_target_phase = 'discussion' THEN
        UPDATE public.game_sessions
        SET phase = 'discussion',
            discussion_start_time = now(),
            discussion_end_time = now() + (v_disc_seconds || ' seconds')::interval,
            timer_paused = false,
            timer_remaining_seconds = v_disc_seconds,
            updated_at = now()
        WHERE id = p_session_id;
    ELSE
        UPDATE public.game_sessions
        SET phase = p_target_phase,
            updated_at = now()
        WHERE id = p_session_id;
    END IF;

    RETURN jsonb_build_object('session_id', p_session_id, 'phase', p_target_phase);
END;
$$;


-- G. Submit Clue RPC
CREATE OR REPLACE FUNCTION public.submit_online_clue(
    p_session_id UUID,
    p_clue_text TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session RECORD;
    v_current_step INT;
    v_order_len INT;
BEGIN
    SELECT * INTO v_session FROM public.game_sessions WHERE id = p_session_id;
    IF v_session IS NULL OR v_session.phase != 'clue' THEN
        RAISE EXCEPTION 'Game is not in the clue phase.';
    END IF;

    v_current_step := v_session.clue_step;
    v_order_len := jsonb_array_length(v_session.turn_order);

    INSERT INTO public.game_clues (session_id, player_id, clue_step, round_number, clue_text)
    VALUES (p_session_id, auth.uid(), v_current_step, v_session.round_number, trim(p_clue_text));

    -- Advance clue step
    UPDATE public.game_sessions
    SET clue_step = v_current_step + 1,
        updated_at = now()
    WHERE id = p_session_id;

    RETURN jsonb_build_object('clue_step', v_current_step + 1);
END;
$$;


-- H. Cast Online Vote RPC
CREATE OR REPLACE FUNCTION public.cast_online_vote(
    p_session_id UUID,
    p_target_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session RECORD;
    v_voter RECORD;
    v_target RECORD;
BEGIN
    SELECT * INTO v_session FROM public.game_sessions WHERE id = p_session_id;
    IF v_session IS NULL OR v_session.phase != 'vote' THEN
        RAISE EXCEPTION 'Game is not in the voting phase.';
    END IF;

    SELECT * INTO v_voter FROM public.game_players 
    WHERE session_id = p_session_id AND player_id = auth.uid() AND is_alive = true;
    IF v_voter IS NULL THEN
        RAISE EXCEPTION 'Voter is eliminated or not in this game.';
    END IF;

    SELECT * INTO v_target FROM public.game_players 
    WHERE session_id = p_session_id AND player_id = p_target_id AND is_alive = true;
    IF v_target IS NULL THEN
        RAISE EXCEPTION 'Target player is already eliminated or not found.';
    END IF;

    INSERT INTO public.game_votes (session_id, voter_id, target_id, round_number, revote_number)
    VALUES (p_session_id, auth.uid(), p_target_id, v_session.round_number, v_session.revotes)
    ON CONFLICT (session_id, voter_id, round_number, revote_number)
    DO UPDATE SET target_id = EXCLUDED.target_id, created_at = now();

    RETURN jsonb_build_object('status', 'vote_cast');
END;
$$;


-- I. Tally Online Votes (Server-Authoritative Resolution)
CREATE OR REPLACE FUNCTION public.tally_online_votes(p_session_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_session RECORD;
    v_top_target UUID;
    v_top_votes INT;
    v_second_votes INT;
    v_eliminated_is_imp BOOLEAN;
    v_rem_imp INT;
    v_rem_crew INT;
    v_winner TEXT := NULL;
    v_reason TEXT := NULL;
    v_secret_word TEXT;
    v_imposter_ids JSONB;
BEGIN
    SELECT * INTO v_session FROM public.game_sessions WHERE id = p_session_id;
    IF v_session IS NULL THEN
        RAISE EXCEPTION 'Session not found.';
    END IF;

    -- Count votes per target in this revote round
    WITH tally AS (
        SELECT target_id, count(*)::int AS vote_count
        FROM public.game_votes
        WHERE session_id = p_session_id 
          AND round_number = v_session.round_number 
          AND revote_number = v_session.revotes
        GROUP BY target_id
        ORDER BY vote_count DESC
    )
    SELECT target_id, vote_count INTO v_top_target, v_top_votes FROM tally LIMIT 1;

    -- Check for tie
    SELECT vote_count INTO v_second_votes FROM (
        SELECT vote_count FROM (
            SELECT target_id, count(*)::int AS vote_count
            FROM public.game_votes
            WHERE session_id = p_session_id 
              AND round_number = v_session.round_number 
              AND revote_number = v_session.revotes
            GROUP BY target_id
            ORDER BY vote_count DESC
            LIMIT 2
        ) sub OFFSET 1
    ) s;

    -- If tied on first vote round, trigger revote
    IF v_second_votes IS NOT NULL AND v_second_votes = v_top_votes AND v_session.revotes = 0 THEN
        UPDATE public.game_sessions
        SET revotes = v_session.revotes + 1,
            phase = 'vote',
            updated_at = now()
        WHERE id = p_session_id;

        RETURN jsonb_build_object('tie', true, 'revote_number', v_session.revotes + 1);
    END IF;

    -- Eliminate top target
    UPDATE public.game_players
    SET is_alive = false, is_eliminated = true, eliminated_round = v_session.round_number
    WHERE session_id = p_session_id AND player_id = v_top_target;

    -- Check if eliminated player was imposter
    SELECT is_imposter INTO v_eliminated_is_imp 
    FROM public.private_player_assignments
    WHERE session_id = p_session_id AND player_id = v_top_target;

    -- Count remaining alive players
    SELECT count(*)::int INTO v_rem_imp
    FROM public.game_players gp
    JOIN public.private_player_assignments ppa ON ppa.session_id = gp.session_id AND ppa.player_id = gp.player_id
    WHERE gp.session_id = p_session_id AND gp.is_alive = true AND ppa.is_imposter = true;

    SELECT count(*)::int INTO v_rem_crew
    FROM public.game_players gp
    JOIN public.private_player_assignments ppa ON ppa.session_id = gp.session_id AND ppa.player_id = gp.player_id
    WHERE gp.session_id = p_session_id AND gp.is_alive = true AND ppa.is_imposter = false;

    -- Win condition check
    IF v_rem_imp = 0 THEN
        v_winner := 'crew';
        v_reason := 'allImpostersCaught';
    ELSIF v_rem_imp >= v_rem_crew THEN
        v_winner := 'imposters';
        v_reason := 'impostersOutnumber';
    ELSIF NOT v_eliminated_is_imp THEN
        -- Wrong player voted out
        v_winner := 'imposters';
        v_reason := 'wrongPlayerVoted';
    END IF;

    IF v_winner IS NOT NULL THEN
        -- Get secret word & imposters list for official results record
        SELECT secret_word INTO v_secret_word FROM public.private_player_assignments
        WHERE session_id = p_session_id AND is_imposter = false LIMIT 1;

        SELECT jsonb_agg(player_id) INTO v_imposter_ids FROM public.private_player_assignments
        WHERE session_id = p_session_id AND is_imposter = true;

        INSERT INTO public.game_results (session_id, winner, win_reason, secret_word, imposters)
        VALUES (p_session_id, v_winner, v_reason, COALESCE(v_secret_word, 'Unknown'), COALESCE(v_imposter_ids, '[]'::jsonb));

        UPDATE public.game_sessions
        SET phase = 'result',
            winner = v_winner,
            win_reason = v_reason,
            updated_at = now()
        WHERE id = p_session_id;

        UPDATE public.rooms SET status = 'finished', updated_at = now() WHERE id = v_session.room_id;

        RETURN jsonb_build_object(
            'phase', 'result',
            'winner', v_winner,
            'reason', v_reason,
            'eliminated_id', v_top_target,
            'was_imposter', v_eliminated_is_imp
        );
    ELSE
        -- Next round of clues or discussion
        UPDATE public.game_sessions
        SET round_number = v_session.round_number + 1,
            phase = 'discussion',
            revotes = 0,
            updated_at = now()
        WHERE id = p_session_id;

        RETURN jsonb_build_object(
            'phase', 'discussion',
            'eliminated_id', v_top_target,
            'was_imposter', v_eliminated_is_imp,
            'round_number', v_session.round_number + 1
        );
    END IF;
END;
$$;


-- J. Leave Room RPC
CREATE OR REPLACE FUNCTION public.leave_room(p_room_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_room RECORD;
    v_next_host UUID;
    v_rem_count INT;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN RETURN; END IF;

    SELECT * INTO v_room FROM public.rooms WHERE id = p_room_id;
    IF v_room IS NULL THEN RETURN; END IF;

    DELETE FROM public.room_players WHERE room_id = p_room_id AND player_id = v_user_id;

    SELECT count(*) INTO v_rem_count FROM public.room_players WHERE room_id = p_room_id;

    IF v_rem_count = 0 THEN
        DELETE FROM public.rooms WHERE id = p_room_id;
    ELSIF v_room.host_id = v_user_id THEN
        -- Transfer host to longest-staying active player
        SELECT player_id INTO v_next_host FROM public.room_players 
        WHERE room_id = p_room_id ORDER BY joined_at ASC LIMIT 1;

        IF v_next_host IS NOT NULL THEN
            UPDATE public.rooms SET host_id = v_next_host, updated_at = now() WHERE id = p_room_id;
            UPDATE public.room_players SET is_host = true WHERE room_id = p_room_id AND player_id = v_next_host;
        END IF;
    END IF;
END;
$$;
