import { isSupabaseConfigured, supabase } from './supabase';

const STAFF_ROLES = ['owner', 'admin', 'manager', 'secretary', 'sales', 'finance'];

export async function signInWithPassword(email, password) {
  if (!isSupabaseConfigured) throw new Error('O sistema de autenticação ainda não foi configurado.');
  const { data, error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
  if (error) throw error;
  const { data: roles, error: roleError } = await supabase.from('user_roles').select('role').eq('user_id', data.user.id);
  if (roleError) { await supabase.auth.signOut(); throw roleError; }
  const allowedRoles = (roles || []).map(({ role }) => role).filter(role => STAFF_ROLES.includes(role));
  if (!allowedRoles.length) { await supabase.auth.signOut(); throw new Error('Esta conta não tem permissão para acessar a administração.'); }
  return { user: data.user, roles: allowedRoles };
}

export async function signOut() {
  if (!supabase) return;
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}

export async function requestPasswordReset(email) {
  if (!isSupabaseConfigured) throw new Error('O sistema de autenticação ainda não foi configurado.');
  const redirectTo = window.location.origin + '/';
  const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), { redirectTo });
  if (error) throw error;
}

export async function getCurrentSession() {
  if (!supabase) return null;
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  return data.session;
}
