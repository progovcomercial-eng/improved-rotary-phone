-- EXECUTAR SOMENTE DEPOIS de criar a conta da proprietária no Supabase Auth.
-- Substitua o UUID pelo id real da conta Alexandra/proprietária.
-- Nunca coloque service_role ou senha neste arquivo ou no aplicativo.
-- Execute no SQL Editor do projeto Supabase, sob controle da proprietária.

-- SELECT id, email FROM auth.users WHERE email = 'EMAIL_DA_PROPRIETARIA';
-- Depois de conferir o UUID retornado, execute:
-- INSERT INTO public.user_roles (user_id, role)
-- VALUES ('UUID_REAL_DA_PROPRIETARIA', 'owner')
-- ON CONFLICT (user_id, role) DO NOTHING;

REVOKE INSERT, UPDATE, DELETE ON TABLE public.user_roles FROM anon, authenticated;
GRANT SELECT ON TABLE public.user_roles TO authenticated;
REVOKE ALL ON FUNCTION public.has_role(public.app_role[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_role(public.app_role[]) TO authenticated;
